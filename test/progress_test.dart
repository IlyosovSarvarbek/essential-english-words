import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:essential_words_flutter/models/vocabulary.dart';
import 'package:essential_words_flutter/services/vocabulary_repository.dart';
import 'package:essential_words_flutter/state/app_state.dart';

import 'support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late VocabularyRepository vocabulary;
  setUpAll(() async {
    vocabulary = await VocabularyRepository.load();
  });

  test(
    'progress remains scoped to each book and survives a fresh state',
    () async {
      final storage = MemoryStorage();
      final state = AppState(vocabulary: vocabulary, storage: storage);
      await state.initialize();
      await state.setLearned(vocabulary.unit(1, 1).words.first, true);
      expect(state.stats(vocabulary.unit(1, 1).words).percentage, 5);
      expect(state.stats(vocabulary.unit(2, 1).words).learned, 0);
      await state.toggleTheme(true);
      final reloaded = AppState(vocabulary: vocabulary, storage: storage);
      await reloaded.initialize();
      expect(reloaded.isLearned(vocabulary.unit(1, 1).words.first), isTrue);
      expect(reloaded.themeMode, ThemeMode.light);
      await reloaded.setLearned(vocabulary.unit(1, 1).words.first, false);
      expect(storage.learned, isEmpty);
    },
  );

  test(
    'rapid changes save the latest snapshot and discard invalid stored IDs',
    () async {
      final storage = MemoryStorage()..learned = {'not_a_word'};
      final state = AppState(vocabulary: vocabulary, storage: storage);
      await state.initialize();
      expect(state.learnedIds, isEmpty);
      final word = vocabulary.unit(1, 1).words.first;
      await Future.wait([
        state.setLearned(word, true),
        state.setLearned(word, false),
        state.setLearned(word, true),
      ]);
      expect(storage.learned, {word.uniqueId});
    },
  );

  test(
    'quiz history persists the score, direction and timestamp exactly once',
    () async {
      final storage = MemoryStorage();
      final state = AppState(vocabulary: vocabulary, storage: storage);
      await state.initialize();
      const result = QuizResult(
        bookId: 2,
        unitId: 3,
        mode: QuizMode.uzEn,
        score: 17,
        total: 20,
        completedAt: 12345,
      );
      await state.saveResult(result);
      final reloaded = AppState(vocabulary: vocabulary, storage: storage);
      await reloaded.initialize();
      expect(reloaded.history.length, 1);
      expect(reloaded.history.first.toJson(), result.toJson());
      expect(reloaded.history.first.percentage, 85);
    },
  );
}
