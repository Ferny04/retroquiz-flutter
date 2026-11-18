import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/world_progress.dart';

abstract class ProgressService {
  const ProgressService();

  String? get currentUserId;
  Future<WorldProgress?> loadVolcanicProgress();
  Future<WorldProgress> saveVolcanicProgress({
    required String userId,
    required int score,
  });
}

class UnavailableProgressService extends ProgressService {
  const UnavailableProgressService();

  @override
  String? get currentUserId => null;

  @override
  Future<WorldProgress?> loadVolcanicProgress() async {
    throw StateError('Supabase no está disponible.');
  }

  @override
  Future<WorldProgress> saveVolcanicProgress({
    required String userId,
    required int score,
  }) async {
    throw StateError('Supabase no está disponible.');
  }
}

class SupabaseProgressService extends ProgressService {
  const SupabaseProgressService(this.client);

  final SupabaseClient client;

  @override
  String? get currentUserId => client.auth.currentUser?.id;

  @override
  Future<WorldProgress?> loadVolcanicProgress() async {
    final userId = currentUserId;
    if (userId == null) throw StateError('Inicia sesión para cargar progreso.');
    final data = await client
        .from('world_progress')
        .select('user_id, world_id, best_score, completed')
        .eq('user_id', userId)
        .eq('world_id', volcanicWorldId)
        .maybeSingle()
        .timeout(const Duration(seconds: 15));
    if (currentUserId != userId) throw StateError('La sesión cambió.');
    return data == null ? null : WorldProgress.fromJson(data);
  }

  @override
  Future<WorldProgress> saveVolcanicProgress({
    required String userId,
    required int score,
  }) async {
    if (currentUserId == null || currentUserId != userId) {
      throw StateError('La sesión de la partida ya no está disponible.');
    }
    if (score < 0 || score > 1000 || score % 100 != 0) {
      throw ArgumentError.value(score, 'score');
    }
    // SQL conserva el máximo en una sola operación, incluso con dos partidas.
    final data = await client
        .rpc('complete_volcanic_world', params: {'p_score': score})
        .single()
        .timeout(const Duration(seconds: 15));
    if (currentUserId != userId) throw StateError('La sesión cambió.');
    return WorldProgress.fromJson(data);
  }
}
