import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe_mobile;
import 'token_manager.dart';

Future<void> processPayment({
  required BuildContext context,
  required String clientSecret,
  required int tokenAmount,
}) async {
  try {
    // Initialize payment sheet
    await stripe_mobile.Stripe.instance.initPaymentSheet(
      paymentSheetParameters: stripe_mobile.SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Math Kids',
        style: ThemeMode.light,
      ),
    );

    // Present payment sheet
    await stripe_mobile.Stripe.instance.presentPaymentSheet();

    // Add tokens to user's balance
    final tokenManager = TokenManager();
    await tokenManager.addTokens(tokenAmount, _getPriceForTokens(tokenAmount));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment successful! $tokenAmount tokens added.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    debugPrint('Error in mobile payment: $e');
    if (context.mounted && e.toString() != 'Canceled') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    }
  }
}

double _getPriceForTokens(int tokens) {
  // Helper to get price from token amount
  const prices = {
    10: 4.99,
    25: 9.99,
    50: 17.99,
    100: 29.99,
  };
  return prices[tokens] ?? 0.0;
}
