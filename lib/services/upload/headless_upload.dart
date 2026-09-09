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
import '../processing/job_queue.dart';
import 'connectivity_probe.dart';
import 'upload_service.dart';
import 'upload_token_store.dart';

enum HeadlessDrainOutcome { drained, failed }

/// One upload-lane pass with its own database handle (the app process and
/// the worker may overlap; SQLite serializes, and both sides claim rows
/// via queued→running transitions).
Future<HeadlessDrainOutcome> runHeadlessUploadDrain() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  try {
    final probe = ConnectivityProbe();
    final tokens = UploadTokenStore();
    final queue = JobQueue(
      db,
      MemoRepository(db),
      CassetteRepository(db),
      SettingsRepository(db),
      // The ML lanes are never driven from this worker — only the upload
      // drain runs. These getters exist solely to satisfy the constructor
      // and must never be invoked here.
      () => throw UnsupportedError('no ML engines in the upload worker'),
      () => throw UnsupportedError('no ML engines in the upload worker'),
      uploadPerformer: UploadService(),
      uploadTokenReader: tokens.read,
      hasConnectivity: probe.hasConnectivity,
      isUnmetered: probe.isUnmetered,
      appVersionProvider: () async {
        try {
          final info = await PackageInfo.fromPlatform();
          return '${info.version}+${info.buildNumber}';
        } catch (_) {
          return '';
        }
      },
    );
    await queue.drainUploads();
    return HeadlessDrainOutcome.drained;
  } catch (_) {
    // WorkManager applies its own retry on top of the queue's row-level
    // backoff; surfacing a failure here is correct, not noisy.
    return HeadlessDrainOutcome.failed;
  } finally {
    await db.close();
  }
}
