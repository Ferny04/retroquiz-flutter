import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroquiz/data/questions_data.dart';
import 'package:retroquiz/screens/world_map_screen.dart';

void main() {
  for (final correctCount in [0, 6, 10]) {
    testWidgets('Partida con $correctCount aciertos, regreso y reinicio', (
      tester,
    ) async {
      // Ancho de teléfono: las opciones y los mensajes pueden ocupar varias líneas.
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(useMaterial3: true),
          home: const WorldMapScreen(),
        ),
      );
      await tester.tap(find.text('1. Planeta Volcánico'));
      await tester.pumpAndSettle();

      final seen = <String>{};
      final categories = <String>{};
      for (int i = 0; i < 10; i++) {
        expect(find.text('Pregunta ${i + 1} de 10'), findsOneWidget);
        final question = questionsData.singleWhere(
          (q) => find.text(q.text).evaluate().isNotEmpty,
        );
        expect(seen.add(question.id), isTrue);
        categories.add(question.category);
        final isCorrect = i < correctCount;
        final labels = [
          for (int option = 0; option < 4; option++)
            (tester
                        .widget<OutlinedButton>(
                          find.byKey(ValueKey('answer_$option')),
                        )
                        .child!
                    as Text)
                .data!,
        ];
        final correctAnswer = question.options[question.correctAnswerIndex];
        final correctIndex = labels.indexWhere(
          (label) => label.substring(3) == correctAnswer,
        );
        expect(correctIndex, isNonNegative);
        for (int option = 0; option < 4; option++) {
          expect(
            labels[option].startsWith('${String.fromCharCode(65 + option)}) '),
            isTrue,
          );
        }
        final answerIndex = isCorrect ? correctIndex : (correctIndex + 1) % 4;
        final answer = find.byKey(ValueKey('answer_$answerIndex'));
        final originalCallback = tester
            .widget<OutlinedButton>(answer)
            .onPressed!;
        await tester.ensureVisible(answer);
        await tester.tap(answer);
        // Dos toques antes de reconstruir no deben sumar dos veces.
        await tester.tap(answer);
        await tester.pump();
        for (int option = 0; option < 4; option++) {
          final button = tester.widget<OutlinedButton>(
            find.byKey(ValueKey('answer_$option')),
          );
          expect((button.child! as Text).data, labels[option]);
          if (option == correctIndex || option == answerIndex) {
            expect(
              button.style!.backgroundColor!.resolve({WidgetState.disabled}),
              option == correctIndex
                  ? const Color(0xFF1B5E20)
                  : const Color(0xFF8E2424),
            );
          }
          expect(
            tester
                .widget<OutlinedButton>(find.byKey(ValueKey('answer_$option')))
                .onPressed,
            isNull,
          );
        }
        expect(
          find.text(
            'Puntos: ${(i < correctCount ? i + 1 : correctCount) * 100}',
          ),
          findsOneWidget,
        );
        final feedback = find.text(isCorrect ? '¡Correcto!' : '¡Incorrecto!');
        expect(feedback, findsOneWidget);
        expect(
          tester.widget<Text>(feedback).style!.color,
          isCorrect ? Colors.greenAccent : Colors.redAccent,
        );
        if (isCorrect) {
          final points = find.byKey(ValueKey('points_${question.id}'));
          final opacity = find.descendant(
            of: points,
            matching: find.byType(Opacity),
          );
          final transform = find.descendant(
            of: points,
            matching: find.byType(Transform),
          );
          expect(find.text('+100 puntos'), findsOneWidget);
          expect(tester.widget<Opacity>(opacity).opacity, 0);
          expect(
            tester.widget<Transform>(transform).transform.entry(0, 0),
            closeTo(0.8, 0.001),
          );
          await tester.pump(const Duration(milliseconds: 150));
          expect(
            tester.widget<Opacity>(opacity).opacity,
            allOf(greaterThan(0), lessThan(1)),
          );
          await tester.pump(const Duration(milliseconds: 150));
          expect(tester.widget<Opacity>(opacity).opacity, 1);
          expect(tester.widget<Transform>(transform).transform.entry(0, 0), 1);
          // Un callback antiguo tampoco puede repetir los puntos ni la animación.
          originalCallback();
          await tester.pump();
          expect(tester.widget<Opacity>(opacity).opacity, 1);
          expect(find.text('Puntos: ${(i + 1) * 100}'), findsOneWidget);
        } else {
          final correction = find.text('Respuesta correcta: $correctAnswer');
          expect(correction, findsOneWidget);
          expect(
            tester.widget<Text>(correction).style!.color,
            Colors.greenAccent,
          );
          expect(find.text('+100 puntos'), findsNothing);
        }
        final next = find.text(i == 9 ? 'Ver resultado' : 'Siguiente pregunta');
        await tester.ensureVisible(next);
        await tester.tap(next);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      expect(categories, hasLength(6));
      expect(find.text('Correctas: $correctCount'), findsOneWidget);
      expect(find.text('Incorrectas: ${10 - correctCount}'), findsOneWidget);
      expect(
        find.text('Puntuación total: ${correctCount * 100}'),
        findsOneWidget,
      );
      await tester.ensureVisible(find.text('Volver al mapa'));
      await tester.tap(find.text('Volver al mapa'));
      await tester.pumpAndSettle();
      expect(find.text('Mapa de mundos'), findsOneWidget);
      await tester.tap(find.text('1. Planeta Volcánico'));
      await tester.pumpAndSettle();
      expect(find.text('Pregunta 1 de 10'), findsOneWidget);
      expect(find.text('Puntos: 0'), findsOneWidget);
      expect(find.text('Siguiente pregunta'), findsNothing);
      expect(
        tester
            .widget<OutlinedButton>(find.byKey(const ValueKey('answer_0')))
            .onPressed,
        isNotNull,
      );
      // También se puede abandonar una partida con el botón de retroceso.
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Mapa de mundos'), findsOneWidget);
    });
  }

  testWidgets('Los mundos del dos al seis no abren partidas', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: WorldMapScreen()));
    for (final name in [
      '2. Reino Arcoíris',
      '3. Planeta Glacial',
      '4. Selva Cósmica',
      '5. Ciudad Neón',
      '6. Núcleo del Universo',
    ]) {
      final world = find.text(name);
      await tester.scrollUntilVisible(world, 150);
      await tester.tap(world);
      await tester.pumpAndSettle();
      expect(find.text('Mapa de mundos'), findsOneWidget);
      expect(find.text('Pregunta 1 de 10'), findsNothing);
    }
  });
}
