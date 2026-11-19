import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:retroquiz/screens/world_map_screen.dart';
import 'package:retroquiz/services/avatar_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// PNG válido de un píxel.
final png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAEElEQVR4AQEFAPr/'
  'AP9kAP8GLAJjdNN84QAAAABJRU5ErkJggg==',
);
const firstUser = '00000000-0000-0000-0000-000000000001';
const secondUser = '00000000-0000-0000-0000-000000000002';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Storage de avatares', () {
    late SupabaseClient client;
    late SupabaseAvatarService service;
    late Map<String, Uint8List> stored;
    late int requests;
    late bool storageFails;

    Future<void> signIn(String userId) => client.auth.signInWithPassword(
      email: '$userId@example.com',
      password: 'test',
    );

    setUp(() {
      stored = {};
      requests = 0;
      storageFails = false;
      client = SupabaseClient(
        'https://example.supabase.co',
        'test-key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: MockClient((request) async {
          const endpoint = '/storage/v1/object';
          if (request.url.path.endsWith('/token')) {
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            final email = body['email'] as String;
            final userId = email.split('@').first;
            return http.Response(
              jsonEncode({
                'access_token': 'token-$userId',
                'refresh_token': 'refresh-$userId',
                'token_type': 'bearer',
                'expires_in': 3600,
                'user': {
                  'id': userId,
                  'app_metadata': {},
                  'user_metadata': {},
                  'aud': 'authenticated',
                  'created_at': '2026-01-01T00:00:00Z',
                },
              }),
              200,
            );
          }
          requests++;
          final userId = client.auth.currentUser!.id;
          expect(request.headers['authorization'], 'Bearer token-$userId');
          if (storageFails) return http.Response('Storage no disponible', 503);

          if (request.url.path == '$endpoint/list/player-avatars') {
            expect(request.method, 'POST');
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            expect(body['prefix'], userId);
            expect(body['search'], 'avatar');
            return http.Response(
              stored.containsKey(userId) ? '[{"name":"avatar"}]' : '[]',
              200,
            );
          }

          expect(request.url.path, '$endpoint/player-avatars/$userId/avatar');
          if (request.method == 'GET') {
            expect(request.url.queryParameters, contains('cacheNonce'));
            return http.Response.bytes(stored[userId]!, 200);
          }
          expect(request.method, 'POST');
          expect(request.headers['x-upsert'], 'true');
          final multipart = latin1.decode(request.bodyBytes);
          expect(multipart, contains('content-type: image/png'));
          expect(multipart, contains(latin1.decode(png)));
          stored[userId] = png;
          return http.Response('{"Key":"player-avatars/$userId/avatar"}', 200);
        }),
      );
      service = SupabaseAvatarService(client);
    });

    tearDown(() async => client.dispose());

    test(
      'Guarda en una ruta única y recupera al volver a iniciar sesión',
      () async {
        await signIn(firstUser);
        expect(await service.loadAvatar(firstUser), isNull);
        await service.saveAvatar(firstUser, png);
        await service.saveAvatar(firstUser, png);
        expect(stored.keys, [firstUser]);

        await signIn(secondUser);
        expect(await service.loadAvatar(secondUser), isNull);
        await expectLater(service.loadAvatar(firstUser), throwsStateError);
        await expectLater(service.saveAvatar(firstUser, png), throwsStateError);
        expect(requests, 4);

        await signIn(firstUser);
        final reopened = SupabaseAvatarService(client);
        expect(await reopened.loadAvatar(firstUser), png);
      },
    );

    test('Sin sesión y con imágenes inválidas no llama a Storage', () async {
      await expectLater(service.loadAvatar(firstUser), throwsStateError);
      await expectLater(service.saveAvatar(firstUser, png), throwsStateError);
      await signIn(firstUser);
      for (final bytes in [
        Uint8List.fromList([1, 2, 3]),
        Uint8List.fromList(png.take(8).toList()),
        Uint8List(SupabaseAvatarService.maxBytes + 1),
      ]) {
        await expectLater(
          service.saveAvatar(firstUser, bytes),
          throwsFormatException,
        );
      }
      expect(requests, 0);
    });

    test('Un error de Storage es distinto de una cuenta sin avatar', () async {
      await signIn(firstUser);
      storageFails = true;
      await expectLater(
        service.loadAvatar(firstUser),
        throwsA(isA<StorageException>()),
      );
    });
  });

  testWidgets('La demo omite el avatar aunque exista una sesión', (
    tester,
  ) async {
    final service = FakeAvatarService();
    await openMap(tester, service, isDemo: true);
    expect(find.byTooltip('Cambiar avatar'), findsNothing);
    expect(service.loads, 0);
    expect(service.picks, 0);
    expect(service.saves, 0);
  });

  testWidgets('Muestra el avatar guardado y lo recupera al volver al mapa', (
    tester,
  ) async {
    final service = FakeAvatarService()..selected = png;
    await openMap(tester, service);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    await tapAvatar(tester);
    expect(find.text('Avatar guardado.'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(service.saves, 1);

    await tester.pumpWidget(const SizedBox());
    await openMap(tester, service);
    expect(find.byType(Image), findsOneWidget);
    expect(service.loads, 2);
  });

  testWidgets('Avisa errores de carga, selección y guardado', (tester) async {
    final service = FakeAvatarService()..loadFails = true;
    await openMap(tester, service);
    expect(find.text('No se pudo cargar el avatar.'), findsOneWidget);

    service.loadFails = false;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(service.loads, 2);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);

    await tapAvatar(tester);
    expect(service.saves, 0); // Se canceló el selector.
    service.pickFails = true;
    await tapAvatar(tester);
    expect(find.text('No se pudo seleccionar la imagen.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    service
      ..pickFails = false
      ..selected = png
      ..saveFails = true;
    await tapAvatar(tester);
    expect(
      find.text('No se pudo guardar el avatar. Intenta de nuevo.'),
      findsOneWidget,
    );
    expect(find.byType(Image), findsNothing);
  });
}

Future<void> openMap(
  WidgetTester tester,
  AvatarService service, {
  bool isDemo = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: WorldMapScreen(isDemo: isDemo, avatarService: service),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> tapAvatar(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Cambiar avatar'));
  await tester.pumpAndSettle();
}

class FakeAvatarService implements AvatarService {
  @override
  String? get currentUserId => firstUser;

  Uint8List? selected;
  Uint8List? stored;
  int loads = 0;
  int picks = 0;
  int saves = 0;
  bool loadFails = false;
  bool pickFails = false;
  bool saveFails = false;

  @override
  Future<Uint8List?> loadAvatar(String userId) async {
    loads++;
    if (loadFails) throw StateError('sin red');
    return stored;
  }

  @override
  Future<Uint8List?> pickAvatar() async {
    picks++;
    if (pickFails) throw StateError('selector no disponible');
    return selected;
  }

  @override
  Future<void> saveAvatar(String userId, Uint8List bytes) async {
    saves++;
    if (saveFails) throw StateError('sin red');
    stored = bytes;
  }
}
