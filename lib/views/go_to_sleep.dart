import 'package:flutter/material.dart';

class GoToSleepPage extends StatelessWidget {
  const GoToSleepPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF90CAF9),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.bedtime, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              "🌙 It's bedtime!\nSee you back in the morning!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}