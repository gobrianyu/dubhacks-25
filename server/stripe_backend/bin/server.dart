import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart' as dotenv;

// ---------------------
// Models (Gemini)
// ---------------------
class Question {
  final String id;
  final String prompt;
  final String answer;
  final String type;
  final List<String>? options;
  final String explanation;

  Question({
    required this.id,
    required this.prompt,
    required this.answer,
    required this.type,
    this.options,
    required this.explanation,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'prompt': prompt,
        'answer': answer,
        'type': type,
        if (options != null) 'options': options,
        'explanation': explanation,
      };
}

// ---------------------
// Global Gemini state
// ---------------------
final Map<String, Question> _questions = {};
const _geminiModel = 'gemini-2.0-flash';
const _geminiBase =
    'https://generativelanguage.googleapis.com/v1beta/models';

// ---------------------
// Helpers
// ---------------------
Response jsonResponse(Object body, {int status = 200}) => Response(
      status,
      body: json.encode(body),
      headers: {
        'content-type': 'application/json',
        'access-control-allow-origin': '*', // CORS for Flutter
      },
    );

String buildPrompt({
  required String topic,
  required String gradeBand,
  required int count,
  required String difficulty,
  required String type,
}) {
  return '''
Return ONLY a JSON array of $count math problems for grade band "$gradeBand" on the topic "$topic".
Rules:
- Difficulty: $difficulty.
- Language: clear for $gradeBand.
- For each problem include: id, prompt, type, answer, explanation.
- If type == "mcq", include options (A,B,C,D) and answer must be one of those.
No markdown or commentary — only pure JSON.
''';
}

Future<String> _invokeGemini(String model, String apiKey, String prompt) async {
  final uri = Uri.parse('$_geminiBase/$model:generateContent?key=$apiKey');
  final body = json.encode({
    'contents': [
      {
        'role': 'user',
        'parts': [
          {'text': prompt}
        ]
      }
    ]
  });

  final resp = await http.post(uri,
      headers: {'content-type': 'application/json'}, body: body);

  if (resp.statusCode != 200) {
    throw Exception('Gemini error: ${resp.statusCode} ${resp.body}');
  }

  final decoded = json.decode(resp.body);
  final text = decoded['candidates']?[0]?['content']?['parts']?[0]?['text'];
  if (text == null) throw Exception('Gemini returned no text.');
  return text;
}

bool _compareAnswers(String expected, String given) {
  expected = expected.trim().toLowerCase();
  given = given.trim().toLowerCase();
  if (expected == given) return true;
  final eNum = double.tryParse(expected);
  final gNum = double.tryParse(given);
  if (eNum != null && gNum != null) {
    return (eNum - gNum).abs() < 1e-6;
  }
  return false;
}

// ---------------------
// MAIN
// ---------------------
void main() async {
  final env = dotenv.DotEnv()..load();

  final secretKey = env['STRIPE_SECRET_KEY'];
  final geminiKey = env['GEMINI_KEY'];

  if (secretKey == null) {
    print('Stripe secret key not found in environment variables');
  }
  if (geminiKey == null) {
    print('Gemini key not found in environment variables');
  }

  final app = Router();

  // ======================
  // STRIPE PAYMENT ROUTE
  // ======================
  app.post('/create-payment-intent', (Request request) async {
    if (secretKey == null) {
      return Response(500,
          body: jsonEncode({'error': 'Stripe secret key missing'}));
    }

    final payload = await request.readAsString();
    final data = jsonDecode(payload);
    final amount = data['amount']; // expect amount in cents

    if (amount == null) {
      return Response(400, body: jsonEncode({'error': 'Amount is required'}));
    }

    final response = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $secretKey',
        HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
      },
      body: {
        'amount': amount.toString(),
        'currency': 'usd',
        'payment_method_types[]': 'card',
      },
    );

    if (response.statusCode != 200) {
      return Response(
        response.statusCode,
        body: response.body,
        headers: {'content-type': 'application/json'},
      );
    }

    final responseData = jsonDecode(response.body);

    return Response.ok(
      jsonEncode({'clientSecret': responseData['client_secret']}),
      headers: {'content-type': 'application/json'},
    );
  });

  // ======================
  // GEMINI ENDPOINTS
  // ======================

  // POST /generateQuestion
