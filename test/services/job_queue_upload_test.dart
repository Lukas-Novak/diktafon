import 'dart:io';

import 'package:diktafon/data/db/database.dart';
import 'package:diktafon/data/repositories/cassette_repository.dart';
import 'package:diktafon/data/repositories/memo_repository.dart';
import 'package:diktafon/data/repositories/settings_repository.dart';
import 'package:diktafon/domain/models.dart';
import 'package:diktafon/services/processing/job_queue.dart';
import 'package:diktafon/services/upload/upload_service.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'job_queue_test.dart'
    show FakeSummarizationProvider, FakeTranscriptionProvider, shortTranscript;

class FakeUploadPerformer implements UploadPerformer {
  final List<UploadOutcome> scripted = [];
  final List<(UploadConfig, MemoUpload)> calls = [];
  bool throwOnce = false;

  @override
  Future<UploadOutcome> upload(UploadConfig config, MemoUpload data) async {
    calls.add((config, data));
    if (throwOnce) {
      throwOnce = false;
      throw StateError('unexpected performer explosion');
    }
    if (scripted.isNotEmpty) return scripted.removeAt(0);
    return const UploadSuccess();
  }
}

void main() {
  late AppDatabase db;
  late MemoRepository memos;
  late CassetteRepository cassettes;
  late SettingsRepository settings;
  late FakeTranscriptionProvider engine;
  late FakeSummarizationProvider llm;
  late FakeUploadPerformer uploader;
  late JobQueue queue;
  late Directory tmp;
  bool online = true;
  bool unmetered = true;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    memos = MemoRepository(db);
    cassettes = CassetteRepository(db);
    settings = SettingsRepository(db);
    engine = FakeTranscriptionProvider();
    llm = FakeSummarizationProvider();
    uploader = FakeUploadPerformer();
    online = true;
    unmetered = true;
    // One instance per test — the queue's single-flight guards only cover
    // one instance, exactly like the production provider singleton.
    queue = JobQueue(
      db,
      memos,
      cassettes,
      settings,
      () => engine,
      () => llm,
      retryDelayUnit: Duration.zero,
      uploadPerformer: uploader,
      uploadTokenReader: () async => 'test-token',
      hasConnectivity: () async => online,
      isUnmetered: () async => unmetered,
      appVersionProvider: () async => '1.0.10+test',
      uploadBackoffSchedule: const [Duration(seconds: 30)],
      uploadDeferDelay: Duration.zero,
      autoDrainUploads: false,
    );
    tmp = await Directory.systemTemp.createTemp('job_queue_upload_test');
    await db.into(db.cassettes).insert(CassetteRow(
          id: 'c1',
          titleIsUserSet: false,
          colorSeed: 1,
          createdAt: 0,
          updatedAt: 0,
        ));
  });

  tearDown(() async {
    await db.close();
    await tmp.delete(recursive: true);
  });

  /// Pulls a parked job's availableAt back to now (tests skip wall-clock
  /// backoff this way, keeping the backoff semantics asserted elsewhere).
  Future<void> makeDue(String jobId) async {
    await (db.update(db.jobs)..where((j) => j.id.equals(jobId)))
        .write(const JobsCompanion(availableAt: Value(0)));
  }

  Future<File> seedAudio(String name, [int size = 7]) async {
    final file = File('${tmp.path}/$name');
    await file.writeAsBytes(List.filled(size, 3));
    return file;
  }

  Future<Memo> seedMemo(String id, String fileName) async {
    final memo = Memo(
      id: id,
      cassetteId: 'c1',
      filePath: '${tmp.path}/$fileName',
      durationMs: 4000,
      createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
      status: MemoStatus.stored,
    );
    await memos.insert(memo);
    return memo;
  }

  Future<void> enableUpload() async {
    await settings.setUploadEnabled(true);
    await settings.setUploadUrl('https://example.com/diktafon/upload');
  }

  Future<List<JobRow>> jobs() => db.select(db.jobs).get();
  Future<MemoRow> memoRow(String id) =>
      (db.select(db.memos)..where((m) => m.id.equals(id))).getSingle();

  group('scheduling', () {
    test('a completed transcription schedules the upload in the same '
        'transaction', () async {
      await enableUpload();
      await seedAudio('m1.m4a');
      await seedMemo('m1', 'm1.m4a');

      await queue.enqueueTranscription('m1');
      await queue.drain();

      final uploadJobs = (await jobs())
          .where((j) => j.type == JobType.uploadMemo.name)
          .toList();
      expect(uploadJobs, hasLength(1));
      expect(uploadJobs.single.status, 'queued');
      expect((await memoRow('m1')).uploadStatus, UploadStatus.queued.name);
    });

    test('feature off → no upload touch at all (privacy default)', () async {
      await seedAudio('m1.m4a');
      await seedMemo('m1', 'm1.m4a');

      await queue.enqueueTranscription('m1');
      await queue.drain();

      expect(
          (await jobs()).where((j) => j.type == JobType.uploadMemo.name),
          isEmpty);
      expect((await memoRow('m1')).uploadStatus, isNull);
    });
  });

  group('the lane', () {
    test('uploads happy path: job deleted, memo marked uploaded', () async {
      await enableUpload();
      await seedAudio('m1.m4a');
      final memo = await seedMemo('m1', 'm1.m4a');
      await memos.setTranscript(memo.id, shortTranscript('cs', 'ahoj světe'),
          MemoStatus.ready);
      await queue.retryUpload('m1');
      await queue.drainUploads();

      expect(uploader.calls, hasLength(1));
      final (config, data) = uploader.calls.single;
      expect(config.url, 'https://example.com/diktafon/upload');
      expect(config.token, 'test-token');
      expect(data.memo.id, 'm1');
      expect(data.appVersion, '1.0.10+test');
      expect(data.memo.transcript, isNotNull);
      expect((await jobs()).where((j) => j.type == JobType.uploadMemo.name),
          isEmpty,
          reason: 'completed upload jobs are pruned like every other lane');
      final row = await memoRow('m1');
      expect(row.uploadStatus, UploadStatus.uploaded.name);
      expect(row.uploadedAt, isNotNull);
    });

    test('a WAV waits for its live transcode; uploads the archival AAC once '
        'the transcode completes', () async {
      await enableUpload();
      await seedAudio('m1.wav');
      await seedAudio('m1.m4a');
      await seedMemo('m1', 'm1.wav');
      await memos.setTranscript(
          'm1', shortTranscript('cs', 'ahoj'), MemoStatus.ready);
      await db.into(db.jobs).insert(JobRow(
            availableAt: 0,
            id: 'transcode-m1',
            type: JobType.transcodeAudio.name,
            targetId: 'm1',
            status: 'queued',
            attempts: 0,
            createdAt: 10,
          ));
      await queue.retryUpload('m1');

      await queue.drainUploads();
      expect(uploader.calls, isEmpty,
          reason: 'the archival transcode must finish first');
      var row = await memoRow('m1');
      expect(row.uploadStatus, UploadStatus.queued.name);

      // Transcode completes: filePath swaps to .m4a, its job row is pruned.
      await memos.updateFilePath('m1', '${tmp.path}/m1.m4a');
      await (db.delete(db.jobs)
            ..where((j) => j.id.equals('transcode-m1')))
          .go();
      await queue.drainUploads();

      expect(uploader.calls, hasLength(1));
      expect(uploader.calls.single.$2.memo.filePath, endsWith('.m4a'));
      expect((await memoRow('m1')).uploadStatus, UploadStatus.uploaded.name);
    });

    test('a permanently failed transcode settles as a WAV upload (the WAV '
        'is the final master then)', () async {
      await enableUpload();
      await seedAudio('m1.wav');
      await seedMemo('m1', 'm1.wav');
      await memos.setTranscript(
          'm1', shortTranscript('cs', 'ahoj'), MemoStatus.ready);
      await db.into(db.jobs).insert(JobRow(
            availableAt: 0,
            id: 'transcode-m1',
            type: JobType.transcodeAudio.name,
            targetId: 'm1',
            status: 'failed',
            attempts: 5,
            createdAt: 10,
          ));
      await queue.retryUpload('m1');
      await queue.drainUploads();

      expect(uploader.calls, hasLength(1));
      expect(uploader.calls.single.$2.memo.filePath, endsWith('.wav'));
    });

    test('offline → parked without spending attempts', () async {
      await enableUpload();
      await seedAudio('m1.m4a');
      await seedMemo('m1', 'm1.m4a');
      await memos.setTranscript(
          'm1', shortTranscript('cs', 'ahoj'), MemoStatus.ready);
      await queue.retryUpload('m1');
      online = false;
      await queue.drainUploads();

      expect(uploader.calls, isEmpty);
      final job = (await jobs())
          .singleWhere((j) => j.type == JobType.uploadMemo.name);
      expect(job.attempts, 0, reason: 'offline is a gate, not a failure');
      online = true;
      await queue.drainUploads();
      expect(uploader.calls, hasLength(1));
    });

    test('Wi-Fi-only defers on a metered connection', () async {
      await enableUpload(); // uploadWifiOnly defaults to true
      await seedAudio('m1.m4a');
      await seedMemo('m1', 'm1.m4a');
      await memos.setTranscript(
          'm1', shortTranscript('cs', 'ahoj'), MemoStatus.ready);
      await queue.retryUpload('m1');
      unmetered = false;
      await queue.drainUploads();
      expect(uploader.calls, isEmpty);
      unmetered = true;
      await queue.drainUploads();
      expect(uploader.calls, hasLength(1));
    });

    test('no URL or no token → queued work waits for configuration', () async {
      await settings.setUploadEnabled(true); // URL deliberately missing
      await seedAudio('m1.m4a');
      await seedMemo('m1', 'm1.m4a');
      await memos.setTranscript(
          'm1', shortTranscript('cs', 'ahoj'), MemoStatus.ready);
      await queue.retryUpload('m1');
      await queue.drainUploads();
      expect(uploader.calls, isEmpty);
      expect((await memoRow('m1')).uploadStatus, UploadStatus.queued.name);

      await settings.setUploadUrl('https://example.com/diktafon/upload');
      await queue.drainUploads();
      expect(uploader.calls, hasLength(1));
    });
  });

  group('retry semantics', () {
    Future<void> seedUploadable() async {
      await enableUpload();
      await seedAudio('m1.m4a');
      await seedMemo('m1', 'm1.m4a');
      await memos.setTranscript(
          'm1', shortTranscript('cs', 'ahoj'), MemoStatus.ready);
      await queue.retryUpload('m1');
    }

    test('a retryable failure requeues with backoff and keeps attempts',
        () async {
      await seedUploadable();
      uploader.scripted.add(const UploadRetryable('server error (HTTP 500)'));
      await queue.drainUploads();

      final job = (await jobs())
          .singleWhere((j) => j.type == JobType.uploadMemo.name);
      expect(job.status, 'queued');
      expect(job.attempts, 1);
      expect(job.availableAt, greaterThan(DateTime.now().millisecondsSinceEpoch),
          reason: 'retryable failures park with backoff');
      expect((await memoRow('m1')).uploadStatus, UploadStatus.queued.name);

      await queue.drainUploads();
      expect(uploader.calls, hasLength(1), reason: 'parked rows wait');

      await makeDue(job.id);
      await queue.drainUploads();
      expect(uploader.calls, hasLength(2));
      expect((await memoRow('m1')).uploadStatus, UploadStatus.uploaded.name);
    });

    test('a permanent failure fails the job and the surface; the manual '
        'retry starts clean', () async {
      await seedUploadable();
      uploader.scripted.add(const UploadPermanent('auth rejected (401)'));
      await queue.drainUploads();

      var job = (await jobs())
          .singleWhere((j) => j.type == JobType.uploadMemo.name);
      expect(job.status, 'failed');
      expect((await memoRow('m1')).uploadStatus, UploadStatus.failed.name);

      await queue.retryUpload('m1'); // UI affordance
      job = (await jobs()).singleWhere((j) => j.type == JobType.uploadMemo.name);
      expect(job.status, 'queued');
      expect(job.attempts, 0, reason: 'a manual retry gets a fresh budget');
      await queue.drainUploads();
      expect((await memoRow('m1')).uploadStatus, UploadStatus.uploaded.name);
    });

    test('unexpected performer exception is budgeted like a server error',
        () async {
      await seedUploadable();
      uploader.throwOnce = true;
      await queue.drainUploads();
      var job = (await jobs())
          .singleWhere((j) => j.type == JobType.uploadMemo.name);
      expect(job.status, 'queued');
      expect(job.attempts, 1);

      await makeDue(job.id);
      await queue.drainUploads();
      expect((await memoRow('m1')).uploadStatus, UploadStatus.uploaded.name);
    });

    test('missing audio on disk fails permanently, data untouched', () async {
      await enableUpload();
      await seedMemo('m1', 'gone.m4a'); // no file written
      await memos.setTranscript(
          'm1', shortTranscript('cs', 'ahoj'), MemoStatus.ready);
      await queue.retryUpload('m1');
      await queue.drainUploads();

      expect(uploader.calls, isEmpty);
      expect((await memoRow('m1')).status, MemoStatus.ready.name,
          reason: 'upload failure must not failed-mark the memo itself');
      expect((await memoRow('m1')).uploadStatus, UploadStatus.failed.name);
    });

    test('an orphaned "running" upload re-runs after process death '
        '(deduped server-side, so the re-send is safe)', () async {
      await enableUpload();
      await seedAudio('m1.m4a');
      await seedMemo('m1', 'm1.m4a');
      await memos.setTranscript(
          'm1', shortTranscript('cs', 'ahoj'), MemoStatus.ready);
      await queue.retryUpload('m1');
      // Kill in-flight: row stuck 'running', surface stuck 'uploading'.
      final job = (await jobs())
          .singleWhere((j) => j.type == JobType.uploadMemo.name);
      await (db.update(db.jobs)..where((j) => j.id.equals(job.id)))
          .write(const JobsCompanion(
              status: Value('running'), attempts: Value(3)));
      await memos.setUploadState('m1', UploadStatus.uploading);

      // Fresh queue instance = the process came back up.
      await queue.drainUploads();

      expect(uploader.calls, hasLength(1));
      expect((await memoRow('m1')).uploadStatus, UploadStatus.uploaded.name);
    });
  });

  group('self-healing', () {
    test('a stranded "queued" surface with no job row re-schedules at '
        'launch', () async {
      await enableUpload();
      await seedAudio('m1.m4a');
      await seedMemo('m1', 'm1.m4a');
      await memos.setTranscript(
          'm1', shortTranscript('cs', 'ahoj'), MemoStatus.ready);
      await memos.setUploadState('m1', UploadStatus.queued);
      // No job row — the kill-in-the-scheduling-window case.

      await queue.drainUploads(); // recovery runs first
      expect(uploader.calls, hasLength(1));
      expect((await memoRow('m1')).uploadStatus, UploadStatus.uploaded.name);
    });
  });
}
