import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
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
  bool isReviewMode = false;
  List<int> reviewedDays = [];

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  void loadReviewedDays() async {
    final dbHelper = DatabaseHelper();
    List<int> entryDays =
        await dbHelper.getDaysWithEntries(); // new helper function

    setState(() {
      reviewedDays = entryDays;
    });
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
            entriesPerDay: entriesPerDay,
            updateEntryCount: updateEntryCount,
            reviewedDays: reviewedDays,
            isReviewMode: isReviewMode,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text('Tap a day to log symptoms'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isReviewMode = !isReviewMode;
                if (isReviewMode) {
                  loadReviewedDays();
                } else {
                  reviewedDays.clear();
                }
              });
            },
            child: Text("Review Entries"),
          ),
        ],
      ),
    );
  }
}

class CalendarWidget extends StatelessWidget {
  final Map<int, int> entriesPerDay;
  final Function(int) updateEntryCount;
  final List<int> reviewedDays;
  final bool isReviewMode;

  const CalendarWidget({
    required this.entriesPerDay,
    required this.updateEntryCount,
    required this.reviewedDays,
    required this.isReviewMode,
  });

  // Define `getColorForEntries` Outside of `build()`
  Color getColorForEntries(
      int entryCount, int day, List<int> reviewedDays, bool isReviewMode) {
    if (isReviewMode && reviewedDays.contains(day)) return Color(0xFF4B0082);
    if (entryCount == 0) return Colors.grey;
    if (entryCount >= 1 && entryCount <= 5) return Colors.green;
    if (entryCount >= 6 && entryCount <= 9) return Colors.yellow;
    if (entryCount >= 10) return Colors.red;
    return Colors.red.shade900;
  }

  // Move `buildCalendarCell` OUTSIDE `build()` and define it properly
  Widget buildCalendarCell(int day, BuildContext context) {
    if (day > 30) return SizedBox(); // Prevent overflow

    Color color = getColorForEntries(
        entriesPerDay[day] ?? 0, day, reviewedDays, isReviewMode);
    Color numberColor = (isReviewMode && reviewedDays.contains(day))
        ? Color(0xFFE6E6FA)
        : Colors.black;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                EntryScreen(day: day, updateEntryCount: updateEntryCount),
          ),
        );
      },
      child: CircleAvatar(
        backgroundColor: color,
        child: Text('$day', style: TextStyle(color: numberColor)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int firstWeekday =
        DateTime(DateTime.now().year, DateTime.now().month, 1).weekday;

    return Column(
      children: [
        // Weekday labels
        Table(
          defaultColumnWidth: FixedColumnWidth(50),
          children: [
            TableRow(
              children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                  .map((day) => Padding(
                        padding: EdgeInsets.all(6),
                        child: Text(
                          day,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
        // Calendar rows
        Table(
          defaultColumnWidth: FixedColumnWidth(50),
          children: [
            TableRow(
              children: List.generate(7, (dayIndex) {
                if (dayIndex < firstWeekday - 1)
                  return SizedBox(); // Empty space before first day
                int actualDay = dayIndex - firstWeekday + 2;
                return actualDay <= 30
                    ? buildCalendarCell(actualDay, context)
                    : SizedBox();
              }),
            ),
            ...List.generate(4, (weekIndex) {
              return TableRow(
                children: List.generate(7, (dayIndex) {
                  int actualDay =
                      (weekIndex * 7 + dayIndex + (8 - firstWeekday));
                  actualDay = (weekIndex == 0)
                      ? (dayIndex - firstWeekday + 2)
                      : actualDay;
                  if (actualDay > 30) return SizedBox();
                  return buildCalendarCell(actualDay, context);
                }),
              );
            }),
          ],
        ),
      ],
    );
  }
}
