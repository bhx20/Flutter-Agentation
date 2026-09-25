import 'package:flutter/material.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/core/agentation_scope.dart';
import 'package:flutter_agentation/src/models/annotation_intent.dart';
import 'package:flutter_agentation/src/models/widget_bounds.dart';
import 'package:flutter_agentation/src/models/widget_context.dart';
import 'package:flutter_agentation/src/models/widget_identity.dart';
import 'package:flutter_agentation/src/models/widget_inspection_result.dart';
import 'package:flutter_agentation/src/overlay/annotation_popup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnnotationPopup', () {
    const dummyResult = WidgetInspectionResult(
      identity: WidgetIdentity(
        id: 'action_btn',
        keyString: 'action_key',
        widgetType: 'ElevatedButton',
      ),
      bounds: WidgetBounds(x: 40, y: 80, width: 140, height: 44),
      context: WidgetContext(depth: 4),
      ancestors: ['MaterialApp', 'Scaffold', 'ElevatedButton'],
    );

    testWidgets('renders widget identity and input fields', (tester) async {
      final controller = AgentationController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AgentationScope(
                  controller: controller,
                  child: AnnotationPopup(
                    result: dummyResult,
                    onClose: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify header details
      expect(find.text('ElevatedButton'), findsOneWidget);
      expect(find.text('action_key'), findsOneWidget);

      // Verify comment input field
      expect(find.byType(TextField), findsOneWidget);

      // Verify intent chips exist
      expect(find.text('Change'), findsOneWidget);
      expect(find.text('Bug'), findsOneWidget);
      expect(find.text('Suggestion'), findsOneWidget);

      // Verify Save button
      expect(find.text('Save Note'), findsOneWidget);
    });

    testWidgets('typing comment and tapping Save persists annotation to controller',
        (tester) async {
      final controller = AgentationController();
      controller.selectResult(dummyResult);
      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AgentationScope(
                  controller: controller,
                  child: AnnotationPopup(
                    result: dummyResult,
                    onClose: () => closed = true,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Enter comment
      await tester.enterText(find.byType(TextField), 'Change text to Submit');
      await tester.pump();

      // Tap Bug chip
      await tester.tap(find.text('Bug'));
      await tester.pump();

      // Tap Save Note
      await tester.tap(find.text('Save Note'));
      await tester.pumpAndSettle();

      expect(controller.annotations.length, equals(1));
      expect(controller.annotations.first.comment, equals('Change text to Submit'));
      expect(controller.annotations.first.intent, equals(AnnotationIntent.bug));
      expect(closed, isTrue);
    });

    testWidgets('cancel button invokes onClose without creating annotation',
        (tester) async {
      final controller = AgentationController();
      controller.selectResult(dummyResult);
      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AgentationScope(
                  controller: controller,
                  child: AnnotationPopup(
                    result: dummyResult,
                    onClose: () => closed = true,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(controller.annotations, isEmpty);
      expect(closed, isTrue);
    });
  });
}
