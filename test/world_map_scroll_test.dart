import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroquiz/screens/world_map_screen.dart';

void main() {
  for (final size in [const Size(320, 568), const Size(390, 844)]) {
    for (final isDemo in [true, false]) {
      testWidgets(
        'Android $size, demo=$isDemo: conserva proporciones durante overscroll',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData.dark(useMaterial3: true)
                  .copyWith(platform: TargetPlatform.android),
              home: WorldMapScreen(isDemo: isDemo),
            ),
          );
          final scrollable = tester.state<ScrollableState>(
            find.byType(Scrollable),
          );
          await tester.scrollUntilVisible(
            find.text('6. Núcleo del Universo'),
            150,
          );
          scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
          await tester.pumpAndSettle();

          void expectNormalScale(Finder finder) {
            final box = tester.renderObject<RenderBox>(finder);
            // Medir la transformación de pintura también detecta estiramientos
            // que no cambian el tamaño del layout de textos o iconos.
            final transform = box.getTransformTo(null);
            expect(transform.entry(0, 0), closeTo(1, 0.00001));
            expect(transform.entry(1, 1), closeTo(1, 0.00001));
          }

          final bottomText = find.text('6. Núcleo del Universo');
          final bottomIcon = find.byIcon(Icons.auto_awesome);
          expectNormalScale(bottomText);
          expectNormalScale(bottomIcon);
          final gesture = await tester.startGesture(
            tester.getCenter(find.byType(ListView)),
          );
          await gesture.moveBy(const Offset(0, -80));
          await tester.pump(const Duration(milliseconds: 16));
          await gesture.moveBy(const Offset(0, -120));
          await tester.pump(const Duration(milliseconds: 100));
          // Comprobar ANTES de soltar: pumpAndSettle ocultaría el defecto.
          for (final title in [
            '4. Selva Cósmica',
            '5. Ciudad Neón',
            '6. Núcleo del Universo',
          ]) {
            final text = find.text(title);
            expectNormalScale(text);
            expectNormalScale(
              find.ancestor(of: text, matching: find.byType(InkWell)),
            );
          }
          for (final icon in [
            Icons.forest,
            Icons.location_city,
            Icons.auto_awesome,
          ]) {
            expectNormalScale(find.byIcon(icon));
          }
          await gesture.up();
          await tester.pumpAndSettle();
          expect(
            scrollable.position.pixels,
            closeTo(scrollable.position.maxScrollExtent, 0.1),
          );

          scrollable.position.jumpTo(0);
          await tester.pumpAndSettle();
          final topGesture = await tester.startGesture(
            tester.getCenter(find.byType(ListView)),
          );
          await topGesture.moveBy(const Offset(0, 80));
          await tester.pump(const Duration(milliseconds: 16));
          await topGesture.moveBy(const Offset(0, 120));
          await tester.pump(const Duration(milliseconds: 100));
          expectNormalScale(find.text('1. Planeta Volcánico'));
          expectNormalScale(find.byIcon(Icons.local_fire_department));
          await topGesture.up();
          await tester.pumpAndSettle();
          expect(scrollable.position.pixels, closeTo(0, 0.1));
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final isDemo in [true, false]) {
      testWidgets(
        'Mapa en $platform, demo=$isDemo: desplazamiento en pantalla pequeña',
        (tester) async {
          tester.view.physicalSize = const Size(320, 568);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData.dark(useMaterial3: true)
                  .copyWith(platform: platform),
              home: WorldMapScreen(isDemo: isDemo),
            ),
          );
          // Un solo desplazamiento; se puede llegar a ambos extremos sin overflow.
          expect(find.byType(Scrollable), findsOneWidget);
          final state = tester.state<ScrollableState>(find.byType(Scrollable));
          expect(state.position.pixels, 0);
          expect(state.position.maxScrollExtent, greaterThan(0));
          await tester.scrollUntilVisible(
            find.text('6. Núcleo del Universo'),
            150,
          );
          await tester.pumpAndSettle();
          expect(
            find.text('6. Núcleo del Universo').hitTestable(),
            findsOneWidget,
          );
          await tester.fling(
            find.byType(ListView),
            const Offset(0, -600),
            1500,
          );
          await tester.pumpAndSettle();
          expect(
            state.position.pixels,
            closeTo(state.position.maxScrollExtent, 0.1),
          );
          await tester.fling(
            find.byType(ListView),
            const Offset(0, 1600),
            3000,
          );
          await tester.pumpAndSettle();
          expect(state.position.pixels, closeTo(0, 0.1));
          expect(
            find.text('Explora el multiverso').hitTestable(),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
