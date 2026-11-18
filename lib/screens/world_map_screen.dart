import 'package:flutter/material.dart';

import 'quiz_screen.dart';

class WorldMapScreen extends StatelessWidget {
  const WorldMapScreen({super.key, this.isDemo = true});

  final bool isDemo;

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
      appBar: AppBar(title: const Text('Mapa de mundos')),
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
                  if (isDemo) ...[
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
                  const Text(
                    'Juega el Planeta Volcánico. Los demás mundos siguen bloqueados.',
                  ),
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
                        onTap: i == 0
                            ? () => Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (context) => const QuizScreen(),
                                ),
                              )
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                iconos[i],
                                size: 36,
                                color: i == 0
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
                                      i == 0 ? 'Disponible' : 'Bloqueado',
                                      style: TextStyle(
                                        color: i == 0
                                            ? Colors.orangeAccent
                                            : Colors.white54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Los otros cinco mundos permanecen bloqueados.
                              Icon(
                                i == 0 ? Icons.lock_open : Icons.lock,
                                color: i == 0
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
