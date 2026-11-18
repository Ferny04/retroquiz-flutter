import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroquiz/main.dart';
import 'package:retroquiz/screens/email_confirmation_screen.dart';
import 'package:retroquiz/screens/register_screen.dart';
import 'package:retroquiz/screens/world_map_screen.dart';
import 'package:retroquiz/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAuthService extends AuthService {
  int loginCalls = 0;
  int signupCalls = 0;
  String? lastEmail;
  String? lastPassword;
  bool hasSession = true;
  Object? error;
  Completer<bool>? pending;

  Future<bool> _respond(String email, String password) async {
    lastEmail = email;
    lastPassword = password;
    if (error != null) throw error!;
    return pending == null ? hasSession : pending!.future;
  }

  @override
  Future<bool> signIn({required String email, required String password}) {
    loginCalls++;
    return _respond(email, password);
  }

  @override
  Future<bool> signUp({required String email, required String password}) {
    signupCalls++;
    return _respond(email, password);
  }
}

Future<void> tapText(WidgetTester tester, String label) async {
  final button = find.ancestor(
    of: find.text(label),
    matching: find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
  );
  final target = button.evaluate().isNotEmpty
      ? button.last
      : find.text(label).last;
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.pump();
}

Future<void> openLogin(WidgetTester tester, AuthService auth) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(RetroQuizApp(authService: auth));
  await tapText(tester, 'Comenzar aventura');
}

Future<void> fillLogin(WidgetTester tester) async {
  await tester.enterText(
    find.byType(TextFormField).at(0),
    ' jugador@example.com ',
  );
  await tester.enterText(find.byType(TextFormField).at(1), 'Abcdef1!');
}

Future<void> fillRegistration(WidgetTester tester) async {
  await fillLogin(tester);
  await tester.enterText(find.byType(TextFormField).at(2), 'Abcdef1!');
}

Future<void> disposeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump();
}

