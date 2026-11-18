import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:essential_words_flutter/models/vocabulary.dart';
import 'package:essential_words_flutter/services/vocabulary_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late VocabularyRepository repository;
  setUpAll(() async {
    repository = await VocabularyRepository.load();
  });

  test(
    'all six original books load with 180 units and 3600 unique word IDs',
    () {
      expect(repository.books.length, 6);
      expect(repository.allWords.length, 3600);
      expect(
        repository.allWords.map((word) => word.uniqueId).toSet().length,
        3600,
      );
      for (final book in repository.books) {
        expect(book.units.length, 30);
        for (final unit in book.units) {
          expect(unit.words.length, 20);
          expect(
            unit.words.every(
              (word) => word.english.isNotEmpty && word.translation.isNotEmpty,
            ),
            isTrue,
          );
        }
      }
      expect(repository.unit(1, 1).words.first.english, 'afraid');
      expect(
        repository.unit(1, 1).words.first.translation,
        "qo'rqqan, cho'chigan",
      );
      expect(
        repository.unit(6, 1).words.first.uniqueId.startsWith('b6_b6_'),
        isFalse,
      );
    },
  );

  test(
    'English and Uzbek search match substrings, case, and trimmed queries',
    () {
      expect(
        repository
            .search('  AFRAID  ', QuizMode.enUz)
            .any((word) => word.english == 'afraid'),
        isTrue,
      );
      expect(
        repository
            .search("qo'rqqan", QuizMode.uzEn)
            .any((word) => word.english == 'afraid'),
        isTrue,
      );
      expect(
        repository
            .search('fraid', QuizMode.enUz)
            .any((word) => word.english == 'afraid'),
        isTrue,
      );
      expect(repository.search(' ', QuizMode.enUz), isEmpty);
      expect(repository.search('zzzzzzzzz', QuizMode.uzEn), isEmpty);
    },
  );

  test('every quiz has four distinct answers and one correct option in both directions', () {
    final random = Random(42);
    for (final book in repository.books) {
      for (final unit in book.units) {
        for (final mode in QuizMode.values) {
          final questions = generateQuiz(unit, book, mode, random: random);
          expect(questions.length, 20);
          for (var index = 0; index < questions.length; index++) {
            final question = questions[index];
            expect(question.word.uniqueId, unit.words[index].uniqueId);
            expect(question.options.length, 4);
            expect(question.options.toSet().length, 4);
            expect(
              question.options
                  .where((answer) => answer == question.correctAnswer)
                  .length,
              1,
            );
            expect(
              question.question,
              mode == QuizMode.enUz
                  ? question.word.english
                  : question.word.translation,
            );
          }
        }
      }
    }
  });
}
