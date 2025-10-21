# DubHacks-25: Brain-Bloom Backend
A primitive server implementation for Brain-Bloom is implemented in `server.dart`. This server controls and monitors all fetch requests made to the Stripe API and the Gemini API from the frontend. Specifically, the server responds to these requests:
- (Gemini) POST/generateQuestion: Generates math question given provided user age.
- (Gemini) POST/checkAnswer: Checks correctness of submitted answer.
- (Stripe) POST/create-payment-intent: Purchases in-app tokens from provided payment method and amount.
- (Stripe) POST/redeem-prepaid-card: Redeems a prepaid card from provided token values.

Ensure that a `.env` file containing valid API keys is present in `/server/stripe_backend/` before running:
- `STRIPE_SECRET_KEY = your_key`
- `GEMINI_KEY = your_key`

Check Stripe API documentation for further details on dashboard settings, creating valid cardholders, and using Stripe test cards.

## How to Run
1. In your terminal, navigate to `/server/stripe_backend/`.
2. Run the command `run bin/server.dart/`.

The server should hosted locally on port 8080. Note that the frontend assumes the app runs on a separate device to the server but on the same WiFi network. Ensure that the frontend IPv4 addresses are correct. To find your local system's IPv4 address, run `ipconfig` in your console.
