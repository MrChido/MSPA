import 'package:flutter/material.dart';

void main() {
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

class CalendarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daily Journal')),
      body: Column(
        children: [
          CalendarWidget(),
          Expanded(child: Center(child: Text('Tap a day to log symptoms'))),
        ],
      ),
    );
  }
}

class CalendarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Placeholder calendar UI with hardcoded data
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(30, (index) {
          int score = (index % 13); //simulated score
          Color color = getColorForScore(score);
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EntryScreen(day: index + 1)),
              );
            },
            child: CircleAvatar(
              backgroundColor: color,
              child: score >= 10
                  ? Icon(Icons.whatshot, color: Colors.white)
                  : Text('${index + 1}'),
            ),
          );
        }),
      ),
    );
  }
}

Color getColorForScore(int score) {
  if (score <= 3) return Colors.green;
  if (score <= 6) return Colors.yellow;
  if (score <= 9) return Colors.red;
  return Colors.red.shade900;
}

class EntryScreen extends StatefulWidget {
  final int day;
  EntryScreen({required this.day});

  @override
  _EntryScreenState createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  bool fatigue = false;
  bool pain = false;
  double severity = 4.0;
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
              decoration: InputDecoration(hintText: "Enter mulitple readings"),
            ),
            Text('Meals/Medications:'),
            TextField(maxLines: 2),
            Text('Daily Activities:'),
            TextField(maxLines: 2),
          ],
        ),
      ),
    );
  }
}
