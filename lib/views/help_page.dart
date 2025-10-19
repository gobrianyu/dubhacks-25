import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    const nostalgicColors = {
      'sky': Color(0xFFB4E9FF),
      'sun': Color(0xFFFFE082),
      'cloud': Color(0xFFFFFFFF),
      'grass': Color(0xFFA5D6A7),
      'berry': Color(0xFFF48FB1),
    };

    return Scaffold(
      backgroundColor: nostalgicColors['sky'],
      appBar: AppBar(
        backgroundColor: nostalgicColors['sun'],
        title: const Text(
          'Help & Info 🌟',
          style: TextStyle(
            fontFamily: 'ComicNeue',
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: nostalgicColors['cloud'],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How Math Kids Works',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ComicNeue',
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Parents can set a weekly allowance 💰. Kids earn tokens 🎯 by completing fun math quizzes. Tokens can be exchanged for rewards or prepaid cards. Math questions are created and graded automatically by the app.',
                      style: TextStyle(fontSize: 16, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: nostalgicColors['grass'],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quiz Tips 🧠',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ComicNeue',
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text('• Read each question carefully.'),
                    Text('• Try solving problems on paper if needed.'),
                    Text('• Use hints to learn step by step.'),
                    Text('• Don’t worry if you make mistakes — that’s how you learn! 🌈'),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: nostalgicColors['berry'],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    elevation: 4,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Got it!',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'ComicNeue',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
