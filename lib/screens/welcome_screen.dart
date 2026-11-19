import 'package:flutter/material.dart';

import 'login_screen.dart';
import '../services/auth_service.dart';
import '../services/avatar_service.dart';
import '../services/progress_service.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    this.authService = const UnavailableAuthService(),
    this.progressService = const UnavailableProgressService(),
    this.avatarService,
  });

  final AuthService authService;
  final ProgressService progressService;
  final AvatarService? avatarService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF101329), Color(0xFF36235E)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      Icon(Icons.auto_awesome, color: Colors.white70),
                      Icon(Icons.star, color: Colors.amber, size: 14),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Icon(
                    Icons.rocket_launch,
                    size: 110,
                    color: Colors.deepPurpleAccent,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'RetroQuiz',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Aventura Multiverso',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, color: Colors.amberAccent),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Un viaje de conocimiento entre estrellas y mundos.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  if (authService.configurationMessage != null) ...[
                    Text(
                      authService.configurationMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.amberAccent),
                    ),
                    const SizedBox(height: 16),
                  ],
                  FilledButton.icon(
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Comenzar aventura'),
                    onPressed: () {
                      // Apila el login para poder regresar a la bienvenida.
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => LoginScreen(
                            authService: authService,
                            progressService: progressService,
                            avatarService: avatarService,
                          ),
                        ),
                      );
                    },
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
