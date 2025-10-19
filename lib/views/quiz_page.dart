import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/account_manager.dart';

class Question {
  final String id;
  final String text;
  final String answer; // still store server-provided correct answer (optional)
  final String hint;

  Question({
    required this.id,
    required this.text,
    required this.answer,
    required this.hint,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      text: json['prompt'] ?? json['text'] ?? '',
      answer: json['answer'] ?? '',
      hint: json['explanation'] ?? json['hint'] ?? '',
    );
  }
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
  final String ipv4 = '10.18.60.85';
  bool quizStarted = false;
  bool loadingFirstQuestion = true;
  int currentQuestionIndex = 0;
  int triesLeft = 3;
  late List<List<bool>> triesResults;
  bool hintUnlocked = false;
  String feedbackText = '';
  bool showSummary = false;

  final TextEditingController _answerController = TextEditingController();

  List<Question> questions = [];
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    triesResults =
        List.generate(widget.accountManager.numQuestionsPerQuiz, (_) => []);
    _fetchQuestions(); // start loading immediately
  }

  Future<void> _fetchQuestions() async {
    final numQuestions = widget.accountManager.numQuestionsPerQuiz;
    final childAge = widget.accountManager.childAge;

    // Temporary list to fill as questions arrive
    final List<Question> loadedQuestions = [];

    // Fetch questions one by one
    for (int i = 0; i < numQuestions; i++) {
      try {
        final response = await http.post(
          Uri.parse('http://$ipv4:8080/generateQuestion'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'topic': 'Basic Algebra',
            'gradeBand': 'Grade $childAge',
            'count': 1,
            'difficulty': 'medium',
            'type': 'open',
            'childAge': childAge,
          }),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          // Ensure the response has 'questions' as a list
          if (data['questions'] is List && data['questions'].isNotEmpty) {
            final q = Question.fromJson(data['questions'][0]);
            loadedQuestions.add(q);

            // As soon as the first question arrives, show it
            if (loadedQuestions.length == 1 && mounted) {
              setState(() {
                questions = List.from(loadedQuestions);
                loadingFirstQuestion = false;
              });
            }
          } else {
            throw Exception('Invalid response format: ${response.body}');
          }
        } else {
          throw Exception('Failed to fetch question: ${response.body}');
        }
      } catch (e) {
        print('Error fetching question: $e');
      }
    }

    // Once all questions are fetched, update full list
    if (mounted) {
      setState(() {
        questions = List.from(loadedQuestions);
        loadingFirstQuestion = false;
      });
    }
  }


  Future<void> _submitAnswer() async {
    if (isSubmitting) return;
    setState(() => isSubmitting = true);

    final question = questions[currentQuestionIndex];
    final answer = _answerController.text.trim();

    try {
      final response = await http.post(
        Uri.parse('http://$ipv4:8080/checkAnswer'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'questionId': question.id,
          'answer': answer,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = data['result'];
        final correct = result['correct'] ?? false;
        final explanation = result['explanation'] ?? '';

        setState(() {
          triesResults[currentQuestionIndex].add(correct);

          if (correct) {
            feedbackText = 'Good job!';

            widget.accountManager.recordQuestionResult(correct: true);
            _nextQuestion();
          } else {
            triesLeft--;
            widget.accountManager.recordQuestionResult(correct: false);

            if (triesLeft > 0) {
              feedbackText = 'That\'s not correct. Try again!';
            } else {
              feedbackText = 'That\'s not correct. $explanation';
              _nextQuestion();
            }
          }
        });
      } else {
        setState(() {
          feedbackText = 'Server error: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        feedbackText = 'Network error: $e';
      });
    } finally {
      setState(() => isSubmitting = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: nostalgicColors['sky'],
      appBar: quizStarted
          ? null
          : AppBar(
              backgroundColor: nostalgicColors['cloud'],
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'Today\'s Math Quiz',
                style:
                    TextStyle(fontFamily: 'ComicNeue', fontWeight: FontWeight.bold),
              ),
            ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/background.png')),
        ),
        padding: const EdgeInsets.all(16),
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (loadingFirstQuestion) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (questions.isEmpty) {
      return Center(
        child: Text(
          'Failed to load quiz questions. Try again later.',
          style: const TextStyle(fontFamily: 'ComicNeue', fontSize: 18),
        ),
      );
    }

    if (!quizStarted) {
      return _buildReadyCard(context);
    }

    return showSummary ? _buildSummaryPage(context) : _buildQuizContent(context);
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
              'Are you ready for today\'s quiz?',
              style: TextStyle(
                  fontFamily: 'ComicNeue',
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            const SizedBox(height: 12),
            Text(
              'There are ${widget.accountManager.numQuestionsPerQuiz} questions today!',
              style: const TextStyle(fontFamily: 'ComicNeue', fontSize: 16),
            ),
            const SizedBox(height: 20),
            _buildButton(
              context,
              label: '✨ Ready',
              color: nostalgicColors['grass']!,
              onPressed: () => setState(() => quizStarted = true),
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton(
              context,
              label: isSubmitting ? '⏳ Checking...' : '🎉 Submit Answer',
              color: nostalgicColors['grass']!,
              onPressed: isSubmitting
                  ? null
                  : () {
                      if (_answerController.text.trim() != '' && triesLeft > 0) {
                        _submitAnswer();
                        FocusScope.of(context).unfocus();
                      }
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
              color: feedbackText.contains('Good')
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
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Hint: ${question.hint}',
              style: const TextStyle(
                fontFamily: 'ComicNeue',
                fontSize: 16,
                color: Color.fromARGB(255, 98, 98, 98),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(height: 40)
      ],
    );
  }

  Widget _buildQuestionCard(Question question) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: nostalgicColors['cloud'],
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Solve this!',
            style: TextStyle(
                fontFamily: 'ComicNeue',
                fontWeight: FontWeight.bold,
                fontSize: 20),
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
      {required String label,
      required Color color,
      required VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
      child: Text(
        label,
        style: const TextStyle(
            fontFamily: 'ComicNeue',
            fontWeight: FontWeight.bold,
            fontSize: 16),
      ),
    );
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
          _showSummary();
        }
      });
    });
  }

  void _showSummary() {
    int correctCount = triesResults.where((r) => r.contains(true)).length;
    double scorePercent = (correctCount / questions.length) * 100;
    final maxTokensEarnable =
        widget.accountManager.balance.maxEarnablePerDay;
    final unearnedBalance = widget.accountManager.balance.unearnedBalance;
    int tokensEarnedThisSession = 0;

    if (scorePercent >= widget.accountManager.requiredQuizScore &&
        unearnedBalance > 0) {
      tokensEarnedThisSession = unearnedBalance >= maxTokensEarnable
          ? maxTokensEarnable
          : unearnedBalance;
      widget.accountManager.earnTokens(amount: tokensEarnedThisSession);
      feedbackText =
          '🎉 Congrats! You earned $tokensEarnedThisSession tokens!';
    } else {
      feedbackText =
          '😞 You didn\'t score high enough. Please try again to earn tokens.';
    }
    showSummary = true;
    triesLeft = 0;
    hintUnlocked = false;
  }

  Widget _buildSummaryPage(BuildContext context) {
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
            if (feedbackText.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  feedbackText,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: feedbackText.contains('Congrats')
                        ? Colors.green
                        : Colors.red,
                    fontFamily: 'ComicNeue',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const Text(
              'Quiz Summary',
              style: TextStyle(
                  fontFamily: 'ComicNeue',
                  fontWeight: FontWeight.bold,
                  fontSize: 24),
            ),
            const SizedBox(height: 16),
            Column(
              children: List.generate(questions.length, (index) {
                final results = triesResults[index];
                final firstCorrectIndex = results.indexOf(true);
                String status;
                if (firstCorrectIndex == 0) {
                  status = '✔️';
                } else if (firstCorrectIndex > 0) {
                  status = '❔';
                } else {
                  status = '❌';
                }

                List<Widget> tryIcons = [];
                for (int i = 0; i < 3; i++) {
                  if (i < results.length) {
                    tryIcons.add(Text(
                      results[i] ? '🟩' : '🟥',
                      style: const TextStyle(fontSize: 22),
                    ));
                  } else {
                    tryIcons
                        .add(const Text('⬜', style: TextStyle(fontSize: 22)));
                  }
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Question ${index + 1}:  ',
                          style: const TextStyle(
                              fontFamily: 'ComicNeue', fontSize: 18)),
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
                final today = DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day);
                widget.accountManager.addStreakEvent(today, 'Completed quiz');
                setState(() {
                  quizStarted = false;
                  showSummary = false;
                  currentQuestionIndex = 0;
                  triesLeft = 3;
                  hintUnlocked = false;
                  feedbackText = '';
                  _answerController.clear();
                  triesResults = List.generate(
                      widget.accountManager.numQuestionsPerQuiz, (_) => []);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
