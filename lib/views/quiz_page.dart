import 'package:flutter/material.dart';
import '../models/account_manager.dart';
import '../models/gemini.dart';

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
  bool isLoadingQuestions = false;

  final geminiService = GeminiService();
  List<Question> questions = [];

  Future<void> _loadQuestions() async {
    setState(() {
      isLoadingQuestions = true;
      questions = []; // Clear existing questions
      currentQuestionIndex = 0;
      triesLeft = 3;
      hintUnlocked = false;
      feedbackText = '';
      showSummary = false;
      _answerController.clear();
    });

    try {
      final generatedQuestions = await geminiService.generateQuestions(
        count: widget.accountManager.numQuestionsPerQuiz,
        childAge: widget.accountManager.childAge,
      );
      setState(() {
        questions = generatedQuestions;
        if (questions.length != widget.accountManager.numQuestionsPerQuiz) {
          // If we didn't get the exact number of questions requested, pad with fallback questions
          questions.addAll(_generateFallbackQuestions(
            widget.accountManager.numQuestionsPerQuiz - questions.length
          ));
        }
        triesResults = List.generate(questions.length, (_) => []);
        isLoadingQuestions = false;
      });
    } catch (e) {
      setState(() {
        questions = _generateFallbackQuestions(widget.accountManager.numQuestionsPerQuiz);
        triesResults = List.generate(questions.length, (_) => []);
        isLoadingQuestions = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Load questions immediately when the quiz page is opened
    _loadQuestions();
  }

  List<Question> _generateFallbackQuestions(int count) {
    final List<Question> questions = [];
    for (int i = 0; i < count; i++) {
      // Generate simple addition questions with increasing difficulty
      final a = (i * 2) + 1;  // 1, 3, 5, 7, ...
      final b = i + 2;        // 2, 3, 4, 5, ...
      questions.add(Question(
        text: 'What is $a + $b?',
        answer: '${a + b}',
        hint: 'Try counting up $b numbers starting from $a.',
      ));
    }
    return questions;
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
            if (isLoadingQuestions)
              Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  const Text(
                    'Preparing your personalized questions...',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'ComicNeue', fontSize: 16),
                  ),
                ],
              )
            else
              Text(
                'There are ${widget.accountManager.numQuestionsPerQuiz} questions today!',
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
                  onPressed: (isLoadingQuestions || questions.isEmpty)
                    ? null
                    : () => setState(() => quizStarted = true),
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
        widget.accountManager.recordQuestionResult(correct: true);
        _nextQuestion();
      } else {
        triesLeft--;
        feedbackText = triesLeft > 0
            ? 'Not quite! Try again! You have $triesLeft tries left.'
            : '❌ Out of tries! The correct answer was ${question.answer}.';
        widget.accountManager.recordQuestionResult(correct: false);
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
          int correctCount = triesResults.where((r) => r.contains(true)).length;
          double scorePercent = (correctCount / questions.length) * 100;

          final maxTokensEarnable = widget.accountManager.balance.maxEarnablePerDay;
          final unearnedBalance = widget.accountManager.balance.unearnedBalance;
          int tokensEarnedThisSession = 0;

          if (scorePercent >= widget.accountManager.requiredQuizScore && unearnedBalance > 0) {
            tokensEarnedThisSession = unearnedBalance >= maxTokensEarnable ? maxTokensEarnable : unearnedBalance;
            widget.accountManager.earnTokens(amount: tokensEarnedThisSession);
            feedbackText = '🎉 Congrats! You earned $tokensEarnedThisSession tokens!';
          } else {
            feedbackText = '😞 You didn\'t score high enough. Please try again to earn tokens.';
          }
          showSummary = true;
          triesLeft = 0;
          hintUnlocked = false;
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
            if (feedbackText.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  feedbackText,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: feedbackText.contains('Congrats') ? Colors.green : Colors.red,
                    fontFamily: 'ComicNeue',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
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
              onPressed: () async {
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
                });
                // Load new questions immediately
                await _loadQuestions();
              },
            ),
            if (feedbackText.contains('below required'))
              _buildButton(
                context,
                label: 'Retake Quiz',
                color: nostalgicColors['berry']!,
                onPressed: () async {
                  await _loadQuestions(); // Generate new questions
                  setState(() {
                    quizStarted = true;
                    showSummary = false;
                    currentQuestionIndex = 0;
                    triesLeft = 3;
                    triesResults = List.generate(questions.length, (_) => []);
                    _answerController.clear();
                    feedbackText = '';
                    hintUnlocked = false;
                  });
                },
              ),

          ],
        ),
      ),
    );
  }
}
