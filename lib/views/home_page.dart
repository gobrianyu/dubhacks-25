import 'package:dubhacks_25/views/streak_history.dart';
import 'package:flutter/material.dart';
import '../models/account_manager.dart';
import 'quiz_page.dart';
import 'parental_controls_page.dart';
import 'help_page.dart';

class HomePage extends StatefulWidget {
  final AccountManager accountManager;

  const HomePage({super.key, required this.accountManager});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final nostalgicColors = const {
    'sky': Color(0xFFA9E4FC),
    'sun': Color(0xFFFFE082),
    'grass': Color(0xFFA5D6A7),
    'berry': Color(0xFFF48FB1),
    'cloud': Color(0xFFFFFFFF),
  };
  late Map<DateTime, List<String>> streaks = widget.accountManager.streakHistory;
  final DateTime now = DateTime.now();

  // Find Monday of the current week
  late DateTime monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));

  // Generate activity list from Monday to Sunday
  late final List<bool> _weekActivity = List.generate(7, (index) {
    final DateTime day = monday.add(Duration(days: index));
    return streaks.containsKey(day) && streaks[day]!.isNotEmpty;
  });


  int _calculateStreak(List<bool> activity) {
    int streak = 0;
    int dayIndex = DateTime.now().difference(monday).inDays % 7;
    for (int i = dayIndex; i >= 0; i--) {
      if (activity[i]) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  Future<void> _navigateTo(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    setState(() {}); // Refresh UI after returning
  }

  @override
  Widget build(BuildContext context) {
    final currentStreak = _calculateStreak(_weekActivity);
    final balance = widget.accountManager.balance;

    return Scaffold(
      backgroundColor: nostalgicColors['sky'],
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
              width: 40,
              height: 40,
            ),
          ),
        ),
        title: const Text('Math Kids'),
        backgroundColor: nostalgicColors['sun'],
        centerTitle: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/background.png')),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ... Your existing widgets ...
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
                children: [
                  Text(
                    'Welcome back, ${widget.accountManager.username}!',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ComicNeue'),
                  ),
                  const SizedBox(height: 8),
                  Text('Questions answered: ${widget.accountManager.questionsAnswered}'),
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
                  value: '${balance.tokenBalance}',
                  color: nostalgicColors['grass']!,
                ),
                _infoCard(
                  icon: Icons.star,
                  label: 'Level',
                  value: '${widget.accountManager.userLevel}',
                  color: nostalgicColors['berry']!,
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Modify gesture handler to use _navigateTo:
            GestureDetector(
              onTap: () => _navigateTo(
                StreakHistoryPage(accountManager: widget.accountManager),
              ),
              child: Container(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (index) {
                        final dayDate = monday.add(Duration(days: index));
                        final isToday = DateTime.now().year == dayDate.year &&
                                        DateTime.now().month == dayDate.month &&
                                        DateTime.now().day == dayDate.day;

                        final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        final completed = _weekActivity[index];

                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                          decoration: BoxDecoration(
                            color: isToday
                                ? nostalgicColors['sun'] ?? Colors.yellow[200]
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Text(
                                dayLabels[index],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: completed
                                      ? nostalgicColors['grass']
                                      : nostalgicColors['cloud'],
                                  border: !completed
                                      ? Border.all(color: Colors.black26)
                                      : null,
                                ),
                                child: completed
                                    ? ClipOval(
                                      child: Image.asset(
                                          './assets/images/logo.png',
                                          fit: BoxFit.contain,
                                        ),
                                    )
                                    : null,
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentStreak > 0
                          ? "🔥 You're on a streak of $currentStreak days this week, keep it up! >>>"
                          : "Let's continue your streak today! >>>",
                      textAlign: TextAlign.center,
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
            ),

            const SizedBox(height: 28),
            
            // Buttons: replace Navigator.push with _navigateTo calls:
            _buildButton(
              context,
              label: '🎯 Start Quiz',
              color: nostalgicColors['grass']!,
              onPressed: () {
                _navigateTo(QuizPage(accountManager: widget.accountManager));
              },
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _buildButton(
                    context,
                    label: '🔒 Parental Controls',
                    color: nostalgicColors['cloud']!,
                    onPressed: () => _navigateTo(ParentalControlsPage(accountManager: widget.accountManager)),
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
                    backgroundColor: nostalgicColors['berry'],
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
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

  Widget _buildButton(BuildContext context,
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
