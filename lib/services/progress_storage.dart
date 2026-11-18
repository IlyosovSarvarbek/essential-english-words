import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/vocabulary.dart';

abstract class ProgressStorage {
  Future<Set<String>> loadLearned();
  Future<void> saveLearned(Set<String> ids);
  Future<String?> loadTheme();
  Future<void> saveTheme(String mode);
  Future<List<QuizResult>> loadHistory();
  Future<void> saveHistory(List<QuizResult> history);
}

class LocalProgressStorage implements ProgressStorage {
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();
  static const _learnedKey = 'essential_words_learned';
  static const _themeKey = 'essential_words_theme_mode';
  static const _historyKey = 'essential_words_quiz_history';

  @override
  Future<Set<String>> loadLearned() async =>
      (await _preferences.getStringList(_learnedKey) ?? []).toSet();
  @override
  Future<void> saveLearned(Set<String> ids) =>
      _preferences.setStringList(_learnedKey, ids.toList());
  @override
  Future<String?> loadTheme() => _preferences.getString(_themeKey);
  @override
  Future<void> saveTheme(String mode) =>
      _preferences.setString(_themeKey, mode);
  @override
  Future<List<QuizResult>> loadHistory() async {
    final raw = await _preferences.getString(_historyKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .cast<Map<String, dynamic>>()
          .map(QuizResult.fromJson)
          .toList();
    } on FormatException {
      return [];
    }
  }

  @override
  Future<void> saveHistory(List<QuizResult> history) => _preferences.setString(
    _historyKey,
    jsonEncode(history.map((result) => result.toJson()).toList()),
  );
}
