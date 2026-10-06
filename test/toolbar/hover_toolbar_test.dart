import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/core/flutter_agentation.dart';
import 'package:flutter_agentation/src/toolbar/agentation_toolbar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Toolbar Position & Hover Stability Test Suite', () {
    testWidgets('toolbar position remains completely stable on hover of any widget or toolbar itself',
        (tester) async {
      final controller = AgentationController();

      await tester.pumpWidget(
        MaterialApp(
          home: FlutterAgentation(
            controller: controller,
            showToolbar: true,
            child: Scaffold(
              body: Column(
                children: [
                  Container(
                    key: const ValueKey('red_box'),
                    height: 200,
                    width: 300,
                    color: Colors.red,
                  ),
                  Container(
                    key: const ValueKey('blue_box'),
                    height: 200,
                    width: 300,
                    color: Colors.blue,
                  ),
                  Container(
                    key: const ValueKey('green_box'),
                    height: 200,
                    width: 300,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final toolbarFinder = find.byType(AgentationToolbar);
      final initialToolbarRect = tester.getRect(toolbarFinder);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await tester.pump();

      // 1. Hover over red container
      await gesture.moveTo(const Offset(100, 100));
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.getRect(toolbarFinder), equals(initialToolbarRect));
      expect(controller.hoveredResult, isNotNull);

      // 2. Hover over green container (near bottom)
      await gesture.moveTo(const Offset(100, 500));
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.getRect(toolbarFinder), equals(initialToolbarRect));
      expect(controller.hoveredResult, isNotNull);

      // 3. Hover directly over toolbar: position does not move and hoveredResult clears
      final toolbarCenter = initialToolbarRect.center;
      await gesture.moveTo(toolbarCenter);
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.getRect(toolbarFinder), equals(initialToolbarRect));
      expect(controller.hoveredResult, isNull);

      // 4. After animation delay, toolbar position remains completely stable
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.getRect(toolbarFinder), equals(initialToolbarRect));

      await gesture.removePointer();
    });

    testWidgets('toolbar position remains fixed at dragged position across hover events',
        (tester) async {
      final controller = AgentationController();

      await tester.pumpWidget(
        MaterialApp(
          home: FlutterAgentation(
            controller: controller,
            showToolbar: true,
            child: Scaffold(
              body: Center(
                child: Container(
                  height: 300,
                  width: 300,
                  color: Colors.purple,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final toolbarFinder = find.byType(AgentationToolbar);

      // Drag toolbar from bottom right toward the center
      final center = tester.getCenter(toolbarFinder);
      await tester.dragFrom(center, const Offset(-150, -100));
      await tester.pumpAndSettle();

      final draggedToolbarRect = tester.getRect(toolbarFinder);

      // Hover over various points
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await tester.pump();

      await gesture.moveTo(const Offset(50, 50));
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.getRect(toolbarFinder), equals(draggedToolbarRect));

      await gesture.moveTo(draggedToolbarRect.center);
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.getRect(toolbarFinder), equals(draggedToolbarRect));

      await gesture.moveTo(const Offset(400, 300));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.getRect(toolbarFinder), equals(draggedToolbarRect));

      await gesture.removePointer();
    });
  });
}
