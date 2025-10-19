# Data Persistence Fix

## Problem
Settings and tokens were not being saved when returning from the payment screen, especially on web platforms. This was caused by:

1. **No Data Persistence**: All data was stored only in memory
2. **Web Page Reload**: On web, Stripe Checkout redirects to a new URL, causing the Flutter app to reload and lose all state
3. **Lost Settings**: Quiz settings, token balances, and other configurations were lost after the redirect

## Solution Implemented

### 1. Added SharedPreferences Integration
- Imported `shared_preferences` and `dart:convert` packages to `AccountManager`
- Added automatic serialization/deserialization methods

### 2. Persistence Methods in AccountManager

#### `saveToPreferences()`
```dart
Future<void> saveToPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonData = jsonEncode(toJson());
  await prefs.setString('account_manager_data', jsonData);
}
```
Saves all account data to persistent storage.

#### `loadFromPreferences()`
```dart
static Future<AccountManager?> loadFromPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString('account_manager_data');
  // ... deserializes and returns AccountManager
}
```
Loads saved account data on app startup.

### 3. Auto-Save Triggers
The following actions now automatically save data:

- **Quiz Settings Changes**
  - `childAge` setter
  - `requiredQuizScore` setter
  - `numQuestionsPerQuiz` setter

- **Token Operations**
  - `purchaseTokens()` - when tokens are purchased
  - `earnTokens()` - when tokens are earned through quizzes

- **Curfew Settings**
  - `setCurfew()` - when curfew times are updated

### 4. Updated main.dart
The app now:
1. Attempts to load saved data on startup
2. Falls back to creating demo data if no saved data exists
3. Saves initial demo data for future sessions

```dart
AccountManager? accountManager = await AccountManager.loadFromPreferences();

if (accountManager == null) {
  // Create new account with demo data
  accountManager = AccountManager(userId: 'user_001', username: 'Math Hero', password: '1234');
  // ... setup demo data
  await accountManager.saveToPreferences();
}
```

### 5. Enhanced BalanceManager
- Added factory constructor `BalanceManager.fromJson()` for deserialization
- Added default constructor for normal instantiation
- Made serialization/deserialization work with TopUpEntry history

## What Gets Saved

All the following data persists across app restarts:
- ✅ User credentials (userId, username, password)
- ✅ Token balances (earned and unearned)
- ✅ Quiz settings (age, required score, questions per quiz)
- ✅ Curfew settings (start and end times)
- ✅ User level and progress
- ✅ Streak history (last 60 days)
- ✅ Top-up transaction history
- ✅ Max earnable tokens per day
- ✅ Event history

## How It Works on Web

1. User makes settings changes → **Auto-saved to browser localStorage**
2. User clicks "Buy Tokens" → **Current state is saved**
3. Stripe redirects away → **Page reloads**
4. App restarts → **Loads saved state from localStorage**
5. Payment completes → **Tokens are added and saved**
6. User returns to app → **All settings and tokens are preserved** ✅

## Testing the Fix

To verify the fix works:

1. Change quiz settings
2. Purchase tokens
3. Close and reopen the app (or simulate payment redirect)
4. Verify all settings and balances are preserved

## Technical Notes

- Uses SharedPreferences which maps to:
  - **Web**: browser localStorage
  - **iOS/Android**: native key-value storage
  - **Desktop**: platform-specific storage
  
- All saves are asynchronous but non-blocking
- JSON serialization ensures compatibility across platforms
- Failed loads gracefully fall back to creating new accounts
