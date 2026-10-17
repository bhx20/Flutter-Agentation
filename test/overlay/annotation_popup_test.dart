import 'package:flutter/material.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/core/agentation_scope.dart';
import 'package:flutter_agentation/src/domain/widget_bounds.dart';
import 'package:flutter_agentation/src/domain/widget_context.dart';
import 'package:flutter_agentation/src/domain/widget_identity.dart';
import 'package:flutter_agentation/src/domain/widget_inspection_result.dart';
import 'package:flutter_agentation/src/ui/overlay/annotation_popup.dart';
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

      // Verify Cancel and Add buttons exist and Add button height is 32.0
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
      expect(tester.getSize(find.byType(ElevatedButton)).height, equals(32.0));
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

    testWidgets('AnnotationPopup code review box is collapsed by default and expands on tap',
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
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify controller.popupBounds is populated
      expect(controller.popupBounds, isNotNull);

      // Verify header is present
      expect(find.text('ElevatedButton'), findsOneWidget);

      // Verify code review box is collapsed by default
      expect(find.text('WIDGET CODE'), findsNothing);
      expect(find.text('Copy'), findsNothing);

      // Tap header to expand code review box
      await tester.tap(find.text('ElevatedButton'));
      await tester.pumpAndSettle();

      // Verify WIDGET CODE label and Copy button are now present
      expect(find.text('WIDGET CODE'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.textContaining('ElevatedButton('), findsWidgets);

      // Tap Copy button
      await tester.tap(find.text('Copy'));
      await tester.pump();

      // Verify visual feedback indicates Copied
      expect(find.text('Copied'), findsOneWidget);

      // Tap header again to collapse
      await tester.tap(find.text('ElevatedButton'));
      await tester.pumpAndSettle();

      expect(find.text('WIDGET CODE'), findsNothing);
      expect(find.text('Copy'), findsNothing);
    });

    testWidgets('AnnotationPopup with initialCodeExpanded: true renders code box immediately',
        (tester) async {
      final controller = AgentationController();
      const customCodeResult = WidgetInspectionResult(
        identity: WidgetIdentity(
          id: 'custom_widget',
          widgetType: 'SpecialCard',
        ),
        bounds: WidgetBounds(x: 10, y: 10, width: 200, height: 100),
        context: WidgetContext.empty(),
        ancestors: ['SpecialCard'],
        widgetCode: 'SpecialCard(\n  color: Colors.purple,\n)',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AgentationScope(
                  controller: controller,
                  child: AnnotationPopup(
                    result: customCodeResult,
                    initialCodeExpanded: true,
                    onClose: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('WIDGET CODE'), findsOneWidget);
      expect(find.textContaining('SpecialCard('), findsWidgets);
      expect(find.textContaining('Colors.purple'), findsWidgets);
    });

    testWidgets('AnnotationPopup adapts responsively to narrow mobile screens and sets basic cursor',
        (tester) async {
      final controller = AgentationController();

      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

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
      await tester.pumpAndSettle();

      // Verify popup renders within screen bounds without overflow and is centered
      final mouseRegionFinder = find.byKey(const ValueKey('annotation_popup_card_mouse_region'));
      expect(mouseRegionFinder, findsOneWidget);
      final mouseRegion = tester.widget<MouseRegion>(mouseRegionFinder);
      expect(mouseRegion.cursor, equals(SystemMouseCursors.basic));

      final positioned = tester.widget<Positioned>(
        find.ancestor(of: mouseRegionFinder, matching: find.byType(Positioned)).first,
      );
      // On 320 width screen, card width is 320 - 24 = 296, centered at (320 - 296)/2 = 12.0
      expect(positioned.left, equals(12.0));

      // Verify comment box is compact on mobile (minLines: 1)
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.minLines, equals(1));
      expect(textField.maxLines, equals(3));
    });

    testWidgets('AnnotationPopup positions dynamically near tapPosition rather than fixed at widget bounds',
        (tester) async {
      final controller = AgentationController();

      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Wide container spanning 800px, user clicks at (550, 90)
      final wideResult = WidgetInspectionResult(
        identity: const WidgetIdentity(id: 'wide_card', widgetType: 'Card'),
        bounds: const WidgetBounds(x: 50.0, y: 50.0, width: 800.0, height: 200.0),
        context: const WidgetContext.empty(),
        ancestors: const [],
        tapPosition: const Offset(550.0, 90.0),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AgentationScope(
                  controller: controller,
                  child: AnnotationPopup(
                    result: wideResult,
                    onClose: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Pinned '+' badge must be at the tap coordinates (550, 90), NOT at the widget bottom-left (50, 250)
      final plusCenter = tester.getCenter(find.byIcon(Icons.add));
      expect(plusCenter.dx, closeTo(550.0, 1.0));
      expect(plusCenter.dy, closeTo(90.0, 1.0));

      // Card must be centered horizontally on tapPosition (550.0)
      final cardRect = tester.getRect(find.byKey(const ValueKey('annotation_popup_card_mouse_region')));
      expect(cardRect.center.dx, closeTo(550.0, 1.0));
      expect(cardRect.top, greaterThanOrEqualTo(90.0 + 16.0));
    });

    testWidgets('dynamically resolves action colors and placeholders for AreaSelection, MultiSelect, and Rearrange',
        (tester) async {
      final controller = AgentationController();

      // 1. AreaSelection: Green (#34C759) and "What should change in this area?"
      const areaResult = WidgetInspectionResult(
        identity: WidgetIdentity(id: 'area_1', widgetType: 'AreaSelection'),
        bounds: WidgetBounds(x: 20, y: 30, width: 200, height: 100),
        context: WidgetContext.empty(),
        ancestors: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AgentationScope(
                  controller: controller,
                  child: AnnotationPopup(
                    result: areaResult,
                    onClose: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('What should change in this area?'), findsOneWidget);
      expect(find.text('Area selection'), findsOneWidget);

      // Verify Add button background is Green (#34C759)
      final addButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(addButton.style?.backgroundColor?.resolve({}), equals(const Color(0xFF34C759)));

      // 2. Standard element click uses vibrant Blue (#0088FF)
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
      await tester.pumpAndSettle();

      var dynamicAddButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(dynamicAddButton.style?.backgroundColor?.resolve({}), equals(const Color(0xFF0088FF)));

      // 3. Intent Selector: tapping Change, Bug, Suggestion dynamically updates colors
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AgentationScope(
                  controller: controller,
                  child: AnnotationPopup(
                    result: dummyResult,
                    showIntentSelector: true,
                    onClose: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initial intent is Suggestion -> Green (#34C759)
      dynamicAddButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(dynamicAddButton.style?.backgroundColor?.resolve({}), equals(const Color(0xFF34C759)));

      // Tap 'Change' -> updates button and active color to Yellow (#FFCC00)
      await tester.tap(find.text('Change'));
      await tester.pumpAndSettle();

      dynamicAddButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(dynamicAddButton.style?.backgroundColor?.resolve({}), equals(const Color(0xFFFFCC00)));

      // Tap 'Bug' -> updates button and active color to Red (#FF383C)
      await tester.tap(find.text('Bug'));
      await tester.pumpAndSettle();

      dynamicAddButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(dynamicAddButton.style?.backgroundColor?.resolve({}), equals(const Color(0xFFFF383C)));

      // Tap 'Suggestion' -> updates button and active color to Green (#34C759)
      await tester.tap(find.text('Suggestion'));
      await tester.pumpAndSettle();

      dynamicAddButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(dynamicAddButton.style?.backgroundColor?.resolve({}), equals(const Color(0xFF34C759)));
    });
  });
}


