import 'package:flutter/material.dart';
import '../models/account_manager.dart';

class Question {
  final String text;
  final String answer;
  final String hint;

  Question({required this.text, required this.answer, required this.hint});
}

class QuizPage extends StatefulWidget {
  final AccountManager accountManager;

  const QuizPage({super.key, required this.accountManager});

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

  bool quizStarted = false;
  int currentQuestionIndex = 0;
  int triesLeft = 3;
  late List<List<bool>> triesResults;
  bool hintUnlocked = false;
  String feedbackText = '';
  final TextEditingController _answerController = TextEditingController();
  bool showSummary = false;

  late final List<Question> questions;

  @override
  void initState() {
    super.initState();
    questions = [
      Question(text: 'What is 2x + 5 = 9?', answer: '2', hint: 'Try subtracting 5 from both sides!'),
      Question(text: 'What is 3x = 12?', answer: '4', hint: 'Divide both sides by 3.'),
      Question(text: 'What is 10 - 7?', answer: '3', hint: 'It\'s a small number!'),
      Question(text: 'What is 10 - 7?', answer: '3', hint: 'It\'s a small number!'),
      Question(text: 'What is 10 - 7?', answer: '3', hint: 'It\'s a small number!')
    ];
    triesResults = List.generate(questions.length, (_) => []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: nostalgicColors['sky'],
      appBar: quizStarted ? null : AppBar(
        backgroundColor: nostalgicColors['cloud'],
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Today\'s Math Quiz',
          style: TextStyle(fontFamily: 'ComicNeue', fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: !quizStarted
            ? _buildReadyCard(context)
            : (showSummary ? _buildSummaryPage(context) : _buildQuizContent(context)),
      ),
    );
  }

  Widget _buildReadyCard(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: nostalgicColors['cloud'],
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you ready for today’s quiz?',
              style: TextStyle(fontFamily: 'ComicNeue', fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 12),
            Text(
              'There are ${widget.accountManager.numQuestions} questions today!',
              style: const TextStyle(fontFamily: 'ComicNeue', fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(
                  context,
                  label: '✨ Ready',
                  color: nostalgicColors['grass']!,
                  onPressed: () => setState(() => quizStarted = true),
                ),
                _buildButton(
                  context,
                  label: 'Go Back',
                  color: nostalgicColors['berry']!,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizContent(BuildContext context) {
    final question = questions[currentQuestionIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        _buildQuestionCard(question),
        const SizedBox(height: 20),
        TextField(
          controller: _answerController,
          decoration: InputDecoration(
            hintText: 'Type your answer here...',
            filled: true,
            fillColor: nostalgicColors['cloud'],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton(
              context,
              label: '🎉 Submit Answer',
              color: nostalgicColors['grass']!,
              onPressed: () {
                if (_answerController.text.trim() != '' && triesLeft > 0) _submitAnswer();
                FocusScope.of(context).unfocus();
              },
            ),
            _buildButton(
              context,
              label: '💡 Get Hint',
              color: nostalgicColors['sun']!,
              onPressed: () {
                FocusScope.of(context).unfocus();
                if (triesLeft < 3) _unlockHint();
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Tries left: $triesLeft',
          style: const TextStyle(fontSize: 16),
        ),
        const Spacer(),
        if (feedbackText.isNotEmpty)
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
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'ComicNeue',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (hintUnlocked)
          Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'Hint: ${question.hint}',
              style: TextStyle(
                fontFamily: 'ComicNeue',
                fontSize: 16,
                color: const Color.fromARGB(255, 98, 98, 98),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuestionCard(Question question) {
    return Container(
      margin: EdgeInsets.only(top: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: nostalgicColors['cloud'],
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Column(
        children: [
          const Text(
            'Solve this!',
            style: TextStyle(fontFamily: 'ComicNeue', fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 12),
          Text(
            question.text,
            style: const TextStyle(fontFamily: 'ComicNeue', fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      {required String label, required Color color, required VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
      child: Text(
        label,
        style: const TextStyle(fontFamily: 'ComicNeue', fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  void _submitAnswer() {
    final question = questions[currentQuestionIndex];
    final answer = _answerController.text.trim();
    final isCorrect = answer == question.answer;

    setState(() {
      triesResults[currentQuestionIndex].add(isCorrect);
      if (isCorrect) {
        feedbackText = '🌟 Great job! You got it right!';
        widget.accountManager.recordQuestionResult(correct: true, reward: 5);
        _nextQuestion();
      } else {
        triesLeft--;
        feedbackText = triesLeft > 0
            ? 'Not quite! Try again! You have $triesLeft tries left.'
            : '❌ Out of tries! The correct answer was ${question.answer}.';
        widget.accountManager.recordQuestionResult(correct: false, reward: 0);
        if (triesLeft == 0) _nextQuestion();
      }
    });
  }

  void _unlockHint() {
    setState(() => hintUnlocked = true);
  }

  void _nextQuestion() {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        if (currentQuestionIndex < questions.length - 1) {
          currentQuestionIndex++;
          triesLeft = 3;
          hintUnlocked = false;
          feedbackText = '';
          _answerController.clear();
        } else {
          showSummary = true;
        }
      });
    });
  }

  Widget _buildSummaryPage(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: nostalgicColors['cloud'],
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quiz Summary',
              style: TextStyle(fontFamily: 'ComicNeue', fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 16),
            Column(
              children: List.generate(questions.length, (index) {
                final results = triesResults[index];
                final firstCorrectIndex = results.indexOf(true);
                String status;
                if (firstCorrectIndex == 0) {
                  status = '✔️'; // Correct on first try
                } else if (firstCorrectIndex > 0) {
                  status = '❔'; // Correct after first try
                } else {
                  status = '❌'; // Did not get correct within tries
                }

                List<Widget> tryIcons = [];
                // Fill tries with max 3 tries (some unused)
                for (int i = 0; i < 3; i++) {
                  if (i < results.length) {
                    tryIcons.add(Text(
                      results[i] ? '🟩' : '🟥',
                      style: const TextStyle(fontSize: 22),
                    ));
                  } else {
                    tryIcons.add(const Text('⬜', style: TextStyle(fontSize: 22)));
                  }
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$status Question ${index + 1}:  ', style: const TextStyle(fontFamily: 'ComicNeue', fontSize: 18)),
                      ...tryIcons,
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            _buildButton(
              context,
              label: 'Return Home',
              color: nostalgicColors['sun']!,
              onPressed: () {
                final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                widget.accountManager.addStreakEvent(today, 'Completed quiz');
                setState(() {
                  quizStarted = false;
                  showSummary = false;
                  currentQuestionIndex = 0;
                  triesLeft = 3;
                  hintUnlocked = false;
                  feedbackText = '';
                  _answerController.clear();
                  triesResults = List.generate(questions.length, (_) => []);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
