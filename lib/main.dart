import 'package:flutter/material.dart';
import 'views/home_page.dart';

void main() {
  runApp(MathKidsApp());
}

class MathKidsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Kids',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}