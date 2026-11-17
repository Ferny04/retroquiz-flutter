import 'dart:math';

import '../models/question.dart';

const questionsData = <Question>[
  Question(
    id: 'M01',
    category: 'Música',
    text: '¿Quién fue el vocalista principal de Queen?',
    options: ['David Bowie', 'Robert Plant', 'Freddie Mercury', 'Elton John'],
    correctAnswerIndex: 2,
  ),
  Question(
    id: 'M02',
    category: 'Música',
    text: '¿Qué banda lanzó la canción «Smells Like Teen Spirit»?',
    options: ['Pearl Jam', 'Nirvana', 'Soundgarden', 'Alice in Chains'],
    correctAnswerIndex: 1,
  ),
  Question(
    id: 'M03',
    category: 'Música',
    text: '¿Qué grupo ganó Eurovisión en 1974 con «Waterloo»?',
    options: ['ABBA', 'Roxette', 'Ace of Base', 'Europe'],
    correctAnswerIndex: 0,
  ),
  Question(
    id: 'M04',
    category: 'Música',
    text: '¿Qué banda publicó el álbum «Abbey Road» en 1969?',
    options: ['The Rolling Stones', 'The Beatles', 'The Who', 'The Kinks'],
    correctAnswerIndex: 1,
  ),
  Question(
    id: 'V01',
    category: 'Videojuegos',
    text: '¿Cómo se llama el protagonista principal de The Legend of Zelda?',
    options: ['Zelda', 'Link', 'Ganon', 'Tingle'],
    correctAnswerIndex: 1,
  ),
  Question(
    id: 'V02',
    category: 'Videojuegos',
    text: '¿Quién creó el videojuego Tetris?',
    options: [
      'Shigeru Miyamoto',
      'Alexey Pajitnov',
      'Hideo Kojima',
      'John Carmack',
    ],
    correctAnswerIndex: 1,
  ),
  Question(
    id: 'V03',
    category: 'Videojuegos',
    text: '¿Qué consola portátil lanzó Nintendo en 1989?',
    options: ['Game Boy', 'Game Gear', 'Atari Lynx', 'WonderSwan'],
    correctAnswerIndex: 0,
  ),
  Question(
    id: 'V04',
    category: 'Videojuegos',
    text: '¿Qué empresa desarrolló el videojuego DOOM de 1993?',
    options: ['Epic Games', 'id Software', 'Valve', 'Electronic Arts'],
    correctAnswerIndex: 1,
  ),
  Question(
    id: 'C01',
    category: 'Cine',
    text: '¿Qué velocidad debe alcanzar el DeLorean para viajar en el tiempo en «Volver al futuro»?',
    options: [
      '60 millas por hora',
      '88 millas por hora',
      '100 millas por hora',
      '120 millas por hora',
    ],
    correctAnswerIndex: 1,
  ),
  Question(
    id: 'C02',
    category: 'Cine',
    text: '¿Cómo se llama el droide azul y blanco de Star Wars?',
    options: ['C-3PO', 'R2-D2', 'BB-8', 'K-2SO'],
    correctAnswerIndex: 1,
  ),
  Question(
    id: 'C03',
    category: 'Cine',
    text: '¿Quién dirigió «Jurassic Park» de 1993?',
    options: [
      'George Lucas',
      'Steven Spielberg',
      'James Cameron',
      'Ridley Scott',
    ],
    correctAnswerIndex: 1,
  ),
  Question(
    id: 'C04',
    category: 'Cine',
    text: '¿De qué color es la píldora que toma Neo para conocer la verdad en «The Matrix»?',
    options: ['Azul', 'Roja', 'Verde', 'Amarilla'],
    correctAnswerIndex: 1,
  ),
  Question(
    id: 'H01',
    category: 'Historia',
    text: '¿En qué año llegó Cristóbal Colón a América?',
    options: ['1488', '1492', '1502', '1519'],
    correctAnswerIndex: 1,
  ),
  Question(
    id: 'H02',
    category: 'Historia',
    text: '¿En qué año comenzó la Primera Guerra Mundial?',
    options: ['1914', '1918', '1939', '1945'],
    correctAnswerIndex: 0,
  ),
  Question(
    id: 'H03',
    category: 'Historia',
    text: '¿En qué año cayó el Muro de Berlín?',
    options: ['1985', '1989', '1991', '1995'],
    correctAnswerIndex: 1,
  ),
  Question(
    id: 'H04',
    category: 'Historia',
    text: '¿Qué civilización antigua desarrolló la escritura cuneiforme?',
    options: ['Egipcia', 'Sumeria', 'Fenicia', 'Griega'],
    correctAnswerIndex: 1,
  ),
  Question(
    id: 'S01',
    category: 'Ciencias',
    text: '¿Cuál es el símbolo químico del oro?',
    options: ['Ag', 'Au', 'Fe', 'Cu'],
    correctAnswerIndex: 1,
  ),
  Question(
    id: 'S02',
    category: 'Ciencias',
    text: '¿Qué planeta es conocido como el planeta rojo?',
    options: ['Venus', 'Marte', 'Júpiter', 'Saturno'],
    correctAnswerIndex: 1,
  ),
  Question(
    id: 'S03',
    category: 'Ciencias',
    text: '¿Cuál es el gas más abundante en la atmósfera terrestre?',
    options: ['Oxígeno', 'Nitrógeno', 'Dióxido de carbono', 'Argón'],
    correctAnswerIndex: 1,
  ),
  Question(
    id: 'S04',
    category: 'Ciencias',
    text: '¿Qué partícula subatómica tiene carga eléctrica negativa?',
    options: ['Protón', 'Electrón', 'Neutrón', 'Fotón'],
    correctAnswerIndex: 1,
  ),
  Question(
    id: 'G01',
    category: 'Geografía',
    text: '¿En qué país se encuentra la Torre Eiffel?',
    options: ['Italia', 'Francia', 'Alemania', 'España'],
    correctAnswerIndex: 1,
  ),
  Question(
    id: 'G02',
    category: 'Geografía',
    text: '¿Cuál es el país más grande del mundo por superficie?',
    options: ['Canadá', 'Rusia', 'China', 'Estados Unidos'],
    correctAnswerIndex: 1,
  ),
  Question(
    id: 'G03',
    category: 'Geografía',
    text: '¿Cuál es la capital de Australia?',
    options: ['Sídney', 'Canberra', 'Melbourne', 'Brisbane'],
    correctAnswerIndex: 1,
  ),
  Question(
    id: 'G04',
    category: 'Geografía',
    text: '¿En qué país se encuentran las ruinas de Machu Picchu?',
    options: ['Colombia', 'Perú', 'Ecuador', 'Chile'],
    correctAnswerIndex: 1,
  ),
];

List<Question> selectGameQuestions({Random? random}) {
  final generator = random ?? Random();
  final selected = <Question>[];
  final categories = questionsData.map((question) => question.category).toSet();

  // Primero elegimos una de cada categoría para garantizar las seis.
  for (final category in categories) {
    final categoryQuestions =
        questionsData
            .where((question) => question.category == category)
            .toList()
          ..shuffle(generator);
    selected.add(categoryQuestions.first);
  }

  // Completamos con cuatro preguntas que aún no han sido elegidas.
  final remaining =
      questionsData.where((question) => !selected.contains(question)).toList()
        ..shuffle(generator);
  selected.addAll(remaining.take(10 - selected.length));
  selected.shuffle(generator);

  // Copiamos las opciones una sola vez por partida; el banco queda intacto.
  return selected.map((question) {
    final correctAnswer = question.options[question.correctAnswerIndex];
    final options = List<String>.from(question.options)..shuffle(generator);
    return Question(
      id: question.id,
      category: question.category,
      text: question.text,
      options: options,
      correctAnswerIndex: options.indexOf(correctAnswer),
    );
  }).toList();
}
