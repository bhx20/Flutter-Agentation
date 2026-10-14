import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/core/agentation_scope.dart';
import 'package:flutter_agentation/src/models/annotation.dart';
import 'package:flutter_agentation/src/models/annotation_severity.dart';
import 'package:flutter_agentation/src/models/widget_bounds.dart';
import 'package:flutter_agentation/src/models/widget_context.dart';
import 'package:flutter_agentation/src/models/widget_identity.dart';
import 'package:flutter_agentation/src/models/widget_inspection_result.dart';
import 'package:flutter_agentation/src/overlay/annotation_marker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnnotationMarker & Hover/Edit Flow', () {
    final dummyAnnotation = Annotation(
      id: 'ann_marker_1',
      comment: 'sdfdf',
      timestamp: DateTime.now(),
      targetWidget: const WidgetIdentity(id: 'item_1', widgetType: 'ListTile'),
      bounds: const WidgetBounds(x: 100, y: 150, width: 200, height: 40),
      severity: AnnotationSeverity.high,
    );

    testWidgets('renders index number resting and edit icon on hover (Screenshot 1)', (tester) async {
      bool tapped = false;
      bool hoverChanged = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AnnotationMarker(
                  index: 1,
                  annotation: dummyAnnotation,
                  onTap: () => tapped = true,
                  onHoverChanged: (h) => hoverChanged = h,
                ),
              ],
            ),
          ),
        ),
      );

      // Resting state: displays number "1"
      expect(find.text('1'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsNothing);

      // Hover over the marker
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(find.byType(AnnotationMarker)));
      await tester.pumpAndSettle();

      // Hover state: displays edit pencil icon
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(hoverChanged, isTrue);

      // Tap marker
      await gesture.down(tester.getCenter(find.byType(AnnotationMarker)));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(tapped, isTrue);

      await gesture.removePointer();
    });

    testWidgets('AnnotationHoverPreviewCard renders italic list item and comment text (Screenshot 1)', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AnnotationHoverPreviewCard(
                  annotation: dummyAnnotation,
                  bounds: dummyAnnotation.bounds,
                  onTap: () => tapped = true,
                ),
              ],
            ),
          ),
        ),
      );

      // Displays "list item" in italic and "sdfdf" comment text
      expect(find.text('list item'), findsOneWidget);
      expect(find.text('sdfdf'), findsOneWidget);

      await tester.tap(find.byType(AnnotationHoverPreviewCard));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('AnnotationDetailCard renders edit dialog and saves updated comment (Screenshot 2)', (tester) async {
      final controller = AgentationController();
      await controller.createAnnotation(
        comment: 'sdfdf',
        targetResult: WidgetInspectionResult(
          identity: dummyAnnotation.targetWidget,
          bounds: dummyAnnotation.bounds,
          context: const WidgetContext(depth: 1),
          ancestors: const ['MaterialApp', 'Scaffold', 'ListTile'],
        ),
      );
      final created = controller.annotations.first;

      bool closed = false;
      bool deleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AgentationScope(
            controller: controller,
            child: Scaffold(
              body: Stack(
                children: [
                  AnnotationDetailCard(
                    index: 1,
                    annotation: created,
                    onClose: () => closed = true,
                    onDelete: () => deleted = true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Header displays chevron and "list item"
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
      expect(find.text('list item'), findsOneWidget);

      // TextField contains existing comment "sdfdf"
      expect(find.text('sdfdf'), findsOneWidget);

      // Buttons: Delete, Cancel, Save
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);

      // Edit the text
      await tester.enterText(find.byType(TextField), 'updated comment text');
      await tester.pump();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(closed, isTrue);
      expect(controller.annotations.first.comment, equals('updated comment text'));
    });
  });
}
