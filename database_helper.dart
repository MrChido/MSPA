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
    String mnmInput = mnm.isNotEmpty ? jsonEncode(mnm) : '[]';
    String activitiesInput =
        activities.isNotEmpty ? jsonEncode(activities) : '[]';
    print("$day, $severity, $sugars,$mnmInput, $activitiesInput");

    await db.insert(
      'entries',
      {
        'day': day,
        'severity': severity,
        'fatigue': fatigue ? 1 : 0,
        'pain': pain ? 1 : 0,
        'timestamp': DateTime.now().toIso8601String(),
        'BSugars': sugars,
        'mnm': mnmInput,
        'activities': activitiesInput,
      },
    );
    print("Inserted entry: ${await db.query('entries')}"); //verify sugars
    // print("Inserted mnm: ${jsonEncode(mnm)}"); //debug
    // print("Inserted activites: ${activities}"); //debug
  }

  Future<int> getEntryCountForDay(int day) async {
    final db = await database;
    List<Map<String, dynamic>> result =
        await db.query('entries', where: 'day =?', whereArgs: [day]);

    return result.length;
  }

  Future<List<Map<String, dynamic>>> getEntriesForDay(int day) async {
    final db = await database;
    List<Map<String, dynamic>> result =
        await db.query('entries', where: 'day =?', whereArgs: [day]);

    return result.map((entry) {
      entry['mnm'] = entry['mnm'] != null ? jsonDecode(entry['mnm']) : [];
      entry['activities'] =
          entry['activities'] != null ? jsonDecode(entry['activities']) : [];
      return entry;
    }).toList();
  }
}
