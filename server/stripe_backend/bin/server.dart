import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart' as dotenv;

void main() async {
  final env = dotenv.DotEnv();
  try {
    env.load();
  } catch (_) {
    // ignore if .env not found; fall back to platform env
  }

  final secretKey = env['STRIPE_SECRET_KEY'] ?? Platform.environment['STRIPE_SECRET_KEY'];
  if (secretKey == null) {
    print('Stripe secret key not found in environment variables');
    exit(1);
  }

  final app = Router();

  // Simple CORS middleware
  Response _cors(Response res) => res.change(headers: {
        ...res.headers,
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      });

  Response _options(Request req) => _cors(Response.ok(''));

  app.options('/<ignored|.*>', _options);

  app.post('/create-payment-intent', (Request request) async {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);

    final amount = data['amount']; // expect amount in cents
    if (amount == null) {
      return Response(400, body: jsonEncode({'error': 'Amount is required'}));
    }

    // Create payment intent with Stripe API
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
      return _cors(Response(
        response.statusCode,
        body: response.body,
        headers: {'content-type': 'application/json'},
      ));
    }

    final responseData = jsonDecode(response.body);

    return _cors(Response.ok(
      jsonEncode({'clientSecret': responseData['client_secret']}),
      headers: {'content-type': 'application/json'},
    ));
  });

  // Web: Create Checkout Session
  app.post('/create-checkout-session', (Request request) async {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);
    final amount = data['amount'];
    if (amount == null) {
      return _cors(Response(400, body: jsonEncode({'error': 'Amount is required'})));
    }
    final successUrl = (data['success_url'] ?? 'http://localhost:3000') as String;
    final cancelUrl = (data['cancel_url'] ?? 'http://localhost:3000') as String;
    final tokens = ((amount as num) ~/ 100); // since unit_amount is cents per token

    final response = await http.post(
      Uri.parse('https://api.stripe.com/v1/checkout/sessions'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $secretKey',
        HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
      },
      body: {
        'mode': 'payment',
        'payment_method_types[]': 'card',
        'line_items[0][price_data][currency]': 'usd',
        'line_items[0][price_data][product_data][name]': 'Math Kids Tokens',
        'line_items[0][price_data][unit_amount]': amount.toString(),
        'line_items[0][quantity]': '1',
        // Redirect back to app with tokens as a query param so UI can credit after redirect
        'success_url': '$successUrl?success=1&tokens=$tokens',
        'cancel_url': '$cancelUrl?canceled=1',
      },
    );

    if (response.statusCode != 200) {
      return _cors(Response(
        response.statusCode,
        body: response.body,
        headers: {'content-type': 'application/json'},
      ));
    }

    return _cors(Response.ok(
      response.body,
      headers: {'content-type': 'application/json'},
    ));
  });

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware((innerHandler) => (req) async {
            if (req.method == 'OPTIONS') {
              return _options(req);
            }
            final res = await innerHandler(req);
            return _cors(res);
          })
      .addHandler(app);

  final port = int.tryParse(Platform.environment['PORT'] ?? env['PORT'] ?? '') ?? 8080;
  final server = await io.serve(handler, '0.0.0.0', port);
  print('Server listening on port ${server.port}');
}
