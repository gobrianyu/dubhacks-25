import 'package:flutter/material.dart';
import '../models/account_manager.dart';

class QuizSettingsPage extends StatefulWidget {
  final AccountManager accountManager;

  const QuizSettingsPage({super.key, required this.accountManager});

  @override
  State<QuizSettingsPage> createState() => _QuizSettingsPageState();
}

class _QuizSettingsPageState extends State<QuizSettingsPage> {
  late TextEditingController _ageController;
  late TextEditingController _scoreController;
  late TextEditingController _questionsController;

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController(text: widget.accountManager.childAge.toString());
    _scoreController = TextEditingController(text: widget.accountManager.requiredQuizScore.toString());
    _questionsController = TextEditingController(text: widget.accountManager.numQuestionsPerQuiz.toString());
  }

  @override
  void dispose() {
    _ageController.dispose();
    _scoreController.dispose();
    _questionsController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final int? age = int.tryParse(_ageController.text);
    final int? score = int.tryParse(_scoreController.text);
    final int? questions = int.tryParse(_questionsController.text);

    if (age != null && age > 0 && score != null && score >= 0 && score <= 100 && questions != null && questions > 0) {
      widget.accountManager.childAge = age;
      widget.accountManager.requiredQuizScore = score;
      widget.accountManager.numQuestionsPerQuiz = questions;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved successfully!')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid values.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Settings')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _buildTextField('Age of Child', _ageController, TextInputType.number),
            const SizedBox(height: 20),
            _buildTextField('Required Quiz Score (%)', _scoreController, TextInputType.number),
            const SizedBox(height: 20),
            _buildTextField('Number of Questions per Quiz', _questionsController, TextInputType.number),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: _saveSettings, child: const Text('Save Settings')),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType type) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }
}
