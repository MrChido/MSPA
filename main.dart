import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:convert';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daily Journal')),
      body: Column(
        children: [
          CalendarWidget(
              entriesPerDay: entriesPerDay, updateEntryCount: updateEntryCount),
          Expanded(child: Center(child: Text('Tap a day to log symptoms'))),
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

class EntryScreen extends StatefulWidget {
  final int day;
  final Function(int) updateEntryCount;
  const EntryScreen({required this.day, required this.updateEntryCount});

  @override
  _EntryScreenState createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  bool fatigue = false;
  bool pain = false;
  double severity = 4.0;
  final TextEditingController _bsugarsController = TextEditingController();
  List<String> mnm = [];
  List<String> activities = [];
  final TextEditingController _mnmController = TextEditingController();
  final TextEditingController _activitiesController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Entry for Day ${widget.day}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Toggle Symptoms:'),
            SwitchListTile(
              title: Text('Fatigue'),
              value: fatigue,
              onChanged: (bool newValue) {
                setState(() {
                  fatigue = newValue;
                });
              },
            ),
            SwitchListTile(
              title: Text('Pain'),
              value: pain,
              onChanged: (bool newValue) {
                setState(() {
                  pain = newValue;
                });
              },
            ),
            Text('Symptom Severity:'),
            Slider(
              value: severity,
              min: 0,
              max: 10,
              divisions: 10,
              label: severity.round().toString(), //shows current value
              onChanged: (double newValue) {
                setState(() {
                  severity = newValue;
                });
              },
            ),
            Text('Wake Time:'),
            TextField(decoration: InputDecoration(hintText: '7:00AM')),
            Text('Bed Time'),
            TextField(decoration: InputDecoration(hintText: '10.00PM')),
            Text('Blood Sugar:'),
            TextField(
              controller: _bsugarsController, //tracks the input
              decoration: InputDecoration(hintText: "Enter single readings"),
            ),
            Text('Meals/Medications:'),
            TextField(
              controller: _mnmController, //tracks the input
              maxLines: 2,
              decoration: InputDecoration(
                  hintText: "Enter Meals and Medications taken"),
            ),

            Text('Activities:'),
            TextField(
              controller: _activitiesController, //tracks the input
              maxLines: 2,
              decoration: InputDecoration(hintText: "Enter your activities"),
            ),

            //Save Entry Button
            ElevatedButton(
              onPressed: () async {
                String bloodSugarInput =
                    _bsugarsController.text.trim(); //get user input

                List<String> mnm = _mnmController.text.trim().split(",");
                List<String> activities =
                    _activitiesController.text.trim().split(",");

                String mnmInput = mnm.isNotEmpty ? jsonEncode(mnm) : '[]';
                String activitiesInput =
                    activities.isNotEmpty ? jsonEncode(activities) : '[]';

                await DatabaseHelper().insertEntry(
                  widget.day,
                  severity.round(),
                  fatigue,
                  pain,
                  bloodSugarInput,
                  mnm,
                  activities,
                );
                print("mnm before inserting: $mnmInput");
                print("activities before inserting: $activitiesInput");

                widget.updateEntryCount(widget
                    .day); // Calls the function passed from CalendarScreen
                Navigator.pop(context);
              },
              child: Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
