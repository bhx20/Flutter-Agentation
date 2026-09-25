import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/core/flutter_agentation.dart';
import 'package:flutter_agentation/src/overlay/widget_highlight.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Pointer Hover & Touch Interaction', () {
    testWidgets('mouse hover sets hovered candidate result when inspecting',
        (tester) async {
      final controller = AgentationController();

      await tester.pumpWidget(
        MaterialApp(
          home: FlutterAgentation(
            controller: controller,
            showToolbar: false,
            child: Scaffold(
              body: Center(
                child: ElevatedButton(
                  key: const ValueKey('hover_btn'),
                  onPressed: () {},
                  child: const Text('Hover Me'),
                ),
              ),
            ),
          ),
        ),
      );

      controller.activate();
      await tester.pumpAndSettle();

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await tester.pump();

      // Move mouse over button
      final buttonCenter = tester.getCenter(find.text('Hover Me'));
      await gesture.moveTo(buttonCenter);
      await tester.pump();

      // Should have hoveredResult
      expect(controller.hoveredResult, isNotNull);
      expect(controller.hoveredResult!.identity.widgetType, equals('ElevatedButton'));

      // Highlight widget should be rendered in hover mode
      final highlightFinder = find.byType(WidgetHighlight);
      expect(highlightFinder, findsOneWidget);

      await gesture.removePointer();
    });

    testWidgets('direct tap selects widget and locks highlight',
        (tester) async {
      final controller = AgentationController();

      await tester.pumpWidget(
        MaterialApp(
          home: FlutterAgentation(
            controller: controller,
            showToolbar: false,
            child: Scaffold(
              body: Center(
                child: ElevatedButton(
                  key: const ValueKey('touch_btn'),
                  onPressed: () {},
                  child: const Text('Touch Me'),
                ),
              ),
            ),
          ),
        ),
      );

      controller.activate();
      await tester.pumpAndSettle();

      // Direct tap without prior hover
      await tester.tap(find.text('Touch Me'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(controller.selectedResult, isNotNull);
      expect(controller.selectedResult!.identity.widgetType, equals('ElevatedButton'));
    });
  });
}
