class BalanceManager {
  int _tokenBalance = 0;              // Earned tokens usable now
  int _unearnedBalance = 0;           // Tokens bought but unearned yet
  int _weeklyAllowance = 0;
  int _maxEarnablePerDay = 10;        // New: Max tokens child can earn per day

  // Keeps track of token top-up history with timestamps for expiry.
  final List<TopUpEntry> _topUpEntries = [];

  int get tokenBalance => _tokenBalance;
  int get unearnedBalance => _unearnedBalance;
  int get weeklyAllowance => _weeklyAllowance;
  int get maxEarnablePerDay => _maxEarnablePerDay;

  void setMaxEarnablePerDay(int amount) {
    _maxEarnablePerDay = amount;
  }

  // Adds tokens as unearned; they must be earned through quizzes eventually.
  void addTokens(int amount) {
    _unearnedBalance += amount;
    final now = DateTime.now();
    _topUpEntries.add(TopUpEntry(amount: amount, timestamp: now));
  }

  // Moves tokens from unearned to permanent balance when quizzes are completed.
  bool earnTokens(int amount) {
    _removeExpiredTokens();
    if (amount > _unearnedBalance) return false;

    _unearnedBalance -= amount;
    _tokenBalance += amount;
    return true;
  }

  // Removes tokens older than 30 days from unearned balance and entries
  void _removeExpiredTokens() {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    while (_topUpEntries.isNotEmpty && _topUpEntries.first.timestamp.isBefore(cutoff)) {
      final expiredEntry = _topUpEntries.removeAt(0);
      _unearnedBalance -= expiredEntry.amount;
      if (_unearnedBalance < 0) _unearnedBalance = 0;
    }
  }

  bool subtractTokens(int amount) {
    if (amount > _tokenBalance) return false;
    _tokenBalance -= amount;
    return true;
  }

  List<TopUpEntry> getTopUpHistory() => List.unmodifiable(_topUpEntries);

  Map<String, dynamic> toJson() => {
        'tokenBalance': _tokenBalance,
        'unearnedBalance': _unearnedBalance,
        'weeklyAllowance': _weeklyAllowance,
        'maxEarnablePerDay': _maxEarnablePerDay,
        'topUpEntries': _topUpEntries.map((e) => e.toJson()).toList(),
      };
}

class TopUpEntry {
  final int amount;
  final DateTime timestamp;

  TopUpEntry({required this.amount, required this.timestamp});

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'timestamp': timestamp.toIso8601String(),
      };
}
