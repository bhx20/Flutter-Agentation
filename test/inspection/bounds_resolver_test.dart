import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/inspection/bounds_resolver.dart';
import '../helpers/inspection_test_harness.dart';

void main() {
  group('BoundsResolver', () {
    final resolver = BoundsResolver();

    testWidgets('resolves accurate global bounds for standard widgets', (tester) async {
      await InspectionTestHarness.pumpStandardTree(
        tester,
        targetKey: const ValueKey('button_bounds_target'),
      );

      final buttonFinder = find.byKey(const ValueKey('button_bounds_target'));
      final renderBox = tester.renderObject<RenderBox>(buttonFinder);
      final expectedRect = tester.getRect(buttonFinder);

      final bounds = resolver.resolveBounds(renderBox);

      expect(bounds.x, closeTo(expectedRect.left, 1.0));
      expect(bounds.y, closeTo(expectedRect.top, 1.0));
      expect(bounds.width, closeTo(expectedRect.width, 1.0));
      expect(bounds.height, closeTo(expectedRect.height, 1.0));
    });

    testWidgets('returns zero bounds for unattached render object safely', (tester) async {
      final unattachedBox = RenderParagraph(
        const TextSpan(text: 'Unattached'),
        textDirection: TextDirection.ltr,
      );

      final bounds = resolver.resolveBounds(unattachedBox);
      expect(bounds.x, 0.0);
      expect(bounds.y, 0.0);
      expect(bounds.width, 0.0);
      expect(bounds.height, 0.0);
    });
  });
}
