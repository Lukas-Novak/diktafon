import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../data/db/database.dart';
import '../../data/repositories/cassette_repository.dart';
import '../../data/repositories/mappers.dart';
import '../../data/repositories/memo_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/models.dart';
import '../providers/llm/summary_prompts.dart' show estimateTokens;
import '../audio/audio_transcoder.dart';
import '../providers/summarization_provider.dart';
import '../providers/transcription_provider.dart';
import '../cloud/cloud_client.dart';
import '../cloud/cloud_job_store.dart';
import '../upload/upload_service.dart';
import 'chinese_script.dart';

/// Cloud-poll schedule: short-start backoff, capped at 15 s (the ingest
/// worker usually answers well ahead of this).
const _cloudPollSchedule = [
  Duration(seconds: 2),
  Duration(seconds: 4),
  Duration(seconds: 8),
  Duration(seconds: 15),
];

/// How far one job attempt may poll before yielding to the queue budget;
/// expiry resumes (not restarts) polling against the durable request row.
const _cloudPollRounds = 90;

/// Cloud-transient failures (offline, timeouts, provider recoveries): the
/// upload-lane schedule parks the attempt with a generous backoff instead of
/// burning the local 5×1s ladder.
class CloudTransient implements Exception {
  const CloudTransient(this.reason);
  final String reason;

  @override
  String toString() => 'CloudTransient: $reason';
}

/// A hard cloud configuration/auth/result rejection: marks the memo failed
/// immediately rather than re-running an error whose retry cannot differ.
class CloudConfiguration implements Exception {
  const CloudConfiguration(this.code);
  final String code;

  @override
  String toString() => 'CloudConfiguration: $code';
}

/// The §6.5 job types. The cassette overview is always rebuilt from *all*
/// memo digests (§6.7 revised 2026-07-08), so `recomputeCassetteSummary` and
/// `updateCassetteSummary` run the same code — it stays, like
/// `cleanupTranscript` (the retired §6.8 LLM cleanup stage, now routed
/// straight to the gist), only so job rows persisted by older builds keep
/// draining.
enum JobType {
  transcribe,
  cleanupTranscript,
  summarizeMemo,
  updateCassetteSummary,
  recomputeCassetteSummary,
  transcodeAudio,
  uploadMemo;

  /// Enrichment stages whose failure marks the memo `failed` (§14).
  /// `transcodeAudio` deliberately stays out: a WAV that never becomes AAC
  /// is bigger, not broken — the memo plays either way, so its status must
  /// never suffer for a codec hiccup.
  bool get targetsMemo =>
      this == transcribe || this == cleanupTranscript || this == summarizeMemo;

  /// Upload-lane rows ride their own drain; `targetsMemo` deliberately
  /// excludes them: upload state lives on Memos.uploadStatus, never on the
  /// memo lifecycle itself.
  bool get isUpload => this == JobType.uploadMemo;
}

/// §6.7 (revised 2026-07-28): only transcripts estimated *longer* than this
/// many tokens get a memo gist — anything shorter is its own summary, so the
/// LLM pass would only restate it (and burn battery). The cassette overview
/// reads the transcript directly for gistless memos. Counted in tokens, not
/// chars: 350 Han chars carry 2–3× the content of 350 Latin chars, so the
/// old 350-char gate was script-biased; 117 ≈ 350/3 keeps Latin behaviour.
const int gistTokenThreshold = 117;

/// Durable background pipeline (§6.5): jobs persist in the DB so they survive
/// restarts; ML concurrency is 1 to bound CPU/thermals/battery.
///
/// Providers are resolved through getters on every use so a Settings tier
/// switch takes effect without rebuilding the queue (rebuilding could let two
/// queues drain the same jobs).
class JobQueue {
  JobQueue(this._db, this._memos, this._cassettes, this._settings,
      this._transcription, this._summarization,
      {this._transcoder,
      this._retryDelayUnit = const Duration(seconds: 1),
      this._systemZhScript = _defaultZhScript,
      this._uploadPerformer,
      this._uploadTokenReader,
      this._hasConnectivity,
      this._isUnmetered,
      this._appVersionProvider,
      this._onUploadScheduled,
      List<Duration>? uploadBackoffSchedule,
      this._uploadDeferDelay = const Duration(seconds: 30),
      this._autoDrainUploads = true,
      CloudClient Function()? cloudClientFactory})
      : _uploadBackoff =
            uploadBackoffSchedule ?? JobQueue._defaultUploadBackoff,
        _cloudClient = cloudClientFactory,
        _cloudStore = CloudJobStore(_db);

  final AppDatabase _db;
  final MemoRepository _memos;
  final CassetteRepository _cassettes;
  final SettingsRepository _settings;
  final TranscriptionProvider Function() _transcription;
  final SummarizationProvider Function() _summarization;

  /// §6.4: encodes finished WAV captures to the archival AAC. Null (tests
  /// that predate it) keeps transcode jobs parked in the queue.
  final AudioTranscoder Function()? _transcoder;

  /// D8 amendment: the script an auto-detected `zh` memo is stored in —
  /// production wires the system locale; tests inject.
  final String Function() _systemZhScript;