app.post('/generateQuestion', (Request req) async {
  if (geminiKey == null) {
    return jsonResponse({'error': 'Missing GEMINI_KEY'}, status: 500);
  }

  final body = json.decode(await req.readAsString()) as Map<String, dynamic>;
  final topic = body['topic'] ?? 'Arithmetic';
  final gradeBand = body['gradeBand'] ?? 'Grade 3';
  final count = body['count']?.toString() ?? '1';
  final childAge = body['childAge']?.toString() ?? '10';

  final prompt = '''
    Generate exactly $count diverse math questions suitable for a $gradeBand student (approximately age $childAge)
  on the topic "$topic". Vary the question types: include word problems, fill-in-the-blank, and solving-for-x questions.
  Each question should have this JSON structure:

  [
    {
      "id": "unique_id_string",
      "prompt": "question text",
      "answer": "correct answer",
      "type": "open" | "multiple_choice" | "fill_blank",
      "options": ["A", "B", "C", "D"], // optional for multiple choice
      "explanation": "short explanation of the answer"
    }
  ]

  Return ONLY a valid JSON array of questions (no markdown, commentary, or text outside the array).
  ''';

    print(prompt);

    try {
      final text = await _invokeGemini(_geminiModel, geminiKey, prompt);

      List data;
      try {
        data = json.decode(text);
      } catch (_) {
        final start = text.indexOf('[');
        final end = text.lastIndexOf(']');
        if (start >= 0 && end > start) {
          data = json.decode(text.substring(start, end + 1));
        } else {
          throw Exception('Failed to parse Gemini output:\n$text');
        }
      }

      final List<Map<String, dynamic>> out = [];
      for (final item in data) {
        final q = Question(
          id: item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          prompt: item['prompt'] ?? '',
          answer: item['answer'] ?? '',
          type: item['type'] ?? 'open',
          options: (item['options'] as List?)?.map((e) => e.toString()).toList(),
          explanation: item['explanation'] ?? '',
        );
        _questions[q.id] = q;
        out.add(q.toJson());
      }

      return jsonResponse({'questions': out});
    } catch (e) {
      return jsonResponse({'error': e.toString()}, status: 500);
    }
  });


  // Helper for flexible answer checking
  bool compareAnswers(String correctAnswer, String userAnswer) {
    if (correctAnswer.trim().isEmpty || userAnswer.trim().isEmpty) return false;

    final ca = correctAnswer.trim().toLowerCase();
    final ua = userAnswer.trim().toLowerCase();

    // Try numeric comparison first
    final caNum = double.tryParse(ca);
    final uaNum = double.tryParse(ua);
    if (caNum != null && uaNum != null) {
      // Allow small rounding tolerance
      return (caNum - uaNum).abs() < 0.001;
    }

    // Then fall back to text match
    return ca == ua;
  }

  // POST /checkAnswer
  app.post('/checkAnswer', (Request req) async {
    final body = json.decode(await req.readAsString()) as Map<String, dynamic>;
    final qid = body['questionId'];
    final answer = body['answer'] ?? '';

    if (qid == null || !_questions.containsKey(qid)) {
      return jsonResponse({'error': 'Invalid questionId'}, status: 400);
    }

    final q = _questions[qid]!;
    final correct = compareAnswers(q.answer, answer);

    return jsonResponse({
      'result': {
        'correct': correct,
        'explanation': q.explanation.isNotEmpty ? q.explanation : 'Keep practicing!',
      }
    });
  });

  // ======================
  // SERVER
  // ======================
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(app);

  final server = await io.serve(handler, '0.0.0.0', 8080);
  print('✅ Server listening on port ${server.port}');
}