void main() {
  testWidgets('Login valida campos antes de solicitar una sesión', (
    tester,
  ) async {
    final auth = FakeAuthService();
    await openLogin(tester, auth);
    await tapText(tester, 'Iniciar sesión');
    expect(find.text('Ingresa tu correo electrónico.'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'invalido');
    await tapText(tester, 'Iniciar sesión');
    expect(find.text('Ingresa un correo electrónico válido.'), findsOneWidget);
    expect(auth.loginCalls, 0);
    expect(find.byType(WorldMapScreen), findsNothing);
    await disposeApp(tester);
  });

  testWidgets('Login bloquea solicitudes duplicadas y abre mapa con sesión', (
    tester,
  ) async {
    final auth = FakeAuthService()..pending = Completer<bool>();
    await openLogin(tester, auth);
    await fillLogin(tester);
    final callback = tester
        .widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Iniciar sesión'),
        )
        .onPressed!;
    callback();
    callback();
    await tester.pump();
    expect(auth.loginCalls, 1);
    expect(auth.lastEmail, 'jugador@example.com');
    expect(auth.lastPassword, 'Abcdef1!');
    expect(find.bySemanticsLabel('Iniciando sesión'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(find.byType(WorldMapScreen), findsNothing);
    auth.pending!.complete(true);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(
      tester.widget<WorldMapScreen>(find.byType(WorldMapScreen)).isDemo,
      isFalse,
    );
    expect(find.textContaining('Demostración · Sin sesión'), findsNothing);
    await tester.pageBack();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Comenzar aventura'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('Credenciales incorrectas permiten reintentar sin navegar', (
    tester,
  ) async {
    final auth = FakeAuthService()
      ..error = const AuthException('invalid', code: 'invalid_credentials');
    await openLogin(tester, auth);
    await fillLogin(tester);
    await tapText(tester, 'Iniciar sesión');
    expect(
      find.text('El correo o la contraseña son incorrectos.'),
      findsOneWidget,
    );
    expect(find.byType(WorldMapScreen), findsNothing);
    auth.error = null;
    auth.hasSession = false;
    await tapText(tester, 'Iniciar sesión');
    expect(auth.loginCalls, 2);
    expect(
      find.textContaining('No se recibió una sesión válida'),
      findsOneWidget,
    );
    expect(find.byType(WorldMapScreen), findsNothing);
    await disposeApp(tester);
  });

  testWidgets('Error de red no abre mapa y vuelve a habilitar login', (
    tester,
  ) async {
    final auth = FakeAuthService()..error = Exception('network');
    await openLogin(tester, auth);
    await fillLogin(tester);
    await tapText(tester, 'Iniciar sesión');
    expect(find.textContaining('Revisa tu conexión'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
    expect(find.byType(WorldMapScreen), findsNothing);
    await disposeApp(tester);
  });

  testWidgets('Registro valida seguridad y confirmación antes de enviar', (
    tester,
  ) async {
    final auth = FakeAuthService();
    await openLogin(tester, auth);
    await tapText(tester, 'Crear una cuenta');
    await tapText(tester, 'Crear cuenta');
    expect(find.text('Ingresa tu correo electrónico.'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña.'), findsOneWidget);
    expect(find.text('Confirma tu contraseña.'), findsOneWidget);
    await fillRegistration(tester);
    await tester.enterText(find.byType(TextFormField).at(1), 'debil');
    await tapText(tester, 'Crear cuenta');
    expect(find.textContaining('Usa al menos 8 caracteres'), findsOneWidget);
    expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
    expect(auth.signupCalls, 0);
    await tapText(tester, 'Volver al inicio de sesión');
    expect(find.text('Prepara tu aventura'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets(
    'Registro sin sesión solicita confirmar correo y evita reenvíos',
    (tester) async {
      final auth = FakeAuthService()..pending = Completer<bool>();
      await openLogin(tester, auth);
      await tapText(tester, 'Crear una cuenta');
      await fillRegistration(tester);
      final callback = tester
          .widget<FilledButton>(find.byType(FilledButton))
          .onPressed!;
      callback();
      callback();
      await tester.pump();
      expect(auth.signupCalls, 1);
      expect(auth.lastEmail, 'jugador@example.com');
      expect(find.bySemanticsLabel('Creando cuenta'), findsOneWidget);
      auth.pending!.complete(false);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('¡Revisa tu correo!'), findsOneWidget);
      expect(find.byType(RegisterScreen), findsNothing);
      expect(find.byType(WorldMapScreen), findsNothing);
      await tapText(tester, 'Ir a iniciar sesión');
      expect(find.text('Prepara tu aventura'), findsOneWidget);
      expect(auth.loginCalls, 0);
      expect(auth.signupCalls, 1);
      await tester.pageBack();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Comenzar aventura'), findsOneWidget);
      await disposeApp(tester);
    },
  );

  testWidgets('Registro con sesión real abre mapa autenticado', (tester) async {
    final auth = FakeAuthService();
    await openLogin(tester, auth);
    await tapText(tester, 'Crear una cuenta');
    await fillRegistration(tester);
    await tapText(tester, 'Crear cuenta');
    await tester.pump(const Duration(seconds: 1));
    expect(auth.signupCalls, 1);
    expect(find.byType(EmailConfirmationScreen), findsNothing);
    expect(
      tester.widget<WorldMapScreen>(find.byType(WorldMapScreen)).isDemo,
      isFalse,
    );
    await tester.pageBack();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Comenzar aventura'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('Los ojos del registro muestran cada contraseña por separado', (
    tester,
  ) async {
    final auth = FakeAuthService();
    await openLogin(tester, auth);
    await tapText(tester, 'Crear una cuenta');
    await fillRegistration(tester);
    bool hidden(int index) => tester
        .widget<TextField>(
          find.descendant(
            of: find.byType(TextFormField).at(index),
            matching: find.byType(TextField),
          ),
        )
        .obscureText;
    expect(hidden(1), isTrue);
    expect(hidden(2), isTrue);
    expect(find.byIcon(Icons.visibility), findsNWidgets(2));
    await tester.tap(find.byTooltip('Mostrar contraseña'));
    await tester.pump();
    expect(hidden(1), isFalse);
    expect(hidden(2), isTrue);
    await tester.tap(find.byTooltip('Mostrar confirmación de contraseña'));
    await tester.pump();
    expect(hidden(1), isFalse);
    expect(hidden(2), isFalse);
    expect(find.byIcon(Icons.visibility_off), findsNWidgets(2));
    await tester.tap(find.byTooltip('Ocultar contraseña'));
    await tester.pump();
    expect(hidden(1), isTrue);
    expect(hidden(2), isFalse);
    await tester.tap(find.byTooltip('Ocultar confirmación de contraseña'));
    await tester.pump();
    expect(hidden(2), isTrue);
    final values = tester
        .widgetList<TextField>(find.byType(TextField))
        .map((field) => field.controller!.text)
        .toList();
    expect(values, [' jugador@example.com ', 'Abcdef1!', 'Abcdef1!']);
    expect(auth.signupCalls, 0);
    await disposeApp(tester);
  });

  testWidgets('Error de registro conserva formulario y permite reintentar', (
    tester,
  ) async {
    final auth = FakeAuthService()
      ..error = const AuthException('invalid', code: 'weak_password');
    await openLogin(tester, auth);
    await tapText(tester, 'Crear una cuenta');
    await fillRegistration(tester);
    await tapText(tester, 'Crear cuenta');
    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.byType(EmailConfirmationScreen), findsNothing);
    expect(
      find.text('La contraseña no cumple los requisitos de seguridad.'),
      findsOneWidget,
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
    auth.error = null;
    auth.hasSession = false;
    await tapText(tester, 'Crear cuenta');
    expect(auth.signupCalls, 2);
    expect(find.byType(EmailConfirmationScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Prepara tu aventura'), findsOneWidget);
    expect(find.byType(RegisterScreen), findsNothing);
    await disposeApp(tester);
  });

  testWidgets('Confirmación cabe con pantalla pequeña y texto ampliado', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(1.6)),
          child: EmailConfirmationScreen(),
        ),
      ),
    );
    await tester.ensureVisible(find.text('Ir a iniciar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Ir a iniciar sesión').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await disposeApp(tester);
  });

  testWidgets('Vista previa no llama a autenticación ni altera el login', (
    tester,
  ) async {
    final auth = FakeAuthService();
    await openLogin(tester, auth);
    await tapText(tester, 'Vista previa de mundos');
    expect(
      tester.widget<WorldMapScreen>(find.byType(WorldMapScreen)).isDemo,
      isTrue,
    );
    expect(find.textContaining('Demostración · Sin sesión'), findsOneWidget);
    expect(auth.loginCalls, 0);
    expect(auth.signupCalls, 0);
    await tester.pageBack();
    await tester.pump(const Duration(seconds: 1));
    await fillLogin(tester);
    await tapText(tester, 'Iniciar sesión');
    expect(auth.loginCalls, 1);
    expect(
      tester.widget<WorldMapScreen>(find.byType(WorldMapScreen)).isDemo,
      isFalse,
    );
    await disposeApp(tester);
  });

  testWidgets(
    'Respuesta tardía al salir de login no navega ni usa estado eliminado',
    (tester) async {
      final auth = FakeAuthService()..pending = Completer<bool>();
      await openLogin(tester, auth);
      await fillLogin(tester);
      await tapText(tester, 'Iniciar sesión');
      await tester.pageBack();
      await tester.pump(const Duration(seconds: 1));
      auth.pending!.complete(true);
      await tester.pump();
      expect(find.text('Comenzar aventura'), findsOneWidget);
      expect(find.byType(WorldMapScreen), findsNothing);
      expect(tester.takeException(), isNull);
      await disposeApp(tester);
    },
  );
}
