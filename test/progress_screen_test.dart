import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroquiz/data/questions_data.dart';
import 'package:retroquiz/models/world_progress.dart';
import 'package:retroquiz/screens/world_map_screen.dart';
import 'package:retroquiz/services/progress_service.dart';

class FakeProgressService extends ProgressService {
  @override
  String? currentUserId = 'jugador';
  WorldProgress? stored;
  int loads = 0;
  int saves = 0;
  bool offline = false;
  Completer<void>? pendingSave;

  @override
  Future<WorldProgress?> loadVolcanicProgress() async {
    loads++;
    if (offline) throw const SocketException('Sin conexión');
    return stored;
  }

  @override
  Future<WorldProgress> saveVolcanicProgress({
    required String userId,
    required int score,
  }) async {
    saves++;
    if (pendingSave != null) await pendingSave!.future;
    if (offline) throw const SocketException('Sin conexión');
    if (userId != currentUserId) throw StateError('Sesión cambiada');
    final best = stored?.bestScore ?? 0;
    return stored = WorldProgress(
      userId: userId,
      worldId: volcanicWorldId,
      bestScore: score > best ? score : best,
      completed: true,
    );
  }
}

Future<void> openMap(
  WidgetTester tester,
  FakeProgressService service, {
  bool demo = false,
}) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: WorldMapScreen(isDemo: demo, progressService: service),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> tapLabel(WidgetTester tester, String label) async {
  final target = find.text(label);
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> finishGame(
  WidgetTester tester,
  int correctCount, {
  VoidCallback? beforeFinish,
}) async {
  await tapLabel(tester, '1. Planeta Volcánico');
  for (int i = 0; i < 10; i++) {
    final question = questionsData.singleWhere(
      (q) => find.text(q.text).evaluate().isNotEmpty,
    );
    final correctText = question.options[question.correctAnswerIndex];
    final options = tester
        .widgetList<OutlinedButton>(find.byType(OutlinedButton))
        .toList();
    final correct = options.indexWhere(
      (button) => (button.child! as Text).data!.substring(3) == correctText,
    );
    final answer = find.byKey(
      ValueKey('answer_${i < correctCount ? correct : (correct + 1) % 4}'),
    );
    await tester.ensureVisible(answer);
    await tester.tap(answer);
    await tester.pumpAndSettle();
    if (i == 9) beforeFinish?.call();
    await tapLabel(tester, i == 9 ? 'Ver resultado' : 'Siguiente pregunta');
  }
}

void main() {
  testWidgets(
    'Guarda al terminar, conserva el récord y recupera al volver a entrar',
    (tester) async {
      final service = FakeProgressService();
      await openMap(tester, service);
      expect(find.text('Desbloqueado · Próximamente'), findsNothing);
      await finishGame(tester, 8);
      expect(service.saves, 1);
      expect(
        find.text('Progreso guardado. Reino Arcoíris desbloqueado.'),
        findsOneWidget,
      );
      await tapLabel(tester, 'Volver al mapa');
      expect(find.text('Mejor puntuación: 800'), findsOneWidget);
      expect(find.text('Completado'), findsOneWidget);
      expect(find.text('Desbloqueado · Próximamente'), findsOneWidget);
      await tapLabel(tester, '2. Reino Arcoíris');
      expect(
        find.textContaining('Sus preguntas estarán disponibles'),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 5));
      await finishGame(tester, 2);
      await tapLabel(tester, 'Volver al mapa');
      expect(find.text('Mejor puntuación: 800'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await openMap(tester, service);
      expect(find.text('Mejor puntuación: 800'), findsOneWidget);
      expect(find.text('Desbloqueado · Próximamente'), findsOneWidget);
    },
  );

  testWidgets('Demo con sesión existente no consulta ni guarda progreso', (
    tester,
  ) async {
    final service = FakeProgressService();
    await openMap(tester, service, demo: true);
    await finishGame(tester, 10);
    expect(
      find.text('Demostración: el progreso no se guarda.'),
      findsOneWidget,
    );
    await tapLabel(tester, 'Volver al mapa');
    expect(service.loads, 0);
    expect(service.saves, 0);
    expect(find.text('Desbloqueado · Próximamente'), findsNothing);
  });

  testWidgets('Abandonar antes de terminar no guarda', (tester) async {
    final service = FakeProgressService();
    await openMap(tester, service);
    await tapLabel(tester, '1. Planeta Volcánico');
    await tester.tap(find.byKey(const ValueKey('answer_0')));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(service.saves, 0);
    expect(find.text('Desbloqueado · Próximamente'), findsNothing);
  });

  testWidgets('Errores de carga y guardado permiten reintentar', (
    tester,
  ) async {
    final service = FakeProgressService()..offline = true;
    await openMap(tester, service);
    expect(
      find.textContaining('No se pudo cargar el progreso.'),
      findsOneWidget,
    );
    service.offline = false;
    await tapLabel(tester, 'Reintentar carga');
    expect(service.loads, 2);
    expect(find.textContaining('No se pudo cargar el progreso.'), findsNothing);
    service.offline = true;
    await finishGame(tester, 0);
    expect(
      find.textContaining('No se pudo guardar el progreso.'),
      findsOneWidget,
    );
    expect(find.textContaining('Progreso guardado.'), findsNothing);
    service.offline = false;
    service.pendingSave = Completer<void>();
    final callback = tester
        .widget<TextButton>(
          find.widgetWithText(TextButton, 'Reintentar guardado'),
        )
        .onPressed!;
    callback();
    callback();
    await tester.pump();
    expect(service.saves, 2);
    expect(find.text('Guardando progreso…'), findsOneWidget);
    service.pendingSave!.complete();
    await tester.pumpAndSettle();
    await tapLabel(tester, 'Volver al mapa');
    expect(find.text('Mejor puntuación: 0'), findsOneWidget);
    expect(find.text('Desbloqueado · Próximamente'), findsOneWidget);
  });

  testWidgets('Cambiar de usuario durante una partida impide guardar', (
    tester,
  ) async {
    final service = FakeProgressService();
    await openMap(tester, service);
    await finishGame(
      tester,
      6,
      beforeFinish: () => service.currentUserId = null,
    );
    expect(
      find.textContaining('No se pudo guardar el progreso.'),
      findsOneWidget,
    );
    expect(service.stored, isNull);
  });
}
