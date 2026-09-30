/// Drift schema (§7.2): metadata, transcripts and summaries in SQLite;
/// audio stays on disk as files (§7.1).
library;

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

@DataClassName('CassetteRow')
class Cassettes extends Table {
  TextColumn get id => text()();
  TextColumn get label => text().nullable()();
  BoolColumn get titleIsUserSet =>
      boolean().withDefault(const Constant(false))();
  IntColumn get colorSeed => integer()();
  TextColumn get summary => text().nullable()();
  IntColumn get summaryUpdatedAt => integer().nullable()();  // epoch ms
  IntColumn get createdAt => integer()();  // epoch ms
  IntColumn get updatedAt => integer()();  // epoch ms

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MemoRow')
class Memos extends Table {
  TextColumn get id => text()();
  TextColumn get cassetteId =>
      text().references(Cassettes, #id, onDelete: KeyAction.cascade)();
  TextColumn get filePath => text()();
  IntColumn get durationMs => integer()();
  IntColumn get createdAt => integer()();  // epoch ms
  TextColumn get detectedLang => text().nullable()();

  /// Transcript stored as a JSON blob per memo (§7.2 — no search in v1).
  TextColumn get transcript => text().nullable()();

  /// Legacy LLM-cleanup bookkeeping (§6.8, retired 2026-07-13): the
  /// engine's original take from when cleanup rewrote [transcript]. No
  /// longer written — kept, like [foldedAt], so existing databases need no
  /// migration.
  TextColumn get rawTranscript => text().nullable()();
  TextColumn get memoSummary => text().nullable()();

  /// Legacy M3 fold bookkeeping — no longer written since the cassette
  /// summary is rebuilt from all gists (§6.7 revised 2026-07-08); kept so
  /// existing databases need no migration.
  IntColumn get foldedAt => integer().nullable()();  // epoch ms
  TextColumn get status => text()();

  /// Server-upload surface state (UploadStatus.name); null = the feature has
  /// never touched this memo (upload disabled when it was finalized).
  TextColumn get uploadStatus => text().nullable()();

  /// Server-confirmed upload instant (epoch ms); null until then.
  IntColumn get uploadedAt => integer().nullable()();

  /// The user explicitly approved cloud-processing this exact memo
  /// (epoch ms); audio is content-immutable, so the grant never rebinds.
  /// Null = never asked/never granted; phone-local mode handles it.
  IntColumn get cloudConsentAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Durable background jobs (§6.5) — survive app restart.
@DataClassName('JobRow')
class Jobs extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get targetId => text()();
  TextColumn get status => text()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();  // epoch ms

  /// Do-not-pick-before instant (epoch ms). Backoff without occupying the
  /// drain loop: a deferred/requeued job parks in 'queued' until then.
  IntColumn get availableAt => integer().withDefault(const Constant(0))();

  /// Claim token of the process/lane currently working the job — guards
  /// the app process and the WorkManager headless engine from running
  /// each other's jobs concurrently.
  TextColumn get ownerId => text().nullable()();

  /// Claim expiry (epoch ms); another lane may take over only afterwards.
  /// NULL/0 = no lease.
  IntColumn get leaseUntil => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// One outstanding cloud-processing request per memo: upload state,
/// resumable polling, and (after import) the returned transcript's
/// timing precision. Deleted with the memo.
@DataClassName('CloudJobRow')
class CloudJobs extends Table {
  TextColumn get memoId =>
      text().references(Memos, #id, onDelete: KeyAction.cascade)();
  TextColumn get requestId => text()();
  IntColumn get clientRevision => integer()();
  TextColumn get audioSha256 => text()();

  /// pending → uploading → uploaded → complete | imported_end
  /// (terminal 'cancelled'/'failed' survive so state reads honestly;
  /// code resets them lazily on the next run instead of deleting).
  TextColumn get state => text()();
  TextColumn get timingPrecision => text().nullable()();
  TextColumn get error => text().nullable()();
  IntColumn get createdAt => integer()();  // epoch ms
  IntColumn get updatedAt => integer()();  // epoch ms

  @override
  Set<Column> get primaryKey => {memoId};
}

/// Key-value settings (single conceptual row, §7.2).
@DataClassName('SettingRow')
class SettingsEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Cassettes, Memos, Jobs, CloudJobs, SettingsEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// In-memory database for tests.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // M3: cassette-summary fold bookkeeping.
            await m.addColumn(memos, memos.foldedAt);
          }
          if (from < 3) {
            // The retired transcript cleanup's raw-take column (§6.8).
            await m.addColumn(memos, memos.rawTranscript);
          }
          if (from < 4) {
            // Server upload: surface state on memos, parked retries on jobs.
            await m.addColumn(memos, memos.uploadStatus);
            await m.addColumn(memos, memos.uploadedAt);
            await m.addColumn(jobs, jobs.availableAt);
          }
          if (from < 5) {
            // Cloud transcription: per-memo consent, job lane ownership and
            // resumable cloud requests.
            await m.addColumn(memos, memos.cloudConsentAt);
            await m.addColumn(jobs, jobs.ownerId);
            await m.addColumn(jobs, jobs.leaseUntil);
            await m.createTable(cloudJobs);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static QueryExecutor _openConnection() {
    // §7.1: user data lives in app-documents so the OS backup captures it.
    return driftDatabase(
      name: 'diktafon',
      native: DriftNativeOptions(
        databaseDirectory: getApplicationDocumentsDirectory,
      ),
    );
  }
}
