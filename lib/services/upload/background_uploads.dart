/// Android WorkManager integration for server upload (§ upload reliability):
/// the durable Jobs queue only runs while the app's process is alive —
/// WorkManager is what lets a pending upload finish after the process died
/// or the phone rebooted, without the user reopening Diktafon. Two task
/// registrations, both network-constrained and unique-named:
///
///   * a periodic sweep (OS-minimum cadence, ~15 min) — the safety net,
///     drains whatever is pending;
///   * an expedited one-off per freshly scheduled memo — uploads usually
///     start within moments of the memo becoming ready.
///
/// Both run [uploadCallbackDispatcher] in a headless Flutter engine.
library;

import 'dart:io';

import 'package:workmanager/workmanager.dart';

import 'headless_upload.dart';

const uploadPeriodicTaskName = 'diktafon-upload-sweep';
const uploadOneOffTaskName = 'diktafon-upload-now';
const uploadTaskId = 'diktafon.upload.drain';

/// The WorkManager entrypoint — keep it free of app-context assumptions:
/// it boots its own minimal world (database + upload lane only, no ML
/// engines, no UI) and returns false on error so WorkManager applies its
/// own backoff on top of the queue's row-level one.
@pragma('vm:entry-point')
void uploadCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != uploadTaskId) return true;
    try {
      final outcome = await runHeadlessUploadDrain();
      return outcome != HeadlessDrainOutcome.failed;
    } catch (_) {
      return false;
    }
  });
}

/// Owns WorkManager lifecycle so the rest of the app never imports the
/// plugin (tests substitute nothing — [isSupported] is false everywhere
/// but Android, the only v1 target).
class UploadBackgroundScheduler {
  static bool get isSupported => Platform.isAndroid;

  /// Registers the headless callback. Idempotent; safe at every launch.
  Future<void> initialize() =>
      Workmanager().initialize(uploadCallbackDispatcher);

  /// Reconciles registrations with the current settings. Called on startup
  /// and whenever upload settings change.
  Future<void> sync({required bool enabled, required bool wifiOnly}) async {
    if (!isSupported) return;
    if (!enabled) {
      await Workmanager().cancelByUniqueName(uploadPeriodicTaskName);
      await Workmanager().cancelByUniqueName(uploadOneOffTaskName);
      return;
    }
    await Workmanager().registerPeriodicTask(
      uploadPeriodicTaskName,
      uploadTaskId,
      frequency: const Duration(minutes: 15),
      constraints: _constraints(wifiOnly),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      backoffPolicy: BackoffPolicy.exponential,
    );
  }

  /// Nudges WorkManager for a just-scheduled memo. `replace` coalesces
  /// bursts (several memos finalizing in a row) into one fresh run.
  Future<void> kick({required bool wifiOnly}) async {
    if (!isSupported) return;
    await Workmanager().registerOneOffTask(
      uploadOneOffTaskName,
      uploadTaskId,
      constraints: _constraints(wifiOnly),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  Constraints _constraints(bool wifiOnly) => Constraints(
      networkType:
          wifiOnly ? NetworkType.unmetered : NetworkType.connected);
}
