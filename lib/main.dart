import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';

void main() {
  runApp(const RetroQuizApp());
}

class RetroQuizApp extends StatelessWidget {
  const RetroQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RetroQuiz: Aventura Multiverso',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF101329),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}
