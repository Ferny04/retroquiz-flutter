import 'package:flutter/material.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  final int correctAnswers;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.orangeAccent,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '¡Expedición completada!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Planeta Volcánico', textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  Card(
                    color: const Color(0xFF432D32),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text('Correctas: $correctAnswers'),
                          const SizedBox(height: 12),
                          Text(
                            'Incorrectas: ${totalQuestions - correctAnswers}',
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Puntuación total: ${correctAnswers * 100}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.public),
                    label: const Text('Volver al mapa'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
