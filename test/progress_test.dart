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
    'rapid changes preserve tap order and ignore invalid stored IDs',
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
      expect(state.learnedIds, {word.uniqueId});
      // A one-word update does not rewrite unrelated stored IDs.
      expect(storage.learned, {'not_a_word', word.uniqueId});
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

  test(
    'recent history stays bounded while storage retains every attempt',
    () async {
      final storage = MemoryStorage();
      final state = AppState(vocabulary: vocabulary, storage: storage);
      await state.initialize();
      for (var index = 0; index < 150; index++) {
        await state.saveResult(
          QuizResult(
            bookId: 1,
            unitId: 1,
            mode: QuizMode.enUz,
            score: 20,
            total: 20,
            completedAt: index,
          ),
        );
      }
      expect(state.history.length, AppState.recentHistoryLimit);
      expect(state.history.first.completedAt, 149);
      expect(storage.history.length, 150);
      final reloaded = AppState(vocabulary: vocabulary, storage: storage);
      await reloaded.initialize();
      expect(reloaded.history.length, AppState.recentHistoryLimit);
      expect(reloaded.history.first.completedAt, 149);
      expect((await storage.loadHistory(offset: 100)).length, 50);
    },
  );
}
