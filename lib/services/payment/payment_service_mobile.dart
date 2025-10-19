import 'dart:convert';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'payment_service_base.dart';

class MobilePaymentService implements PaymentService {
  @override
  Future<bool> pay({required int tokenCount}) async {
    final backendBase = dotenv.env['BACKEND_BASE_URL'] ?? 'http://10.0.2.2:8080';
    final url = Uri.parse('$backendBase/create-payment-intent');

    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': tokenCount * 100}), // cents
    );

    if (resp.statusCode != 200) {
      return false;
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final clientSecret = data['clientSecret'] as String?;
    if (clientSecret == null) {
      return false;
    }

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Math Kids',
      ),
    );

    try {
      await Stripe.instance.presentPaymentSheet();
      return true;
    } catch (e) {
      return false;
    }
  }
}

PaymentService createPlatformPaymentService() => MobilePaymentService();
