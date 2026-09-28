import 'package:flutter/material.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/core/agentation_scope.dart';
import 'package:flutter_agentation/src/core/flutter_agentation.dart';
import 'package:flutter_agentation/src/toolbar/agentation_toolbar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgentationToolbar Exact UI & Parity Test Suite', () {
    testWidgets('renders all 7 action buttons and Eye icon toggles comments visibility',
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

      // Tap Eye toggle to hide comments
      expect(controller.areCommentsVisible, isTrue);
      await tester.tap(find.byKey(const ValueKey('toolbar_inspect')));
      await tester.pumpAndSettle();

      expect(controller.areCommentsVisible, isFalse);

      // Tapping again displays comments
      await tester.tap(find.byKey(const ValueKey('toolbar_inspect')));
      await tester.pumpAndSettle();

      expect(controller.areCommentsVisible, isTrue);
    });

    testWidgets('play pause button toggles inspect and freeze state', (tester) async {
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
      expect(controller.isInspecting, isFalse);

      await tester.tap(find.byKey(const ValueKey('toolbar_pause')));
      await tester.pumpAndSettle();

      expect(controller.isFrozen, isTrue);
      expect(controller.isInspecting, isTrue);

      await tester.tap(find.byKey(const ValueKey('toolbar_pause')));
      await tester.pumpAndSettle();

      expect(controller.isFrozen, isFalse);
      expect(controller.isInspecting, isFalse);
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

    testWidgets('expanding minimized toolbar near right edge stays within screen bounds', (tester) async {
      final controller = AgentationController();
      const screenSize = Size(800, 600);

      tester.view.physicalSize = screenSize;
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
                  child: const AgentationToolbar(),
                ),
              ],
            ),
          ),
        ),
      );

      // Minimize the toolbar
      await tester.tap(find.byKey(const ValueKey('toolbar_close')));
      await tester.pumpAndSettle();
      expect(controller.isToolbarMinimized, isTrue);

      // Drag minimized pill far to the bottom right edge
      await tester.drag(find.byKey(const ValueKey('toolbar_expand')), const Offset(500, 500));
      await tester.pumpAndSettle();

      // Now expand the toolbar
      await tester.tap(find.byKey(const ValueKey('toolbar_expand')));
      await tester.pumpAndSettle();
      expect(controller.isToolbarMinimized, isFalse);

      // Verify the expanded toolbar container is completely inside the screen bounds
      final toolbarRect = tester.getRect(find.byKey(const ValueKey('toolbar_pause')));
      expect(toolbarRect.left, greaterThanOrEqualTo(0.0));
      expect(toolbarRect.right, lessThanOrEqualTo(screenSize.width));

      final closeRect = tester.getRect(find.byKey(const ValueKey('toolbar_close')));
      expect(closeRect.left, greaterThanOrEqualTo(0.0));
      expect(closeRect.right, lessThanOrEqualTo(screenSize.width));
    });

    testWidgets('toolbar with initialAlignment Alignment.bottomRight renders inside screen', (tester) async {
      final controller = AgentationController();
      const screenSize = Size(800, 600);

      tester.view.physicalSize = screenSize;
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
                  child: const AgentationToolbar(
                    initialAlignment: Alignment.bottomRight,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final pauseRect = tester.getRect(find.byKey(const ValueKey('toolbar_pause')));
      expect(pauseRect.left, greaterThanOrEqualTo(0.0));
      expect(pauseRect.right, lessThanOrEqualTo(screenSize.width));

      final closeRect = tester.getRect(find.byKey(const ValueKey('toolbar_close')));
      expect(closeRect.left, greaterThanOrEqualTo(0.0));
      expect(closeRect.right, lessThanOrEqualTo(screenSize.width));
    });

    testWidgets('right-anchored toolbar keeps right edge fixed and expands to the left', (tester) async {
      final controller = AgentationController();
      const screenSize = Size(800, 600);

      tester.view.physicalSize = screenSize;
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
                  child: const AgentationToolbar(
                    initialAlignment: Alignment.bottomRight,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Minimize the toolbar
      await tester.tap(find.byKey(const ValueKey('toolbar_close')));
      await tester.pumpAndSettle();
      expect(controller.isToolbarMinimized, isTrue);

      final minimizedRect = tester.getRect(find.byKey(const ValueKey('toolbar_expand')));
      final minimizedRight = minimizedRect.right;

      // Expand the toolbar
      await tester.tap(find.byKey(const ValueKey('toolbar_expand')));
      await tester.pumpAndSettle();
      expect(controller.isToolbarMinimized, isFalse);

      final expandedCloseRect = tester.getRect(find.byKey(const ValueKey('toolbar_close')));
      expect(expandedCloseRect.right, lessThanOrEqualTo(screenSize.width));
      expect((expandedCloseRect.right - minimizedRight).abs(), lessThan(30.0));

      final expandedPauseRect = tester.getRect(find.byKey(const ValueKey('toolbar_pause')));
      expect(expandedPauseRect.left, lessThan(minimizedRect.left));
    });

    testWidgets('when toolbar is minimized, inspection does not intercept and host button receives tap', (tester) async {
      int hostTaps = 0;
      final controller = AgentationController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterAgentation(
              controller: controller,
              child: Center(
                child: ElevatedButton(
                  onPressed: () => hostTaps++,
                  child: const Text('Target Button'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(controller.isToolbarMinimized, isFalse);

      // Minimize the toolbar
      await tester.tap(find.byKey(const ValueKey('toolbar_close')));
      await tester.pumpAndSettle();
      expect(controller.isToolbarMinimized, isTrue);
      expect(controller.isInspecting, isFalse);

      // Tap host button while minimized: gestures pass through directly to host app
      await tester.tap(find.text('Target Button'));
      await tester.pumpAndSettle();
      expect(hostTaps, equals(1));

      // Expand toolbar: inspection is re-enabled
      await tester.tap(find.byKey(const ValueKey('toolbar_expand')));
      await tester.pumpAndSettle();
      expect(controller.isToolbarMinimized, isFalse);
      expect(controller.isInspecting, isTrue);
    });

    testWidgets('toggling Eye icon hides and displays annotation comment markers on page', (tester) async {
      final controller = AgentationController();
      await controller.createAnnotation(comment: 'Important note on screen');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterAgentation(
              controller: controller,
              child: const Center(
                child: Text('Main Screen'),
              ),
            ),
          ),
        ),
      );

      // Comments are visible by default: marker with '1' is displayed
      expect(find.text('1'), findsOneWidget);

      // Tap Eye button to hide comments
      await tester.tap(find.byKey(const ValueKey('toolbar_inspect')));
      await tester.pumpAndSettle();

      expect(controller.areCommentsVisible, isFalse);
      expect(find.text('1'), findsNothing);

      // Tap Eye button again to display comments
      await tester.tap(find.byKey(const ValueKey('toolbar_inspect')));
      await tester.pumpAndSettle();

      expect(controller.areCommentsVisible, isTrue);
      expect(find.text('1'), findsOneWidget);
    });
  });
}
