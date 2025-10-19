import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TokenTransaction {
  final String id;
  final int tokens;
  final double price;
  final DateTime date;
  final String status; // 'completed', 'pending', 'failed'

  TokenTransaction({
    required this.id,
    required this.tokens,
    required this.price,
    required this.date,
    this.status = 'completed',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tokens': tokens,
        'price': price,
        'date': date.toIso8601String(),
        'status': status,
      };

  factory TokenTransaction.fromJson(Map<String, dynamic> json) =>
      TokenTransaction(
        id: json['id'],
        tokens: json['tokens'],
        price: json['price'],
        date: DateTime.parse(json['date']),
        status: json['status'],
      );
}

class TokenManager extends ChangeNotifier {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  int _tokenBalance = 0;
  List<TokenTransaction> _transactions = [];

  int get tokenBalance => _tokenBalance;
  List<TokenTransaction> get transactions => List.unmodifiable(_transactions);

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _tokenBalance = prefs.getInt('token_balance') ?? 0;
    
    final transactionsJson = prefs.getString('transactions');
    if (transactionsJson != null) {
      final List<dynamic> decoded = jsonDecode(transactionsJson);
      _transactions = decoded
          .map((json) => TokenTransaction.fromJson(json))
          .toList();
    }
    
    notifyListeners();
  }

  Future<void> addTokens(int tokens, double price) async {
    final transaction = TokenTransaction(
      id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      tokens: tokens,
      price: price,
      date: DateTime.now(),
      status: 'completed',
    );

    _tokenBalance += tokens;
    _transactions.insert(0, transaction);

    await _saveToPreferences();
    notifyListeners();
    
    debugPrint('✅ Added $tokens tokens. New balance: $_tokenBalance');
  }

  Future<void> deductTokens(int tokens) async {
    if (_tokenBalance >= tokens) {
      _tokenBalance -= tokens;
      await _saveToPreferences();
      notifyListeners();
      debugPrint('Deducted $tokens tokens. New balance: $_tokenBalance');
    } else {
      throw Exception('Insufficient tokens');
    }
  }

  Future<void> _saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('token_balance', _tokenBalance);
    
    final transactionsJson = jsonEncode(
      _transactions.map((t) => t.toJson()).toList(),
    );
    await prefs.setString('transactions', transactionsJson);
  }

  Future<void> clearHistory() async {
    _transactions.clear();
    await _saveToPreferences();
    notifyListeners();
  }

  Future<void> resetAll() async {
    _tokenBalance = 0;
    _transactions.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
