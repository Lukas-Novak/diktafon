import 'dart:convert';
import 'dart:io';

import 'package:diktafon/data/db/database.dart';
import 'package:diktafon/data/repositories/cassette_repository.dart';
import 'package:diktafon/data/repositories/memo_repository.dart';
import 'package:diktafon/data/repositories/settings_repository.dart';
import 'package:diktafon/domain/models.dart';
import 'package:diktafon/services/cloud/cloud_client.dart';
import 'package:diktafon/services/processing/job_queue.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'job_queue_test.dart'
    show FakeSummarizationProvider, FakeTranscriptionProvider;
import 'job_queue_upload_test.dart' show FakeUploadPerformer;

/// Scripted cloud seam: drives the JobQueue's cloud lane without any HTTP.
class FakeCloudClient extends CloudClient {
  final Map<String, List<String>> requests = {};
  final List<String> uploads = [];
  final List<String> log = [];
  Object? uploadError;
  List<CloudOutcome> statusScript = [];
  Object? resultError;
  Map<String, dynamic> statusPayload = const {
    'state': 'queued',
    'error_code': null,
    'attempts': 1,
    'client_revision': 1,
  };
  Map<String, dynamic> resultPayload = const {};

  int submits = 0;

  @override
  Future<CloudOutcome> submitTranscriptionJob({
    required CloudConfig config,
    required String memoId,
    required String requestId,
    required int clientRevision,
    required String audioPath,
    required String metadataLanguage,
    required int durationMs,
  }) async {
    submits++;
    log.add('submit $submits memo=$memoId req=${requestId.substring(0, 8)} rev=$clientRevision');
    if (uploadError != null) {
      final error = uploadError!;
      uploadError = null;
      return error as CloudOutcome;
    }
    uploads.add('$memoId:$requestId:$clientRevision');
    return CloudAccepted(
        requestId: requestId, state: 'queued', duplicate: false);
  }

  @override
  Future<CloudOutcome> jobStatus(CloudConfig config, String requestId) async {
    final out = statusScript.isNotEmpty
        ? statusScript.removeAt(0)
        : CloudStatus(
            state: 'complete',
            errorCode: null,
            attempts: 1,
            clientRevision: 1);
    log.add('status ${out is CloudStatus ? out.state : out.runtimeType}');
    return out;
  }

  @override
  Future<CloudOutcome> jobResult(CloudConfig config, String requestId) async {
    if (resultError != null) return resultError as CloudOutcome;
    return resultPayload.isEmpty
        ? CloudResultLoaded(resultPayload)
        : CloudResultLoaded(resultPayload);
  }

