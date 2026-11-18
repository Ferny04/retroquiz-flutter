import 'package:flutter/material.dart';

class EmailConfirmationScreen extends StatelessWidget {
  const EmailConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Semantics(
                        label: 'Correo de confirmación enviado',
                        image: true,
                        child: const ExcludeSemantics(
                          child: SizedBox(
                            width: 144,
                            height: 144,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF36235E),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(28),
                                    child: Icon(
                                      Icons.mark_email_read_outlined,
                                      size: 72,
                                      color: Colors.amberAccent,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 4,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Color(0xFF101329),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.greenAccent,
                                        size: 36,
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
                    const SizedBox(height: 32),
                    const Text(
                      '¡Revisa tu correo!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Te enviamos un enlace de confirmación. Abre tu correo electrónico y verifica tu cuenta para comenzar tu aventura',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.login),
                      label: const Text('Ir a iniciar sesión'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
