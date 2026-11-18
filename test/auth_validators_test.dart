import 'package:flutter_test/flutter_test.dart';
import 'package:retroquiz/utils/auth_validators.dart';
import 'package:retroquiz/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Correo obligatorio, formato válido y espacios exteriores', () {
    for (final email in [
      null,
      '',
      ' ',
      'sin-arroba',
      'a@b',
      'a@@b.com',
      'a b@c.com',
      'a@b..com',
    ]) {
      expect(validateEmail(email), isNotNull, reason: '$email');
    }
    expect(validateEmail(' jugador+quiz@example.com '), isNull);
  });

  test(
    'Login exige contraseña sin aplicar reglas nuevas a cuentas existentes',
    () {
      expect(validateLoginPassword(null), isNotNull);
      expect(validateLoginPassword(''), isNotNull);
      expect(validateLoginPassword('anterior'), isNull);
    },
  );

  test('Registro exige longitud y los cuatro tipos de caracteres', () {
    for (final password in [
      null,
      '',
      'Aa1!',
      'abcdef1!',
      'ABCDEF1!',
      'Abcdefg!',
      'Abcdefg1',
      'Abcdef1 ',
    ]) {
      expect(
        validateRegistrationPassword(password),
        isNotNull,
        reason: '$password',
      );
    }
    expect(validateRegistrationPassword('Abcdef1!'), isNull);
    expect(validatePasswordConfirmation('', 'Abcdef1!'), isNotNull);
    expect(validatePasswordConfirmation('Abcdef2!', 'Abcdef1!'), isNotNull);
    expect(validatePasswordConfirmation('Abcdef1!', 'Abcdef1!'), isNull);
  });

  test('Errores comprensibles sin mostrar detalles internos', () {
    expect(
      authErrorMessage(
        const AuthException('internal', code: 'invalid_credentials'),
      ),
      'El correo o la contraseña son incorrectos.',
    );
    expect(
      authErrorMessage(
        const AuthException('internal', code: 'email_not_confirmed'),
      ),
      contains('Confirma tu correo'),
    );
    expect(
      authErrorMessage(const AuthException('internal', statusCode: '429')),
      contains('Demasiados intentos'),
    );
    expect(
      authErrorMessage(Exception('internal')),
      contains('Revisa tu conexión'),
    );
    expect(
      authErrorMessage(const AuthException('internal')),
      isNot(contains('internal')),
    );
  });
}
