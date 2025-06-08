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

  Future<List<int>> getDaysWithEntries() async {
    final db = await database;
    List<Map<String, dynamic>> result =
        await db.rawQuery("SELECT DISTINCT day From entries WHERE day > 0");

    return result.map((row) => row['day'] as int).toList();
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, "symptoms.db");

    return await openDatabase(
      path,
      version: 2,
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
            activities TEXT,
            symptoms TEXT,
            wake INTEGER,
            sleep INTEGER 
          )
        ''');
      },
    );
  }

  Future<void> checkDEntries() async {
    final db = await DatabaseHelper().database;
    var result = await db.rawQuery("PRAGMA table_info(entries)");
    print(result);
  }

  Future<void> insertEntry(
    int day,
    int severity,
    bool fatigue,
    bool pain,
    String sugars,
    String mnm,
    String activities,
    String symptoms,
    int wake,
    int sleep,
  ) async {
    final db = await database;
    String mnmInput = mnm.isNotEmpty ? jsonEncode(mnm) : '[]';
    String activitiesInput =
        activities.isNotEmpty ? jsonEncode(activities) : '[]';
    String symptomsInput = symptoms.isNotEmpty ? jsonEncode(symptoms) : '[]';
    print(
        "$day, $severity, $sugars,$mnmInput, $activitiesInput, $symptomsInput");

    await db.insert(
      'entries',
      {
        'day': day,
        'severity': severity,
        'fatigue': fatigue ? 1 : 0,
        'pain': pain ? 1 : 0,
        'wake': wake,
        'sleep': sleep,
        'timestamp': DateTime.now().toIso8601String(),
        'BSugars': sugars,
        'mnm': mnmInput,
        'activities': activitiesInput,
        'symptoms': symptomsInput,
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
      entry['symptoms'] =
          entry['symptoms'] != null ? jsonDecode(entry['symptoms']) : [];
      return entry;
    }).toList();
  }
}
