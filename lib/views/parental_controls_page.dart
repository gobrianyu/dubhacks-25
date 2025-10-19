import 'package:dubhacks_25/main.dart';
import 'package:flutter/material.dart';
import '../models/account_manager.dart';
import 'top_up.dart';
import 'curfew_settings.dart';

class ParentalControlsPage extends StatefulWidget {
  final AccountManager accountManager;

  const ParentalControlsPage({super.key, required this.accountManager});

  @override
  State<ParentalControlsPage> createState() => _ParentalControlsPageState();
}

class _ParentalControlsPageState extends State<ParentalControlsPage> {
  bool _authenticated = false;
  final TextEditingController _passwordController = TextEditingController();

  final Color primaryTone = const Color.fromARGB(255, 78, 101, 112);
  final Color accentTone = const Color.fromARGB(255, 104, 135, 151);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => _showPasswordPrompt());
  }

  void _showPasswordPrompt() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Parental Access Required'),
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
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_passwordController.text == widget.accountManager.pw) {
                setState(() => _authenticated = true);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Incorrect password.')),
                );
              }
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primaryTone,
        title: const Text('Parental Controls', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => MathKidsApp(accountManager: widget.accountManager)),
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: !_authenticated
          ? const Center(
              child: Text(
                '🔒 This section is password protected. Please authenticate to continue.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildActionCard(
                    context,
                    title: '💰 Top-Up Tokens',
                    subtitle: 'Add tokens to your child’s account safely.',
                    color: accentTone,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TopUpPage(accountManager: widget.accountManager),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActionCard(
                    context,
                    title: '⏰ Set Time Limits',
                    subtitle: 'Define curfew times to ensure healthy screen habits.',
                    color: accentTone,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CurfewSettingsPage(accountManager: widget.accountManager),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildActionCard(BuildContext context,
      {required String title,
      required String subtitle,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 6),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w400)),
            ],
          ),
        ),
      ),
    );
  }
}
