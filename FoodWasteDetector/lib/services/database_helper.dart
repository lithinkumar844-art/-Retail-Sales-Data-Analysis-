import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/scan_record.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'food_waste_detector.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE scans (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            foodName TEXT NOT NULL,
            freshnessStatus TEXT NOT NULL,
            confidence REAL NOT NULL,
            imagePath TEXT NOT NULL,
            dateTime TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertScan(ScanRecord record) async {
    final db = await database;
    return db.insert('scans', record.toMap());
  }

  Future<List<ScanRecord>> getAllScans() async {
    final db = await database;
    final rows = await db.query('scans', orderBy: 'dateTime DESC');
    return rows.map(ScanRecord.fromMap).toList();
  }

  Future<Map<String, int>> getSummaryStats() async {
    final db = await database;
    final total = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM scans'),
        ) ??
        0;
    final rotten = Sqflite.firstIntValue(
          await db.rawQuery(
              "SELECT COUNT(*) FROM scans WHERE freshnessStatus = 'Rotten'"),
        ) ??
        0;
    return {'total': total, 'rotten': rotten};
  }

  Future<List<Map<String, dynamic>>> getWeeklyWasteData() async {
    final db = await database;
    return db.rawQuery('''
      SELECT substr(dateTime, 1, 10) as day,
             COUNT(*) as total,
             SUM(CASE WHEN freshnessStatus = 'Rotten' THEN 1 ELSE 0 END) as rotten
      FROM scans
      WHERE dateTime >= datetime('now', '-7 days')
      GROUP BY day
      ORDER BY day
    ''');
  }
}
