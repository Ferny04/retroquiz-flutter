import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/welcome_screen.dart';
import 'services/auth_service.dart';
import 'services/progress_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  AuthService authService = const UnavailableAuthService();
  ProgressService progressService = const UnavailableProgressService();
  if (key.isNotEmpty && key.startsWith('sb_publishable_')) {
    try {
      await Supabase.initialize(
        url: 'https://gnpsqairefmqaudvkovv.supabase.co',
        publishableKey: key,
        debug: false,
      );
      authService = SupabaseAuthService(Supabase.instance.client);
      progressService = SupabaseProgressService(Supabase.instance.client);
    } catch (_) {
      authService = const UnavailableAuthService(
        'No se pudo inicializar Supabase. Revisa la configuración y reinicia la aplicación. '
        'La vista previa sigue disponible.',
      );
    }
  } else if (key.isNotEmpty) {
    authService = const UnavailableAuthService(
      'Configura SUPABASE_PUBLISHABLE_KEY con una Publishable key (sb_publishable_). '
      'No uses claves secretas ni contraseñas de base de datos.',
    );
  }
  runApp(
    RetroQuizApp(authService: authService, progressService: progressService),
  );
}

class RetroQuizApp extends StatelessWidget {
  const RetroQuizApp({
    super.key,
    this.authService = const UnavailableAuthService(),
    this.progressService = const UnavailableProgressService(),
  });

  final AuthService authService;
  final ProgressService progressService;

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
      home: WelcomeScreen(
        authService: authService,
        progressService: progressService,
      ),
    );
  }
}
