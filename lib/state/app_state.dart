import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../models/vocabulary.dart';
import '../services/progress_storage.dart';
import '../services/pronunciation.dart';
import '../services/vocabulary_repository.dart';

class AppState extends ChangeNotifier {
  AppState({required this.vocabulary, required this.storage});
  final VocabularyRepository vocabulary;
  final ProgressStorage storage;
  final Pronunciation pronunciation = Pronunciation();
  final Set<String> _learned = {};
  final List<QuizResult> _history = [];
  ThemeMode themeMode = ThemeMode.dark;
  Future<void> _writes = Future.value();
  String? storageError;
  Set<String> get learnedIds => Set.unmodifiable(_learned);
  List<QuizResult> get history => List.unmodifiable(_history.reversed);

  Future<void> initialize() async {
    try {
      final values = await Future.wait<Object?>([
        storage.loadLearned(),
        storage.loadTheme(),
        storage.loadHistory(),
      ]);
      final validIds = vocabulary.allWords.map((word) => word.uniqueId).toSet();
      _learned.addAll((values[0] as Set<String>).intersection(validIds));
      themeMode = switch (values[1]) {
        'light' => ThemeMode.light,
        'system' => ThemeMode.system,
        _ => ThemeMode.dark,
      };
      _history.addAll(values[2] as List<QuizResult>);
    } catch (error) {
      storageError = 'Could not load saved progress: $error';
    }
  }

  bool isLearned(Word word) => _learned.contains(word.uniqueId);
  ProgressStats stats(Iterable<Word> words) {
    var learned = 0;
    var total = 0;
    for (final word in words) {
      total++;
      if (_learned.contains(word.uniqueId)) learned++;
    }
    return ProgressStats(learned, total);
  }

  Future<void> _enqueue(Future<void> Function() write) {
    // Serialize snapshots so rapid taps cannot overwrite newer progress.
    _writes = _writes.then((_) => write()).catchError((Object error) {
      storageError = 'Could not save progress. $error';
      notifyListeners();
    });
    return _writes;
  }

  Future<void> setLearned(Word word, bool learned) {
    if (learned) {
      _learned.add(word.uniqueId);
    } else {
      _learned.remove(word.uniqueId);
    }
    unawaited(HapticFeedback.selectionClick());
    notifyListeners();
    final snapshot = Set<String>.of(_learned);
    return _enqueue(() => storage.saveLearned(snapshot));
  }

  Future<void> toggleTheme(bool currentlyDark) {
    themeMode = currentlyDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    final value = themeMode.name;
    return _enqueue(() => storage.saveTheme(value));
  }

  Future<void> saveResult(QuizResult result) {
    _history.add(result);
    final snapshot = List<QuizResult>.of(_history);
    return _enqueue(() => storage.saveHistory(snapshot));
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);
  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
