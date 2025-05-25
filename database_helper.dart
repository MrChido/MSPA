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

  // Future<void> resetDatabase() async {
  //   final db = await database;
  //   await db.delete('entries');
  //   await db.execute("DELETE FROM sqlite_sequence WHERE name='entries'");
  //   print("Database cleared and ID reset!");

  //   await DatabaseHelper().resetDatabase();
  //}

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
    String sugars,
    List<String> mnm,
    List<String> activities,
  ) async {
    final db = await database;

    await db.insert(
      'entries',
      {
        'day': day,
        'severity': severity,
        'fatigue': fatigue ? 1 : 0,
        'pain': pain ? 1 : 0,
        'timestamp': DateTime.now().toIso8601String(),
        'BSugars': sugars,
        'mnm': jsonEncode(mnm),
        'activities': jsonEncode(activities),
      },
    );
    print("Inserted entry: ${await db.query('entries')}"); //verify sugars
  }

  Future<List<Map<String, dynamic>>> getEntriesForDay(int day) async {
    final db = await database;
    return await db.query('entries', where: 'day =?', whereArgs: [day]);
  }
}
