
import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;
import 'dart:html' as html;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'payment_service_base.dart';

Future<bool> showStripeCardForm(String publishableKey, String clientSecret) async {
  final completer = Completer<bool>();

  html.document.body!.appendHtml('''
    <div id="card-element" style="margin:24px 0;"></div>
    <button id="pay-button" style="padding:12px 24px;font-size:18px;">Pay</button>
  ''');

  js.context['onStripePaymentResult'] = (error, paymentIntent) {
    if (error != null) {
      completer.complete(false);
    } else {
      completer.complete(true);
    }
    html.document.getElementById('card-element')?.remove();
    html.document.getElementById('pay-button')?.remove();
  };

  js.context.callMethod('stripePayWithCard', [publishableKey, clientSecret, 'onStripePaymentResult']);
  return completer.future;
}

class WebPaymentService implements PaymentService {
  @override
  Future<bool> pay({required int tokenCount}) async {
    final publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'];
    final backendBase = dotenv.env['BACKEND_BASE_URL'] ?? 'http://localhost:3000';

    // 1. Create Payment Intent on backend
    final resp = await http.post(
      Uri.parse('$backendBase/create-payment-intent'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': tokenCount * 100}),
    );
    if (resp.statusCode != 200) throw Exception('Failed to create Payment Intent');
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final clientSecret = data['clientSecret'] as String;

    // 2. Show Stripe Elements card form and confirm payment
    final success = await showStripeCardForm(publishableKey!, clientSecret);
    return success;
  }
}

PaymentService createPlatformPaymentService() => WebPaymentService();
