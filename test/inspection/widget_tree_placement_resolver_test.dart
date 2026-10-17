import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/inspection/widget_tree_placement_resolver.dart';

void main() {
  group('WidgetTreePlacementResolver Widget Tree Placement Test Suite', () {
    test('formatComment formats Move and Place correctly for all directions', () {
      final resolver = WidgetTreePlacementResolver();

      // Case 1: After sibling in Column
      const placementAfter = WidgetTreePlacement(
        parentWidget: 'Column',
        direction: 'after',
        relativeTarget: "Text ('Basic & Boxes')",
        siblingBefore: "Text ('Basic & Boxes')",
        siblingAfter: "TextField ('Search')",
        childIndex: 1,
        totalChildren: 3,
        description: "after Text ('Basic & Boxes') in Column",
      );

      expect(
        resolver.formatComment(
          action: 'Move',
          targetLabel: 'ElevatedButton',
          placement: placementAfter,
        ),
        equals("Move ElevatedButton after Text ('Basic & Boxes') in Column"),
      );

      expect(
        resolver.formatComment(
          action: 'Place',
          targetLabel: 'ElevatedButton',
          placement: placementAfter,
        ),
        equals("Place ElevatedButton inside Column after Text ('Basic & Boxes')"),
      );

      // Case 2: As first child of Column
      const placementFirst = WidgetTreePlacement(
        parentWidget: 'Column',
        direction: 'first',
        relativeTarget: "Text ('Header')",
        siblingAfter: "Text ('Header')",
        childIndex: 0,
        totalChildren: 3,
        description: 'as first child of Column',
      );

      expect(
        resolver.formatComment(
          action: 'Move',
          targetLabel: 'ElevatedButton',
          placement: placementFirst,
        ),
        equals('Move ElevatedButton as first child of Column'),
      );

      expect(
        resolver.formatComment(
          action: 'Place',
          targetLabel: 'ElevatedButton',
          placement: placementFirst,
        ),
        equals('Place ElevatedButton as first child of Column'),
      );

      // Case 3: As last child of Column
      const placementLast = WidgetTreePlacement(
        parentWidget: 'Column',
        direction: 'last',
        relativeTarget: "TextButton ('Cancel')",
        siblingBefore: "TextButton ('Cancel')",
        childIndex: 3,
        totalChildren: 3,
        description: 'as last child of Column',
      );

      expect(
        resolver.formatComment(
          action: 'Move',
          targetLabel: 'ElevatedButton',
          placement: placementLast,
        ),
        equals('Move ElevatedButton as last child of Column'),
      );

      // Case 4: Inside container
      const placementInside = WidgetTreePlacement(
        parentWidget: 'Card',
        direction: 'inside',
        relativeTarget: 'Card',
        description: 'inside Card',
      );

      expect(
        resolver.formatComment(
          action: 'Move',
          targetLabel: 'ElevatedButton',
          placement: placementInside,
        ),
        equals('Move ElevatedButton inside Card'),
      );

      expect(
        resolver.formatComment(
          action: 'Place',
          targetLabel: 'ElevatedButton',
          placement: placementInside,
        ),
        equals('Place ElevatedButton inside Card'),
      );

      // Case 5: Before sibling in Column
      const placementBefore = WidgetTreePlacement(
        parentWidget: 'Column',
        direction: 'before',
        relativeTarget: "TextField ('Username')",
        siblingBefore: "Text ('Header')",
        siblingAfter: "TextField ('Username')",
        childIndex: 1,
        totalChildren: 3,
        description: "before TextField ('Username') in Column",
      );

      expect(
        resolver.formatComment(
          action: 'Move',
          targetLabel: 'ElevatedButton',
          placement: placementBefore,
        ),
        equals("Move ElevatedButton before TextField ('Username') in Column"),
      );
    });

    testWidgets('resolves widget tree placement in live Column layout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 50, child: Text('Basic & Boxes')),
                  const SizedBox(height: 50, child: TextField(key: ValueKey('input_box'))),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Submit Button'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final resolver = WidgetTreePlacementResolver();
      final rootElement = tester.element(find.byType(Scaffold));

      // 1. Drop between 'Basic & Boxes' and 'Submit Button'
      final textRect = tester.getRect(find.text('Basic & Boxes'));
      final buttonRect = tester.getRect(find.text('Submit Button'));
      final midpoint = Offset(
        textRect.center.dx,
        (textRect.bottom + buttonRect.top) / 2.0,
      );

      final placement = resolver.resolvePlacement(
        dropPosition: midpoint,
        rootElement: rootElement,
      );

      expect(placement.parentWidget, equals('Column'));
      expect(placement.direction, isNotNull);
      expect(placement.relativeTarget, isNotNull);

      final comment = resolver.formatComment(
        action: 'Move',
        targetLabel: 'ElevatedButton',
        placement: placement,
      );

      // Verify widget tree placement string is complete and does not contain broken fragments
      expect(comment, startsWith('Move ElevatedButton'));
      expect(comment, contains('Column'));
      expect(comment, isNot(endsWith('after')));
      expect(comment, isNot(endsWith('before')));
      expect(comment, isNot(contains('exact position (x:')));
    });

    testWidgets('resolves widget tree placement in live Row layout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                const SizedBox(width: 80, child: Icon(Icons.star)),
                const SizedBox(width: 120, child: Text('Rating Label')),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final resolver = WidgetTreePlacementResolver();
      final rootElement = tester.element(find.byType(Scaffold));

      final iconRect = tester.getRect(find.byType(Icon));
      final dropPos = Offset(iconRect.right + 10, iconRect.center.dy);

      final placement = resolver.resolvePlacement(
        dropPosition: dropPos,
        rootElement: rootElement,
      );

      expect(placement.parentWidget, equals('Row'));
      final comment = resolver.formatComment(
        action: 'Place',
        targetLabel: 'Chip',
        placement: placement,
      );

      expect(comment, startsWith('Place Chip'));
      expect(comment, contains('Row'));
      expect(comment, isNot(endsWith('after')));
      expect(comment, isNot(contains('exact position (x:')));
    });
  });
}
