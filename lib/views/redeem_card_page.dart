import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/account_manager.dart';

class RedeemCardPage extends StatefulWidget {
  final AccountManager accountManager;

  const RedeemCardPage({super.key, required this.accountManager});

  @override
  State<RedeemCardPage> createState() => _RedeemCardPageState();
}

class _RedeemCardPageState extends State<RedeemCardPage> {
  final TextEditingController _amountController = TextEditingController();
  bool isLoading = false;
  String feedbackText = '';
  Map<String, dynamic>? cardInfo;
  final String ipv4 = '10.18.60.85';

  Future<void> _redeemCard() async {
    final maxAmount = widget.accountManager.balance.tokenBalance + 100; // assume in cents or tokens
    int amount = int.tryParse(_amountController.text) ?? 0;

    if (amount <= 0 || amount > maxAmount) {
      setState(() {
        feedbackText = 'Enter a valid amount (1 - $maxAmount)';
      });
      return;
    }

    setState(() {
      isLoading = true;
      feedbackText = '';
    });

    try {
      final response = await http.post(
        Uri.parse('http://$ipv4:8080/redeem-prepaid-card'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': widget.accountManager.username,
          'email': 'brian127@uw.edu',
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Deduct tokens locally
        widget.accountManager.earnTokens(amount: -amount);

        setState(() {
          cardInfo = data['card'];
          feedbackText = 'Prepaid card issued successfully!';
        });
      } else {
        setState(() {
          feedbackText = 'Server error: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        feedbackText = 'Network error: $e';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxAmount = widget.accountManager.balance.tokenBalance + 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Redeem Prepaid Card'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Your current balance: $maxAmount tokens',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount to redeem',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _redeemCard,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Redeem on Prepaid Card'),
            ),
            const SizedBox(height: 20),
            if (feedbackText.isNotEmpty)
              Text(
                feedbackText,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            if (cardInfo != null) ...[
              const SizedBox(height: 20),
              Text('Card ID: ${cardInfo!['id']}'),
              Text('Last4: ${cardInfo!['last4']}'),
              Text('Expires: ${cardInfo!['exp_month']}/${cardInfo!['exp_year']}'),
              Text('Type: ${cardInfo!['type']}'),
              Text('Status: ${cardInfo!['status']}'),
            ],
          ],
        ),
      ),
    );
  }
}
