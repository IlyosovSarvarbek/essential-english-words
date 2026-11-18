import 'package:essential_words_flutter/models/vocabulary.dart';
import 'package:essential_words_flutter/services/progress_storage.dart';

class MemoryStorage implements ProgressStorage {
  Set<String> learned = {};
  String? theme;
  List<QuizResult> history = [];
  @override
  Future<Set<String>> loadLearned() async => Set.of(learned);
  @override
  Future<String?> loadTheme() async => theme;
  @override
  Future<List<QuizResult>> loadHistory({
    int limit = 100,
    int offset = 0,
  }) async => history.reversed.skip(offset).take(limit).toList();
  @override
  Future<void> setLearned(String wordId, bool value) async {
    if (value) {
      learned.add(wordId);
    } else {
      learned.remove(wordId);
    }
  }

  @override
  Future<void> saveTheme(String mode) async {
    theme = mode;
  }

  @override
  Future<void> appendResult(QuizResult result) async {
    history.add(result);
  }
}
