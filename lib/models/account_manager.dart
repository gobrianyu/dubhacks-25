import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  final Map<DateTime, List<String>> _streakHistory = {};

  TimeOfDay _curfewStart = const TimeOfDay(hour: 21, minute: 0); // 9 PM
  TimeOfDay _curfewEnd = const TimeOfDay(hour: 7, minute: 0);   // 7 AM

  TimeOfDay get curfewStart => _curfewStart;
  TimeOfDay get curfewEnd => _curfewEnd;

  final List<Map<String, dynamic>> _topUpHistory = [];

  List<Map<String, dynamic>> get topUpHistory => List.unmodifiable(_topUpHistory);

  int _childAge = 8;
  int _requiredQuizScore = 70; // percent
  int _numQuestionsPerQuiz = 5;

  int get childAge => _childAge;
  int get requiredQuizScore => _requiredQuizScore;
  int get numQuestionsPerQuiz => _numQuestionsPerQuiz;

  set childAge(int age) {
    if (age > 0) {
      _childAge = age;
      saveToPreferences(); // Auto-save
    }
  }

  set requiredQuizScore(int score) {
    if (score >= 0 && score <= 100) {
      _requiredQuizScore = score;
      saveToPreferences(); // Auto-save
    }
  }

  set numQuestionsPerQuiz(int num) {
    if (num > 0) {
      _numQuestionsPerQuiz = num;
      saveToPreferences(); // Auto-save
    }
  }


  void purchaseTokens(int amount) {
    _balance.addTokens(amount);
    logEvent('Parent purchased $amount tokens');
    _recordTopUp(amount);
    saveToPreferences(); // Auto-save after purchase
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
    saveToPreferences(); // Auto-save after setting curfew
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
        _tokensEarned = 0;

  // ----- Getters -----
  String get userId => _userId;
  String get username => _username;
  int get userLevel => _userLevel;
  BalanceManager get balance => _balance;
  int get tokensEarned => _tokensEarned;
  int get questionsAnswered => _questionsAnswered;
  List<String> get history => List.unmodifiable(_history);
  String get pw => _password;

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

  void recordQuestionResult({required bool correct}) {
    if (correct) _questionsAnswered++;
    if (_questionsAnswered % 20 == 0) {
      _userLevel++;
      logEvent('Level up! Now level $_userLevel');
    }
  }

  void earnTokens({required int amount}) {
    _tokensEarned += amount;
    _balance.earnTokens(amount);
    logEvent('Earned $amount tokens');
    saveToPreferences(); // Auto-save after earning tokens
  }

  Map<String, dynamic> toJson() => {
    'userId': _userId,
    'username': _username,
    'password': _password,
    'userLevel': _userLevel,
    'tokensEarned': _tokensEarned,
    'questionsAnswered': _questionsAnswered,
    'balance': _balance.toJson(),
    'history': _history,
    'streakHistory': _streakHistory.map((k, v) => MapEntry(k.toIso8601String(), v)),
    'curfewStart': '${_curfewStart.hour}:${_curfewStart.minute}',
    'curfewEnd': '${_curfewEnd.hour}:${_curfewEnd.minute}',
    'topUpHistory': _topUpHistory.map((entry) {
      return <String, dynamic>{
        'amount': entry['amount'],
        'timestamp': (entry['timestamp'] as DateTime).toIso8601String(),
        'transactionId': entry['transactionId'],
      };
    }).toList(),
    'childAge': _childAge,
    'requiredQuizScore': _requiredQuizScore,
    'numQuestionsPerQuiz': _numQuestionsPerQuiz,
  };

  // Save account data to SharedPreferences
  Future<void> saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(toJson());
    await prefs.setString('account_manager_data', jsonData);
  }

  // Load account data from SharedPreferences
  static Future<AccountManager?> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('account_manager_data');
    
    if (jsonString == null) return null;

    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      return AccountManager._fromJson(data);
    } catch (e) {
      debugPrint('Error loading account data: $e');
      return null;
    }
  }

  // Private constructor for deserialization
  AccountManager._fromJson(Map<String, dynamic> json)
      : _userId = json['userId'],
        _username = json['username'],
        _password = json['password'] ?? '1234',
        _userLevel = json['userLevel'] ?? 1,
        _balance = BalanceManager.fromJson(json['balance'] ?? {}),
        _history = List<String>.from(json['history'] ?? []),
        _questionsAnswered = json['questionsAnswered'] ?? 0,
        _tokensEarned = json['tokensEarned'] ?? 0,
        _childAge = json['childAge'] ?? 8,
        _requiredQuizScore = json['requiredQuizScore'] ?? 70,
        _numQuestionsPerQuiz = json['numQuestionsPerQuiz'] ?? 5 {
    
    // Load curfew times
    if (json['curfewStart'] != null) {
      final parts = json['curfewStart'].toString().split(':');
      _curfewStart = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    if (json['curfewEnd'] != null) {
      final parts = json['curfewEnd'].toString().split(':');
      _curfewEnd = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    // Load streak history
    if (json['streakHistory'] != null) {
      final Map<String, dynamic> streakData = json['streakHistory'];
      streakData.forEach((key, value) {
        _streakHistory[DateTime.parse(key)] = List<String>.from(value);
      });
    }

    // Load top-up history
    if (json['topUpHistory'] != null) {
      final List<dynamic> historyList = json['topUpHistory'];
      for (var entry in historyList) {
        _topUpHistory.add(<String, dynamic>{
          'amount': entry['amount'],
          'timestamp': DateTime.parse(entry['timestamp']),
          'transactionId': entry['transactionId'],
        });
      }
    }
  }
}
