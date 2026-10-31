import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_agentation/flutter_agentation.dart';
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

    testWidgets('AnnotationHoverPreviewCard on a large Container anchors directly next to marker pin rather than bottom of container', (tester) async {
      const containerBounds = WidgetBounds(x: 50.0, y: 100.0, width: 300.0, height: 350.0);
      final containerAnnotation = Annotation(
        id: 'ann_box_1',
        comment: 'dffgdf',
        bounds: containerBounds,
        targetWidget: const WidgetIdentity(id: 'box_1', widgetType: 'Container'),
        tapPosition: const Offset(80.0, 110.0),
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AnnotationHoverPreviewCard(
                  annotation: containerAnnotation,
                  bounds: containerBounds,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AnnotationHoverPreviewCard), findsOneWidget);
      final cardTopLeft = tester.getTopLeft(find.byType(AnnotationHoverPreviewCard));
      // Marker pin is at tapPosition (80, 110) -> markerBottom = 122
      // Card should be right below marker pin (~128), NOT at bottom of container (450+)
      expect(cardTopLeft.dy, lessThan(160.0));
      expect(cardTopLeft.dy, greaterThanOrEqualTo(120.0));

      // Card must be centered horizontally directly under the marker pin (markerCenterX = 80.0)
      final cardCenter = tester.getCenter(find.byType(AnnotationHoverPreviewCard));
      expect(cardCenter.dx, closeTo(80.0, 1.0));
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

      // Buttons: Delete icon, Cancel, Save
      expect(find.byKey(const ValueKey('agentation_card_delete_button')), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);

      final saveText = tester.widget<Text>(find.text('Save'));
      expect(saveText.style?.fontWeight, equals(FontWeight.normal));
      final saveContainerFinder = find.ancestor(
        of: find.text('Save'),
        matching: find.byType(Container),
      );
      expect(tester.getSize(saveContainerFinder.first).height, equals(32.0));

      // Edit the text
      await tester.enterText(find.byType(TextField), 'updated comment text');
      await tester.pump();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(closed, isTrue);
      expect(deleted, isFalse);
      expect(controller.annotations.first.comment, equals('updated comment text'));
    });

    testWidgets('tapping delete icon in AnnotationDetailCard triggers onDelete callback', (tester) async {
      bool deleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AnnotationDetailCard(
                  index: 1,
                  annotation: dummyAnnotation,
                  onClose: () {},
                  onDelete: () => deleted = true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('agentation_card_delete_button')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('agentation_card_delete_button')));
      await tester.pumpAndSettle();

      expect(deleted, isTrue);
    });

    testWidgets('AnnotationMarker places marker exactly at tapPosition when provided', (tester) async {
      final tapPos = const Offset(155.0, 165.0);
      final annotationWithTap = dummyAnnotation.copyWith(
        tapPosition: tapPos,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AnnotationMarker(
                  index: 1,
                  annotation: annotationWithTap,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Verify Positioned widget has coordinates centered on tapPosition (posX - 12, posY - 12)
      final positionedFinder = find.byType(Positioned);
      expect(positionedFinder, findsOneWidget);
      final positioned = tester.widget<Positioned>(positionedFinder);
      expect(positioned.left, equals(155.0 - 12.0));
      expect(positioned.top, equals(165.0 - 12.0));
    });

    testWidgets('typing in AnnotationDetailCard text field and pressing Backspace deletes characters', (tester) async {
      final controller = AgentationController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterAgentation(
              controller: controller,
              child: const Center(child: Text('Inspectable Widget')),
            ),
          ),
        ),
      );

      final ann = await controller.createAnnotation(
        comment: 'Needs contrast',
        targetResult: const WidgetInspectionResult(
          identity: WidgetIdentity(id: 'btn1', widgetType: 'ElevatedButton'),
          bounds: WidgetBounds(x: 50, y: 50, width: 100, height: 40),
          context: WidgetContext.empty(),
          ancestors: [],
        ),
      );
      await tester.pumpAndSettle();

      controller.viewAnnotation(ann);
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      await tester.tap(textField);
      await tester.pumpAndSettle();

      await tester.enterText(textField, 'hello');
      await tester.pumpAndSettle();

      final tf = tester.widget<TextField>(textField);
      tf.controller!.selection = TextSelection.collapsed(offset: tf.controller!.text.length);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pumpAndSettle();

      expect(tf.controller!.text, equals('hell'));
      expect(controller.annotations.length, equals(1));
    });

    testWidgets('AnnotationMarker animates scale up from 0.3 to 1.0 on entrance', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AnnotationMarker(
                  index: 1,
                  annotation: dummyAnnotation,
                  onTap: () {},
                  animateEntrance: true,
                  layerIndex: 0,
                  layerSize: 1,
                ),
              ],
            ),
          ),
        ),
      );

      // Initial frame: scale is 0.3, opacity is 0.0
      final scaleFinder = find.byKey(const ValueKey('annotation_marker_scale_transform'));
      final initialScale = tester.widget<Transform>(scaleFinder);
      expect(initialScale.transform.entry(0, 0), closeTo(0.3, 0.05));

      // Advance by entrance animation duration (250ms)
      await tester.pump(const Duration(milliseconds: 250));

      final settledScale = tester.widget<Transform>(scaleFinder);
      expect(settledScale.transform.entry(0, 0), closeTo(1.0, 0.05));
    });

    testWidgets('AnnotationMarker animates scale down to 0.3 when isExiting becomes true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AnnotationMarker(
                  index: 1,
                  annotation: dummyAnnotation,
                  onTap: () {},
                  animateEntrance: false,
                  isExiting: false,
                  layerIndex: 0,
                  layerSize: 1,
                ),
              ],
            ),
          ),
        ),
      );

      final scaleFinder = find.byKey(const ValueKey('annotation_marker_scale_transform'));
      // Resting state: scale 1.0
      var scaleWidget = tester.widget<Transform>(scaleFinder);
      expect(scaleWidget.transform.entry(0, 0), closeTo(1.0, 0.05));

      // Trigger exit
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AnnotationMarker(
                  index: 1,
                  annotation: dummyAnnotation,
                  onTap: () {},
                  animateEntrance: false,
                  isExiting: true,
                  layerIndex: 0,
                  layerSize: 1,
                ),
              ],
            ),
          ),
        ),
      );

      // After exit duration (200ms)
      await tester.pump(const Duration(milliseconds: 200));

      scaleWidget = tester.widget<Transform>(scaleFinder);
      expect(scaleWidget.transform.entry(0, 0), closeTo(0.3, 0.05));
    });

    testWidgets('InspectionOverlay coordinates scale-down exit and scale-up entrance on toggleCommentsVisibility', (tester) async {
      final storage = MemoryAnnotationStorage();
      final controller = AgentationController(storage: storage);
      controller.setToolbarMinimized(false);

      await controller.createAnnotation(
        comment: 'First comment',
        targetResult: const WidgetInspectionResult(
          identity: WidgetIdentity(id: 'txt1', widgetType: 'Text'),
          bounds: WidgetBounds(x: 50, y: 50, width: 100, height: 40),
          context: WidgetContext.empty(),
          ancestors: [],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterAgentation(
              controller: controller,
              showToolbar: false,
              child: const Center(child: Text('Inspectable Widget')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AnnotationMarker), findsOneWidget);

      // Hide comments: marker remains in tree during exit animation
      controller.toggleCommentsVisibility();
      await tester.pump();

      expect(find.byType(AnnotationMarker), findsOneWidget);

      // Advance halfway through exit
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(AnnotationMarker), findsOneWidget);

      // Complete exit animation & timer
      await tester.pumpAndSettle();
      expect(find.byType(AnnotationMarker), findsNothing);

      // Show comments again: marker reappears and scales up
      controller.toggleCommentsVisibility();
      await tester.pump();

      expect(find.byType(AnnotationMarker), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(AnnotationMarker), findsOneWidget);
    });
  });
}

