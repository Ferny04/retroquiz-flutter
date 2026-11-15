import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroquiz/main.dart';

void main() {
  testWidgets('La bienvenida presenta el acceso a la aventura', (tester) async {
    await tester.pumpWidget(const RetroQuizApp());
    expect(find.text('RetroQuiz'), findsOneWidget);
    expect(find.text('Aventura Multiverso'), findsOneWidget);
    expect(find.text('Comenzar aventura'), findsOneWidget);
  });

  testWidgets('El login informa lo pendiente y abre la vista previa', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const RetroQuizApp());
    await tester.tap(find.text('Comenzar aventura'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final password = find.widgetWithText(TextField, 'Contraseña');
    expect(tester.widget<TextField>(password).obscureText, isTrue);
    await tester.enterText(password, 'ejemplo');
    await tester.tap(find.byTooltip('Mostrar contraseña'));
    await tester.pump();
    expect(tester.widget<TextField>(password).obscureText, isFalse);

    final iniciar = find.widgetWithText(FilledButton, 'Iniciar sesión');
    await tester.ensureVisible(iniciar);
    await tester.tap(iniciar);
    await tester.pump();
    expect(
      find.text('El inicio de sesión está pendiente de implementar.'),
      findsWidgets,
    );
    expect(find.text('Mapa de mundos'), findsNothing);

    final vistaPrevia = find.text('Vista previa de mundos');
    await tester.ensureVisible(vistaPrevia);
    await tester.tap(vistaPrevia);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Mapa de mundos'), findsOneWidget);
    expect(find.text('Disponible'), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsNWidgets(5));
    expect(find.text('10 preguntas'), findsNWidgets(5));
    expect(find.text('20 preguntas'), findsOneWidget);

    await tester.pageBack();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Vista previa de mundos'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
