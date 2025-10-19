import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TokenPurchasePage extends StatefulWidget {
  const TokenPurchasePage({super.key});

  @override
  State<TokenPurchasePage> createState() => _TokenPurchasePageState();
}

class _TokenPurchasePageState extends State<TokenPurchasePage> {
  int _tokensToBuy = 1;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handlePayment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Create PaymentIntent on backend
      final url = Uri.parse('http://10.0.83.32:8080/create-payment-intent');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': _tokensToBuy * 100}), // in cents
      );

      if (response.statusCode != 200) {
        setState(() {
          _errorMessage = 'Failed to create payment intent: ${response.body}';
          _isLoading = false;
        });
        return;
      }

      final data = jsonDecode(response.body);
      final clientSecret = data['clientSecret'];
      if (clientSecret == null) {
        setState(() {
          _errorMessage = 'Payment intent client secret missing in response.';
          _isLoading = false;
        });
        return;
      }

      // 2. Initialize payment sheet with Stripe
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Math Kids',
        ),
      );

      // 3. Present payment sheet to user
      await Stripe.instance.presentPaymentSheet();

      // 4. Payment successful!
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment successful! You bought $_tokensToBuy tokens.')),
      );

      Navigator.of(context).pop(_tokensToBuy); // Return tokens bought to previous screen
    } on StripeException catch (e) {
      setState(() {
        _errorMessage = 'Payment cancelled or failed: ${e.error.localizedMessage}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildError() {
    if (_errorMessage == null) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = _tokensToBuy;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Tokens'),
        backgroundColor: Color.fromARGB(255, 78, 101, 112),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Select number of tokens to buy:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            DropdownButton<int>(
              value: _tokensToBuy,
              items: [1, 5, 10, 20, 50, 100]
                  .map((e) => DropdownMenuItem(value: e, child: Text('$e tokens')))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _tokensToBuy = val;
                    _errorMessage = null;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Total cost: \$$totalPrice',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            _buildError(),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Icon(Icons.payment),
                label: Text(_isLoading ? 'Processing...' : 'Pay with Card'),
                onPressed: _isLoading ? null : _handlePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFA5D6A7),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
