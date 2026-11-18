import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:retroquiz/services/progress_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  late SupabaseClient client;
  late SupabaseProgressService service;
  Map<String, dynamic>? stored;
  bool offline = false;
  int writes = 0;
  const userId = '00000000-0000-0000-0000-000000000001';

  setUp(() async {
    stored = null;
    offline = false;
    writes = 0;
    client = SupabaseClient(
      'https://example.supabase.co',
      'test-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((request) async {
        if (offline) throw const SocketException('Sin conexión');
        if (request.url.path.endsWith('/token')) {
          return http.Response(
            jsonEncode({
              'access_token': 'test-token',
              'refresh_token': 'test-refresh',
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
            request: request,
          );
        }
        if (request.url.path.endsWith('/rpc/complete_volcanic_world')) {
          expect(request.method, 'POST');
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body.keys, ['p_score']);
          final score = body['p_score'] as int;
          // Simula ON CONFLICT/GREATEST; el SQL real se verifica en Supabase.
          final previous = stored?['best_score'] as int? ?? 0;
          stored = {
            'user_id': userId,
            'world_id': 'volcanic',
            'best_score': score > previous ? score : previous,
            'completed': true,
          };
          writes++;
          return http.Response(jsonEncode(stored), 200, request: request);
        }
        expect(request.url.path, '/rest/v1/world_progress');
        expect(request.url.queryParameters['user_id'], 'eq.$userId');
        expect(request.url.queryParameters['world_id'], 'eq.volcanic');
        return http.Response(
          jsonEncode(stored == null ? [] : [stored]),
          200,
          request: request,
        );
      }),
    );
    await client.auth.signInWithPassword(
      email: 'test@example.com',
      password: 'test',
    );
    service = SupabaseProgressService(client);
  });

  tearDown(() async => client.dispose());

  test('Guarda usuario, mundo, puntuación y estado completado', () async {
    final progress = await service.saveVolcanicProgress(
      userId: userId,
      score: 600,
    );
    expect(progress.userId, userId);
    expect(progress.worldId, 'volcanic');
    expect(progress.bestScore, 600);
    expect(progress.completed, isTrue);
    expect(writes, 1);
  });

  test('Conserva el máximo y recupera desde otro servicio', () async {
    for (final score in [800, 200, 1000, 0]) {
      await service.saveVolcanicProgress(userId: userId, score: score);
    }
    final reopened = SupabaseProgressService(client);
    expect((await reopened.loadVolcanicProgress())!.bestScore, 1000);
    expect(writes, 4);
  });

  test('Sin partida completada devuelve null', () async {
    expect(await service.loadVolcanicProgress(), isNull);
  });

  test('No guarda si la sesión pertenece a otro usuario', () async {
    await expectLater(
      service.saveVolcanicProgress(userId: 'otro', score: 100),
      throwsStateError,
    );
    expect(writes, 0);
  });

  test('Rechaza puntuaciones inválidas', () async {
    for (final score in [-100, 50, 1100]) {
      await expectLater(
        service.saveVolcanicProgress(userId: userId, score: score),
        throwsArgumentError,
      );
    }
    expect(writes, 0);
  });

  test('Propaga errores de conexión para permitir reintentar', () async {
    offline = true;
    await expectLater(
      service.loadVolcanicProgress(),
      throwsA(isA<SocketException>()),
    );
    await expectLater(
      service.saveVolcanicProgress(userId: userId, score: 600),
      throwsA(isA<SocketException>()),
    );
    offline = false;
    expect(
      (await service.saveVolcanicProgress(
        userId: userId,
        score: 600,
      )).bestScore,
      600,
    );
  });
}
