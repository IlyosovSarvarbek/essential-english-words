import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/vocabulary.dart';

class LegacyProgress {
  const LegacyProgress({
    this.learned = const {},
    this.theme,
    this.history = const [],
  });

  final Set<String> learned;
  final String? theme;
  final List<QuizResult> history;
}

/// Read-only compatibility with installations using preferences storage.
/// Leave the original keys intact, even after a successful SQL migration.
Future<LegacyProgress> readLegacyProgress() async {
  final preferences = SharedPreferencesAsync();
  final learned = await preferences.getStringList('essential_words_learned');
  final theme = await preferences.getString('essential_words_theme_mode');
  final rawHistory = await preferences.getString(
    'essential_words_quiz_history',
  );
  return LegacyProgress(
    learned: learned?.toSet() ?? {},
    theme: theme,
    history: rawHistory == null
        ? []
        : (jsonDecode(rawHistory) as List)
              .map((row) => QuizResult.fromJson(row as Map<String, dynamic>))
              .toList(),
  );
}
