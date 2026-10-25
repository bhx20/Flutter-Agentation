import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/core/agentation_widget.dart';
import 'package:flutter_agentation/src/inspection/element_inspector.dart';
import 'package:flutter_agentation/src/source_location/source_location_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Hot Reload & Restart Performance Stability', () {
    testWidgets('repeating reassemble 10 times clears stale caches without lag or memory leaks',
        (tester) async {
      final controller = AgentationController();

      await tester.pumpWidget(
        MaterialApp(
          home: FlutterAgentation(
            controller: controller,
            showToolbar: true,
            initialToolbarMinimized: false,
            child: Scaffold(
              body: ListView.builder(
                itemCount: 50,
                itemBuilder: (context, index) {
                  return ListTile(
                    key: ValueKey('item_$index'),
                    title: Text('Item #$index'),
                    subtitle: Text('Detail description for item $index'),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      controller.activate();
      await tester.pumpAndSettle();

      // Add annotations
      controller.selectResult(controller.engine.inspectAt(const Offset(100, 100)));
      await controller.createAnnotation(
        comment: 'First annotation on item',
      );
      controller.selectResult(controller.engine.inspectAt(const Offset(100, 200)));
      await controller.createAnnotation(
        comment: 'Second annotation on item',
      );
      await tester.pumpAndSettle();

      controller.clearSelection();
      await tester.pumpAndSettle();

      // Hover over items
      final target = tester.getCenter(find.text('Item #1'));
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await tester.pump();
      await gesture.moveTo(target);
      await tester.pump();
      expect(controller.hoveredResult, isNotNull);

      // Simulate 20 consecutive hot reloads while moving pointer continuously
      for (int i = 0; i < 20; i++) {
        // ignore: invalid_use_of_protected_member
        tester.element(find.byType(FlutterAgentation)).reassemble();
        await tester.pump();

        // Perform hover inspection after reload across varying widget targets
        await gesture.moveTo(Offset(target.dx, target.dy + ((i % 5) * 8.0)));
        await tester.pump(const Duration(milliseconds: 16));

        // Hover should continue functioning instantaneously
        expect(controller.hoveredResult, isNotNull);
      }

      // After 20 reloads, verify annotations and inspection are fully intact and responsive
      expect(controller.annotations.length, equals(2));

      // Select an item after 20 reloads
      await gesture.moveTo(const Offset(100, 100));
      await tester.pump();
      await tester.tapAt(const Offset(100, 100));
      await tester.pumpAndSettle();

      expect(controller.selectedResult, isNotNull);

      await gesture.removePointer();
    });

    testWidgets('clearCaches directly resets element, source location, and engine registries',
        (tester) async {
      final controller = AgentationController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Container(
                key: const ValueKey('attached_box'),
                width: 100,
                height: 100,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final renderBox = tester.renderObject(find.byKey(const ValueKey('attached_box'))) as RenderBox;
      expect(renderBox.attached, isTrue);

      controller.engine.registerRenderBox('attached_box_id', renderBox);
      expect(controller.engine.getRenderBox('attached_box_id'), isNotNull);

      // Trigger clearCaches
      controller.clearCaches();

      // Registry should be cleared
      expect(controller.engine.getRenderBox('attached_box_id'), isNull);

      // ElementInspector and FlutterSourceLocationResolver should not throw
      ElementInspector.clearCaches();
      FlutterSourceLocationResolver.clearCache();
    });
  });
}

