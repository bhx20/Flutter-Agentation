import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/inspection/hit_test_engine.dart';
import '../helpers/inspection_test_harness.dart';

void main() {
  group('HitTestEngine', () {
    final engine = HitTestEngine();

    testWidgets('successfully hits RenderBox under tap position', (tester) async {
      await InspectionTestHarness.pumpStandardTree(
        tester,
        targetKey: const ValueKey('button_target'),
      );

      final buttonFinder = find.byKey(const ValueKey('button_target'));
      final center = tester.getCenter(buttonFinder);

      final targetBox = engine.findTargetRenderBox(center);
      expect(targetBox, isNotNull);
      expect(targetBox!.hasSize, isTrue);
    });

    testWidgets('respects ignoredRenderObjects set', (tester) async {
      await InspectionTestHarness.pumpStandardTree(
        tester,
        targetKey: const ValueKey('button_target'),
      );

      final buttonFinder = find.byKey(const ValueKey('button_target'));
      final center = tester.getCenter(buttonFinder);

      final firstBox = engine.findTargetRenderBox(center);
      expect(firstBox, isNotNull);

      // Pass firstBox into ignored list
      final nextBox = engine.findTargetRenderBox(
        center,
        ignoredRenderObjects: {firstBox!},
      );

      // Should skip firstBox and find underlying/parent render box
      expect(nextBox, isNot(equals(firstBox)));
    });

    testWidgets('returns empty list for coordinates outside bounds', (tester) async {
      await InspectionTestHarness.pumpStandardTree(tester);

      final result = engine.hitTest(const Offset(-999.0, -999.0));
      expect(result, isEmpty);

      final target = engine.findTargetRenderBox(const Offset(-999.0, -999.0));
      expect(target, isNull);
    });
  });
}
