import 'package:sqflite/sqflite.dart';

import '../models/vocabulary.dart';
import 'database_opener.dart';
import 'legacy_progress.dart';

abstract class ProgressStorage {
  Future<Set<String>> loadLearned();
  Future<void> setLearned(String wordId, bool learned);
  Future<String?> loadTheme();
  Future<void> saveTheme(String mode);
  Future<List<QuizResult>> loadHistory({int limit = 100, int offset = 0});
  Future<void> appendResult(QuizResult result);
}

class LocalProgressStorage implements ProgressStorage {
  LocalProgressStorage({
    Future<Database> Function(OpenDatabaseOptions)? openDatabase,
    Future<LegacyProgress> Function()? loadLegacy,
  }) : _openDatabase = openDatabase ?? openProgressDatabase,
       _loadLegacy = loadLegacy ?? readLegacyProgress;

  final Future<Database> Function(OpenDatabaseOptions) _openDatabase;
  final Future<LegacyProgress> Function() _loadLegacy;
  Future<Database>? _opening;
  static const _migrationKey = 'legacy_preferences_imported';

  Future<Database> get _database => _opening ??= _open();

  Future<Database> _open() async {
    Database? database;
    try {
      database = await _openDatabase(
        OpenDatabaseOptions(version: 1, onCreate: _createSchema),
      );
      await _migrateLegacy(database);
      return database;
    } catch (_) {
      await database?.close();
      _opening = null;
      rethrow;
    }
  }

  static Future<void> _createSchema(Database db, int version) async {
    final batch = db.batch();
    batch.execute('''
      CREATE TABLE learned_words (
        word_id TEXT NOT NULL PRIMARY KEY
      )
    ''');
    batch.execute('''
      CREATE TABLE app_settings (
        key TEXT NOT NULL PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    batch.execute('''
      CREATE TABLE quiz_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bookId INTEGER NOT NULL,
        unitId INTEGER NOT NULL,
        mode TEXT NOT NULL CHECK (mode IN ('en-uz', 'uz-en')),
        score INTEGER NOT NULL CHECK (score >= 0 AND score <= total),
        total INTEGER NOT NULL CHECK (total > 0),
        completedAt INTEGER NOT NULL
      )
    ''');
    batch.execute('''
      CREATE INDEX quiz_results_recent
      ON quiz_results (completedAt DESC, id DESC)
    ''');
    await batch.commit(noResult: true);
  }

  Future<bool> _hasMigrated(DatabaseExecutor db) async => (await db.query(
    'app_settings',
    columns: ['key'],
    where: 'key = ?',
    whereArgs: [_migrationKey],
  )).isNotEmpty;

  Future<void> _migrateLegacy(Database db) async {
    if (await _hasMigrated(db)) return;
    final legacy = await _loadLegacy();
    // Import and marker commit together. A failed import can safely be retried;
    // reopening never duplicates results or restores old learned IDs.
    await db.transaction((transaction) async {
      if (await _hasMigrated(transaction)) return;
      final batch = transaction.batch();
      for (final id in legacy.learned) {
        batch.insert('learned_words', {
          'word_id': id,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      if (legacy.theme != null) {
        batch.insert('app_settings', {
          'key': 'theme',
          'value': legacy.theme,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      for (final result in legacy.history) {
        batch.insert('quiz_results', result.toJson());
      }
      batch.insert('app_settings', {'key': _migrationKey, 'value': '1'});
      await batch.commit(noResult: true);
    });
  }

  @override
  Future<Set<String>> loadLearned() async {
    final rows = await (await _database).query(
      'learned_words',
      columns: ['word_id'],
    );
    return rows.map((row) => row['word_id'] as String).toSet();
  }

  @override
  Future<void> setLearned(String wordId, bool learned) async {
    final database = await _database;
    if (learned) {
      await database.insert('learned_words', {
        'word_id': wordId,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    } else {
      await database.delete(
        'learned_words',
        where: 'word_id = ?',
        whereArgs: [wordId],
      );
    }
  }

  @override
  Future<String?> loadTheme() async {
    final rows = await (await _database).query(
      'app_settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: ['theme'],
    );
    return rows.isEmpty ? null : rows.single['value'] as String;
  }

  @override
  Future<void> saveTheme(String mode) async {
    await (await _database).insert('app_settings', {
      'key': 'theme',
      'value': mode,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<List<QuizResult>> loadHistory({
    int limit = 100,
    int offset = 0,
  }) async {
    RangeError.checkValueInInterval(limit, 1, 1000, 'limit');
    RangeError.checkNotNegative(offset, 'offset');
    final rows = await (await _database).query(
      'quiz_results',
      orderBy: 'completedAt DESC, id DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map(QuizResult.fromJson).toList();
  }

  @override
  Future<void> appendResult(QuizResult result) async {
    await (await _database).insert('quiz_results', result.toJson());
  }

  Future<void> close() async {
    final opening = _opening;
    if (opening == null) return;
    await (await opening).close();
    _opening = null;
  }
}
