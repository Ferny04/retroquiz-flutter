import 'package:flutter/material.dart';

class WorldMapScreen extends StatelessWidget {
  const WorldMapScreen({super.key});

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
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Explora el multiverso',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Vista previa: las preguntas y los desbloqueos están pendientes.',
                ),
                const SizedBox(height: 20),
                for (int i = 0; i < nombres.length; i++)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: i == 0
                          ? const Color(0xFF432D32)
                          : const Color(0xFF202338),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: i == 0 ? Colors.orangeAccent : Colors.white24,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          iconos[i],
                          size: 36,
                          color: i == 0 ? Colors.orangeAccent : Colors.white38,
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
                        // Solo es una indicación visual; no hay desbloqueos.
                        Icon(
                          i == 0 ? Icons.lock_open : Icons.lock,
                          color: i == 0 ? Colors.orangeAccent : Colors.white38,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
