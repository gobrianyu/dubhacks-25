import 'package:flutter/material.dart';
import '../services/payment_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

import '../models/account_manager.dart';

class TokenPurchasePage extends StatefulWidget {
  final AccountManager? accountManager;
  const TokenPurchasePage({super.key, this.accountManager});

  @override
  State<TokenPurchasePage> createState() => _TokenPurchasePageState();
}

class _TokenPurchasePageState extends State<TokenPurchasePage> {
  int _tokensToBuy = 1;
  bool _isLoading = false;
  String? _errorMessage;
  final _payment = createPaymentService();

  @override
  void initState() {
    super.initState();
    // Handle Stripe Checkout return on web: look for success params
    if (kIsWeb) {
      final uri = Uri.parse(html.window.location.href);
      final success = uri.queryParameters['success'];
      final tokensStr = uri.queryParameters['tokens'];
      if (success == '1' && tokensStr != null) {
        final tokens = int.tryParse(tokensStr);
        if (tokens != null && tokens > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Credit tokens directly if accountManager is provided
            if (widget.accountManager != null) {
              widget.accountManager!.purchaseTokens(tokens);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Added $tokens tokens!')),
              );
            }
            Navigator.of(context).pop(tokens);
            _removeQueryParams();
          });
        }
      }
    }
  }

  void _removeQueryParams() {
    if (!kIsWeb) return;
    final uri = Uri.parse(html.window.location.href);
    final cleared = uri.replace(queryParameters: {});
    html.window.history.replaceState(null, '', cleared.toString());
  }

  Future<void> _handlePayment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _payment.pay(tokenCount: _tokensToBuy);
      if (success) {
        widget.accountManager?.purchaseTokens(_tokensToBuy);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment successful! You bought $_tokensToBuy tokens.')),
        );
        Navigator.of(context).pop(_tokensToBuy);
      } else {
        setState(() {
          _errorMessage = 'Payment failed. Please try again.';
        });
      }
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
