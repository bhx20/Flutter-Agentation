import 'package:flutter/material.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/core/agentation_scope.dart';
import 'package:flutter_agentation/src/toolbar/agentation_toolbar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgentationToolbar Exact UI & Parity Test Suite', () {
    testWidgets('renders all 7 action buttons matching Screenshot 1 and toggles inspect',
        (tester) async {
      final controller = AgentationController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AgentationScope(
                  controller: controller,
                  child: const AgentationToolbar(),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify all 7 buttons exist by ValueKey
      expect(find.byKey(const ValueKey('toolbar_pause')), findsOneWidget);
      expect(find.byKey(const ValueKey('toolbar_layout')), findsOneWidget);
      expect(find.byKey(const ValueKey('toolbar_inspect')), findsOneWidget);
      expect(find.byKey(const ValueKey('toolbar_copy')), findsOneWidget);
      expect(find.byKey(const ValueKey('toolbar_clear')), findsOneWidget);
      expect(find.byKey(const ValueKey('toolbar_settings')), findsOneWidget);
      expect(find.byKey(const ValueKey('toolbar_close')), findsOneWidget);

      // Tap Inspect toggle
      await tester.tap(find.byKey(const ValueKey('toolbar_inspect')));
      await tester.pumpAndSettle();

      expect(controller.isInspecting, isTrue);

      // Tapping again deactivates inspect
      await tester.tap(find.byKey(const ValueKey('toolbar_inspect')));
      await tester.pumpAndSettle();

      expect(controller.isInactive, isTrue);
    });

    testWidgets('pause animations button toggles freeze state', (tester) async {
      final controller = AgentationController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AgentationScope(
                  controller: controller,
                  child: const AgentationToolbar(),
                ),
              ],
            ),
          ),
        ),
      );

      expect(controller.isFrozen, isFalse);

      await tester.tap(find.byKey(const ValueKey('toolbar_pause')));
      await tester.pumpAndSettle();

      expect(controller.isFrozen, isTrue);

      await tester.tap(find.byKey(const ValueKey('toolbar_pause')));
      await tester.pumpAndSettle();

      expect(controller.isFrozen, isFalse);
    });

    testWidgets('clear action clears annotations in controller',
        (tester) async {
      final controller = AgentationController();
      await controller.createAnnotation(comment: 'Test note');
      expect(controller.annotations.length, equals(1));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AgentationScope(
                  controller: controller,
                  child: const AgentationToolbar(),
                ),
              ],
            ),
          ),
        ),
      );

      // Tap clear button
      final clearFinder = find.byKey(const ValueKey('toolbar_clear'));
      expect(clearFinder, findsOneWidget);
      await tester.tap(clearFinder);
      await tester.pumpAndSettle();

      expect(controller.annotations, isEmpty);
    });

    testWidgets('pan drag moves toolbar across screen', (tester) async {
      final controller = AgentationController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AgentationScope(
                  controller: controller,
                  child: const AgentationToolbar(),
                ),
              ],
            ),
          ),
        ),
      );

      final initialCenter = tester.getCenter(find.byType(AgentationToolbar));

      // Drag toolbar by 100px left and 100px up
      await tester.drag(find.byType(AgentationToolbar), const Offset(-100, -100));
      await tester.pumpAndSettle();

      final newCenter = tester.getCenter(find.byType(AgentationToolbar));
      expect(newCenter.dx, isNot(equals(initialCenter.dx)));
      expect(newCenter.dy, isNot(equals(initialCenter.dy)));
    });

    testWidgets('minimize button collapses toolbar into compact pill',
        (tester) async {
      final controller = AgentationController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AgentationScope(
                  controller: controller,
                  child: const AgentationToolbar(),
                ),
              ],
            ),
          ),
        ),
      );

      final closeFinder = find.byKey(const ValueKey('toolbar_close'));
      expect(closeFinder, findsOneWidget);

      await tester.tap(closeFinder);
      await tester.pumpAndSettle();

      expect(controller.isToolbarMinimized, isTrue);

      // In minimized state, expand pill should be available
      final expandFinder = find.byKey(const ValueKey('toolbar_expand'));
      expect(expandFinder, findsOneWidget);

      await tester.tap(expandFinder);
      await tester.pumpAndSettle();

      expect(controller.isToolbarMinimized, isFalse);
    });

    testWidgets('toggling layout mode opens Layout Mode panel (Screenshot 4)', (tester) async {
      final controller = AgentationController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AgentationScope(
                  controller: controller,
                  child: const AgentationToolbar(),
                ),
              ],
            ),
          ),
        ),
      );

      // Tap layout mode button
      await tester.tap(find.byKey(const ValueKey('toolbar_layout')));
      await tester.pumpAndSettle();

      expect(find.text('Layout Mode'), findsOneWidget);
      expect(find.text('Wireframe New Page'), findsOneWidget);
    });

    testWidgets('toggling settings opens Settings panel (Screenshot 3)', (tester) async {
      final controller = AgentationController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AgentationScope(
                  controller: controller,
                  child: const AgentationToolbar(),
                ),
              ],
            ),
          ),
        ),
      );

      // Tap settings button
      await tester.tap(find.byKey(const ValueKey('toolbar_settings')));
      await tester.pumpAndSettle();

      expect(find.text('Agentation'), findsOneWidget);
      expect(find.text('v3.1.2'), findsOneWidget);
      expect(find.text('Marker Color'), findsOneWidget);
    });
  });
}
