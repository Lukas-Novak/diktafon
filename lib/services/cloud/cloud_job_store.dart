/// Durable cloud-processing bookkeeping on the phone (§ cloud): one active
/// ingest `request_id` per memo so a retry can resume polling the same job
/// server-side (or deliberately spin a newer revision when the recording or
/// the destination logically changed) – without depending on network or on
/// the app's process lifetime.
///
/// Row lifecycle: pending → uploading → uploaded → complete | imported_end;
/// cancelled/failed persist until explicitly retried. Deleted with the memo
/// (cascade), tombstones never resurrect on their own.
library;

import 'package:drift/drift.dart';

import '../../data/db/database.dart';

class CloudJobStore {
  CloudJobStore(this._db);

  final AppDatabase _db;

  static const pendingState = 'pending';
  static const uploadingState = 'uploading';
  static const uploadedState = 'uploaded';
  static const completeState = 'complete';
  static const importedState = 'imported_end';

  Future<CloudJobRow?> current(String memoId) =>
      (_db.select(_db.cloudJobs)..where((r) => r.memoId.equals(memoId)))
          .getSingleOrNull();

  /// The row the next step should use:
  ///  * identical → reuse (poll resume),
  ///  * different audio or terminal/cancelled → supersede with a fresh
  ///    `request_id` and `client_revision = previous + 1`,
  ///  * none → insert revision 1.
  /// Writes happen through your caller's transaction.
  Future<CloudJobRow> ensure({
    required String memoId,
    required String audioSha256,
    required String requestId,
    String? timingPrecision,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final existing = await current(memoId);
    if (existing == null) {
      await _insert(
          memoId: memoId,
          requestId: requestId,
          clientRevision: 1,
          audioSha256: audioSha256,
          state: pendingState,
          createdAt: now,
          updatedAt: now,
          timingPrecision: timingPrecision);
      return (await current(memoId))!;
    }
    final identical = existing.audioSha256 == audioSha256 &&
        existing.state != 'cancelled' &&
        existing.state != importedState;
    if (identical && existing.requestId == requestId) {
      return existing;
    }
    if (!identical || existing.requestId != requestId) {
      // Audio/revisit shift or cancels that were not explicit: revise +1.
      final revision = existing.clientRevision + 1;
      await (_db.update(_db.cloudJobs)..where((r) => r.memoId.equals(memoId)))
          .write(CloudJobsCompanion(
        requestId: Value(requestId),
        clientRevision: Value(revision),
        audioSha256: Value(audioSha256),
        state: Value(pendingState),
        timingPrecision: Value(timingPrecision),
        error: const Value(null),
        updatedAt: Value(now),
      ));
    }
    return (await current(memoId))!;
  }

  Future<void> markUploaded(String memoId) => _set(memoId, uploadedState);

  Future<void> markPending(String memoId) => _set(memoId, pendingState);

  Future<void> markUploading(String memoId) => _set(memoId, uploadingState);

  Future<void> markComplete(String memoId, {String? timingPrecision}) =>
      _set(memoId, completeState, timingPrecision: timingPrecision);

  Future<void> markImported(String memoId, {String? timingPrecision}) =>
      _set(memoId, importedState, timingPrecision: timingPrecision);

  Future<void> recordFailure(String memoId, String error) async =>
      (_db.update(_db.cloudJobs)..where((r) => r.memoId.equals(memoId))).write(
          CloudJobsCompanion(
              error: Value(error),
              updatedAt: Value(DateTime.now().millisecondsSinceEpoch)));

  Future<void> _set(String memoId, String state,
      {String? timingPrecision}) async {
    await (_db.update(_db.cloudJobs)..where((r) => r.memoId.equals(memoId)))
        .write(CloudJobsCompanion(
            state: Value(state),
            timingPrecision: timingPrecision == null
                ? const Value.absent()
                : Value(timingPrecision),
            error: const Value(null),
            updatedAt: Value(DateTime.now().millisecondsSinceEpoch)));
  }

  Future<void> _insert({
    required String memoId,
    required String requestId,
    required int clientRevision,
    required String audioSha256,
    required String state,
    required int createdAt,
    required int updatedAt,
    String? timingPrecision,
  }) {
    return _db.into(_db.cloudJobs).insert(CloudJobRow(
          memoId: memoId,
          requestId: requestId,
          clientRevision: clientRevision,
          audioSha256: audioSha256,
          state: state,
          timingPrecision: timingPrecision,
          createdAt: createdAt,
          updatedAt: updatedAt,
        ));
  }

  Future<void> deleteForMemo(String memoId) =>
      (_db.delete(_db.cloudJobs)..where((r) => r.memoId.equals(memoId))).go();
}
