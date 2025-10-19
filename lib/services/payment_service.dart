import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Conditional imports for platform-specific code
import 'payment_service_mobile.dart'
    if (dart.library.html) 'payment_service_web.dart' as platform;

class PaymentService {
  static const String serverUrl = 'http://localhost:3000';

  // Token packages available for purchase
  static const List<Map<String, dynamic>> tokenPackages = [
    {'tokens': 10, 'price': 4.99, 'description': '10 Tokens'},
    {'tokens': 25, 'price': 9.99, 'description': '25 Tokens'},
    {'tokens': 50, 'price': 17.99, 'description': '50 Tokens'},
    {'tokens': 100, 'price': 29.99, 'description': '100 Tokens'},
  ];

  Future<void> initializePayment({
    required BuildContext context,
    required int tokenAmount,
    required double priceInDollars,
  }) async {
    try {
      // Create payment intent
      final paymentIntent = await _createPaymentIntent(priceInDollars);
      final clientSecret = paymentIntent['clientSecret'];

      // Use platform-specific implementation
      await platform.processPayment(
        context: context,
        clientSecret: clientSecret,
        tokenAmount: tokenAmount,
      );
    } catch (e) {
      debugPrint('Error initializing payment: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing payment: $e')),
        );
      }
    }
  }

  Future<Map<String, dynamic>> _createPaymentIntent(double amount) async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': (amount * 100).round()}), // Convert to cents
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create payment intent: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static void showTokenPurchaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Purchase Tokens',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: tokenPackages.length,
              itemBuilder: (context, index) {
                final package = tokenPackages[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF90CAF9),
                      child: Text(
                        '${package['tokens']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(package['description']),
                    subtitle: Text('\$${package['price'].toStringAsFixed(2)}'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        PaymentService().initializePayment(
                          context: context,
                          tokenAmount: package['tokens'],
                          priceInDollars: package['price'],
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF546E7A),
                      ),
                      child: const Text('Buy'),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
