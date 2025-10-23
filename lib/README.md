# DubHacks-25: Brain-Bloom Frontend
This is the frontend for Brain-Bloom, built with Dart and Flutter, utilising Gemini AI API and Stripe's payment API.

## Prerequisites
Before beginning, ensure you have the most recent [Flutter](https://docs.flutter.dev/get-started) installation on your system.

## Setup
1. Fork or download this repository.
2. Navigate to repo head `./dubhacks-25`.
3. Install dependencies

    ```bash
    flutter pub get
    ```
4. Start the backend server (see more [here](https://github.com/gobrianyu/dubhacks-25/blob/main/server/stripe_backend/README.md)).
5. Build the app (ensure connection to an android phone with USB debugging enabled if building and running through extensions)

   ```bash
   flutter build apk
   ```

### Debugging Common Issues
- API keys must be set in a `.env` variable for the following:
  ```bash
  STRIPE_SECRET_KEY = your_key
  GEMINI_KEY = your_key
  ```
- Ensure the correct IPv4 address to your server is set in the relevant files:

      lib/views/quiz_page.dart
      lib/views/redeem_card_page.dart
      lib/views/token_purchase_page.dart

### Folder Structure

```
lib/
├── models/                    # Custom class objects
│  ├── account_manager.dart           #
│  ├── balance_maanger.dart           #
├── views/                     # Custom flutter screens
│  ├── curfew_settings.dart           # Curfew settings screen component
│  ├── go_to_sleep.dart               # Curfew lock screen component
│  ├── help_page.dart                 # Help page screen component
│  ├── home_page.dart                 # Main home-page screen component
│  ├── parental_controls_page.dart    # Main screen component
│  ├── quiz_page.dart                 # Quiz screen component
│  ├── quiz_settings.dart             # Quiz settings screen component
│  ├── redeem_card_page.dart          # Token redeem screen component
│  ├── streak_history.dart            # Streak history screen component
│  ├── token_purchase_page.dart       # Token purchase screen component
│  ├── top_up.dart                    # Top-up screen component
└── main.dart                 # Entry point
```
