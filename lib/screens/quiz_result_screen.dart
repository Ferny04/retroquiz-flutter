import 'package:flutter/material.dart';

import '../services/progress_service.dart';

class QuizResultScreen extends StatefulWidget {
  const QuizResultScreen({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    this.isDemo = true,
    this.userId,
    this.progressService = const UnavailableProgressService(),
  });

  final int correctAnswers;
  final int totalQuestions;
  final bool isDemo;
  final String? userId;
  final ProgressService progressService;

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  bool _saving = false;
  bool _saved = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _saveProgress();
  }

  Future<void> _saveProgress() async {
    if (widget.isDemo || _saving || _saved) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (widget.userId == null || widget.totalQuestions != 10) {
        throw StateError('Se necesita una partida completa con sesión.');
      }
      await widget.progressService.saveVolcanicProgress(
        userId: widget.userId!,
        score: widget.correctAnswers * 100,
      );
      if (!mounted) return;
      setState(() => _saved = true);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _error = 'No se pudo guardar el progreso. Revisa tu conexión y sesión, y reintenta antes de salir.',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

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
                          Text('Correctas: ${widget.correctAnswers}'),
                          const SizedBox(height: 12),
                          Text(
                            'Incorrectas: ${widget.totalQuestions - widget.correctAnswers}',
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Puntuación total: ${widget.correctAnswers * 100}',
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
                  if (widget.isDemo)
                    const Text('Demostración: el progreso no se guarda.'),
                  if (_saving) const Text('Guardando progreso…'),
                  if (_saved)
                    const Text(
                      'Progreso guardado. Reino Arcoíris desbloqueado.',
                    ),
                  if (_error != null) ...[
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.amberAccent),
                    ),
                    TextButton(
                      onPressed: _saveProgress,
                      child: const Text('Reintentar guardado'),
                    ),
                    const Text(
                      'Si sales ahora, este resultado no se conservará para reintentar.',
                    ),
                  ],
                  FilledButton.icon(
                    onPressed: _saving ? null : () => Navigator.pop(context),
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
