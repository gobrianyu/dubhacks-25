import 'package:flutter/material.dart';
import '../models/account_manager.dart';

class TopUpPage extends StatelessWidget {
  final AccountManager accountManager;

  const TopUpPage({Key? key, required this.accountManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top-Up Tokens')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Add tokens to your child’s account:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.monetization_on),
              label: const Text('Add 10 Tokens'),
              onPressed: () {
                accountManager.purchaseTokens(10);
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Added 10 tokens (demo).')));
              },
            ),
          ],
        ),
      ),
    );
  }
}
