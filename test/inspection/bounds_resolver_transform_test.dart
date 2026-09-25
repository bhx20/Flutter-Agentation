import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/inspection/bounds_resolver.dart';
import '../helpers/inspection_test_harness.dart';

void main() {
  group('BoundsResolver Transforms', () {
    final resolver = BoundsResolver();

    testWidgets('computes enclosing bounding box for rotated widgets accurately', (tester) async {
      const boxKey = ValueKey('transformed_box');
      await InspectionTestHarness.pumpTransformedTree(tester, targetKey: boxKey);

      final boxFinder = find.byKey(boxKey);
      final renderBox = tester.renderObject<RenderBox>(boxFinder);

      final bounds = resolver.resolveBounds(renderBox);

      // Rotated 100x100 box by ~28.6 degrees should produce enclosing width > 100
      expect(bounds.width, greaterThan(100.0));
      expect(bounds.height, greaterThan(100.0));
      expect(bounds.x.isFinite, isTrue);
      expect(bounds.y.isFinite, isTrue);
    });

    testWidgets('computes accurate bounds for scaled containers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Transform.scale(
                scale: 2.0,
                child: Container(
                  key: const ValueKey('scaled_box'),
                  width: 50.0,
                  height: 50.0,
                  color: Colors.green,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final boxFinder = find.byKey(const ValueKey('scaled_box'));
      final renderBox = tester.renderObject<RenderBox>(boxFinder);

      final bounds = resolver.resolveBounds(renderBox);

      // Scaled by 2.0: 50x50 becomes 100x100 in global coordinates
      expect(bounds.width, closeTo(100.0, 1.0));
      expect(bounds.height, closeTo(100.0, 1.0));
    });
  });
}
