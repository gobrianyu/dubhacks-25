import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;
import 'dart:html' as html;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'payment_service_base.dart';

class WebPaymentService implements PaymentService {
  @override
  Future<void> pay({required int tokenCount}) async {
    final publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'];
    if (publishableKey == null || publishableKey.isEmpty) {
      throw Exception('Missing STRIPE_PUBLISHABLE_KEY for web');
    }

  final backendBase = dotenv.env['BACKEND_BASE_URL'] ?? 'http://localhost:3000';
  final url = Uri.parse('$backendBase/create-checkout-session');
  final origin = html.window.location.origin;

    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': tokenCount * 100,
        // We ask backend to inject the {CHECKOUT_SESSION_ID} into success_url so we can validate on return
        'success_url': origin,
        'cancel_url': origin,
        // Persist purchase info in Stripe metadata so we can read it after redirect
        'metadata': {
          'tokens': tokenCount,
        },
      }),
    );

    if (resp.statusCode != 200) {
      throw Exception('Failed to create Checkout Session: ${resp.statusCode} ${resp.body}');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final sessionId = data['id'] as String?;
    if (sessionId == null) {
      throw Exception('Checkout session id missing from backend response');
    }

    // Call JS helper to redirect to Checkout
    js.context.callMethod('stripeRedirectToCheckout', [publishableKey, sessionId]);
  }
}

PaymentService createPlatformPaymentService() => WebPaymentService();
