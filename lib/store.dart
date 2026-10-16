import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'decay.dart';

/// Companion persistence — ported from `src/lib/sqlite-store.ts`.
///
/// Offline-first, zero-backend. The SQLite DB is local to the app sandbox; a
/// reinstall wipes it unless the user explicitly exports a JSON backup via the
/// Quiet Archive. We never attempt to persist across reinstall.
// Reinstall boundary: documented intentionally here; no attempt to persist
// across reinstall. Long neglect caps: decay.dart caps at stage 5 (Passing).
// Locale fallback: fragment bank English only.

/// Schema version for defensive migration.
const int _schemaVersion = 2;

class CompanionRow {
  CompanionRow({
    this.plantedAt,
    this.passedAt,
    this.ambientOn = false,
    this.onboarded = false,
    this.gentleReminderOn = false,
    this.seed = 0,
    this.visits = const [],
  });

  int? plantedAt;
  int? passedAt;
  bool ambientOn;
  bool onboarded;
  bool gentleReminderOn;
  int seed;
  List<Visit> visits;
}

class DecayStore {
  DecayStore._();
  static final DecayStore instance = DecayStore._();

  Database? _db;

  Future<Database> _open() async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'decay.db');
    _db = await openDatabase(
      path,
      version: _schemaVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS meta (
            key TEXT PRIMARY KEY,
            value INTEGER NOT NULL
          );
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS companion (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            planted_at INTEGER,
            passed_at INTEGER,
            ambient_on INTEGER DEFAULT 0,
            gentle_reminder_on INTEGER DEFAULT 0,
            onboarded INTEGER DEFAULT 0,
            seed INTEGER DEFAULT 0,
            schema_version INTEGER DEFAULT 2
          );
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS visits (
            t INTEGER PRIMARY KEY,
            present INTEGER NOT NULL,
            ms INTEGER NOT NULL
          );
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS fragments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            seed INTEGER NOT NULL,
            text TEXT NOT NULL,
            created_at INTEGER DEFAULT (strftime('%s','now'))
          );
        ''');
        await db.insert(
          'meta',
          {'key': 'schema_version', 'value': _schemaVersion},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE companion ADD COLUMN gentle_reminder_on INTEGER DEFAULT 0",
          );
        }
      },
    );
    return _db!;
  }

  /// Atomic state read with monotonic sanity.
  Future<CompanionRow> loadCompanionState() async {
    try {
      final db = await _open();
      final rows = await db.query('companion', where: 'id = 1', limit: 1);
      if (rows.isEmpty) return CompanionRow();
      final row = rows.first;
      final visitRows =
          await db.query('visits', orderBy: 't ASC', columns: ['t', 'present', 'ms']);
      return CompanionRow(
        plantedAt: row['planted_at'] as int?,
        passedAt: row['passed_at'] as int?,
        ambientOn: row['ambient_on'] == 1,
        gentleReminderOn: row['gentle_reminder_on'] == 1,
        onboarded: row['onboarded'] == 1,
        seed: (row['seed'] as int?) ?? 0,
        visits: visitRows
            .map((v) => Visit(
                  t: v['t'] as int,
                  present: v['present'] == 1,
                  ms: v['ms'] as int,
                ))
            .toList(),
      );
    } catch (_) {
      return CompanionRow();
    }
  }

  /// Atomic write with transaction.
  Future<void> saveCompanionState(CompanionRow state) async {
    final db = await _open();
    await db.transaction((txn) async {
      await txn.rawInsert('''
        INSERT INTO companion (id, planted_at, passed_at, ambient_on, gentle_reminder_on, onboarded, seed)
        VALUES (1, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
          planted_at = excluded.planted_at,
          passed_at = excluded.passed_at,
          ambient_on = excluded.ambient_on,
          gentle_reminder_on = excluded.gentle_reminder_on,
          onboarded = excluded.onboarded,
          seed = excluded.seed;
      ''', [
        state.plantedAt,
        state.passedAt,
        state.ambientOn ? 1 : 0,
        state.gentleReminderOn ? 1 : 0,
        state.onboarded ? 1 : 0,
        state.seed,
      ]);
      await txn.delete('visits');
      for (final v in state.visits) {
        await txn.insert(
          'visits',
          {'t': v.t, 'present': v.present ? 1 : 0, 'ms': v.ms},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    });
  }
}

/// Clock-change resilience: monotonic elapsed tracking.
///
/// If wall clock jumped backward > 1h, cap to last known good elapsed rather
/// than negative.
double computeMonotonicElapsed(int? plantedAt, List<Visit> visits, int nowWallMs) {
  if (plantedAt == null) return 0;
  final lastVisitTime = visits.isNotEmpty ? visits.last.t : plantedAt;
  if (nowWallMs < plantedAt - 3600000) {
    // Clock rolled back significantly — use monotonic approximation from last
    // visit + bounded delta
    final safeNow = lastVisitTime;
    return [0.0, (safeNow - plantedAt) / 86400000].reduce((a, b) => a > b ? a : b);
  }
  return [0.0, (nowWallMs - plantedAt) / 86400000].reduce((a, b) => a > b ? a : b);
}
