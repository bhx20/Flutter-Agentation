import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/core/agentation_scope.dart';
import 'package:flutter_agentation/src/domain/widget_bounds.dart';
import 'package:flutter_agentation/src/domain/widget_context.dart';
import 'package:flutter_agentation/src/domain/widget_identity.dart';
import 'package:flutter_agentation/src/domain/widget_inspection_result.dart';
import 'package:flutter_agentation/src/ui/overlay/annotation_popup.dart';

void main() {
  group('AnnotationPopup Enter Key Behavior', () {
    testWidgets('Pressing Enter triggers Add Comment and does not insert newline', (tester) async {
      final controller = AgentationController();

      const result = WidgetInspectionResult(
        identity: WidgetIdentity(id: 'btn1', widgetType: 'OutlinedButton'),
        bounds: WidgetBounds(x: 100, y: 100, width: 140, height: 40),
        context: WidgetContext.empty(),
        ancestors: [],
      );

      bool isClosed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentationScope(
              controller: controller,
              child: Stack(
                children: [
                  AnnotationPopup(
                    result: result,
                    onClose: () => isClosed = true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Type comment text
      await tester.enterText(textField, 'dfdfdf');
      await tester.pump();

      // Press Enter key
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      // Annotation must have been added to the controller
      expect(controller.annotations.length, equals(1));
      expect(controller.annotations.first.comment, equals('dfdfdf'));
      expect(isClosed, isTrue);
    });

    testWidgets('Pressing Shift+Enter does not close popup or submit, allowing multiline text', (tester) async {
      final controller = AgentationController();

      const result = WidgetInspectionResult(
        identity: WidgetIdentity(id: 'btn2', widgetType: 'OutlinedButton'),
        bounds: WidgetBounds(x: 100, y: 100, width: 140, height: 40),
        context: WidgetContext.empty(),
        ancestors: [],
      );

      bool isClosed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentationScope(
              controller: controller,
              child: Stack(
                children: [
                  AnnotationPopup(
                    result: result,
                    onClose: () => isClosed = true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'first line');
      await tester.pump();

      // Send Shift+Enter
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();

      // Should NOT submit yet
      expect(controller.annotations.isEmpty, isTrue);
      expect(isClosed, isFalse);
    });
  });
}

