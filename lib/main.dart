import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'views/home_page.dart';
import 'views/go_to_sleep.dart';
import 'models/account_manager.dart';

void main() {
  final accountManager = AccountManager(userId: 'user_001', username: 'Math Hero');

  accountManager.purchaseTokens(50);

  final year = DateTime.now().year;
  const month = 10; // October

  final List<int> demoDays = [15, 14, 13, 11, 10, 8, 7, 5, 4, 3, 2, 1];
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

    // Handles overnight curfews
    return start.hour > end.hour ? (afterStart || beforeEnd) : (afterStart && beforeEnd);
  }

  @override
  Widget build(BuildContext context) {
    final curfew = _isCurfewActive();
    return MaterialApp(
      title: 'Math Kids',
      home: curfew
          ? GoToSleepPage(accountManager: accountManager)
          : HomePage(accountManager: accountManager),
      debugShowCheckedModeBanner: false,
    );
  }
}