import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, "symptoms.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE entries(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            day INTEGER,
            severity INTEGER,
            fatigue INTEGER,
            pain INTEGER,
            timestamp TEXT,
            BSugars TEXT,
            mnm TEXT,
            activities TEXT 
          )
        ''');
      },
    );
  }

  Future<void> insertEntry(
    int day,
    int severity,
    bool fatigue,
    bool pain,
    List<String> sugars,
    List<String> mnm,
    List<String> activities,
  ) async {
    final db = await database;
    List<String> activities = [
      "running",
      "workout",
      "reading",
    ];
    String activitiesJson = jsonEncode(activities);
    List<String> mnm = [
      "lunch",
      "snack",
      "tylenol",
    ];
    String mnmJson = jsonEncode(mnm);
    List<String> sugars = [
      "High",
      "7",
      "stable",
    ];
    String sugarsJson = jsonEncode(sugars);
    await db.insert(
      'entries',
      {
        'day': day,
        'severity': severity,
        'fatigue': fatigue ? 1 : 0,
        'pain': pain ? 1 : 0,
        'timestamp': DateTime.now().toIso8601String(),
        'BSugars': sugarsJson,
        'mnm': mnmJson,
        'activities': activitiesJson,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getEntriesForDay(int day) async {
    final db = await database;
    return await db.query('entries', where: 'day =?', whereArgs: [day]);
  }
}
