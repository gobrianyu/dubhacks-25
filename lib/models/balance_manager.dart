class BalanceManager {
  int _tokenBalance = 0;
  int _weeklyAllowance = 0;
  int _availableToEarn = 0;

  int get tokenBalance => _tokenBalance;
  int get weeklyAllowance => _weeklyAllowance;
  int get availableToEarn => _availableToEarn;

  void setWeeklyAllowance(int amount) {
    _weeklyAllowance = amount;
    _availableToEarn = amount;
  }

  void addTokens(int amount) {
    _tokenBalance += amount;
    if (amount <= _availableToEarn) {
      _availableToEarn -= amount;
    }
  }

  bool subtractTokens(int amount) {
    if (amount > _tokenBalance) return false;
    _tokenBalance -= amount;
    return true;
  }

  Map<String, dynamic> toJson() => {
        'tokenBalance': _tokenBalance,
        'weeklyAllowance': _weeklyAllowance,
        'availableToEarn': _availableToEarn,
      };
}
