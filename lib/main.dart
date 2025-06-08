import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:convert';
import 'entry_screen.dart';

void main() {
  databaseFactory = databaseFactoryFfi;
  runApp((SymptomTrackerApp()));
}

class SymptomTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Symptom Tracker',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<int, int> entriesPerDay = {};

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  void loadEntries() async {
    final dbHelper = DatabaseHelper();
    for (int day = 1; day <= 30; day++) {
      int count = await dbHelper.getEntryCountForDay(day);
      setState(() {
        entriesPerDay[day] = count;
      });
      print("day $day has $count entries"); //debuging
    }
  }

  void updateEntryCount(int day) {
    setState(() {
      entriesPerDay[day] = (entriesPerDay[day] ?? 0) + 1;
    });
  }

  @override // this is what the user opens up to
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daily Journal')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CalendarWidget(
              entriesPerDay: entriesPerDay, updateEntryCount: updateEntryCount),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text('Tap a day to log symptoms'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text("Review Entries"),
          )
        ],
      ),
    );
  }
}

class CalendarWidget extends StatelessWidget {
  final Map<int, int> entriesPerDay;
  final Function(int) updateEntryCount;

  const CalendarWidget(
      {required this.entriesPerDay, required this.updateEntryCount});
  @override
  Widget build(BuildContext context) {
    //Placeholder calendar UI with hardcoded data
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(31, (index) {
          print('Index is: ${index + 1}');
          int entryCount = entriesPerDay[index + 1] ?? 0; //simulated score
          Color color = getColorForEntries(entriesPerDay[index + 1] ?? 0);

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EntryScreen(
                      day: index + 1, updateEntryCount: updateEntryCount),
                ),
              );
            },
            child: CircleAvatar(
              backgroundColor: color,
              child: entryCount >= 10
                  ? Icon(Icons.whatshot,
                      color: Colors.white) // Special icon for high entries
                  : Text('${index + 1}'), // Show correct day number
            ),
          );
        }),
      ),
    );
  }
}

Color getColorForEntries(int entryCount) {
  if (entryCount == 0) return Colors.grey;
  if (entryCount >= 1 && entryCount <= 5) return Colors.green;
  if (entryCount >= 6 && entryCount <= 9) return Colors.yellow;
  if (entryCount >= 10) return Colors.red;
  return Colors.red.shade900;
}
