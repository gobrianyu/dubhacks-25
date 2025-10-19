import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart' as dotenv;

void main() async {
  final env = dotenv.DotEnv()..load();

  final secretKey = env['STRIPE_SECRET_KEY'];
  if (secretKey == null) {
    print('Stripe secret key not found in environment variables');
    exit(1);
  }

  final app = Router();

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

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(app);

  final server = await io.serve(handler, '0.0.0.0', 8080);
  print('Server listening on port ${server.port}');
}
