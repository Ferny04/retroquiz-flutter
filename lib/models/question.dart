class Question {
  const Question({
    required this.id,
    required this.category,
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
  });

  final String id;
  final String category;
  final String text;
  final List<String> options;
  final int correctAnswerIndex;
}
