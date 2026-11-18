import 'package:flutter/material.dart';

import '../data/questions_data.dart';
import '../models/question.dart';
import '../services/progress_service.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    this.isDemo = true,
    this.progressService = const UnavailableProgressService(),
  });

  final bool isDemo;
  final ProgressService progressService;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final List<Question> _questions;
  int _questionIndex = 0;
  int _correctAnswers = 0;
  int? _selectedAnswer;
  String? _userId;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _questions = selectGameQuestions();
    _userId = widget.isDemo ? null : widget.progressService.currentUserId;
  }

  void _answer(int index) {
    // También protege contra dos toques antes de reconstruir la pantalla.
    if (_selectedAnswer != null) return;
    setState(() {
      _selectedAnswer = index;
      if (index == _questions[_questionIndex].correctAnswerIndex) {
        _correctAnswers++;
      }
    });
  }

  Future<void> _nextQuestion() async {
    if (_selectedAnswer == null || _finished) return;
    if (_questionIndex == _questions.length - 1) {
      _finished = true;
      // Espera el resultado antes de cerrar la partida y recargar el mapa.
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => QuizResultScreen(
            correctAnswers: _correctAnswers,
            totalQuestions: _questions.length,
            isDemo: widget.isDemo,
            userId: _userId,
            progressService: widget.progressService,
          ),
        ),
      );
      if (mounted) Navigator.pop(context);
      return;
    }
    setState(() {
      _questionIndex++;
      _selectedAnswer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_questionIndex];
    final answered = _selectedAnswer != null;
    final correct = _selectedAnswer == question.correctAnswerIndex;

    return Scaffold(
      appBar: AppBar(title: const Text('Planeta Volcánico')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.orangeAccent,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pregunta ${_questionIndex + 1} de ${_questions.length}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_questionIndex + 1) / _questions.length,
                    color: Colors.orangeAccent,
                    backgroundColor: const Color(0xFF432D32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Puntos: ${_correctAnswers * 100}',
                    style: const TextStyle(color: Colors.orangeAccent),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    color: const Color(0xFF432D32),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.category,
                            style: const TextStyle(color: Colors.orangeAccent),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            question.text,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (int i = 0; i < question.options.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: OutlinedButton(
                        key: ValueKey('answer_$i'),
                        onPressed: answered ? null : () => _answer(i),
                        style: OutlinedButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.all(16),
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white,
                          backgroundColor:
                              answered && i == question.correctAnswerIndex
                              ? const Color(0xFF1B5E20)
                              : answered && i == _selectedAnswer
                              ? const Color(0xFF8E2424)
                              : const Color(0xFF202338),
                        ),
                        child: Text(
                          '${String.fromCharCode(65 + i)}) ${question.options[i]}',
                        ),
                      ),
                    ),
                  if (answered) ...[
                    Semantics(
                      liveRegion: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            correct ? '¡Correcto!' : '¡Incorrecto!',
                            style: TextStyle(
                              color: correct
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (correct)
                            // Se crea al acertar y no se reinicia al reconstruir.
                            TweenAnimationBuilder<double>(
                              key: ValueKey('points_${question.id}'),
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 300),
                              child: const Text(
                                '+100 puntos',
                                style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              builder: (context, value, child) => Opacity(
                                opacity: value,
                                child: Transform.scale(
                                  scale: 0.8 + 0.2 * value,
                                  alignment: Alignment.centerLeft,
                                  child: child,
                                ),
                              ),
                            )
                          else
                            Text(
                              'Respuesta correcta: ${question.options[question.correctAnswerIndex]}',
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 18,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _nextQuestion,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: const Color(0xFF101329),
                      ),
                      child: Text(
                        _questionIndex == _questions.length - 1
                            ? 'Ver resultado'
                            : 'Siguiente pregunta',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
