import 'package:essential_words_flutter/widgets/common.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets(
    'progress fill renders empty, partial, complete and clamped values',
    (tester) async {
      for (final (percent, expectedWidth) in [
        (-20, 0.0),
        (0, 0.0),
        (50, 100.0),
        (100, 200.0),
        (200, 200.0),
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(width: 200, child: ProgressTrack(percent)),
              ),
            ),
          ),
        );
        final fill = find.descendant(
          of: find.byType(ProgressTrack),
          matching: find.byType(DecoratedBox),
        );
        expect(tester.getSize(fill).width, expectedWidth);
        expect(tester.getSize(find.byType(ProgressTrack)).height, 6);
      }
    },
  );
}
