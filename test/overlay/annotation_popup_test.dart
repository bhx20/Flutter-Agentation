import 'package:flutter/material.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/core/agentation_scope.dart';
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

    testWidgets('renders inputbox, cancel and add buttons by default', (tester) async {
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

      // Verify comment input field
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('What should change?'), findsOneWidget);

      // Verify header details and intent chips are NOT rendered by default
      expect(find.text('Change'), findsNothing);
      expect(find.text('Bug'), findsNothing);
      expect(find.text('Suggestion'), findsNothing);

      // Verify Cancel and Add buttons exist
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('typing comment and tapping Add persists annotation to controller',
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

      // Tap Add
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(controller.annotations.length, equals(1));
      expect(controller.annotations.first.comment, equals('Change text to Submit'));
      expect(closed, isTrue);
    });

    testWidgets('showHierarchy and showIntentSelector flags render extra options when enabled',
        (tester) async {
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
                    showHierarchy: true,
                    showIntentSelector: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('ElevatedButton'), findsOneWidget);
      expect(find.text('Change'), findsOneWidget);
      expect(find.text('Bug'), findsOneWidget);
      expect(find.text('Suggestion'), findsOneWidget);
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
