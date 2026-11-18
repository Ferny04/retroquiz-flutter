const volcanicWorldId = 'volcanic';

class WorldProgress {
  const WorldProgress({
    required this.userId,
    required this.worldId,
    required this.bestScore,
    required this.completed,
  });

  final String userId;
  final String worldId;
  final int bestScore;
  final bool completed;

  factory WorldProgress.fromJson(Map<String, dynamic> json) {
    return WorldProgress(
      userId: json['user_id'] as String,
      worldId: json['world_id'] as String,
      bestScore: json['best_score'] as int,
      completed: json['completed'] as bool,
    );
  }
}
