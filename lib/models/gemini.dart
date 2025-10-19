import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class Question {
  final String text;
  final String answer;
  final String hint;

  Question({required this.text, required this.answer, required this.hint});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      text: json['text'] as String,
      answer: json['answer'] as String,
      hint: json['hint'] as String,
    );
  }
}

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  late final GenerativeModel _model;

  factory GeminiService() {
    return _instance;
  }

  GeminiService._internal() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    print('Loaded environment variables: ${dotenv.env}'); // Debug print
    if (apiKey == null) throw Exception('GEMINI_API_KEY not found in environment variables');
    
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',  // Using a supported model for v0.2.3
      apiKey: apiKey,
    );
  }

  Future<List<Question>> generateQuestions({
    required int count,
    required int childAge,
  }) async {
    final prompt = '''
    Generate $count math questions appropriate for a $childAge year old child.
    For each question, provide:
    1. The question text
    2. The correct numerical answer
    3. A helpful hint that guides them to the solution without giving it away
    
    Format each question as a JSON object with EXACTLY these fields:
    {
      "text": "What is 2 + 2?",
      "answer": "4",
      "hint": "Start by counting on your fingers"
    }
    
    Return an array of $count such question objects. Make sure:
    - Questions are age-appropriate
    - Answers are numerical and unambiguous
    - Hints are encouraging and helpful
    - Questions gradually increase in difficulty

    IMPORTANT: Return ONLY the raw JSON array. Do not add any markdown formatting, code block markers, or additional text.
    Do not wrap the response in ```json or ``` markers.
    ''';

    try {
      print('Sending request to generate $count questions for age $childAge');
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      // Get the response text, ensuring it's not null
      final responseText = response.text;
      if (responseText == null || responseText.isEmpty) {
        print('Received empty response from Gemini API');
        return _getFallbackQuestions(count);
      }

      try {
        print('Raw response from API: $responseText');
        print('Attempting to parse response as JSON');
        
        // Clean up the response by removing markdown code block markers
        final cleanedResponse = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
          
        print('Cleaned response: $cleanedResponse');
        // Parse the JSON array from the response
        final List<dynamic> questionsJson = json.decode(cleanedResponse);
        
        print('Successfully parsed JSON response');
        // Convert each JSON object to a Question
        final questions = questionsJson.map((q) => Question.fromJson(q)).toList();
        
        if (questions.isEmpty) {
          print('No questions were generated, using fallback');
          return _getFallbackQuestions(count);
        }

        print('Generated ${questions.length} questions');
        // Make sure we return exactly the requested number of questions
        if (questions.length < count) {
          print('Filling in missing questions with fallbacks');
          // If we have too few questions, fill with generated ones
          while (questions.length < count) {
            final a = questions.length + 1;
            final b = questions.length + 2;
            questions.add(Question(
              text: 'What is $a + $b?',
              answer: '${a + b}',
              hint: 'Try counting up $b numbers starting from $a.',
            ));
          }
        } else if (questions.length > count) {
          // If we have too many questions, take only what we need
          questions.length = count;
        }
        
        return questions;
      } catch (parseError) {
        print('Error parsing Gemini response: $parseError');
        print('Raw response: $responseText');
        return _getFallbackQuestions(count);
      }
    } catch (e) {
      print('Error generating questions: $e');
      return _getFallbackQuestions(count);
    }
  }

  List<Question> _getFallbackQuestions(int count) {
    return List.generate(count, (i) {
      final a = (i * 2) + 1;
      final b = i + 2;
      return Question(
        text: 'What is $a + $b?',
        answer: '${a + b}',
        hint: 'Try counting up $b numbers starting from $a.',
      );
    });
  }
}
