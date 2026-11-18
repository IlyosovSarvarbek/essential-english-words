import 'package:essential_words_flutter/theme/app_scroll_behavior.dart';
import 'package:essential_words_flutter/theme/app_theme.dart';
import 'package:essential_words_flutter/widgets/animated_flip.dart';
import 'package:essential_words_flutter/widgets/common.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Widget flip(bool flipped, {bool reducedMotion = false}) => MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reducedMotion),
      child: Center(
        child: SizedBox(
          width: 300,
          child: AnimatedFlip(
            flipped: flipped,
            front: const SizedBox(height: 380, child: Text('Front')),
            back: const SizedBox(height: 440, child: Text('Translation')),
          ),
        ),
      ),
    ),
  );

  testWidgets(
    'flip rotates before revealing readable translation and resizes smoothly',
    (tester) async {
      await tester.pumpWidget(flip(false));
      await tester.pumpWidget(flip(true));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Front'), findsOneWidget);
      expect(find.text('Translation'), findsNothing);
      final rotation = tester
          .widget<Transform>(
            find
                .descendant(
                  of: find.byType(AnimatedFlip),
                  matching: find.byType(Transform),
                )
                .first,
          )
          .transform;
      expect(rotation.entry(0, 0), inExclusiveRange(0, 1));
      await tester.pump(const Duration(milliseconds: 180));
      expect(find.text('Translation'), findsOneWidget);
      final backRotation = tester
          .widget<Transform>(
            find
                .descendant(
                  of: find.byType(AnimatedFlip),
                  matching: find.byType(Transform),
                )
                .first,
          )
          .transform;
      expect(backRotation.entry(0, 0), greaterThanOrEqualTo(0));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(AnimatedFlip)).height, 440);
      await tester.pumpWidget(flip(false));
      await tester.pumpAndSettle();
      expect(find.text('Front'), findsOneWidget);
      expect(tester.getSize(find.byType(AnimatedFlip)).height, 380);
    },
  );

  testWidgets(
    'rapid reverse and disposal during a flip leave no stale face or ticker',
    (tester) async {
      await tester.pumpWidget(flip(false));
      await tester.pumpWidget(flip(true));
      await tester.pump(const Duration(milliseconds: 90));
      await tester.pumpWidget(flip(false));
      await tester.pumpAndSettle();
      expect(find.text('Front'), findsOneWidget);
      expect(find.text('Translation'), findsNothing);
      await tester.pumpWidget(flip(true));
      await tester.pump(const Duration(milliseconds: 80));
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('reduced motion reveals the other face immediately', (
    tester,
  ) async {
    await tester.pumpWidget(flip(false, reducedMotion: true));
    await tester.pumpWidget(flip(true, reducedMotion: true));
    expect(find.text('Translation'), findsOneWidget);
    expect(tester.getSize(find.byType(AnimatedFlip)).height, 440);
    expect(tester.binding.transientCallbackCount, 0);
  });

  for (final dark in [true, false]) {
    for (final isCard in [true, false]) {
      testWidgets(
        '${dark ? 'dark' : 'light'} ${isCard ? 'card' : 'button'} creates a ripple and lets it fade',
        (tester) async {
          var taps = 0;
          await tester.pumpWidget(
            MaterialApp(
              theme: appTheme(dark),
              home: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 300,
                    child: isCard
                        ? SurfaceCard(
                            onTap: () => taps++,
                            child: const Text('Book 1'),
                          )
                        : ActionButton('Continue', onPressed: () => taps++),
                  ),
                ),
              ),
            ),
          );
          final target = find.byType(InkWell).first;
          final dynamic ink = Material.of(tester.element(target));
          final gesture = await tester.startGesture(tester.getCenter(target));
          await tester.pump(const Duration(milliseconds: 120));
          expect(
            (ink.debugInkFeatures as List).whereType<InkRipple>(),
            isNotEmpty,
          );
          await gesture.up();
          await tester.pumpAndSettle();
          expect(taps, 1);
          expect(
            (ink.debugInkFeatures as List).whereType<InkRipple>(),
            isEmpty,
          );
        },
      );
    }
  }

  testWidgets(
    'short and long lists overscroll while held and spring back at both edges',
    (tester) async {
      for (final count in [1, 20]) {
        final controller = ScrollController();
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          MaterialApp(
            scrollBehavior: const AppScrollBehavior(),
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  height: 240,
                  child: ListView.builder(
                    controller: controller,
                    itemCount: count,
                    itemBuilder: (_, index) =>
                        SizedBox(height: 64, child: Text('Item $index')),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final viewport = find.byType(ListView);
        final topDrag = await tester.startGesture(tester.getCenter(viewport));
        await topDrag.moveBy(const Offset(0, 25));
        await tester.pump();
        await topDrag.moveBy(const Offset(0, 100));
        await tester.pump(const Duration(milliseconds: 100));
        expect(
          controller.offset,
          lessThan(controller.position.minScrollExtent),
        );
        await topDrag.up();
        await tester.pumpAndSettle();
        expect(
          controller.offset,
          closeTo(controller.position.minScrollExtent, .1),
        );

        controller.jumpTo(controller.position.maxScrollExtent);
        await tester.pumpAndSettle();
        final bottomDrag = await tester.startGesture(
          tester.getCenter(viewport),
        );
        await bottomDrag.moveBy(const Offset(0, -25));
        await tester.pump();
        await bottomDrag.moveBy(const Offset(0, -100));
        await tester.pump(const Duration(milliseconds: 100));
        expect(
          controller.offset,
          greaterThan(controller.position.maxScrollExtent),
        );
        await bottomDrag.up();
        await tester.pumpAndSettle();
        expect(
          controller.offset,
          closeTo(controller.position.maxScrollExtent, .1),
        );
      }
    },
    variant: TargetPlatformVariant.all(),
  );

  testWidgets(
    'desktop mouse dragging also rubber-bands and returns to the edge',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          scrollBehavior: const AppScrollBehavior(),
          home: Scaffold(
            body: ListView(
              controller: controller,
              children: const [Text('Short list')],
            ),
          ),
        ),
      );
      final gesture = await tester.startGesture(
        const Offset(200, 150),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.moveBy(const Offset(0, 30));
      await tester.pump();
      await gesture.moveBy(const Offset(0, 120));
      await tester.pump();
      expect(controller.offset, lessThan(0));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(controller.offset, closeTo(0, .1));
    },
  );
}
