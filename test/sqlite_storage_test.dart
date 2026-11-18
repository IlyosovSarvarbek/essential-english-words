import 'dart:io';

import 'package:essential_words_flutter/models/vocabulary.dart';
import 'package:essential_words_flutter/services/legacy_progress.dart';
import 'package:essential_words_flutter/services/progress_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  late Directory directory;
  late String path;
  late LocalProgressStorage storage;

  QuizResult result(int timestamp, {int score = 17}) => QuizResult(
    bookId: 2,
    unitId: 3,
    mode: QuizMode.uzEn,
    score: score,
    total: 20,
    completedAt: timestamp,
  );

  LocalProgressStorage createStorage({
    Future<LegacyProgress> Function()? loadLegacy,
  }) => LocalProgressStorage(
    openDatabase: (options) =>
        databaseFactoryFfi.openDatabase(path, options: options),
    loadLegacy: loadLegacy ?? () async => const LegacyProgress(),
  );

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'essential_words_sqlite_',
    );
    path = p.join(directory.path, 'progress.db');
    storage = createStorage();
  });
  tearDown(() async {
    await storage.close();
    await directory.delete(recursive: true);
  });

  test(
    'word changes, theme and quiz attempts survive closing the database',
    () async {
      expect(await storage.loadLearned(), isEmpty);
      expect(await storage.loadTheme(), isNull);
      await storage.setLearned('b1_word', true);
      await storage.setLearned('b2_word', true);
      await storage.setLearned('b1_word', true);
      await storage.saveTheme('light');
      await storage.appendResult(result(10));
      // Equal timestamps are legitimate separate attempts, not duplicates.
      await storage.appendResult(result(10, score: 18));
      await storage.close();
      storage = createStorage();
      expect(await storage.loadLearned(), {'b1_word', 'b2_word'});
      expect(await storage.loadTheme(), 'light');
      expect((await storage.loadHistory()).map((value) => value.score), [
        18,
        17,
      ]);
      await storage.setLearned('b1_word', false);
      await storage.close();
      storage = createStorage();
      expect(await storage.loadLearned(), {'b2_word'});
      expect((await storage.loadHistory()).length, 2);
    },
  );

  test('legacy data imports once without overwriting later changes', () async {
    var reads = 0;
    Future<LegacyProgress> readLegacy() async {
      reads++;
      return LegacyProgress(
        learned: {'b1_word', 'b2_word'},
        theme: 'light',
        history: [result(10), result(11, score: 18)],
      );
    }

    storage = createStorage(loadLegacy: readLegacy);
    // Concurrent bootstrap reads share one open and one migration.
    await Future.wait<Object?>([
      storage.loadLearned(),
      storage.loadTheme(),
      storage.loadHistory(),
    ]);
    expect(reads, 1);
    expect(await storage.loadLearned(), {'b1_word', 'b2_word'});
    expect(await storage.loadTheme(), 'light');
    expect((await storage.loadHistory()).map((value) => value.score), [18, 17]);
    await storage.setLearned('b1_word', false);
    await storage.saveTheme('dark');
    await storage.appendResult(result(12));
    await storage.close();
    storage = createStorage(loadLegacy: readLegacy);
    expect(await storage.loadLearned(), {'b2_word'});
    expect(await storage.loadTheme(), 'dark');
    expect((await storage.loadHistory()).length, 3);
    expect(reads, 1);
  });

  test('failed migration rolls back every row and can be retried', () async {
    var valid = false;
    storage = createStorage(
      loadLegacy: () async => LegacyProgress(
        learned: {'b1_word'},
        theme: 'light',
        history: [
          result(10),
          result(11, score: valid ? 18 : 99),
        ],
      ),
    );
    await expectLater(storage.loadLearned(), throwsA(isA<DatabaseException>()));
    final database = await databaseFactoryFfi.openDatabase(path);
    for (final table in ['learned_words', 'app_settings', 'quiz_results']) {
      expect(
        await database.query(table),
        isEmpty,
        reason: '$table must roll back',
      );
    }
    await database.close();
    valid = true;
    expect(await storage.loadLearned(), {'b1_word'});
    expect(await storage.loadTheme(), 'light');
    expect((await storage.loadHistory()).length, 2);
  });

  test(
    'unavailable legacy storage fails safely and retries on the same instance',
    () async {
      var available = false;
      storage = createStorage(
        loadLegacy: () async {
          if (!available) throw StateError('Storage unavailable');
          return const LegacyProgress(learned: {'b1_word'});
        },
      );
      await expectLater(storage.loadLearned(), throwsStateError);
      available = true;
      expect(await storage.loadLearned(), {'b1_word'});
    },
  );

  test(
    '10,000 results remain intact with indexed pagination and one-row appends',
    () async {
      storage = createStorage(
        loadLegacy: () async => LegacyProgress(
          history: List.generate(10000, (index) => result(index)),
        ),
      );
      final recent = await storage.loadHistory();
      expect(recent.length, 100);
      expect(recent.first.completedAt, 9999);
      expect(recent.last.completedAt, 9900);
      expect(
        (await storage.loadHistory(
          limit: 2,
          offset: 9998,
        )).map((value) => value.completedAt),
        [1, 0],
      );
      await storage.appendResult(result(10000));
      expect((await storage.loadHistory(limit: 1)).single.completedAt, 10000);
      final database = await databaseFactoryFfi.openDatabase(path);
      expect(
        (await database.rawQuery('SELECT COUNT(*) AS count FROM quiz_results'))
            .single['count'],
        10001,
      );
      final plan = await database.rawQuery(
        'EXPLAIN QUERY PLAN SELECT * FROM quiz_results '
        'ORDER BY completedAt DESC, id DESC LIMIT 100',
      );
      expect(
        plan.map((row) => row['detail']).join(),
        contains('quiz_results_recent'),
      );
      await expectLater(storage.loadHistory(limit: 0), throwsRangeError);
      await expectLater(storage.loadHistory(offset: -1), throwsRangeError);
    },
  );
}
