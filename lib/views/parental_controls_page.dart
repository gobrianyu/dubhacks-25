import 'package:flutter/material.dart';
import '../services/payment_service.dart';
import '../services/token_manager.dart';
import 'package:intl/intl.dart';

class ParentalControlsPage extends StatefulWidget {
  @override
  State<ParentalControlsPage> createState() => _ParentalControlsPageState();
}

class _ParentalControlsPageState extends State<ParentalControlsPage> {
  final Color primaryTone = const Color(0xFF546E7A); // Slate blue-gray
  final Color accentTone = const Color(0xFF90CAF9);  // Soft blue accent
  bool _authenticated = false;
  final TextEditingController _passwordController = TextEditingController();
  final TokenManager _tokenManager = TokenManager();

  @override
  void initState() {
    super.initState();
    _tokenManager.initialize();
    _tokenManager.addListener(_onTokensChanged);
    // Prompt for password overlay when entering
    Future.delayed(Duration.zero, () => _showPasswordPrompt());
  }

  @override
  void dispose() {
    _tokenManager.removeListener(_onTokensChanged);
    super.dispose();
  }

  void _onTokensChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _showPasswordPrompt() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Parental Access Required',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please enter your password to continue:'),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: const Text('Unlock'),
              onPressed: () {
                if (_passwordController.text == '1234') { // Demo validation
                  setState(() => _authenticated = true);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Incorrect password. Please try again.'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primaryTone,
        title: const Text(
          'Parental Controls',
          style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _authenticated
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Token Balance',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: accentTone,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${_tokenManager.tokenBalance} tokens',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Top-up Tokens',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.account_balance_wallet),
                            label: const Text('Add Tokens'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentTone,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              PaymentService.showTokenPurchaseDialog(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Transaction History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      if (_tokenManager.transactions.isNotEmpty)
                        TextButton(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Clear History'),
                                content: const Text(
                                    'Are you sure you want to clear all transaction history?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Clear'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await _tokenManager.clearHistory();
                            }
                          },
                          child: const Text('Clear'),
                        ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: _tokenManager.transactions.isEmpty
                        ? const Center(
                            child: Text(
                              'No transactions yet.\nPurchase tokens to see history here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _tokenManager.transactions.length,
                            itemBuilder: (context, index) {
                              final transaction =
                                  _tokenManager.transactions[index];
                              final dateFormat = DateFormat('MMM d, yyyy');
                              final timeFormat = DateFormat('h:mm a');
                              
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: accentTone,
                                  child: const Icon(Icons.monetization_on,
                                      color: Colors.white),
                                ),
                                title: Text(
                                  '${transaction.tokens} tokens - \$${transaction.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  '${dateFormat.format(transaction.date)} at ${timeFormat.format(transaction.date)}\n'
                                  'Transaction ID: ${transaction.id}',
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    transaction.status,
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            )
          : const Center(
              child: Text(
                '🔒 Access Restricted. Please authenticate to continue.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
    );
  }
}
