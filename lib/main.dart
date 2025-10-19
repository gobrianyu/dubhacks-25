import 'package:flutter/material.dart';
import 'views/home_page.dart';
import 'views/go_to_sleep.dart';
import 'models/account_manager.dart';

void main() {
  final accountManager = AccountManager(userId: 'user_001', username: 'Math Hero');

  accountManager.purchaseTokens(50);
  accountManager.recordQuestionResult(correct: true, reward: 5);

  final year = DateTime.now().year;
  final month = 10; // October

  final List<int> demoDays = [1, 2, 3, 4, 5, 7, 8, 10, 11, 13, 14, 15, 17, 18];
  for (final day in demoDays) {
    final date = DateTime(year, month, day);

    accountManager.logEvent('Completed quiz on $month/$day');
    accountManager.addStreakEvent(date, 'Completed quiz');
  }

  runApp(MathKidsApp(accountManager: accountManager));
}

class MathKidsApp extends StatelessWidget {
  final AccountManager accountManager;

  const MathKidsApp({super.key, required this.accountManager});

  bool _isCurfewActive() {
    final now = TimeOfDay.now();
    final start = accountManager.curfewStart;
    final end = accountManager.curfewEnd;

    bool afterStart = now.hour > start.hour ||
        (now.hour == start.hour && now.minute >= start.minute);
    bool beforeEnd = now.hour < end.hour ||
        (now.hour == end.hour && now.minute <= end.minute);

    // Handles overnight curfews like 9 PM to 7 AM
    return start.hour > end.hour ? (afterStart || beforeEnd) : (afterStart && beforeEnd);
  }

  @override
  Widget build(BuildContext context) {
    final curfew = _isCurfewActive();
    return MaterialApp(
      title: 'Math Kids',
      home: curfew
          ? const GoToSleepPage()
          : HomePage(accountManager: accountManager),
      debugShowCheckedModeBanner: false,
    );
  }
}