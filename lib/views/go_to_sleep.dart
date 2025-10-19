import 'package:dubhacks_25/models/account_manager.dart';
import 'package:dubhacks_25/views/parental_controls_page.dart';
import 'package:flutter/material.dart';

class GoToSleepPage extends StatelessWidget {

  final AccountManager accountManager;
  
  const GoToSleepPage({required this.accountManager, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 41, 56, 69),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bedtime, size: 100, color: Color(0xFFFFE082)),
            const SizedBox(height: 20),
            const Text(
              "It's bedtime!\nSee you back in the morning!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ParentalControlsPage(accountManager: accountManager),
                  ),
                );
              },
              child: const Text('Parental Control')
            )
          ],
        ),
      ),
    );
  }
}
