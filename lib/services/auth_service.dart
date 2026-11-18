import 'package:supabase_flutter/supabase_flutter.dart';

const missingAuthConfiguration =
    'Falta configurar Supabase. Ejecuta Flutter con '
    '--dart-define=SUPABASE_PUBLISHABLE_KEY=TU_PUBLISHABLE_KEY. '
    'La vista previa sigue disponible.';

/// Permite comprobar los formularios sin acceder a una cuenta real.
abstract class AuthService {
  const AuthService();

  String? get configurationMessage => null;
  Future<bool> signIn({required String email, required String password});
  Future<bool> signUp({required String email, required String password});
}

class UnavailableAuthService extends AuthService {
  const UnavailableAuthService([this.message = missingAuthConfiguration]);

  final String message;

  @override
  String get configurationMessage => message;

  @override
  Future<bool> signIn({
    required String email,
    required String password,
  }) async => throw StateError(message);

  @override
  Future<bool> signUp({
    required String email,
    required String password,
  }) async => throw StateError(message);
}

class SupabaseAuthService extends AuthService {
  const SupabaseAuthService(this.client);

  final SupabaseClient client;

  @override
  Future<bool> signIn({required String email, required String password}) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.session != null;
  }

  @override
  Future<bool> signUp({required String email, required String password}) async {
    final response = await client.auth.signUp(email: email, password: password);
    // Un usuario sin sesión debe confirmar su correo antes de entrar al mapa.
    return response.session != null;
  }
}

String authErrorMessage(Object error) {
  if (error is AuthException) {
    switch (error.code) {
      case 'invalid_credentials':
        return 'El correo o la contraseña son incorrectos.';
      case 'email_not_confirmed':
        return 'Confirma tu correo electrónico antes de iniciar sesión.';
      case 'user_already_exists':
      case 'email_exists':
        return 'Ya existe una cuenta con ese correo. Intenta iniciar sesión.';
      case 'weak_password':
        return 'La contraseña no cumple los requisitos de seguridad.';
      case 'email_address_invalid':
      case 'validation_failed':
        return 'Revisa el correo y los datos ingresados.';
      case 'over_email_send_rate_limit':
      case 'over_request_rate_limit':
        return 'Demasiados intentos. Espera unos minutos y vuelve a intentarlo.';
      case 'signup_disabled':
        return 'El registro de cuentas no está disponible en este momento.';
    }
    // Compatibilidad con respuestas que solo incluyen el estado HTTP.
    if (error.statusCode == '429') {
      return 'Demasiados intentos. Espera unos minutos y vuelve a intentarlo.';
    }
    if (error is! AuthRetryableFetchException) {
      return 'No se pudo completar la autenticación. Revisa los datos e inténtalo de nuevo.';
    }
  }
  // No mostrar excepciones crudas que puedan contener datos de la solicitud.
  return 'No se pudo conectar con Supabase. Revisa tu conexión e inténtalo de nuevo.';
}
