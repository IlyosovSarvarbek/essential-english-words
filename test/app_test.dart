import 'package:essential_words_flutter/app.dart';
import 'package:essential_words_flutter/models/vocabulary.dart';
import 'package:essential_words_flutter/screens/quiz_screen.dart';
import 'package:essential_words_flutter/services/vocabulary_repository.dart';
import 'package:essential_words_flutter/state/app_state.dart';
import 'package:essential_words_flutter/widgets/common.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late VocabularyRepository repository;
  late AppState state;
  setUpAll(() async {
    repository = await VocabularyRepository.load();
  });
  setUp(() async {
    state = AppState(vocabulary: repository, storage: MemoryStorage());
    await state.initialize();
  });

  Future<void> start(WidgetTester tester, {String route = '/'}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      EssentialWordsApp(state: state, initialRoute: route),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String text) async {
    final target = find.text(text).last;
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  testWidgets('books, units, review, progress and theme work together', (
    tester,
  ) async {
    await start(tester);
    expect(find.text('0 of 3600 words learned'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Toggle theme'));
    await tester.pumpAndSettle();
    expect(state.themeMode, ThemeMode.light);
    await tap(tester, 'Book 1');
    await tap(tester, 'Unit 1');
    await tap(tester, 'Review All Words');
    await tester.tap(find.text('Mark as Learned').first);
    await tester.pumpAndSettle();
    expect(find.text('1 / 20'), findsOneWidget);
    expect(state.stats(repository.unit(1, 1).words).percentage, 5);
    await tester.tap(find.bySemanticsLabel('Go back'));
    await tester.pumpAndSettle();
    expect(find.text('1 of 20 words learned'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'flashcards keep their session deck and filter learned words on reentry',
    (tester) async {
      await start(tester, route: '/flashcards/1/1');
      await tap(tester, 'Reveal translation');
      expect(find.text("qo'rqqan, cho'chigan"), findsOneWidget);
      await tap(tester, 'Learned');
      expect(find.text('LEARNED'), findsOneWidget);
      expect(find.text('1 OF 20'), findsOneWidget);
      await tap(tester, 'Next');
      expect(find.text('agree'), findsOneWidget);
      await tap(tester, 'Previous');
      expect(find.text('afraid'), findsOneWidget);
      expect(find.text('LEARNED'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Go back'));
      await tester.pumpAndSettle();
      await tap(tester, 'Practice Flashcards');
      expect(find.text('1 OF 19'), findsOneWidget);
      expect(find.text('agree'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'fully learned units offer review and allow words to be unlearned',
    (tester) async {
      await tester.runAsync(() async {
        for (final word in repository.unit(1, 1).words) {
          await state.setLearned(word, true);
        }
      });
      await start(tester, route: '/flashcards/1/1');
      expect(find.text('All Words Learned!'), findsOneWidget);
      await tap(tester, 'Review All Words');
      await tester.tap(find.text('Learned').first);
      await tester.pumpAndSettle();
      expect(find.text('19 / 20'), findsOneWidget);
      expect(state.isLearned(repository.unit(1, 1).words.first), isFalse);
    },
  );

  for (final mode in QuizMode.values) {
    testWidgets(
      '${mode.value} quiz locks answers, scores, saves, retries and returns',
      (tester) async {
        await start(tester, route: '/quiz/1/1?mode=${mode.value}');
        for (var index = 0; index < 20; index++) {
          expect(find.text('QUESTION ${index + 1} OF 20'), findsOneWidget);
          final word = repository.unit(1, 1).words[index];
          final answer = mode == QuizMode.enUz
              ? word.translation
              : word.english;
          await tap(tester, answer);
          expect(find.text('To‘g‘ri javob! (Correct)'), findsOneWidget);
          // A second tap must not increment the score.
          await tap(tester, answer);
          await tap(tester, index == 19 ? 'Natijalarni ko‘rish' : 'Keyingisi');
        }
        expect(find.text('Quiz completed'), findsOneWidget);
        expect(find.text('100%'), findsOneWidget);
        expect(state.history.length, 1);
        expect(state.history.first.score, 20);
        expect(state.history.first.mode, mode);
        expect(state.learnedIds, isEmpty);
        await tap(tester, 'Retry Quiz');
        expect(find.byType(QuizScreen), findsOneWidget);
        expect(find.text('QUESTION 1 OF 20'), findsOneWidget);
        await tester.tap(find.bySemanticsLabel('Go back'));
        await tester.pumpAndSettle();
        expect(find.text('Choose a learning mode'), findsOneWidget);
        await tester.tap(find.bySemanticsLabel('Go back'));
        await tester.pumpAndSettle();
        expect(find.text('Unit 2'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'incorrect answers reveal the correct option and do not add score',
    (tester) async {
      await start(tester, route: '/quiz/1/1');
      final options = find.byType(SurfaceCard);
      final optionTexts = tester
          .widgetList<Text>(
            find.descendant(of: options.at(1), matching: find.byType(Text)),
          )
          .map((text) => text.data)
          .toList();
      final correct = repository.unit(1, 1).words.first.translation;
      final firstAnswer = optionTexts.last!;
      if (firstAnswer != correct) {
        await tap(tester, firstAnswer);
      } else {
        await tester.tap(options.at(2));
        await tester.pumpAndSettle();
      }
      expect(find.text('Noto‘g‘ri javob (Incorrect)'), findsOneWidget);
      expect(find.text('Siz tanlagan javob'), findsOneWidget);
      expect(find.text('To‘g‘ri javob'), findsOneWidget);
      await tap(tester, 'Keyingisi');
      expect(find.text('QUESTION 2 OF 20'), findsOneWidget);
    },
  );

  testWidgets(
    'dictionary searches both languages and opens the containing unit',
    (tester) async {
      await start(tester, route: '/search');
      await tester.enterText(find.byType(TextField), 'afraid');
      await tester.pumpAndSettle();
      expect(find.text('afraid'), findsAtLeastNWidgets(1));
      await tap(tester, 'Uzbek → English');
      await tester.enterText(find.byType(TextField), "qo'rqqan");
      await tester.pumpAndSettle();
      expect(find.text('afraid'), findsAtLeastNWidgets(1));
      tester.testTextInput.hide();
      await tap(tester, 'afraid');
      expect(find.text('Choose a learning mode'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('narrow screens and larger text remain usable', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await start(tester, route: '/unit/1/1');
    tester.view.physicalSize = const Size(320, 640);
    await tester.pumpAndSettle();
    await tap(tester, 'Practice Flashcards');
    await tap(tester, 'Reveal translation');
    expect(tester.takeException(), isNull);
  });
}
