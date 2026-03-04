import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cycle_log.dart';
import '../models/behavioral_data.dart';
import '../models/travel_data.dart';

/// SQLite Local Database Service for Local Mode.
/// Data is stored on-device only — never sent to backend for persistence.
class LocalDbService {
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
          CREATE TABLE behavioral_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            step_count INTEGER DEFAULT 0,
            screen_time REAL DEFAULT 0.0,
            calendar_load INTEGER DEFAULT 0,
            date TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE travel_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            start_date TEXT NOT NULL,
            end_date TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // ── Cycle Logs ──────────────────────────────────────────────────────

  Future<int> insertCycleLog(CycleLog log) async {
    final db = await database;
    return db.insert('cycle_logs', {
      'user_id': log.userId,
      'period_start': log.periodStart.toIso8601String().split('T')[0],
      'cycle_length': log.cycleLength,
    });
  }

  Future<List<CycleLog>> getCycleLogs(int userId) async {
    final db = await database;
    final results = await db.query(
      'cycle_logs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'period_start DESC',
    );
    return results
        .map((row) => CycleLog(
              id: row['id'] as int,
              userId: row['user_id'] as int,
              periodStart: DateTime.parse(row['period_start'] as String),
              cycleLength: row['cycle_length'] as int?,
            ))
        .toList();
  }

  // ── Behavioral Data ──────────────────────────────────────────────────

  Future<int> insertBehavioralData(BehavioralData data) async {
    final db = await database;
    return db.insert('behavioral_data', {
      'user_id': data.userId,
      'step_count': data.stepCount,
      'screen_time': data.screenTime,
      'calendar_load': data.calendarLoad,
      'date': data.date.toIso8601String().split('T')[0],
    });
  }

  Future<List<BehavioralData>> getBehavioralData(int userId) async {
    final db = await database;
    final results = await db.query(
      'behavioral_data',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return results
        .map((row) => BehavioralData(
              id: row['id'] as int,
              userId: row['user_id'] as int,
              stepCount: row['step_count'] as int,
              screenTime: (row['screen_time'] as num).toDouble(),
              calendarLoad: row['calendar_load'] as int,
              date: DateTime.parse(row['date'] as String),
            ))
        .toList();
  }

  // ── Travel Data ──────────────────────────────────────────────────────

  Future<int> insertTravelData(TravelData data) async {
    final db = await database;
    return db.insert('travel_data', {
      'user_id': data.userId,
      'start_date': data.startDate.toIso8601String().split('T')[0],
      'end_date': data.endDate.toIso8601String().split('T')[0],
    });
  }

  Future<List<TravelData>> getTravelData(int userId) async {
    final db = await database;
    final results = await db.query(
      'travel_data',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'start_date DESC',
    );
    return results
        .map((row) => TravelData(
              id: row['id'] as int,
              userId: row['user_id'] as int,
              startDate: DateTime.parse(row['start_date'] as String),
              endDate: DateTime.parse(row['end_date'] as String),
            ))
        .toList();
  }

  /// Delete all local data for a user
  Future<void> clearAllData(int userId) async {
    final db = await database;
    await db.delete('cycle_logs', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('behavioral_data', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('travel_data', where: 'user_id = ?', whereArgs: [userId]);
  }
}
