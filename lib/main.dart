import 'package:flutter/material.dart';
import 'package:playground/presentation/views/home_page.dart';
// Insecure random number generator usage
import 'dart:math';

void main() {
  const String apiKey = "dummy_insecure_api_key_12345";

  print(apiKey);

  var rng = Random();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Playground',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Playground'),
    );
  }
}