  /// Server upload (opt-in). See the upload lane section below.
  final UploadPerformer? _uploadPerformer;
  final Future<String?> Function()? _uploadTokenReader;
  final Future<bool> Function()? _hasConnectivity;
  final Future<bool> Function()? _isUnmetered;
  final Future<String> Function()? _appVersionProvider;
  final void Function()? _onUploadScheduled;
  final List<Duration> _uploadBackoff;
  static const List<Duration> _defaultUploadBackoff = [
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 15),
    Duration(hours: 1),
    Duration(hours: 2),
    Duration(hours: 6),
  ];
  static const _maxUploadAttempts = 10;
  final Duration _uploadDeferDelay;
  Future<void>? _drainingUploads;
  Future<void>? _reconcileFuture;

  /// Cloud transcription (§ cloud): shared multipart client and the durable
  /// per-memo request store. Null client = cloud features fail fast with
  /// [CloudConfiguration] rather than endless local retries.
  final CloudClient Function()? _cloudClient;
  final CloudJobStore _cloudStore;

  static String _defaultZhScript() => 'Hans';

  /// Backoff = attempts × this; tests inject zero.
  final Duration _retryDelayUnit;
  final _uuid = const Uuid();

  /// In-flight cancellation handles, by memo id (§14 delete-during-processing).
  final Map<String, CancelToken> _active = {};

  Future<void>? _draining;
  bool _recoveryComplete = false;
  static const _maxAttempts = 5;

  /// Enqueued on record-stop (D7).
  Future<void> enqueueTranscription(String memoId) async {
    await _insertJob(JobType.transcribe, memoId);
    unawaited(drain());
  }

  /// Enqueued on record-stop, after the transcription (§6.4): the WAV
  /// capture becomes the archival AAC in the background — the memo plays
  /// either form, so nothing waits on this.
  Future<void> enqueueTranscode(String memoId) async {
    await _insertJob(JobType.transcodeAudio, memoId);
    unawaited(drain());
  }

  /// A memo's deferred upload becoming due again should not wait on a wall
  /// clock once the archival file landed (see [_transcodeAudio]'s tail kick):
  /// exposed for the Wi-Fi-only relax path and manual retries where the
  /// memo's row may have been parked by metered/transcode gates.
  Future<void> bumpUploadDue(String memoId) async {
    await (_db.update(_db.jobs)
          ..where((j) =>
              j.targetId.equals(memoId) &
              j.type.equals(JobType.uploadMemo.name) &
              j.status.equals('queued')))
        .write(const JobsCompanion(availableAt: Value(0)));
  }

  /// Failed memo → back on the queue at the right stage (§14 retry
  /// affordance): no transcript yet → transcribe again, otherwise only the
  /// summarization is redone.
  Future<void> retryEnrichment(String memoId) async {
    final row = await _memoRow(memoId);
    if (row == null) return;
    if (row.transcript == null) {
      await _memos.updateStatus(memoId, MemoStatus.stored);
      await _insertJob(JobType.transcribe, memoId);
    } else {
      await _memos.updateStatus(memoId, MemoStatus.transcribed);
      await _insertJob(JobType.summarizeMemo, memoId);
    }
    unawaited(drain());
  }

  /// Explicit user consent to send THIS memo to the configured backend for
  /// cloud transcription (§ cloud): everything after that point is automatic
  /// — upload once, resumable polling, structured transcript back on tape.
  /// Honor is carved per memo: audio is content-immutable, so the consent
  /// never extends to different content.
  Future<void> sendMemoToCloud(String memoId) async {
    final row = await _memoRow(memoId);
    if (row == null) return;
    await _memos.setCloudConsent(
        memoId, DateTime.now().millisecondsSinceEpoch);
    await retryEnrichment(memoId);
  }

  /// Manual transcript edit (§6.9): the corrected text replaces the engine's
  /// take and re-enters the pipeline at the summary stage — the old gist
  /// described the old words, so it is cleared rather than left to lie. Long
  /// transcripts queue a fresh gist (which schedules the overview rebuild
  /// itself); short ones are their own summary (§6.7), so only the overview
  /// needs refreshing. The memo's queued jobs are dropped first — they would
  /// re-derive stale artifacts from the replaced text.
  Future<void> applyTranscriptEdit(String memoId, Transcript transcript) async {
    // Settings fetch fires concurrent with the awaited steps (a fresh
    // serial await inside this method shifts the §6.9 teardown timing).
    final uploadOn = _settings.get().then((s) => s.uploadEnabled);
    final row = await _memoRow(memoId);
    if (row == null) return; // deleted meanwhile (§14)
    await cancelJobsFor(memoId);
    final wantsGist = _wantsGist(transcript);
    // Atomic pair, like retranscribe: a kill between the write and the
    // enqueue must not strand the memo without its follow-up job.
    await _db.transaction(() async {
      await _memos.setEditedTranscript(memoId, transcript,
          wantsGist ? MemoStatus.transcribed : MemoStatus.ready);
      if (wantsGist) {
        await _insertJob(JobType.summarizeMemo, memoId);
      } else {
        await _enqueueCassetteUpdate(row.cassetteId);
      }
    });
    unawaited(drain());
    // The server must see the corrected transcript too (it dedupes by
    // audio, replacing the artifacts). Deliberately fire-and-forget AFTER
    // drain(): awaiting ANY extra database work here shifts this method's
    // completion chain past the §6.9 suite's close-in-teardown timing.
    // The kill window between the transaction and this insert is covered
    // by [_reconcileStrandedUploads] at next launch, the §6.5 way.
    unawaited(uploadOn.then((enabled) async {
      if (!enabled) return;
      try {
        await _enqueueUpload(memoId);
      } catch (_) {
        // Best-effort scheduling inside the edit flow — the upload lane's
        // launch reconcile re-schedules stranded surfaces anyway.
      }
    }));
  }

  /// Re-runs the whole enrichment pipeline for every memo on the cassette —
  /// the user installed a more capable model and wants the texts refreshed.
  /// In-flight and queued work is cancelled, transcripts and gists wiped,
  /// and fresh transcribe jobs queued in tape order. The overview follows
  /// for free: each new gist schedules the coalesced cassette update, and
  /// the old overview stays visible until it's replaced.
  Future<void> retranscribeCassette(String cassetteId) async {
    // A queued overview rebuild would see the wiped gists and blank the
    // summary early — drop it; the new gists schedule their own.
    await cancelJobsFor(cassetteId);
    for (final memo in await _memos.memosOf(cassetteId)) {
      await cancelJobsFor(memo.id);
      // Atomic pair: a kill between the wipe and the enqueue would strand
      // the memo at `stored` with no job and no §14 retry affordance.
      await _db.transaction(() async {
        await _memos.resetEnrichment(memo.id);
        await _insertJob(JobType.transcribe, memo.id);
      });
    }
    unawaited(drain());
  }

  /// Cancels queued *and in-flight* work for a cassette about to be deleted
  /// (§14): every memo's jobs plus the cassette-level summary jobs. Without
  /// this an in-flight transcription keeps burning CPU for minutes after the
  /// delete, then retries its decode against the removed audio file.
  Future<void> cancelCassetteJobs(String cassetteId) async {
    for (final memo in await _memos.memosOf(cassetteId)) {
      await cancelJobsFor(memo.id);
    }
    await cancelJobsFor(cassetteId);
  }

  /// Cancels pending *and in-flight* work for a deleted memo (§14).
  Future<void> cancelJobsFor(String targetId) async {
    _active[targetId]?.cancel();
    await (_db.delete(_db.jobs)
          ..where(
              (j) => j.targetId.equals(targetId) & j.status.equals('queued')))
        .go();
  }

  /// Call after a memo's row is gone: if its gist — or, for gistless memos,
  /// its transcript (§6.7) — was part of the cassette summary, schedule the
  /// rebuild (§14 "cassette summary is scheduled to update").
  Future<void> onMemoDeleted(Memo memo) async {
    final contributed =
        memo.memoSummary != null || !(memo.transcript?.isEmpty ?? true);
    if (!contributed) return;
    await _enqueueCassetteUpdate(memo.cassetteId);
    unawaited(drain());
  }

  /// Processes queued jobs sequentially. Called on app start (resume after
  /// restart), after every enqueue, when a model finishes downloading, and
  /// when summaries are re-enabled. Awaiting joins the drain already in
  /// flight, if any.
  Future<void> drain() => _draining ??=
      _drainLoop().whenComplete(() => _draining = null);

  /// The once-per-process launch recovery both lanes pass before working:
  /// orphan requeue, stranded reconciles, legacy 'done' sweep. Sharing one
  /// future makes the upload lane's transcode gate sound no matter which
  /// lane starts first — the reconciles (re)create rows the gate reads —
  /// while [_recoveryComplete] keeps the post-launch hot path hop-free:
  /// a bare bool check schedules NO microtask (the §6.9 suite's teardown
  /// timing breaks if even one hop is added to the drain's entry chain).
  Future<void> _ensureRecovered() =>
      _reconcileFuture ??= _recoverOnce()
          .whenComplete(() => _recoveryComplete = true);

  Future<void> _recoverOnce() async {
    await _recoverOrphans();
    await _reconcileStrandedMemos();
    await _reconcileStrandedWavs();
    await _reconcileStrandedUploads();
    // Done rows written by pre-pruning builds are pure archaeology —
    // completed jobs are deleted outright now (see _run), so sweep the
    // legacy ones too instead of scanning them on every drain forever.
    await (_db.delete(_db.jobs)..where((j) => j.status.equals('done'))).go();
  }

  Future<void> _drainLoop() async {
    if (!_recoveryComplete) await _ensureRecovered();
    while (true) {
      // Enrichment waits for a provisioned model (§14) — and summarization
      // additionally for the summaries switch (the model picker's "No
      // summaries" row); blocked jobs stay queued. Re-checked every
      // iteration: models/settings can change mid-drain.
      final settings = await _settings.get();
      final llmReady =
          await _summarization().modelStatus() == ModelStatus.ready;
      final runnable = <String>[];
      if (await _transcription().modelStatus() == ModelStatus.ready) {
        runnable.add(JobType.transcribe.name);
      }
      // Legacy cleanup rows only hand over to the gist — no LLM involved,
      // so they are always runnable.
      runnable.add(JobType.cleanupTranscript.name);
      // Transcoding needs no model, only a wired platform encoder.
      if (_transcoder != null) runnable.add(JobType.transcodeAudio.name);
      if (settings.summariesEnabled && llmReady) {
        runnable.addAll([
          JobType.summarizeMemo.name,
          JobType.updateCassetteSummary.name,
          JobType.recomputeCassetteSummary.name,
        ]);
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      var job = await (_db.select(_db.jobs)
            ..where((j) =>
                j.status.equals('queued') &
                j.type.isIn(runnable) &
                // §6.5: a parked requeue parks for real — without this, the
                // upload lane hour-long backoff is ignored and attempts burn.
                j.availableAt.isSmallerOrEqualValue(now))
            ..orderBy([(j) => OrderingTerm.asc(j.createdAt)])
            ..limit(1))
          .getSingleOrNull();
      // Cloud-lane transcribe rows need no on-device model at all — mode
      // "cloud" routes every memo off-device, and a memo's explicit consent
      // routes that one recording too. Without this fallback they awaited a
      // whisper download that may never come.
      try {
        job ??= await _nextCloudTranscribe(now,
            cloudLane: settings.transcriptionMode == 'cloud');
      } on StateError {
        // The drain is fire-and-forget in several flows; a database that
        // closed mid-iteration (app teardown) just means "stop".
        return;
      }
      if (job == null) return;
      await _run(job);
    }
  }

  /// Due queued transcribe rows routed to the cloud (mode "cloud", or a
  /// memo's explicit consent), join against memos for the consent bit.
  Future<JobRow?> _nextCloudTranscribe(int now, {required bool cloudLane}) {
    final query = _db.select(_db.jobs).join([
      innerJoin(_db.memos, _db.memos.id.equalsExp(_db.jobs.targetId)),
    ])
      ..where(_db.jobs.status.equals('queued') &
          _db.jobs.type.equals(JobType.transcribe.name) &
          _db.jobs.availableAt.isSmallerOrEqualValue(now) &
          (cloudLane
              ? const Constant<bool>(true)
              : _db.memos.cloudConsentAt.isNotNull()))
      ..orderBy([OrderingTerm.asc(_db.jobs.createdAt)])
      ..limit(1);
    return query.map((row) => row.readTable(_db.jobs)).getSingleOrNull();
  }

  Future<void> _run(JobRow job) async {
    final type = JobType.values.byName(job.type);
    await _setJob(job.id, 'running', attempts: job.attempts + 1);
    try {
      switch (type) {
        case JobType.transcribe:
          await _transcribe(job.targetId);
        case JobType.cleanupTranscript:
          await _legacyCleanupPassthrough(job.targetId);
        case JobType.summarizeMemo:
          await _summarizeMemo(job.targetId);
        case JobType.updateCassetteSummary:
        case JobType.recomputeCassetteSummary:
          await _updateCassetteSummary(job.targetId);
        case JobType.transcodeAudio:
          await _transcodeAudio(job.targetId);
        case JobType.uploadMemo:
          // Not on this drain's runnable list — uploads run on their own
          // lane; case exists for exhaustiveness only.
          break;
      }
      // Completed jobs are deleted, not archived: nothing reads them back,
      // and years of use would otherwise leave thousands of dead rows under
      // every drain query (the jobs table has no index on status).
      await (_db.delete(_db.jobs)..where((j) => j.id.equals(job.id))).go();
    } on TranscriptionCancelled {
      // Memo deleted while transcribing — the job is moot, not failed.
      await (_db.delete(_db.jobs)..where((j) => j.id.equals(job.id))).go();
    } on CloudConfiguration catch (error) {
      // Hard cloud rejection: configuration/auth/content mismatch — retry
      // cannot change the answer; end with the memo honestly failed once.
      if (type.targetsMemo) {
        await _memos.updateStatus(job.targetId, MemoStatus.failed);
        await _cloudStore.recordFailure(job.targetId, error.code);
      }
      await _setJob(job.id, 'failed', attempts: job.attempts + 1);
    } on CloudTransient catch (error) {
      // Transient cloud failure: park for the upload-lane schedule (minutes
      // to hours) instead of burning the ML ladder on one bad minute.
      final attempts = job.attempts + 1;
      final permanent = attempts >= _maxUploadAttempts;
      await _cloudStore.recordFailure(job.targetId, error.reason);
      if (type.targetsMemo) await _resetToWaiting(job.targetId);
      if (permanent) {
        await _setJob(job.id, 'failed', attempts: attempts);
        if (type.targetsMemo) {
          await _memos.updateStatus(job.targetId, MemoStatus.failed);
        }
      } else {
        final delay =
            _uploadBackoff[(attempts - 1) % _uploadBackoff.length];
        await _setJob(job.id, 'queued', attempts: attempts);
        await (_db.update(_db.jobs)..where((j) => j.id.equals(job.id))).write(
            JobsCompanion(
              availableAt:
                  Value(DateTime.now().add(delay).millisecondsSinceEpoch),
            ));
      }
    } catch (_) {
      final attempts = job.attempts + 1;
      final permanent = attempts >= _maxAttempts;
      await _setJob(job.id, permanent ? 'failed' : 'queued',
          attempts: attempts);
      if (permanent) {
        // Memo stays playable; a retry affordance is offered (§14). Cassette
        // jobs leave no failed memo — their digests stay unfolded and ride
        // along with the next successful update.
        if (type.targetsMemo) {
          await _memos.updateStatus(job.targetId, MemoStatus.failed);
        }
      } else {
        // The requeued job may park behind a closed drain gate (model
        // deleted, tier switched to a not-yet-downloaded one) — reset the
        // memo to its honest waiting status so the "transcribing…" shimmer
        // never outlives the stage that showed it; the rerun re-asserts it.
        if (type.targetsMemo) await _resetToWaiting(job.targetId);
        // Brief backoff so transient failures don't hot-loop (§6.5).
        await Future<void>.delayed(_retryDelayUnit * attempts);
      }
    }
  }

  /// Puts a memo back to the waiting status its enrichment stage starts
  /// from — `stored` before a transcript exists, `transcribed` after.
  Future<void> _resetToWaiting(String memoId) async {
    final row = await _memoRow(memoId);
    if (row == null) return; // deleted meanwhile (§14)
    await _memos.updateStatus(
        memoId,
        row.transcript == null ? MemoStatus.stored : MemoStatus.transcribed);
  }

  /// A job stays 'running' in the DB for the length of its stage — if the
  /// process dies meanwhile (Android freely kills backgrounded apps, and
  /// transcription is minutes of heavy CPU with no foreground service), the
  /// row is orphaned: the drain only picks 'queued', so the job would never
  /// run again and its memo would show "transcribing…" forever. Once per
  /// process, before the first drain, every 'running' row is therefore a
  /// leftover of a dead run (ML concurrency is 1 and this instance hasn't
  /// started anything yet): requeue it and put its memo back to the honest
  /// waiting status — the stage re-asserts the in-flight one when it reruns.
  /// The interrupted run already counted its attempt, so an input that kills
  /// the engine natively exhausts [_maxAttempts] across launches instead of
  /// crash-looping the app forever.
  Future<void> _recoverOrphans() async {
    final orphans = await (_db.select(_db.jobs)
          ..where((j) => j.status.equals('running')))
        .get();
    for (final job in orphans) {
      final type = JobType.values.byName(job.type);
      if (type == JobType.uploadMemo) {
        // A killed in-flight upload is simply retried from the top — the
        // server dedupes by memo id, so the re-send is safe. Its own
        // attempt budget applies.
        if (kDebugMode) debugPrint('[upload-lane] orphan-recover ${job.targetId} (attempts=${job.attempts})');
        await _setJob(
            job.id, job.attempts >= _maxUploadAttempts ? 'failed' : 'queued');
        await _memos.setUploadState(
            job.targetId,
            job.attempts >= _maxUploadAttempts
                ? UploadStatus.failed
                : UploadStatus.queued);
        continue;
      }
      final permanent = job.attempts >= _maxAttempts;
      await _setJob(job.id, permanent ? 'failed' : 'queued');
      if (!type.targetsMemo) continue;
      if (permanent) {
        await _memos.updateStatus(job.targetId, MemoStatus.failed);
      } else {
        await _resetToWaiting(job.targetId);
      }
    }
  }

  /// The other way an enrichment chain breaks (§6.5): a memo stranded in a
  /// waiting/in-flight status with *no* job at all — the process died
  /// between the memo insert and its enqueue (record stop, import), or
  /// between a wipe and its re-enqueue (pre-transaction retranscribe).
  /// Nothing would ever pick it up: it renders as "queued for
  /// transcription" forever and, not being `failed`, offers no retry.
  /// Re-enter the pipeline at the right stage, like [retryEnrichment].
  Future<void> _reconcileStrandedMemos() async {
    final live = await (_db.select(_db.jobs)
          ..where((j) => j.status.isIn(['queued', 'running'])))
        .get();
    final covered = {for (final job in live) job.targetId};
    final rows = await (_db.select(_db.memos)
          ..where((m) => m.status.isIn([
                MemoStatus.stored.name,
                MemoStatus.transcribing.name,
                MemoStatus.transcribed.name,
                MemoStatus.summarizing.name,
              ])))
        .get();
    for (final row in rows) {
      if (covered.contains(row.id)) continue;
      if (row.transcript == null) {
        await _memos.updateStatus(row.id, MemoStatus.stored);
        await _insertJob(JobType.transcribe, row.id);
      } else {
        await _memos.updateStatus(row.id, MemoStatus.transcribed);
        await _insertJob(JobType.summarizeMemo, row.id);
      }
    }
  }

  /// A memo still on its WAV capture with no transcode row anywhere — the
  /// process died between the memo insert and the enqueue, or the row was
  /// recovered by an older build. One fresh job puts it back on track;
  /// `failed` rows count as covered so a permanently hopeless encode doesn't
  /// re-enter on every launch (the WAV plays fine as it is).
  Future<void> _reconcileStrandedWavs() async {
    if (_transcoder == null) return;
    final covered = {
      for (final job in await (_db.select(_db.jobs)
            ..where((j) => j.type.equals(JobType.transcodeAudio.name)))
          .get())
        job.targetId,
    };
    final rows = await (_db.select(_db.memos)
          ..where((m) => m.filePath.like('%.wav')))
        .get();
    for (final row in rows) {
      if (covered.contains(row.id)) continue;
      await _insertJob(JobType.transcodeAudio, row.id);
    }
  }

  /// Upload-lane counterpart of [_reconcileStrandedMemos]: a memo whose
  /// surface says queued/uploading but whose job row is GONE — killed in a
  /// scheduling window (stop/recovery's two write steps, transcript-edit's
  /// cancel-then-reschedule) — would otherwise say "waiting" forever with
  /// nothing riding the lane. Re-scheduled coalesced; only when enabled.
  Future<void> _reconcileStrandedUploads() async {
    if (!(await _settings.get()).uploadEnabled) return;
    final live = await (_db.select(_db.jobs)
          ..where((j) =>
              j.type.equals(JobType.uploadMemo.name) &
              j.status.isIn(['queued', 'running'])))
        .get();
    final covered = {for (final job in live) job.targetId};
    final stranded = await (_db.select(_db.memos)
          ..where((m) => m.uploadStatus
              .isIn([UploadStatus.queued.name, UploadStatus.uploading.name])))
        .get();
    for (final row in stranded) {
      if (covered.contains(row.id)) continue;
      if (row.transcript == null) {
        await (_db.update(_db.memos)..where((m) => m.id.equals(row.id)))
            .write(const MemosCompanion(uploadStatus: Value(null)));
        continue;
      }
      await _tryScheduleUpload(row.id);
    }
  }

  /// §6.4: WAV capture → archival AAC, then the memo row is swapped over
  /// and the WAV deleted. Idempotent and self-cancelling: a memo already on
  /// AAC, gone, or missing its audio simply completes the job.
  Future<void> _transcodeAudio(String memoId) async {
    final row = await _memoRow(memoId);
    if (row == null) return; // deleted meanwhile (§14)
    final wavPath = row.filePath;
    if (!wavPath.endsWith('.wav')) return; // already archival
    if (!File(wavPath).existsSync()) return; // missing audio (§14)

    final outPath = '${wavPath.substring(0, wavPath.length - 4)}.m4a';
    await _transcoder!().transcode(wavPath, outPath);
    final out = File(outPath);
    if (!out.existsSync() || out.lengthSync() == 0) {
      throw StateError('transcode produced no output');
    }
    if (await _memoRow(memoId) == null) {
      // Deleted mid-encode — drop the output; the WAV went with the memo.
      try {
        out.deleteSync();
      } catch (_) {}
      return;
    }
    await _memos.updateFilePath(memoId, outPath);
    try {
      File(wavPath).deleteSync();
    } catch (_) {
      // A busy/vanished WAV is orphan-sweep food, not a failure.
    }
    // The upload lane defers on a live transcode row (it wants the archival
    // AAC). That row parks by clock as a fallback — the *event* just landed:
    // un-park it so the kick below doesn't find a not-yet-due row, then
    // kick unconditionally (the coalesce returns early on live rows and
    // would skip it).
    final tcSettings = await _settings.get();
    if (tcSettings.uploadEnabled && tcSettings.transcriptionMode != 'cloud') {
      await (_db.update(_db.jobs)
            ..where((j) =>
                j.targetId.equals(memoId) &
                j.type.equals(JobType.uploadMemo.name) &
                j.status.equals('queued')))
          .write(const JobsCompanion(availableAt: Value(0)));
      await _enqueueUpload(memoId);
      _afterUploadScheduled();
    }
  }

  Future<Transcript> _transcribeCloud(
      MemoRow row, AppSettings settings, CancelToken cancel) async {
    final memoId = row.id;
    final url = settings.uploadUrl;
    final token = await _uploadTokenReader?.call();
    if (url == null || url.isEmpty || token == null || token.isEmpty) {
      throw const CloudConfiguration('config');
    }
    if (_cloudClient == null) {
      throw const CloudConfiguration('wiring');
    }

    final client = _cloudClient();
    final config = CloudConfig(url: url, token: token);

    final audioFile = File(row.filePath);
    if (!await audioFile.exists()) {
      throw const TranscriptionCancelled();
    }
    final audioSha = await CloudClient.sha256OfFile(audioFile);

    // § cloud "upload once": a durable row for this exact audio resumes —
    // pending rows keep their request_id (the re-POST replays through the
    // server's idempotency), accepted rows skip the upload entirely and go
    // straight to polling. Only a changed recording supersedes (revision+1
    // via a fresh id below).
    final existing = await _cloudStore.current(memoId);
    final sameAudio = existing != null && existing.audioSha256 == audioSha;
    final alreadyAccepted = sameAudio &&
        (existing.state == CloudJobStore.uploadedState ||
            existing.state == CloudJobStore.completeState);
    var rowStoreId = sameAudio ? existing.requestId : _uuid.v4();

    var accepted = alreadyAccepted;
    if (!alreadyAccepted) await _cloudStore.markUploading(memoId);
    while (!accepted) {
      final flow = await _cloudStore.ensure(
          memoId: memoId, requestId: rowStoreId, audioSha256: audioSha);
      final outcome = await client.submitTranscriptionJob(
        config: config,
        memoId: memoId,
        requestId: flow.requestId,
        clientRevision: flow.clientRevision,
        audioPath: row.filePath,
        metadataLanguage: settings.appLanguage ?? '',
        durationMs: row.durationMs,
      );
      switch (outcome) {
        case CloudAccepted():
          accepted = true;
        case CloudRetryableError(:final reason):
          await _cloudStore.recordFailure(memoId, reason);
          throw CloudTransient(reason);
        case CloudPermanentError(:final code):
          if (code == 'conflict') {
            rowStoreId = _uuid.v4(); // fresh revision; one more cycle
            continue;
          }
          throw CloudConfiguration(code);
        default:
          await _cloudStore.recordFailure(memoId, 'unexpected_outcome');
          throw CloudTransient('unexpected_outcome');
      }
    }
    if (!alreadyAccepted) await _cloudStore.markUploaded(memoId);

    for (var step = 0; step < _cloudPollRounds; step++) {
      if (cancel.isCancelled) {
        await client.cancelJob(config, (await _cloudStore.current(memoId))!.requestId);
        throw const TranscriptionCancelled();
      }
      await Future<void>.delayed(
          _cloudPollSchedule[step < _cloudPollSchedule.length
              ? step
              : _cloudPollSchedule.length - 1]);
      final statusOutcome = await client.jobStatus(
          config, (await _cloudStore.current(memoId))!.requestId);
      switch (statusOutcome) {
        case CloudStatus(:final state, :final errorCode):
          if (state == 'complete') {
            final rd = (await _cloudStore.current(memoId))!;
            final loaded = await client.jobResult(config, rd.requestId);
            if (loaded is CloudResultLoaded) {
              return _acceptCloudResult(row, loaded.payload, audioSha,
                  markComplete: (precision) =>
                      _cloudStore.markImported(memoId, timingPrecision: precision));
            }
            if (loaded is CloudRetryableError) {
              throw CloudTransient(loaded.reason);
            }
            throw CloudTransient('result_read');
          }
          if (state == 'failed' || state == 'cancelled') {
            if (errorCode == 'auth') {
              throw const CloudConfiguration('auth');
            }
            // Retry server-side ONCE per attempt, giving the provider time
            // to recover first; we only then bill the durable budget.
            await client.retryJob(
                config, (await _cloudStore.current(memoId))!.requestId);
            throw CloudTransient('server_job_$errorCode');
          }
        case CloudResultNotReady():
          throw CloudTransient('polling');
        case CloudRetryableError(:final reason):
          throw CloudTransient(reason);
        case CloudPermanentError(:final code):
          if (code == 'not_found') {
            await _cloudStore.markPending(memoId);
            throw CloudTransient('remote_lost');
          }
          throw CloudConfiguration(code);
        default:
          throw CloudTransient('status_unhandled');
      }
    }
    throw CloudTransient('poll_timeout');
  }

  Future<Transcript> _acceptCloudResult(
      MemoRow row,
      Map<String, dynamic> payload,
      String audioSha,
      {required Future<void> Function(String? precision) markComplete}) async {
    final memoId = row.id;
    if (payload['memo_id'] != memoId || payload['audio_sha256'] != audioSha) {
      throw CloudConfiguration('result_mismatch');
    }
    final transcriptJson = payload['transcript'];
    final transcript = transcriptJson is Map
        ? Transcript.fromJson((transcriptJson).cast<String, dynamic>())
        : null;
    if (transcript == null) {
      throw CloudConfiguration('result_invalid');
    }
    final provenance = payload['provenance'];
    final precision = provenance is Map
        ? provenance['timing_precision'] as String?
        : null;
    await _memos.setUploadState(memoId, UploadStatus.uploaded,
        uploadedAt: DateTime.now());
    await markComplete(precision);
    return transcript;
  }

  Future<void> _transcribe(String memoId) async {
    final row = await _memoRow(memoId);
    if (row == null) return; // deleted meanwhile (§14)

    final cancel = CancelToken();
    _active[memoId] = cancel;
    try {
      await _memos.updateStatus(memoId, MemoStatus.transcribing);
      final settings = await _settings.get();
      final cloudRun = settings.transcriptionMode == 'cloud' ||
          row.cloudConsentAt != null;
      final raw = cloudRun
          ? await _transcribeCloud(row, settings, cancel)
          : await _transcription().transcribe(
              AudioRef(row.filePath),
              languageCode: settings.appLanguage,
              cancel: cancel,
            );
      // D8 amendment: Chinese transcripts are stored script-converted under
      // a script-qualified code (forced zh-Hans/zh-Hant, or the system
      // locale's script for an auto-detected zh); everything else is
      // untouched.
      final transcript = resolveChineseScript(
        raw,
        appLanguage: settings.appLanguage,
        systemZhScript: _systemZhScript,
      );

      // Server upload (opt-in): scheduled in the same transaction as the
      // transcript write — a kill between them must not strand a finished
      // memo with an unschedulable upload. The lane itself additionally
      // waits for the archival transcode before touching the network.
      // Cloud runs never round-trip through the archive: the backend already
      // holds the master and emitted the notification when it verified.
      final uploadOn = settings.uploadEnabled && !cloudRun;

      if (transcript.isEmpty) {
        // Empty/near-silent memo: kept playable, summary skipped (§14, §6.7)
        // — nothing left to enrich.
        await _db.transaction(() async {
          await _memos.setTranscript(memoId, transcript, MemoStatus.ready);
          if (uploadOn) await _tryScheduleUpload(memoId);
        });
      } else if (!_wantsGist(transcript)) {
        // Short transcript (§6.7): it is its own summary — the memo is done
        // without ever touching the LLM; only the overview job (which reads
        // the transcript directly) waits on the summarization gate.
        await _db.transaction(() async {
          await _memos.setTranscript(memoId, transcript, MemoStatus.ready);
          if (uploadOn) await _tryScheduleUpload(memoId);
        });
        await _enqueueCassetteUpdate(row.cassetteId);
      } else {
        await _db.transaction(() async {
          await _memos.setTranscript(memoId, transcript, MemoStatus.transcribed);
          if (uploadOn) await _tryScheduleUpload(memoId);
          // The gist job waits in the queue while its model is missing or
          // summaries are disabled — the drain gate holds it, never the memo.
          await _insertJob(JobType.summarizeMemo, memoId);
        });
      }
      if (uploadOn) _afterUploadScheduled();
    } finally {
      _active.remove(memoId);
    }
  }

  /// A cleanup row persisted by a pre-removal build (§6.8, retired
  /// 2026-07-13: the phase-0 bench showed LLM cleanup is accuracy-inert at
  /// ~1.2× the ASR's runtime): hand the memo to the gist stage unchanged.
  Future<void> _legacyCleanupPassthrough(String memoId) async {
    final row = await _memoRow(memoId);
    if (row == null || row.transcript == null) return;
    await _insertJob(JobType.summarizeMemo, memoId);
  }

  Future<void> _summarizeMemo(String memoId) async {
    final row = await _memoRow(memoId);
    if (row == null) return; // deleted meanwhile (§14)
    final transcriptJson = row.transcript;
    if (transcriptJson == null) return; // can't happen; be safe

    final transcript = Transcript.fromJson(
        (jsonDecode(transcriptJson) as Map).cast<String, dynamic>());
    if (transcript.isEmpty) {
      // Nothing to summarize (§6.7) — reachable via retryEnrichment on a
      // silent memo; complete the enrichment instead of prompting the LLM.
      await _memos.setMemoSummary(memoId, null, MemoStatus.ready);
      return;
    }
    if (!_wantsGist(transcript)) {
      // Short transcript (§6.7) — reachable via retryEnrichment or a job
      // persisted by an older build: complete without the LLM; the overview
      // reads the transcript directly.
      await _memos.setMemoSummary(memoId, null, MemoStatus.ready);
      await _enqueueCassetteUpdate(row.cassetteId);
      return;
    }
    await _memos.updateStatus(memoId, MemoStatus.summarizing);

    final language = await _languageFor(row.detectedLang);
    // matchChineseScript is belt-and-braces (D8): the prompt pins
    // Simplified/Traditional, but small models drift.
    final summary = matchChineseScript(
        (await _summarization()
                .summarizeMemo(transcript, languageCode: language))
            .trim(),
        language);

    // An empty gist (model produced nothing usable) is recorded as "no
    // summary", not a failure — the memo is still fully enriched (§6.7).
    // The overview updates either way: gistless memos contribute their
    // transcript.
    await _memos.setMemoSummary(
        memoId, summary.isEmpty ? null : summary, MemoStatus.ready);
    await _enqueueCassetteUpdate(row.cassetteId);
  }

  /// §6.7: short transcripts are their own summary — no gist.
  bool _wantsGist(Transcript t) =>
      estimateTokens(t.plainText) > gistTokenThreshold;

  /// Rebuilds the overview from *all* memo digests, in tape order (§6.7
  /// revised): the gist where one exists, the (short) transcript itself
  /// where none does. Always faithful to the tape's current content —
  /// additions and deletions alike — at the cost of re-reading every
  /// digest (bounded by the prompt's char budget).
  Future<void> _updateCassetteSummary(String cassetteId) async {
    final cassette = await (_db.select(_db.cassettes)
          ..where((c) => c.id.equals(cassetteId)))
        .getSingleOrNull();
    if (cassette == null) return; // deleted meanwhile (§14)

    final rows = await (_db.select(_db.memos)
          ..where((m) =>
              m.cassetteId.equals(cassetteId) &
              (m.memoSummary.isNotNull() | m.transcript.isNotNull()))
          ..orderBy([
            (m) => OrderingTerm.asc(m.createdAt),
            (m) => OrderingTerm.asc(m.id),
          ]))
        .get();
    final contributing = <(MemoRow, String)>[
      for (final row in rows)
        if (row.memoSummary ?? _transcriptText(row.transcript)
            case final text?)
          (row, text), // silent memos yield null and drop out
    ];
    if (contributing.isEmpty) {
      // The last contributing memo was deleted — the overview no longer
      // describes anything; the (possibly user-set) label stays.
      await _cassettes.setSummary(cassetteId, null);
      return;
    }

    final language = await _languageFor(contributing.first.$1.detectedLang);
    final summary = matchChineseScript(
        (await _summarization().updateCassetteSummary(
          previousSummary: null,
          newMemos: [
            for (final (row, text) in contributing)
              MemoDigest(
                memoSummary: text,
                createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
              ),
          ],
          languageCode: language,
        ))
            .trim(),
        language);
    if (summary.isEmpty) return;

    await _cassettes.setSummary(cassetteId, summary);

    // D10 (revised): a title is suggested only while the label is blank —
    // effectively once, with the first overview; after that the name stays
    // put until the user renames.
    if (cassette.label == null && !cassette.titleIsUserSet) {
      final title = matchChineseScript(
          (await _summarization()
                  .suggestTitle(summary, languageCode: language))
              .trim(),
          language);
      if (title.isNotEmpty) {
        await _cassettes.setSuggestedLabel(cassetteId, title);
      }
    }
  }

  /// The digest text of a gistless memo (§6.7): its short transcript,
  /// flattened to one line; null when the memo is silent.
  String? _transcriptText(String? transcriptJson) {
    if (transcriptJson == null) return null;
    final transcript = Transcript.fromJson(
        (jsonDecode(transcriptJson) as Map).cast<String, dynamic>());
    if (transcript.isEmpty) return null;
    return transcript.plainText.replaceAll('\n', ' ');
  }

  /// D8: languages are per memo — an explicit Settings override wins (for
  /// speakers whisper keeps mis-detecting), otherwise the memo's own
  /// detection; 'en' only as the last resort.
  Future<String> _languageFor(String? detectedLang) async =>
      (await _settings.get()).appLanguage ?? detectedLang ?? 'en';

  /// Coalescing (§6.5 debounce): the rebuild reads the tape's state at run
  /// time, so one queued cassette job covers every gist (or deletion) that
  /// lands before it runs — bursts collapse into a single update.
  Future<void> _enqueueCassetteUpdate(String cassetteId) async {
    final queued = await (_db.select(_db.jobs)
          ..where((j) =>
              j.targetId.equals(cassetteId) &
              j.status.equals('queued') &
              j.type.isIn([
                JobType.updateCassetteSummary.name,
                JobType.recomputeCassetteSummary.name,
              ])))
        .get();
    if (queued.isNotEmpty) return;
    await _insertJob(JobType.updateCassetteSummary, cassetteId);
  }

  Future<MemoRow?> _memoRow(String memoId) =>
      (_db.select(_db.memos)..where((m) => m.id.equals(memoId)))
          .getSingleOrNull();

  Future<void> _insertJob(JobType type, String targetId) =>
      _db.into(_db.jobs).insert(JobRow(
            id: _uuid.v4(),
            type: type.name,
            targetId: targetId,
            status: 'queued',
            attempts: 0,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            availableAt: 0,
            leaseUntil: 0,
          ));

  Future<void> _setJob(String id, String status, {int? attempts}) =>
      (_db.update(_db.jobs)..where((j) => j.id.equals(id))).write(JobsCompanion(
        status: Value(status),
        attempts: attempts == null ? const Value.absent() : Value(attempts),
      ));

  // --------------------------------------------------------- server upload
  //
  // The upload lane (§ upload, opt-in). Same durability rules as the ML
  // drain — rows persist across process death — but it runs on its OWN
  // single-flight loop so a slow multipart never throttles transcription
  // behind it, and reads its configuration per attempt (URL/token may
  // change while rows are queued).

  /// Coalesced scheduling used by every trigger point: a live row already
  /// covers the memo; a 'failed' row is swept (fresh trigger, fresh
  /// conditions). Callers must check settings.uploadEnabled first.
  Future<bool> _tryScheduleUpload(String memoId) async {
    final live = await (_db.select(_db.jobs)
          ..where((j) =>
              j.targetId.equals(memoId) &
              j.type.equals(JobType.uploadMemo.name) &
              j.status.isIn(['queued', 'running'])))
        .get();
    if (live.isNotEmpty) {
      if (kDebugMode) debugPrint('[upload-lane] schedule $memoId: live row exists (${live.single.status})');
      return false;
    }
    await (_db.delete(_db.jobs)
          ..where((j) =>
              j.targetId.equals(memoId) &
              j.type.equals(JobType.uploadMemo.name) &
              j.status.equals('failed')))
        .go();
    await _memos.setUploadState(memoId, UploadStatus.queued);
    await _insertJob(JobType.uploadMemo, memoId);
    if (kDebugMode) debugPrint('[upload-lane] scheduled $memoId');
    return true;
  }

  Future<void> _enqueueUpload(String memoId) async {
    if (!(await _settings.get()).uploadEnabled) return;
    if (await _tryScheduleUpload(memoId)) _afterUploadScheduled();
  }

  /// Manual retry ("Upload failed — retry"). Also the re-entry point when
  /// the user fixes the URL/token after a permanent failure. Always *now*
  /// for a manual tap: any backoff-parked due time is cleared first.
  Future<void> retryUpload(String memoId) async {
    if (!(await _settings.get()).uploadEnabled) return;
    await bumpUploadDue(memoId);
    if (await _tryScheduleUpload(memoId)) {
      _afterUploadScheduled(); // newly scheduled: wake WorkManager too
    } else {
      unawaited(drainUploads()); // live row exists (now due): kick the lane
    }
  }

  /// Whether scheduling fires the lane immediately (production) or waits
  /// for explicit [drainUploads] calls (tests priming scripted outcomes —
  /// like [_retryDelayUnit], an honest wiring seam, not behavior).
  final bool _autoDrainUploads;

  void _afterUploadScheduled() {
    _onUploadScheduled?.call(); // wakes WorkManager in production
    if (_autoDrainUploads) unawaited(drainUploads());
  }

  /// The upload lane's own single-flight drain: uploads must never stall
  /// the ML drain behind a big multipart body.
  Future<void> drainUploads() => _drainingUploads ??=
      _drainUploadLoop().whenComplete(() => _drainingUploads = null);

  Future<void> _drainUploadLoop() async {
    if (!_recoveryComplete) await _ensureRecovered();
    if (_uploadPerformer == null) return;
    if (kDebugMode) debugPrint('[upload-lane] drain start');
    while (true) {
      final settings = await _settings.get();
      if (!settings.uploadEnabled) {
        if (kDebugMode) debugPrint('[upload-lane] gate: disabled');
        return;
      }
      final url = settings.uploadUrl;
      if (url == null || url.isEmpty) {
        if (kDebugMode) debugPrint('[upload-lane] gate: url missing');
        return;
      }
      final token = await _uploadTokenReader?.call();
      if (token == null || token.isEmpty) {
        if (kDebugMode) debugPrint('[upload-lane] gate: token missing');
        return;
      }
      bool online;
      bool unmetered;
      try {
        online = _hasConnectivity == null || await _hasConnectivity();
        unmetered = _isUnmetered == null || await _isUnmetered();
      } catch (e) {
        // Connectivity probing broke (platform quirks, e.g. VPN-shaped
        // transports): rather than wedge the lane silently, TRY the
        // upload — the outcome classifier retries real outages sanely.
        if (kDebugMode) debugPrint('[upload-lane] connectivity probe failed ($e) — trying anyway');
        online = true;
        unmetered = true;
      }
      if (!online) {
        if (kDebugMode) debugPrint('[upload-lane] gate: offline');
        return;
      }
      if (settings.uploadWifiOnly && !unmetered) {
        if (kDebugMode) debugPrint('[upload-lane] gate: wifi-only, metered');
        return;
      }
      final config = UploadConfig(url: url, token: token);
      final now = DateTime.now().millisecondsSinceEpoch;
      final job = await (_db.select(_db.jobs)
            ..where((j) =>
                j.status.equals('queued') &
                j.type.equals(JobType.uploadMemo.name) &
                j.availableAt.isSmallerOrEqualValue(now))
            ..orderBy([(j) => OrderingTerm.asc(j.createdAt)])
            ..limit(1))
          .getSingleOrNull();
      if (job == null) {
        if (kDebugMode) debugPrint('[upload-lane] clean: no due row');
        return;
      }
      // A deferred job parks with a future availableAt — nothing else in
      // this lane can usefully run right now (FIFO: older rows first), so
      // the lane exits and waits for the next kick.
      if (!await _runUpload(job, config)) return;
    }
  }

  /// One upload row. Returns false when the lane should stop (the row was
  /// parked — its availableAt moved into the future).
  Future<bool> _runUpload(JobRow job, UploadConfig config) async {
    final memoId = job.targetId;
    final row = await _memoRow(memoId);
    if (row == null) {
      // Deleted meanwhile (§14) — the job is moot, not failed.
      await _deleteJobRow(job.id);
      return true;
    }
    if (row.transcript == null) {
      // Wiped for a re-transcribe race; the fresh transcription schedules
      // the upload again. Convergent, so this row may close quietly.
      await _deleteJobRow(job.id);
      return true;
    }
    if (!File(row.filePath).existsSync()) {
      // The master is gone — no retry will ever conjure it.
      await _failUpload(job, row, attempts: job.attempts + 1);
      return true;
    }
    if (!row.filePath.endsWith('.m4a') && await _hasLiveTranscode(memoId)) {
      // Transcode in flight — upload the archival AAC once it lands: park
      // without consuming an attempt (its completion re-kicks the lane).
      if (kDebugMode) debugPrint('[upload-lane] $memoId deferred: transcode in flight (${row.filePath})');
      await (_db.update(_db.jobs)..where((j) => j.id.equals(job.id)))
          .write(JobsCompanion(
              availableAt: Value(DateTime.now()
                  .add(_uploadDeferDelay)
                  .millisecondsSinceEpoch)));
      return false; // FIFO: older rows first — exit the lane
    }

    await _setJob(job.id, 'running', attempts: job.attempts + 1);
    await _memos.setUploadState(memoId, UploadStatus.uploading);
    if (kDebugMode) debugPrint('[upload-lane] attempt ${job.attempts + 1} for $memoId');
    try {
      final outcome = await _uploadPerformer!.upload(
        config,
        MemoUpload(
          memo: memoFromRow(row),
          cassetteLabel: await _cassetteLabel(row.cassetteId),
          appVersion: await _appVersion(),
        ),
      );
      switch (outcome) {
        case UploadSuccess():
          if (kDebugMode) debugPrint('[upload-lane] success: $memoId uploaded');
          await _deleteJobRow(job.id);
          await _memos.setUploadState(memoId, UploadStatus.uploaded,
              uploadedAt: DateTime.now());
        case UploadRetryable(:final reason, :final retryAfter):
          if (kDebugMode) debugPrint('[upload-lane] retryable: $memoId ($reason)');
          await _retryUploadLater(job, row, retryAfter);
        case UploadPermanent(:final reason):
          if (kDebugMode) debugPrint('[upload-lane] permanent: $memoId ($reason)');
          await _failUpload(job, row, attempts: job.attempts + 1);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[upload-lane] error: $memoId — $e');
      // Unexpected performer failure gets the same budgeted treatment as a
      // server error — never silently dropped, never hot-looped.
      await _retryUploadLater(job, row, null);
    }
    return true;
  }

  Future<void> _retryUploadLater(
      JobRow job, MemoRow row, Duration? retryAfter) async {
    final attempts = job.attempts + 1;
    if (attempts >= _maxUploadAttempts) {
      if (kDebugMode) debugPrint('[upload-lane] ${job.targetId} failed: budget exhausted');
      await _failUpload(job, row, attempts: attempts);
      return;
    }
    final delay =
        retryAfter ?? _uploadBackoff[(attempts - 1) % _uploadBackoff.length];
    if (kDebugMode) debugPrint('[upload-lane] ${job.targetId} requeued (attempt $attempts, +${delay.inSeconds}s)');
    await _setJob(job.id, 'queued', attempts: attempts);
    await (_db.update(_db.jobs)..where((j) => j.id.equals(job.id))).write(
        JobsCompanion(
            availableAt:
                Value(DateTime.now().add(delay).millisecondsSinceEpoch)));
    await _memos.setUploadState(job.targetId, UploadStatus.queued);
  }

  Future<void> _failUpload(JobRow job, MemoRow row,
      {required int attempts}) async {
    await _setJob(job.id, 'failed', attempts: attempts);
    await _memos.setUploadState(row.id, UploadStatus.failed);
  }

  /// True while any transcodeAudio row for this memo is queued or running —
  /// a settled transcode leaves either an .m4a filePath, a 'failed' row, or
  /// no row at all. The lane and the ML drain share one isolate and one
  /// first-run recovery, so this is read only at quiescent points.
  Future<bool> _hasLiveTranscode(String memoId) async {
    final rows = await (_db.select(_db.jobs)
          ..where((j) =>
              j.targetId.equals(memoId) &
              j.type.equals(JobType.transcodeAudio.name) &
              j.status.isIn(['queued', 'running'])))
        .get();
    return rows.isNotEmpty;
  }

  Future<void> _deleteJobRow(String id) =>
      (_db.delete(_db.jobs)..where((j) => j.id.equals(id))).go();

  Future<String?> _cassetteLabel(String cassetteId) async =>
      (await (_db.select(_db.cassettes)
                ..where((c) => c.id.equals(cassetteId)))
              .getSingleOrNull())
          ?.label;

  Future<String> _appVersion() async {
    try {
      return await _appVersionProvider?.call() ?? '';
    } catch (_) {
      return '';
    }
  }

}
