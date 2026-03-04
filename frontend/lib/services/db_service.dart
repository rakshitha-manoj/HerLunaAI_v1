import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cycle_log_model.dart';

/// SQLite local database service for offline / local-mode storage.
/// Data stays on-device only — never sent to backend for persistence.
class DbService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'herluna_local.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cycle_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            period_start TEXT NOT NULL,
            cycle_length INTEGER,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        await db.execute('''
          CREATE TABLE mood_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            mood TEXT NOT NULL,
            energy_level INTEGER DEFAULT 5,
            notes TEXT,
            date TEXT NOT NULL,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        await db.execute('''
          CREATE TABLE sleep_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            hours REAL DEFAULT 0,
            quality INTEGER DEFAULT 5,
            date TEXT NOT NULL,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      },
    );
  }

  // ── Cycle Logs ────────────────────────────────────────────────────────

  Future<int> insertCycleLog(CycleLogModel log) async {
    final db = await database;
    return db.insert('cycle_logs', {
      'user_id': log.userId,
      'period_start': log.periodStart.toIso8601String().split('T')[0],
      'cycle_length': log.cycleLength,
    });
  }

  Future<List<CycleLogModel>> getCycleLogs(int userId) async {
    final db = await database;
    final results = await db.query(
      'cycle_logs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'period_start DESC',
    );
    return results
        .map((row) => CycleLogModel(
              id: row['id'] as int,
              userId: row['user_id'] as int,
              periodStart: DateTime.parse(row['period_start'] as String),
              cycleLength: row['cycle_length'] as int?,
            ))
        .toList();
  }

  // ── Mood Logs ─────────────────────────────────────────────────────────

  Future<int> insertMoodLog({
    required int userId,
    required String mood,
    int energyLevel = 5,
    String? notes,
    required DateTime date,
  }) async {
    final db = await database;
    return db.insert('mood_logs', {
      'user_id': userId,
      'mood': mood,
      'energy_level': energyLevel,
      'notes': notes,
      'date': date.toIso8601String().split('T')[0],
    });
  }

  Future<List<Map<String, dynamic>>> getMoodLogs(int userId) async {
    final db = await database;
    return db.query(
      'mood_logs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
  }

  // ── Sleep Logs ────────────────────────────────────────────────────────

  Future<int> insertSleepLog({
    required int userId,
    required double hours,
    int quality = 5,
    required DateTime date,
  }) async {
    final db = await database;
    return db.insert('sleep_logs', {
      'user_id': userId,
      'hours': hours,
      'quality': quality,
      'date': date.toIso8601String().split('T')[0],
    });
  }

  Future<List<Map<String, dynamic>>> getSleepLogs(int userId) async {
    final db = await database;
    return db.query(
      'sleep_logs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
  }

  // ── Clear All ─────────────────────────────────────────────────────────

  Future<void> clearAllData(int userId) async {
    final db = await database;
    await db.delete('cycle_logs', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('mood_logs', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('sleep_logs', where: 'user_id = ?', whereArgs: [userId]);
  }
}
