import 'package:flutter/material.dart';

import '../models/world_progress.dart';
import '../services/avatar_service.dart';
import '../services/progress_service.dart';
import '../widgets/player_avatar_button.dart';
import 'quiz_screen.dart';

class WorldMapScreen extends StatefulWidget {
  const WorldMapScreen({
    super.key,
    this.isDemo = true,
    this.progressService = const UnavailableProgressService(),
    this.avatarService,
  });

  final bool isDemo;
  final ProgressService progressService;
  final AvatarService? avatarService;

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen> {
  WorldProgress? _progress;
  bool _loading = false;
  String? _error;

  bool get _secondWorldUnlocked =>
      !widget.isDemo && _progress?.completed == true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    if (widget.isDemo || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
      _progress = null;
    });
    try {
      final progress = await widget.progressService.loadVolcanicProgress();
      if (!mounted) return;
      setState(() => _progress = progress);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _error =
            'No se pudo cargar el progreso. Revisa tu conexión y reintenta.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openVolcanicWorld() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => QuizScreen(
          isDemo: widget.isDemo,
          progressService: widget.progressService,
        ),
      ),
    );
    if (mounted) await _loadProgress();
  }

  void _showSecondWorld() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Reino Arcoíris desbloqueado. Sus preguntas estarán disponibles próximamente.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const nombres = [
      'Planeta Volcánico',
      'Reino Arcoíris',
      'Planeta Glacial',
      'Selva Cósmica',
      'Ciudad Neón',
      'Núcleo del Universo',
    ];
    const iconos = [
      Icons.local_fire_department,
      Icons.looks,
      Icons.ac_unit,
      Icons.forest,
      Icons.location_city,
      Icons.auto_awesome,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de mundos'),
        actions: [
          if (widget.avatarService case final service? when !widget.isDemo)
            PlayerAvatarButton(service: service),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ScrollConfiguration(
              // Material 3 estira el contenido al sobrepasar los extremos en
              // Android. Desactiva solo ese efecto, sin cambiar el scroll.
              behavior: ScrollConfiguration.of(context)
                  .copyWith(overscroll: false),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (widget.isDemo) ...[
                    const Text(
                      'Demostración · Sin sesión de usuario. El progreso no se guarda.',
                      style: TextStyle(color: Colors.amberAccent),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text(
                    'Explora el multiverso',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _secondWorldUnlocked
                        ? 'Reino Arcoíris desbloqueado. Próximamente tendrá preguntas.'
                        : 'Completa el Planeta Volcánico para desbloquear Reino Arcoíris.',
                  ),
                  if (_loading) const LinearProgressIndicator(),
                  if (_error != null) ...[
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.amberAccent),
                    ),
                    TextButton(
                      onPressed: _loadProgress,
                      child: const Text('Reintentar carga'),
                    ),
                  ],
                  if (_progress != null)
                    Text('Mejor puntuación: ${_progress!.bestScore}'),
                  const SizedBox(height: 20),
                  for (int i = 0; i < nombres.length; i++)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: i == 0
                            ? const Color(0xFF432D32)
                            : const Color(0xFF202338),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: i == 0 ? Colors.orangeAccent : Colors.white24,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _loading
                            ? null
                            : i == 0
                            ? _openVolcanicWorld
                            : i == 1 && _secondWorldUnlocked
                            ? _showSecondWorld
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                iconos[i],
                                size: 36,
                                color:
                                    i == 0 || (i == 1 && _secondWorldUnlocked)
                                    ? Colors.orangeAccent
                                    : Colors.white38,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${i + 1}. ${nombres[i]}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('${i == 5 ? 20 : 10} preguntas'),
                                    Text(
                                      i == 0
                                          ? _progress?.completed == true
                                                ? 'Completado'
                                                : 'Disponible'
                                          : i == 1 && _secondWorldUnlocked
                                          ? 'Desbloqueado · Próximamente'
                                          : 'Bloqueado',
                                      style: TextStyle(
                                        color: i == 0
                                            ? Colors.orangeAccent
                                            : Colors.white54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                i == 0 || (i == 1 && _secondWorldUnlocked)
                                    ? Icons.lock_open
                                    : Icons.lock,
                                color:
                                    i == 0 || (i == 1 && _secondWorldUnlocked)
                                    ? Colors.orangeAccent
                                    : Colors.white38,
                              ),
                            ],
                          ),
                        ),
                      ),
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
