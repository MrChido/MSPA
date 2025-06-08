import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'dart:convert';

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
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _wakeTimeController = TextEditingController();
  final TextEditingController _sleepTimeController = TextEditingController();

  String convertToMilitaryTime(String timeInput) {
    timeInput = timeInput.trim().toLowerCase(); //normalize the case usage
    RegExp regExp = RegExp(r'(\d{1,2})[:.](\d{2})\s*(am|pm)?');
    Match? match = regExp.firstMatch(timeInput);

    if (match != null) {
      int hour = int.parse(match.group(1)!);
      int minutes = int.parse(match.group(2)!);
      String? period = match.group(3);

      if (period == "pm" && hour != 12) {
        hour += 12; //add 12 hours to the input
      } else if (period == "am" && hour == 12) {
        hour = 0; //convert 12 AM to 00
      }

      return "${hour.toString().padLeft(2, '0')}${minutes.toString().padLeft(2, '0')}";
    }

    return "Invalid Format";
  }

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
            // SwitchListTile(
            //   title: Text('Pain'),
            //   value: pain,
            //   onChanged: (bool newValue) {
            //     setState(() {
            //       pain = newValue;
            //     });
            //   },
            // ),
            Text('Pain Severity:'),
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
            TextField(
                controller: _wakeTimeController,
                decoration: InputDecoration(hintText: '7:00AM')),
            Text('Bed Time'),
            TextField(
                controller: _sleepTimeController,
                decoration: InputDecoration(hintText: '10.00PM')),
            Text('Blood Sugar:'),
            TextField(
              controller: _bsugarsController, //tracks the input
              decoration: InputDecoration(hintText: "Enter single readings"),
            ),
            Text('Meals/Medications:'),
            TextField(
              controller: _mnmController, //tracks the input
              decoration: InputDecoration(
                  hintText: "Enter Meals and Medications taken"),
            ),

            Text('Activities:'),
            TextField(
              controller: _activitiesController, //tracks the input
              decoration: InputDecoration(hintText: "Enter your activities"),
            ),

            Text('Symptoms:'),
            TextField(
              controller: _symptomsController, //tracks symptom input
              decoration:
                  InputDecoration(hintText: 'Enter your current sympoms'),
            ),

            //Save Entry Button
            ElevatedButton(
              onPressed: () async {
                String bloodSugarInput =
                    _bsugarsController.text.trim(); //get user input
                //int bloodSugarValue = int.tryParse(bloodSugarInput) ?? 0;

                List<String> mnm = _mnmController.text
                    .trim()
                    .split(",")
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
                List<String> activities = _activitiesController.text
                    .trim()
                    .split(",")
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
                List<String> symptoms = _symptomsController.text
                    .trim()
                    .split(",")
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();

                String mnmInput = jsonEncode(mnm);
                String activitiesInput = jsonEncode(activities);
                String symptomsInput = jsonEncode(symptoms);
                String wakeTimeMilitary =
                    convertToMilitaryTime(_wakeTimeController.text);
                String sleepTimeMilitary =
                    convertToMilitaryTime(_sleepTimeController.text);

                await DatabaseHelper().insertEntry(
                    widget.day,
                    severity.round(),
                    fatigue,
                    pain,
                    bloodSugarInput,
                    mnmInput,
                    activitiesInput,
                    symptomsInput,
                    int.parse(wakeTimeMilitary),
                    int.parse(sleepTimeMilitary));
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
