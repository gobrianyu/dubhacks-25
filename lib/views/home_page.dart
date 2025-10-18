import 'package:flutter/material.dart';
import 'quiz_page.dart';
import 'parental_controls_page.dart';
import 'help_page.dart';

class HomePage extends StatelessWidget {
  final nostalgicColors = const {
    'sky': Color(0xFFA9E4FC),
    'sun': Color(0xFFFFE082),
    'grass': Color(0xFFA5D6A7),
    'berry': Color(0xFFF48FB1),
    'cloud': Color(0xFFFFFFFF),
  };

  // Example user activity for streak: true = quiz completed that day
  final List<bool> _weekActivity = [true, true, false, true, true, true, false];

  int _calculateStreak(List<bool> activity) {
    int streak = 0;
    for (int i = activity.length - 1; i >= 0; i--) {
      if (activity[i]) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final currentStreak = _calculateStreak(_weekActivity);

    return Scaffold(
      backgroundColor: nostalgicColors['sky'],
      appBar: AppBar(
        title: const Text(
          'Math Kids',
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
            const SizedBox(height: 10),

            // Welcome back and user info container
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: nostalgicColors['cloud'],
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
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
                    'Welcome back, Math Hero!',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ComicNeue'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tokens and User Level Row with improved card content layout
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoCard(
                  icon: Icons.monetization_on,
                  label: 'Tokens',
                  value: '50',
                  color: nostalgicColors['grass']!,
                ),
                _infoCard(
                  icon: Icons.star,
                  label: 'Level',
                  value: '5',
                  color: nostalgicColors['berry']!,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Calendar and streak tracker container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
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
              child: Column(
                children: [
                  // Weekday labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                        .map((d) => Text(
                              d,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  // Activity dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _weekActivity
                        .map(
                          (completed) => Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: completed
                                  ? nostalgicColors['grass']
                                  : nostalgicColors['cloud'],
                              border: Border.all(color: Colors.black26),
                            ),
                            child: completed
                                ? const Icon(
                                    Icons.check,
                                    size: 18,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  // Motivational text
                  Text(
                    currentStreak > 0
                        ? "🔥 You're on a streak of $currentStreak days, keep it up!"
                        : "Let's start your streak today!",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontFamily: 'ComicNeue',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildFunButton(
                          context,
                          label: '🎯 Start Quiz',
                          color: nostalgicColors['grass']!,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => QuizPage()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HelpPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: nostalgicColors['cloud'],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 6,
                            side: const BorderSide(color: Colors.black12),
                          ),
                          child: const Text(
                            '?',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildFunButton(
                    context,
                    label: '🔒 Parental Controls',
                    color: nostalgicColors['berry']!,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ParentalControlsPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(
      {required IconData icon,
      required String label,
      required String value,
      required Color color}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      child: Container(
        width: 145,
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.white),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    value,
                    style: const TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ComicNeue'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'ComicNeue'),
                overflow: TextOverflow.fade,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunButton(BuildContext context,
      {required String label,
      required Color color,
      required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 60,
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
