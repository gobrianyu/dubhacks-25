# DubHacks-25: Brain-Bloom
## Overview
Brain-Bloom is an innovative mobile app that reimagines how children earn and manage their allowances, turning everyday finances into an opportunity for learning and growth. At its core, Brain-Bloom is an allowance app that lets parents set up a digital allowance system for their kids. These can be earned through completing math challenges tailored to their skill level. Parents have full control over the difficulty and frequency of the tasks, as well as additional features through an extensive parental controls implementation.  

This app is developed in Flutter and Dart, tested for Android, and compilable in iOS, Windows, and as a web app. Brain-Bloom is developed by Brian Yu, Sydney Vo, Tian-Jiao Song, Aaron Quashnock for DubHacks 2025.

Title Track: Grow (Advocate)
Side Tracks: MLH Best Use of Gemini API, VISA

###Gallery
<p float="left">
  <img src="https://github.com/user-attachments/assets/32eb5d99-7e8d-43ef-bb0d-d81f78aaf783" width="100">
  <img src="https://github.com/user-attachments/assets/eed514b4-7dca-4a30-9d59-2a16b4ef05e6" width="100">
  <img src="https://github.com/user-attachments/assets/893943cd-0c13-490f-8752-6e2306908de6" width="100">
  <img src="https://github.com/user-attachments/assets/4e69bc56-ade0-4170-89d2-5e6f9af7434b" width="100">
  <img src="https://github.com/user-attachments/assets/28347f32-1ac7-452a-a222-ce857fe46d62" width="100">
  <img src="https://github.com/user-attachments/assets/7fcfdd41-cf1d-4a3a-aec4-0e7f8b702160" width="100">
  <img src="https://github.com/user-attachments/assets/c0a7d54a-8879-466f-b49c-46663a3741d7" width="100">
</p>

## How It Works

### Setup
No packages or releases are available currently. Interested parties may fork a copy of this repository or download locally. Ensure all relevant Flutter development tools are installed (see guide [here](https://docs.flutter.dev/get-started)).
1. Open this repository in an IDE and navigate to `/server/stripe-backend/` in the terminal.
2. In the terminal, start the backend server with `run bin/server.dart/`.
3. Navigate to `/lib/main.dart` from the root and either run `main.dart` or enter `flutter build x` in the terminal (replace x with your desired build endpoint).
To build as an `.apk` on your Android device, ensure that your device is connected to your environment and that USB Debugging is enabled under Developer Settings.

### Features
- Home screen: Displays user's level and redeemable balance and allows users to navigate to all other features of the app.
- Parental controls: Parental controls are locked behind a password manager. Controls include setting quiz parameters (difficulty, length), monetary controls (topping up, daily limits), and setting curfews.
- Top-up: Parents can load allowances into the app for the user and view a transactions history. Credit/Debit top-up implementation is managed via a Stripe API. Refer to Stripe documentation for further details. Use a Stripe test card in sandbox environments.
- Curfews: Parents can set curfew start and end times to discourage children from accessing the app past bedtime.
- Streaks: History of the child's daily progress is saved and can be viewed.
- Quiz: Daily math quizzes tailored to the child's age and skill level are generated at random. Quiz questions are generated and marked for correctness by Gemini. Upon completion, if the user scores above a threshold score set by parents, they may earn a portion of the week's/month's allowance for the day.

## Reporting Bugs
To report a bug, navigate to the GitHub Issues page, create a new issue, and include:
- Description of the bug
- Steps to reproduce the issue
- Expected vs. actual behaviour
- Screenshots (if applicable)
- System environment details
Please note that this app was developed as a rough sketch/proof-of-concept for hackathon submission. This is not a shippable product.

### Further Readings
- [Frontend README](https://github.com/gobrianyu/dubhacks-25/blob/main/lib/README.md): Frontend developer guidelines and project structure can be found here.
- [Backend README](https://github.com/gobrianyu/dubhacks-25/blob/main/server/stripe_backend/README.md): Developer guidelines for server setup can be found here.
