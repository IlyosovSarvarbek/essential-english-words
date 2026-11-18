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
  Future<List<QuizResult>> loadHistory() async => List.of(history);
  @override
  Future<void> saveLearned(Set<String> ids) async {
    learned = Set.of(ids);
  }

  @override
  Future<void> saveTheme(String mode) async {
    theme = mode;
  }

  @override
  Future<void> saveHistory(List<QuizResult> results) async {
    history = List.of(results);
  }
}
