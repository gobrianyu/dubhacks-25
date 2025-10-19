import 'package:flutter/material.dart';

import 'balance_manager.dart';

class AccountManager {
  final String _userId;
  String _username;
  int _userLevel;
  final BalanceManager _balance;
  final List<String> _history;
  int _questionsAnswered;
  int _tokensEarned;
  String _password;
  int _numQuestions;

  final Map<DateTime, List<String>> _streakHistory = {};

  TimeOfDay _curfewStart = const TimeOfDay(hour: 21, minute: 0); // 9 PM
  TimeOfDay _curfewEnd = const TimeOfDay(hour: 7, minute: 0);   // 7 AM

  TimeOfDay get curfewStart => _curfewStart;
  TimeOfDay get curfewEnd => _curfewEnd;

  final List<Map<String, dynamic>> _topUpHistory = [];

  List<Map<String, dynamic>> get topUpHistory => List.unmodifiable(_topUpHistory);

  void purchaseTokens(int amount) {
    _balance.addTokens(amount);
    logEvent('Parent purchased $amount tokens');
    _recordTopUp(amount);
  }

  void _recordTopUp(int amount) {
    final now = DateTime.now();
    _topUpHistory.add({
      'amount': amount,
      'timestamp': now,
      'transactionId': 'TXN${_topUpHistory.length + 1}',
    });
  }

  void setCurfew(TimeOfDay start, TimeOfDay end) {
    _curfewStart = start;
    _curfewEnd = end;
  }


  AccountManager({
    required String userId,
    required String username,
    required String password
  })  : _userId = userId,
        _username = username,
        _password = password,
        _userLevel = 1,
        _balance = BalanceManager(),
        _history = [],
        _questionsAnswered = 0,
        _tokensEarned = 0,
        _numQuestions = 5;

  // ----- Getters -----
  String get userId => _userId;
  String get username => _username;
  int get userLevel => _userLevel;
  BalanceManager get balance => _balance;
  int get tokensEarned => _tokensEarned;
  int get questionsAnswered => _questionsAnswered;
  List<String> get history => List.unmodifiable(_history);
  String get pw => _password;
  int get numQuestions => _numQuestions;

  /// Returns streak history within last 2 months (from today)
  Map<DateTime, List<String>> get streakHistory {
    final twoMonthsAgo = DateTime.now().subtract(const Duration(days: 60));
    final filtered = <DateTime, List<String>>{};
    _streakHistory.forEach((date, events) {
      if (date.isAfter(twoMonthsAgo)) {
        filtered[date] = List.unmodifiable(events);
      }
    });
    return filtered;
  }

  // ----- Setters -----
  set username(String name) {
    if (name.isNotEmpty) _username = name;
  }

  set questionAmount(int num) {
    _numQuestions = num;
  }

  set newPassword(String pw) {
    _password = pw;
  }

  void addStreakEvent(DateTime date, String event) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    _streakHistory.putIfAbsent(normalizedDate, () => []).add(event);
  }

  // ----- Behavior -----

  /// Logs generic event to _history and _streakHistory keyed by current date (date only)
  void logEvent(String event) {
    _history.add(event);
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    _streakHistory.putIfAbsent(today, () => []);
    _streakHistory[today]!.add(event);
    _cleanOldStreakEntries();
  }

  /// Removes streak history entries older than 2 months
  void _cleanOldStreakEntries() {
    final expiration = DateTime.now().subtract(const Duration(days: 60));
    _streakHistory.removeWhere((date, _) => date.isBefore(expiration));
  }

  void recordQuestionResult({required bool correct, int reward = 5}) {
    _questionsAnswered++;
    if (correct) {
      _tokensEarned += reward;
      _balance.addTokens(reward);
      logEvent('Earned $reward tokens');
    }
    if (_questionsAnswered % 20 == 0) {
      _userLevel++;
      logEvent('Level up! Now level $_userLevel');
    }
  }

  Map<String, dynamic> toJson() => {
        'userId': _userId,
        'username': _username,
        'userLevel': _userLevel,
        'tokensEarned': _tokensEarned,
        'balance': _balance.toJson(),
        'history': _history,
        'streakHistory': streakHistory.map((k, v) => MapEntry(k.toIso8601String(), v)),
      };
}
