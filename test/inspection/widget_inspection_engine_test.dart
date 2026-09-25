import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/inspection/flutter_inspection_engine.dart';
import '../helpers/inspection_test_harness.dart';

void main() {
  group('FlutterInspectionEngine', () {
    late FlutterInspectionEngine engine;

    setUp(() {
      engine = FlutterInspectionEngine();
    });

    testWidgets('inspectAt resolves button widget with accurate bounds and text', (tester) async {
      const buttonKey = ValueKey('submit_action_button');
      const buttonText = 'Submit Form';

      await InspectionTestHarness.pumpStandardTree(
        tester,
        targetKey: buttonKey,
        targetText: buttonText,
      );

      final buttonFinder = find.byKey(buttonKey);
      final center = tester.getCenter(buttonFinder);
      final expectedRect = tester.getRect(buttonFinder);

      final result = engine.inspectAt(center);

      expect(result.isAvailable, isTrue);
      expect(result.identity.keyString, contains('submit_action_button'));
      expect(result.text, buttonText);

      // Verify coordinate precision within 1.0 px
      expect(result.bounds.x, closeTo(expectedRect.left, 1.0));
      expect(result.bounds.y, closeTo(expectedRect.top, 1.0));
      expect(result.bounds.width, closeTo(expectedRect.width, 1.0));
      expect(result.bounds.height, closeTo(expectedRect.height, 1.0));

      // Verify ancestor list contains higher-level containers
      expect(result.ancestors, contains('MaterialApp'));
      expect(result.ancestors, contains('Scaffold'));
    });

    testWidgets('inspectAt returns unavailable for out-of-bounds tap without throwing', (tester) async {
      await InspectionTestHarness.pumpStandardTree(tester);

      final result = engine.inspectAt(const Offset(-500.0, -500.0));

      expect(result.isAvailable, isFalse);
      expect(result.text, isNull);
      expect(result.ancestors, isEmpty);
      expect(result.bounds.width, 0.0);
    });

    testWidgets('inspectElement handles custom widget tree gracefully', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Card(
                key: ValueKey('info_card'),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Card Content'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final cardFinder = find.byKey(const ValueKey('info_card'));
      final cardElement = tester.element(cardFinder);

      final result = engine.inspectElement(cardElement);

      expect(result.isAvailable, isTrue);
      expect(result.identity.widgetType, 'Card');
      expect(result.text, 'Card Content');
      expect(result.ancestors, contains('Card'));
    });
  });
}
