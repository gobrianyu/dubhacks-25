import 'package:flutter/material.dart';
import '../models/account_manager.dart';

class QuizPage extends StatefulWidget {
  final AccountManager accountManager;

  QuizPage({Key? key, required this.accountManager}) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final nostalgicColors = const {
    'sky': Color(0xFFB4E9FF),
    'sun': Color(0xFFFFE082),
    'grass': Color(0xFFA5D6A7),
    'berry': Color(0xFFF48FB1),
    'cloud': Color(0xFFFFFFFF),
  };

  final TextEditingController _answerController = TextEditingController();
  String feedbackText = '';
  bool showFeedBackText = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: nostalgicColors['sky'],
      appBar: AppBar(
        title: const Text(
          'Math Quiz 🌈',
          style: TextStyle(
            fontFamily: 'ComicNeue',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: nostalgicColors['sun'],
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: nostalgicColors['cloud'],
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: const [
                  Text(
                    'Solve this!',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'ComicNeue',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'What is 2x + 5 = 9?',
                    style: TextStyle(fontSize: 18, fontFamily: 'ComicNeue'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _answerController,
              decoration: InputDecoration(
                hintText: 'Type your answer here...',
                filled: true,
                fillColor: nostalgicColors['cloud'],
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _buildButton(
              context,
              label: '🎉 Submit Answer',
              color: nostalgicColors['grass']!,
              onPressed: () {
                setState(() {
                  final correct = _answerController.text.trim() == '2';
                  if (correct) {
                    feedbackText = '🌟 Great job! You got it right!';
                    // award tokens and record
                    widget.accountManager.recordQuestionResult(correct: true, reward: 5);
                  } else {
                    feedbackText = '💡 Not quite! Try again!';
                    widget.accountManager.recordQuestionResult(correct: false, reward: 0);
                  }
                });
              },
            ),
            const SizedBox(height: 30),
            Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: feedbackText.contains('Great')
                    ? nostalgicColors['grass']
                    : nostalgicColors['berry'],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                feedbackText,
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: 'ComicNeue',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      {required String label,
      required Color color,
      required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 4,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontFamily: 'ComicNeue',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
