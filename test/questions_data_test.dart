import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:retroquiz/data/questions_data.dart';

void main() {
  const categories = {
    'Música',
    'Videojuegos',
    'Cine',
    'Historia',
    'Ciencias',
    'Geografía',
  };

  test('El banco contiene 24 preguntas válidas, cuatro por categoría', () {
    expect(questionsData, hasLength(24));
    expect(questionsData.map((q) => q.id).toSet(), hasLength(24));
    expect(questionsData.map((q) => q.category).toSet(), categories);
    for (final category in categories) {
      expect(questionsData.where((q) => q.category == category), hasLength(4));
    }
    for (final question in questionsData) {
      expect(question.text, isNotEmpty);
      expect(question.options, hasLength(4));
      expect(question.options.toSet(), hasLength(4));
      expect(question.options.every((option) => option.isNotEmpty), isTrue);
      expect(question.correctAnswerIndex, inInclusiveRange(0, 3));
      // Clave de respuestas proporcionada para este avance.
      final expectedIndex = question.id == 'M01'
          ? 2
          : {'M03', 'V03', 'H02'}.contains(question.id)
          ? 0
          : 1;
      expect(question.correctAnswerIndex, expectedIndex, reason: question.id);
    }
  });

  test('Cada selección tiene diez preguntas únicas y las seis categorías', () {
    final selections = <String>{};
    for (int seed = 0; seed < 100; seed++) {
      final questions = selectGameQuestions(random: Random(seed));
      expect(questions, hasLength(10));
      expect(questions.map((q) => q.id).toSet(), hasLength(10));
      expect(questions.map((q) => q.category).toSet(), categories);
      expect(
        questions.every(
          (q) => questionsData.any((original) => original.id == q.id),
        ),
        isTrue,
      );
      selections.add(questions.map((q) => q.id).join(','));
    }
    expect(selections.length, greaterThan(1));
    expect(questionsData, hasLength(24));
  });

  test('Barajar conserva la respuesta correcta y no modifica el banco', () {
    final originalOptions = [
      for (final q in questionsData) List<String>.from(q.options),
    ];
    final originalIndexes = questionsData
        .map((q) => q.correctAnswerIndex)
        .toList();
    final orders = <String, Set<String>>{};
    for (int seed = 0; seed < 100; seed++) {
      for (final question in selectGameQuestions(random: Random(seed))) {
        final original = questionsData.singleWhere((q) => q.id == question.id);
        expect(question.text, original.text);
        expect(question.category, original.category);
        expect(question.options, hasLength(4));
        expect(question.options.toSet(), original.options.toSet());
        expect(identical(question.options, original.options), isFalse);
        expect(
          question.options[question.correctAnswerIndex],
          original.options[original.correctAnswerIndex],
        );
        orders
            .putIfAbsent(question.id, () => <String>{})
            .add(question.options.join('|'));
      }
    }
    expect(orders, hasLength(24));
    expect(orders.values.every((variants) => variants.length > 1), isTrue);
    for (int i = 0; i < questionsData.length; i++) {
      expect(questionsData[i].options, originalOptions[i]);
      expect(questionsData[i].correctAnswerIndex, originalIndexes[i]);
    }
  });
}