  static Map<String, dynamic> resultFor(
      {required String memoId,
      required String audioSha,
      String language = 'cs',
      String text = 'hotovo',
      int durationMs = 4000}) {
    final words = text.trim().isEmpty ? <String>[] : text.trim().split(' ');
    final perWordMs = words.isEmpty ? 0 : (durationMs / words.length).round();
    final segments = <Map<String, Object?>>[
      for (var i = 0; i < words.length; i++)
        Segment(
          startMs: i * perWordMs,
          endMs: (i + 1) * perWordMs,
          words: [
            Word(text: words[i],
                startMs: i * perWordMs,
                endMs: (i + 1) * perWordMs),
          ],
        ).toJson(),
    ];
    return {
      'schema': 2,
      'memo_id': memoId,
      'request_id': 'aaaaaaaa-1111-4000-8000-000000000009',
      'audio_sha256': audioSha,
      'provenance': {
        'source': 'cloud',
        'model': 'whisper-large-v3',
        'timing_precision': 'word',
      },
      'metadata': {'duration_ms': durationMs, 'audio_sha256': audioSha},
      'transcript': Transcript(languageCode: language, segments: [
        for (final entry in segments)
          Segment.fromJson(entry.cast<String, dynamic>()),
      ]).toJson(),
    };
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
  late FakeCloudClient cloud;
  late JobQueue queue;
  late Directory tmp;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    memos = MemoRepository(db);
    cassettes = CassetteRepository(db);
    settings = SettingsRepository(db);
    engine = FakeTranscriptionProvider();
    llm = FakeSummarizationProvider();
    uploader = FakeUploadPerformer();
    cloud = FakeCloudClient();
    tmp = await Directory.systemTemp.createTemp('cloud_flow_test');
    queue = JobQueue(
      db, memos, cassettes, settings,
      () => engine, () => llm,
      transcoder: null,
      retryDelayUnit: Duration.zero,
      uploadPerformer: uploader,
      uploadTokenReader: () async => 'test-token',
      hasConnectivity: () async => true,
      isUnmetered: () async => true,
      uploadBackoffSchedule: const [Duration(seconds: 60)],
      cloudClientFactory: () => cloud,
    );
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

  Future<Memo> seedMemo(String id,
      {String? fileName, int size = 7, bool withConsent = false}) async {
    fileName ??= '$id.wav';
    final path = '${tmp.path}/$fileName';
    await File(path).writeAsBytes(List.filled(size, 3));
    final memo = Memo(
      id: id,
      cassetteId: 'c1',
      filePath: path,
      durationMs: 4000,
      createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
      status: MemoStatus.stored,
    );
    await memos.insert(memo);
    if (withConsent) {
      await memos.setCloudConsent(id, 1700000000000);
    }
    return memo;
  }

  Future<List<JobRow>> jobs() => db.select(db.jobs).get();
  Future<MemoRow> memoRow(String id) =>
      (db.select(db.memos)..where((m) => m.id.equals(id))).getSingle();
  Future<CloudJobRow?> cloudRow(String id) =>
      (db.select(db.cloudJobs)..where((c) => c.memoId.equals(id)))
          .getSingleOrNull();

  Future<void> configureServer({bool cloud = false}) async {
    await settings.setUploadEnabled(true);
    await settings.setUploadUrl('https://speech-server.example/diktafon/upload');
    if (cloud) await settings.setTranscriptionMode('cloud');
  }

  group('consent semantics', () {
    test('sendMemoToCloud grants consent once and schedules transcription',
        () async {
      await configureServer(cloud: false);
      final memo = await seedMemo('m1');
      final audioSha = await CloudClient.sha256OfFile(File(memo.filePath));
      cloud.resultPayload = FakeCloudClient.resultFor(
          memoId: 'm1', audioSha: audioSha, text: 'ahoj', durationMs: memo.durationMs);

      await queue.sendMemoToCloud(memo.id);

      final row = await memoRow('m1');
      expect(row.cloudConsentAt, isNotNull);
      await queue.drain(); // completion boundary before context teardown

      final flow = await cloudRow('m1');
      expect(flow, isNotNull);
      expect(flow!.state, 'imported_end');
      expect((await memoRow('m1')).transcript, isNotNull);
    });

    test('unconsented memos stay local in phone mode', () async {
      await configureServer(cloud: false);
      await seedMemo('m1');
      await queue.enqueueTranscription('m1');
      await queue.drain();

      expect(engine.calls, 1);
      expect((await cloudRow('m1')), isNull,
          reason: 'a phone-mode run must not write cloud rows');
    });

    test('consent is per-memo and does not leak to a sibling', () async {
      await configureServer(cloud: false);
      await seedMemo('m1');
      await seedMemo('m2', fileName: 'm2.wav');
      await queue.sendMemoToCloud('m1');
      await queue.enqueueTranscription('m2');
      await queue.drain();

      expect(await cloudRow('m2'), isNull);
      expect(engine.calls, 1);
    });
  });

  group('cloud happy path', () {
    test('requests, polls, imports transcript, marks uploaded and summarizes',
        () async {
      await configureServer();
      final memo = await seedMemo('m1');
      await memos.setCloudConsent('m1', 1700000000000);
      final audioSha = await CloudClient.sha256OfFile(File(memo.filePath));
      cloud.statusScript = [
        CloudStatus(
            state: 'complete', errorCode: null, attempts: 1, clientRevision: 1),
      ];
      cloud.resultPayload = FakeCloudClient.resultFor(
          memoId: 'm1', audioSha: audioSha,
          text: 'dlouhý věta pro gistování ' * 40, durationMs: memo.durationMs);

      await queue.retryEnrichment('m1');
      await queue.drain();

      final row = await memoRow('m1');
      expect(row.status, MemoStatus.ready.name,
          reason: 'cloud-imported transcript completes the local gist cycle too');
      expect(row.uploadStatus, UploadStatus.uploaded.name);
      expect(row.uploadedAt, isNotNull);
      final transcript = Transcript.fromJson(
          jsonDecode(row.transcript!) as Map<String, dynamic>);
      expect(transcript.segments, isNotEmpty);
      expect(llm.memoCalls, greaterThan(0));

      final uploadJobs = (await jobs())
          .where((j) => j.type == JobType.uploadMemo.name)
          .toList();
      expect(uploadJobs, isEmpty,
          reason: 'cloud transcripts must NOT be re-uploaded through archive');
      final cloudjob = await cloudRow('m1');
      expect(cloudjob!.state, 'imported_end');
      expect(cloudjob.timingPrecision, 'word');
      expect(cloud.uploads, hasLength(1));
    });

    test('silent server result yields ready state without summary job',
        () async {
      await configureServer();
      await seedMemo('m2');
      await memos.setCloudConsent('m2', 1700000000000);
      final sha = await CloudClient.sha256OfFile(File('${tmp.path}/m2.wav'));
      cloud.statusScript = [
        CloudStatus(
            state: 'complete', errorCode: null, attempts: 1, clientRevision: 1),
      ];
      cloud.resultPayload = FakeCloudClient.resultFor(
          memoId: 'm2', audioSha: sha, text: '', durationMs: 4000);

      await queue.retryEnrichment('m2');
      await queue.drain();

      final row = await memoRow('m2');
      expect(row.status, MemoStatus.ready.name);
      expect(llm.memoCalls, 0);
    });
  });

  group('error lanes', () {
    test('missing configuration marks memo failed immediately', () async {
      await settings.setUploadEnabled(true); // no URL/token
      await seedMemo('m1');
      await memos.setCloudConsent('m1', 1);

      await queue.retryEnrichment('m1');
      await queue.drain();

      final row = await memoRow('m1');
      expect(row.status, MemoStatus.failed.name,
          reason: 'configuration problems are permanent, not retried forever');
      final remaining = (await jobs())
          .where((j) => j.type == JobType.transcribe.name)
          .toList();
      expect(remaining, hasLength(1));
      expect(remaining.single.status, 'failed',
          reason: 'configuration failures leave an honest failed row (§14)');
    });

    test('transient upload error parks retry with backoff and honest state',
        () async {
      await configureServer();
      await seedMemo('m1');
      await memos.setCloudConsent('m1', 1);
      cloud.uploadError = CloudRetryableError('network flame');

      await queue.retryEnrichment('m1');
      await queue.drain();

      final job = (await jobs())
          .singleWhere((j) => j.type == JobType.transcribe.name);
      expect(job.attempts, 1,
          reason: 'each cloud attempt records exactly one attempt, parked after');
      expect(job.availableAt, greaterThan(DateTime.now().millisecondsSinceEpoch));
      expect((await memoRow('m1')).status, MemoStatus.stored.name);
      final cloudjob = await cloudRow('m1');
      expect(cloudjob!.error, contains('network flame'));
    });

    test('conflict spins a fresh request id and bumps client revision',
        () async {
      await configureServer();
      await seedMemo('m1');
      await memos.setCloudConsent('m1', 1);
      final sha = await CloudClient.sha256OfFile(File('${tmp.path}/m1.wav'));
      // First attempt: direct conflict -> retry with superseding identity.
      cloud.statusScript = [
        CloudStatus(
            state: 'complete', errorCode: null, attempts: 1, clientRevision: 1),
        CloudStatus(
            state: 'complete', errorCode: null, attempts: 1, clientRevision: 1),
      ];
      cloud.resultPayload = FakeCloudClient.resultFor(
          memoId: 'm1', audioSha: sha, durationMs: 4000);
      cloud.uploadError = CloudPermanentError('conflict');

      await queue.retryEnrichment('m1');
      await queue.drain();

      final flow = await cloudRow('m1');
      expect(flow, isNotNull);
      expect(flow!.clientRevision, 2, reason: 'conflicts must supersede, not ghost');
      expect(flow.state, 'imported_end');
      expect(cloud.uploads, hasLength(1),
          reason: 'the conflict threw before any bytes streamed — only the ');
    });

    test('result mismatch marks as configuration, not a retry', () async {
      await configureServer();
      await seedMemo('m1');
      await memos.setCloudConsent('m1', 1);
      cloud.statusScript = [
        CloudStatus(
            state: 'complete', errorCode: null, attempts: 1, clientRevision: 1),
      ];
      cloud.resultPayload = FakeCloudClient.resultFor(
          memoId: 'm1', audioSha: 'b'.padRight(64, '0'));

      await queue.retryEnrichment('m1');
      await queue.drain();

      expect((await memoRow('m1')).status, MemoStatus.failed.name);
    });
  });

  group('persistence and lifecycle', () {
    test('failed memo surface shows honest pending status until next run',
        () async {
      await configureServer();
      await seedMemo('m1');
      await memos.setCloudConsent('m1', 1);
      cloud.uploadError = CloudRetryableError('socket closed');

      await queue.retryEnrichment('m1');
      await queue.drain();

      expect((await memoRow('m1')).status, MemoStatus.stored.name);
      final statuses = (await jobs())
          .where((j) => j.targetId == 'm1' && j.type == JobType.transcribe.name)
          .map((j) => j.status)
          .toList();
      expect(statuses, contains('queued'));
    });

    test('memo deletion cascades through cloud rows cleanly', () async {
      await configureServer();
      await seedMemo('m1');
      await memos.setCloudConsent('m1', 1);
      final sha = await CloudClient.sha256OfFile(File('${tmp.path}/m1.wav'));
      await db.into(db.cloudJobs).insert(CloudJobRow(
            memoId: 'm1',
            requestId: '${sha.substring(0, 8)}-0000-4000-8000-000000000001',
            clientRevision: 1,
            audioSha256: sha,
            state: 'uploaded',
            createdAt: 0,
            updatedAt: 0,
          ));

      await memos.delete('m1');
      expect(await cloudRow('m1'), isNull);
    });
  });
}
