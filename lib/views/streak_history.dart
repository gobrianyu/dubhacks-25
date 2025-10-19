import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/account_manager.dart';
import 'package:table_calendar/table_calendar.dart';

class StreakHistoryPage extends StatefulWidget {
  final AccountManager? accountManager;

  const StreakHistoryPage({Key? key, this.accountManager}) : super(key: key);

  @override
  State<StreakHistoryPage> createState() => _StreakHistoryPageState();
}

class _StreakHistoryPageState extends State<StreakHistoryPage> {
  final nostalgicColors = const {
    'sky': Color(0xFFA9E4FC),
    'sun': Color(0xFFFFE082),
    'grass': Color(0xFFA5D6A7),
    'berry': Color(0xFFF48FB1),
    'cloud': Color(0xFFFFFFFF),
  };

  late final DateTime _firstDayOfMonth;
  late final DateTime _lastDayOfMonth;
  final Map<DateTime, List<String>> _events = {};

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    _firstDayOfMonth = DateTime(now.year, now.month, 1);
    _lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    if (widget.accountManager != null) {
      final streakMap = widget.accountManager!.streakHistory;
      _events.addAll(streakMap.map((key, value) =>
          MapEntry(DateTime(key.year, key.month, key.day), value)));
    }
  }

  int _calculateLongestStreak(Map<DateTime, List<String>> events) {
    if (events.isEmpty) return 0;
    final days = events.keys.toList()..sort((a, b) => a.compareTo(b));

    int longest = 1;
    int current = 1;

    for (int i = 1; i < days.length; i++) {
      if (days[i].difference(days[i - 1]).inDays == 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }
    return longest;
  }

  @override
  Widget build(BuildContext context) {
    final longestStreak = _calculateLongestStreak(_events);

    return Scaffold(
      backgroundColor: nostalgicColors['sky'],
      appBar: AppBar(
        title: const Text(
          'Streak History',
          style: TextStyle(
            fontFamily: 'ComicNeue',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: nostalgicColors['sun'],
        centerTitle: true,
        elevation: 3,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/background.png')),
        ),
        child: Column(
          children: [
            SizedBox(height: 10),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: nostalgicColors['grass'],
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                "🔥 Your longest streak this month is $longestStreak days! Keep up the great work!",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'ComicNeue',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  color: Color(0x99FFFFFF),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          '${DateFormat('MMMM').format(DateTime.now())} ${DateTime.now().year}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: nostalgicColors['berry'],
                            fontFamily: 'ComicNeue',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: TableCalendar(
                          headerVisible: false,
                          firstDay: _firstDayOfMonth,
                          lastDay: _lastDayOfMonth,
                          focusedDay: _focusedDay,
                          calendarFormat: CalendarFormat.month,
                          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            if (selectedDay.isBefore(_firstDayOfMonth) ||
                                selectedDay.isAfter(_lastDayOfMonth)) {
                              return;
                            }
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                          onPageChanged: (focusedDay) {
                            setState(() => _focusedDay = focusedDay);
                          },
                          eventLoader: (day) =>
                              _events[DateTime(day.year, day.month, day.day)] ?? [],
                          headerStyle: HeaderStyle(
                            titleTextStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: nostalgicColors['berry'],
                              fontFamily: 'ComicNeue',
                            ),
                            formatButtonVisible: false,
                            leftChevronIcon:
                                Icon(Icons.chevron_left, color: nostalgicColors['berry']),
                            rightChevronIcon:
                                Icon(Icons.chevron_right, color: nostalgicColors['berry']),
                          ),
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TextStyle(
                              color: nostalgicColors['berry'],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          calendarStyle: CalendarStyle(
                            defaultTextStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'ComicNeue',
                            ),
                            weekendTextStyle: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                            todayDecoration: BoxDecoration(
                              color: nostalgicColors['sun'],
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: nostalgicColors['berry'],
                              shape: BoxShape.circle,
                            ),
                            markerDecoration: BoxDecoration(
                              color: nostalgicColors['grass'],
                              shape: BoxShape.circle,
                            ),
                          ),
                          calendarBuilders: CalendarBuilders(
                            markerBuilder: (context, day, events) {
                              if (events.isNotEmpty) {
                                return Positioned(
                                  bottom: 6,
                                  right: 6,
                                  child: Icon(
                                    Icons.star,
                                    color: nostalgicColors['grass'],
                                    size: 14,
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
           Expanded(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // Shadow color with transparency
                    blurRadius: 12.0, // Adjust for desired blur (higher for more elevation)
                    spreadRadius: 2.0, // Adjust for desired spread (smaller for subtle shadow)
                    offset: const Offset(0, 6), // x and y offset of the shadow (y for elevation)
                  ),
                ],
                color: nostalgicColors['cloud'],
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Event History',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: nostalgicColors['berry'],
                        fontFamily: 'ComicNeue',
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Expanded around ListView to give it bounded height
                  Expanded(
                    child: (widget.accountManager == null ||
                            widget.accountManager!.history.isEmpty)
                        ? const Center(
                            child: Text(
                              'No history available.',
                              style: TextStyle(fontFamily: 'ComicNeue'),
                            ),
                          )
                        : ListView.builder(
                          itemCount: widget.accountManager!.history.length,
                          padding: const EdgeInsets.all(8),
                          itemBuilder: (context, index) {
                            final item = widget.accountManager!.history[index];
                            return Card(
                              color: nostalgicColors['sun'],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: Icon(Icons.check_circle,
                                    color: nostalgicColors['grass']),
                                title: Text(
                                  item,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600
                                  )
                                ),
                              ),
                            );
                          },
                        ),
                  ),
                ],
              ),
            ),
          ),

          ],
        ),
      ),
    );
  }
}
