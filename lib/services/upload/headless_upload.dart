/// Headless upload drain for the WorkManager callback: builds the minimal
/// world the upload lane needs (database + queue seams — no ML engines, no
/// UI, no riverpod) and runs one scheduling pass over the durable queue.
/// Runs in a background Flutter engine started by WorkManager, possibly
/// with no activity at all.
library;

import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../data/db/database.dart';
import '../../data/repositories/cassette_repository.dart';
import '../../data/repositories/memo_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/models.dart';
import '../cloud/cloud_client.dart';
import '../processing/job_queue.dart';
import '../providers/summarization_provider.dart';
import '../providers/transcription_provider.dart';
import 'connectivity_probe.dart';
import 'upload_service.dart';
import 'upload_token_store.dart';

enum HeadlessDrainOutcome { drained, failed }

/// Headless gate for WorkManager kicks: lets the queue drain the durable
/// lanes that require no local engine (network jobs only). In **local** mode
/// the stub reports no transcription model, so whisper/llm rows stay parked
/// exactly as on a missing engine; in **cloud** mode it reports the lane
/// ready because their provider needs no on-device artifact at all.
class _HeadlessTranscriptionGate implements TranscriptionProvider {
  _HeadlessTranscriptionGate(this._settings);

  final SettingsRepository _settings;

  @override
  String get id => 'headless/cloud-gate';

  @override
  Future<ModelStatus> modelStatus() async => switch (
      (await _settings.get()).transcriptionMode) {
        'cloud' => ModelStatus.ready,
        _ => ModelStatus.notInstalled,
      };

  @override
  Future<void> ensureModel({ProgressSink? onProgress}) async {}

  @override
  Future<Transcript> transcribe(AudioRef audio,
      {String? languageCode, CancelToken? cancel}) {
    throw UnsupportedError('local whisper cannot run inside the upload worker');
  }
}

final class _StubSummarizationGate implements SummarizationProvider {
  const _StubSummarizationGate();

  @override
  String get id => 'headless/no-summary';

  @override
  Future<ModelStatus> modelStatus() async => ModelStatus.notInstalled;

  @override
  Future<void> ensureModel({ProgressSink? onProgress}) async {}

  @override
  Future<String> summarizeMemo(Transcript t, {required String languageCode}) =>
      throw UnsupportedError('no LLM in the upload worker');

  @override
  Future<String> updateCassetteSummary(
          {required String? previousSummary,
          required List<MemoDigest> newMemos,
          required String languageCode}) =>
      throw UnsupportedError('no LLM in the upload worker');

  @override
  Future<String> suggestTitle(String cassetteSummary,
          {required String languageCode}) =>
      throw UnsupportedError('no LLM in the upload worker');
}

/// One upload-lane pass with its own database handle (the app process and
/// the worker may overlap; SQLite serializes, and both sides claim rows
/// via queued→running transitions).
Future<HeadlessDrainOutcome> runHeadlessUploadDrain() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  try {
    final probe = ConnectivityProbe();
    final tokens = UploadTokenStore();
    final settings = SettingsRepository(db);
    final gate = _HeadlessTranscriptionGate(settings);
    final summaryGate = const _StubSummarizationGate();
    final queue = JobQueue(
      db,
      MemoRepository(db),
      CassetteRepository(db),
      settings,
      // Only the durable lanes that do not require native engines are
      // reachable: upload cloud-poll lanes AND cloud-transcribe polling
      // (provider-ready because their work is off-device). Phone-side
      // engines stay parked (their reports are the stub's honest nulls).
      () => gate,
      () => summaryGate,
      transcoder: null,
      uploadPerformer: UploadService(),
      uploadTokenReader: tokens.read,
      hasConnectivity: probe.hasConnectivity,
      isUnmetered: probe.isUnmetered,
      cloudClientFactory: CloudClient.new,
      appVersionProvider: () async {
        try {
          final info = await PackageInfo.fromPlatform();
          return '${info.version}+${info.buildNumber}';
        } catch (_) {
          return '';
        }
      },
    );
    // Upload first (acknowledged receipts), then any cloud poll lanes the
    // settings gate unblocks (local-ML rows remain parked, never stranded).
    await queue.drainUploads();
    await queue.drain();
    return HeadlessDrainOutcome.drained;
  } catch (_) {
    // WorkManager applies its own retry on top of the queue's row-level
    // backoff; surfacing a failure here is correct, not noisy.
    return HeadlessDrainOutcome.failed;
  } finally {
    await db.close();
  }
}
