import 'dart:async';

import 'package:essential_words_flutter/main.dart';
import 'package:essential_words_flutter/services/vocabulary_repository.dart';
import 'package:essential_words_flutter/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppState state;
  setUp(() async {
    state = AppState(
      vocabulary: await VocabularyRepository.load(),
      storage: MemoryStorage(),
    );
    await state.initialize();
  });

  testWidgets('cold launch keeps its deep link while storage is loading', (
    tester,
  ) async {
    tester.binding.platformDispatcher.defaultRouteNameTestValue = '/learn/1/1';
    addTearDown(
      tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
    );
    final loading = Completer<AppState>();
    await tester.pumpWidget(Bootstrap(loadState: () => loading.future));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // The loading app can update the browser route before the database opens.
    tester.binding.platformDispatcher.defaultRouteNameTestValue = '/';
    loading.complete(state);
    await tester.pumpAndSettle();
    expect(find.text('afraid'), findsOneWidget);
    expect(find.text('0 / 20'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('storage failure offers retry and retains the launch route', (
    tester,
  ) async {
    tester.binding.platformDispatcher.defaultRouteNameTestValue = '/learn/1/1';
    addTearDown(
      tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
    );
    var attempts = 0;
    await tester.pumpWidget(
      Bootstrap(
        loadState: () async {
          attempts++;
          if (attempts == 1) throw StateError('Database unavailable');
          return state;
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Could not load app data.'), findsOneWidget);
    expect(find.text('afraid'), findsNothing);
    tester.binding.platformDispatcher.defaultRouteNameTestValue = '/';
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.text('afraid'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
