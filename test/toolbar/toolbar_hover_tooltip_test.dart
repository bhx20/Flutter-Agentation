import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/flutter_agentation.dart';

void main() {
  group('Toolbar Hover Effect, Disabled States & Custom Tooltip', () {
    testWidgets('Eye, Copy, and Clear buttons are disabled when annotations are empty', (tester) async {
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
      await tester.pumpAndSettle();

      // Pause and Layout buttons are enabled
      expect(find.byKey(const ValueKey('toolbar_pause')), findsOneWidget);
      expect(find.byKey(const ValueKey('toolbar_layout')), findsOneWidget);
      expect(find.byKey(const ValueKey('toolbar_settings')), findsOneWidget);
      expect(find.byKey(const ValueKey('toolbar_close')), findsOneWidget);

      // Verify disabled buttons have 0.35 opacity and ignore taps
      final inspectFinder = find.byKey(const ValueKey('toolbar_inspect'));
      expect(inspectFinder, findsOneWidget);
      final inspectOpacity = tester.widget<Opacity>(
        find.descendant(of: inspectFinder, matching: find.byType(Opacity)),
      );
      expect(inspectOpacity.opacity, equals(0.35));

      final copyFinder = find.byKey(const ValueKey('toolbar_copy'));
      final copyOpacity = tester.widget<Opacity>(
        find.descendant(of: copyFinder, matching: find.byType(Opacity)),
      );
      expect(copyOpacity.opacity, equals(0.35));

      final clearFinder = find.byKey(const ValueKey('toolbar_clear'));
      final clearOpacity = tester.widget<Opacity>(
        find.descendant(of: clearFinder, matching: find.byType(Opacity)),
      );
      expect(clearOpacity.opacity, equals(0.35));

      // Tapping disabled clear does not crash or change state
      await tester.tap(clearFinder);
      await tester.pumpAndSettle();
      expect(controller.annotations, isEmpty);
    });

    testWidgets('Eye, Copy, and Clear buttons become enabled when annotations exist', (tester) async {
      final controller = AgentationController();
      await controller.createAnnotation(comment: 'First issue');

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
      await tester.pumpAndSettle();

      // Opacity is 1.0 (fully enabled)
      final inspectFinder = find.byKey(const ValueKey('toolbar_inspect'));
      final inspectOpacity = tester.widget<Opacity>(
        find.descendant(of: inspectFinder, matching: find.byType(Opacity)),
      );
      expect(inspectOpacity.opacity, equals(1.0));

      final copyFinder = find.byKey(const ValueKey('toolbar_copy'));
      final copyOpacity = tester.widget<Opacity>(
        find.descendant(of: copyFinder, matching: find.byType(Opacity)),
      );
      expect(copyOpacity.opacity, equals(1.0));

      final clearFinder = find.byKey(const ValueKey('toolbar_clear'));
      final clearOpacity = tester.widget<Opacity>(
        find.descendant(of: clearFinder, matching: find.byType(Opacity)),
      );
      expect(clearOpacity.opacity, equals(1.0));

      // Tapping enabled clear removes annotations
      await tester.tap(clearFinder);
      await tester.pumpAndSettle();
      expect(controller.annotations, isEmpty);
    });

    testWidgets('Hovering enabled button triggers circular hover highlight', (tester) async {
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
      await tester.pumpAndSettle();

      final layoutButton = find.byKey(const ValueKey('toolbar_layout'));
      expect(layoutButton, findsOneWidget);

      // Before hover: AnimatedContainer color is transparent
      final initialContainer = tester.widget<AnimatedContainer>(
        find.descendant(of: layoutButton, matching: find.byType(AnimatedContainer)).first,
      );
      final initialDecoration = initialContainer.decoration as BoxDecoration?;
      expect(initialDecoration?.color, equals(Colors.transparent));

      // Hover over layout button with pointer
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();

      await gesture.moveTo(tester.getCenter(layoutButton));
      await tester.pumpAndSettle();

      // After hover: AnimatedContainer has circular hover highlight
      final hoveredContainer = tester.widget<AnimatedContainer>(
        find.descendant(of: layoutButton, matching: find.byType(AnimatedContainer)).first,
      );
      final hoveredDecoration = hoveredContainer.decoration as BoxDecoration?;
      expect(hoveredDecoration?.shape, equals(BoxShape.circle));
      expect(hoveredDecoration?.color, isNot(equals(Colors.transparent)));

      // Moving mouse away resets background
      await gesture.moveTo(Offset.zero);
      await tester.pumpAndSettle();

      final resetContainer = tester.widget<AnimatedContainer>(
        find.descendant(of: layoutButton, matching: find.byType(AnimatedContainer)).first,
      );
      final resetDecoration = resetContainer.decoration as BoxDecoration?;
      expect(resetDecoration?.color, equals(Colors.transparent));
    });

    testWidgets('Tooltip contains label, keyboard shortcut, and custom beak decoration', (tester) async {
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
      await tester.pumpAndSettle();

      // Find tooltips
      final tooltips = tester.widgetList<Tooltip>(find.byType(Tooltip)).toList();
      expect(tooltips, isNotEmpty);

      // Verify Layout mode tooltip has shortcut 'L' and compact/tall padding
      final layoutTooltip = tooltips.firstWhere(
        (t) => (t.richMessage?.toPlainText() ?? '').contains('Layout mode'),
      );
      expect(layoutTooltip.richMessage?.toPlainText(), contains('Layout mode L'));
      expect(layoutTooltip.preferBelow, isFalse);
      expect(layoutTooltip.verticalOffset, equals(30.0));
      expect(layoutTooltip.padding, equals(const EdgeInsets.symmetric(horizontal: 7.0, vertical: 8.5)));
      final darkShapeDeco = layoutTooltip.decoration as ShapeDecoration;
      expect(darkShapeDeco.color, equals(const Color(0xFF18181B)));

      // Verify Exit button tooltip has shortcut 'Esc', preferBelow: false, and verticalOffset: 30.0
      final exitTooltip = tooltips.firstWhere(
        (t) => (t.richMessage?.toPlainText() ?? '').contains('Exit'),
      );
      expect(exitTooltip.richMessage?.toPlainText(), contains('Exit Esc'));
      expect(exitTooltip.preferBelow, isFalse);
      expect(exitTooltip.verticalOffset, equals(30.0));

      // Switch to light mode and verify tooltip background is white
      controller.updateSettings(controller.settings.copyWith(isDarkMode: false));
      await tester.pumpAndSettle();

      final lightTooltips = tester.widgetList<Tooltip>(find.byType(Tooltip)).toList();
      final lightLayoutTooltip = lightTooltips.firstWhere(
        (t) => (t.richMessage?.toPlainText() ?? '').contains('Layout mode'),
      );
      final lightShapeDeco = lightLayoutTooltip.decoration as ShapeDecoration;
      expect(lightShapeDeco.color, equals(Colors.white));
    });

    testWidgets('Minimized toolbar renders badge with selected marker color anchored top-right without clipping', (tester) async {
      final controller = AgentationController();
      controller.updateSettings(const ToolbarSettings(markerColorId: 'blue'));
      await controller.createAnnotation(comment: 'Issue 1');
      controller.setToolbarMinimized(true);

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
      await tester.pumpAndSettle();

      // Expand button is rendered
      expect(find.byKey(const ValueKey('toolbar_expand')), findsOneWidget);

      // Badge displays '1' with white text inside selected marker color container
      expect(find.text('1'), findsOneWidget);
      final badgeContainerFinder = find.ancestor(
        of: find.text('1'),
        matching: find.byType(Container),
      ).first;
      var badgeContainer = tester.widget<Container>(badgeContainerFinder);
      var badgeDeco = badgeContainer.decoration as BoxDecoration?;
      expect(badgeDeco?.color, equals(const Color(0xFF0088FF)));

      // Positioned at top: -4.0, right: -4.0 OUTSIDE ClipRRect (not clipped by ClipRRect)
      final positionedFinder = find.ancestor(
        of: badgeContainerFinder,
        matching: find.byType(Positioned),
      ).first;
      final positioned = tester.widget<Positioned>(positionedFinder);
      expect(positioned.top, equals(-4.0));
      expect(positioned.right, equals(-4.0));
      expect(find.ancestor(of: badgeContainerFinder, matching: find.byType(ClipRRect)), findsNothing);

      // Dynamic marker color update updates badge color
      controller.updateSettings(controller.settings.copyWith(markerColorId: 'rose'));
      await tester.pumpAndSettle();

      badgeContainer = tester.widget<Container>(badgeContainerFinder);
      badgeDeco = badgeContainer.decoration as BoxDecoration?;
      expect(badgeDeco?.color, equals(const Color(0xFFFF383C)));
    });

    testWidgets('hovering minimized button displays Start Feedback Mode tooltip on left side', (tester) async {
      final controller = AgentationController();
      controller.setToolbarMinimized(true);

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
      await tester.pumpAndSettle();

      final expandButton = find.byKey(const ValueKey('toolbar_expand'));
      expect(expandButton, findsOneWidget);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();

      await gesture.moveTo(tester.getCenter(expandButton));
      await tester.pump();
      // Pump mid-animation: FadeTransition is animating in
      await tester.pump(const Duration(milliseconds: 90));
      final fadeFinder = find.ancestor(
        of: find.text('Start Feedback Mode'),
        matching: find.byType(FadeTransition),
      );
      expect(fadeFinder, findsOneWidget);
      final midFadeInOpacity = tester.widget<FadeTransition>(fadeFinder).opacity.value;
      expect(midFadeInOpacity, greaterThan(0.0));
      expect(midFadeInOpacity, lessThan(1.0));

      await tester.pumpAndSettle();

      // Fully faded in: opacity is 1.0
      expect(tester.widget<FadeTransition>(fadeFinder).opacity.value, equals(1.0));
      expect(find.text('Start Feedback Mode'), findsOneWidget);

      // Verify the tooltip is positioned to the left of the expand button
      final buttonRect = tester.getRect(expandButton);
      final tooltipTextPos = tester.getTopLeft(find.text('Start Feedback Mode'));
      expect(tooltipTextPos.dx, lessThan(buttonRect.left));

      // Move mouse away -> fades out
      await gesture.moveTo(Offset.zero);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 90));
      final midFadeOutOpacity = tester.widget<FadeTransition>(fadeFinder).opacity.value;
      expect(midFadeOutOpacity, lessThan(1.0));
      expect(midFadeOutOpacity, greaterThan(0.0));

      await tester.pumpAndSettle();
      expect(find.text('Start Feedback Mode'), findsNothing);
    });

    testWidgets('tooltips are suppressed for layout mode and settings when their menus are already open', (tester) async {
      final controller = AgentationController();
      controller.setToolbarMinimized(false);

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
      await tester.pumpAndSettle();

      // Initially both menus closed -> tooltips exist
      List<Tooltip> tooltips = tester.widgetList<Tooltip>(find.byType(Tooltip)).toList();
      expect(tooltips.any((t) => (t.richMessage?.toPlainText() ?? '').contains('Layout mode')), isTrue);
      expect(tooltips.any((t) => (t.richMessage?.toPlainText() ?? '').contains('Settings')), isTrue);

      // Open Layout Mode -> layout tooltip is suppressed
      controller.toggleLayoutMode();
      await tester.pumpAndSettle();
      expect(controller.isLayoutModeOpen, isTrue);

      tooltips = tester.widgetList<Tooltip>(find.byType(Tooltip)).toList();
      expect(tooltips.any((t) => (t.richMessage?.toPlainText() ?? '').contains('Layout mode')), isFalse);
      expect(tooltips.any((t) => (t.richMessage?.toPlainText() ?? '').contains('Exit layout mode')), isFalse);

      // Close Layout Mode -> layout tooltip is restored
      controller.closeLayoutMode();
      await tester.pumpAndSettle();
      tooltips = tester.widgetList<Tooltip>(find.byType(Tooltip)).toList();
      expect(tooltips.any((t) => (t.richMessage?.toPlainText() ?? '').contains('Layout mode')), isTrue);

      // Open Settings -> settings tooltip is suppressed
      controller.toggleSettings();
      await tester.pumpAndSettle();
      expect(controller.isSettingsOpen, isTrue);

      tooltips = tester.widgetList<Tooltip>(find.byType(Tooltip)).toList();
      expect(tooltips.any((t) => (t.richMessage?.toPlainText() ?? '').contains('Settings')), isFalse);

      // Close Settings -> settings tooltip is restored
      controller.closeSettings();
      await tester.pumpAndSettle();
      tooltips = tester.widgetList<Tooltip>(find.byType(Tooltip)).toList();
      expect(tooltips.any((t) => (t.richMessage?.toPlainText() ?? '').contains('Settings')), isTrue);
    });

    testWidgets('Clear button renders red icon and red background on hover', (tester) async {
      final controller = AgentationController();
      await controller.createAnnotation(
        comment: 'Test annotation',
        targetResult: const WidgetInspectionResult.unavailable(),
      );

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
      await tester.pumpAndSettle();

      final clearFinder = find.byKey(const ValueKey('toolbar_clear'));
      expect(clearFinder, findsOneWidget);

      // Mouse enters clear button
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(clearFinder));
      await tester.pumpAndSettle();

      // Check red background
      final container = tester.widget<AnimatedContainer>(
        find.descendant(of: clearFinder, matching: find.byType(AnimatedContainer)),
      );
      final boxDeco = container.decoration as BoxDecoration;
      expect(boxDeco.color, equals(AgentationColors.destructive.withValues(alpha: 0.2)));

      // Check red trash icon CustomPaint painter
      final customPaints = tester.widgetList<CustomPaint>(
        find.descendant(of: clearFinder, matching: find.byType(CustomPaint)),
      );
      expect(customPaints, isNotEmpty);
      final trashPaint = customPaints.firstWhere(
        (cp) => cp.painter.runtimeType.toString() == '_TrashIconPainter',
      );
      expect((trashPaint.painter as dynamic).color, equals(AgentationColors.destructive));
    });

    testWidgets('collapsing the toolbar hides markers and expanding shows markers', (tester) async {
      final controller = AgentationController();
      await controller.createAnnotation(
        comment: 'Comment 1',
        targetResult: const WidgetInspectionResult(
          identity: WidgetIdentity(id: 'btn1', widgetType: 'ElevatedButton'),
          bounds: WidgetBounds(x: 40, y: 40, width: 100, height: 40),
          context: WidgetContext.empty(),
          ancestors: [],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterAgentation(
              controller: controller,
              initialToolbarMinimized: false,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Expanded toolbar: AnnotationMarker is visible
      expect(find.byType(AnnotationMarker), findsOneWidget);

      // Collapse toolbar: AnnotationMarker is hidden
      controller.setToolbarMinimized(true);
      await tester.pumpAndSettle();

      expect(find.byType(AnnotationMarker), findsNothing);

      // Expand toolbar again: AnnotationMarker reappears
      controller.setToolbarMinimized(false);
      await tester.pumpAndSettle();

      expect(find.byType(AnnotationMarker), findsOneWidget);
    });

    testWidgets('close icon hover decoration matches other toolbar buttons (34x34 circle with padding)', (tester) async {
      final controller = AgentationController();
      controller.setToolbarMinimized(false);

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
      await tester.pumpAndSettle();

      final closeFinder = find.byKey(const ValueKey('toolbar_close'));
      expect(closeFinder, findsOneWidget);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(closeFinder));
      await tester.pumpAndSettle();

      final container = tester.widget<AnimatedContainer>(
        find.descendant(of: closeFinder, matching: find.byType(AnimatedContainer)),
      );
      expect(container.constraints?.maxWidth ?? (container.constraints?.minWidth), equals(34.0));
      final boxDeco = container.decoration as BoxDecoration;
      expect(boxDeco.shape, equals(BoxShape.circle));
      expect(boxDeco.color, equals(const Color(0x29FFFFFF)));
    });

    testWidgets('hovering minimized button at top-left corner dynamically flips tooltip to right side without cutoff', (tester) async {
      final controller = AgentationController();
      controller.setToolbarMinimized(true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AgentationScope(
                  controller: controller,
                  child: const AgentationToolbar(
                    initialAlignment: Alignment.topLeft,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final expandButton = find.byKey(const ValueKey('toolbar_expand'));
      expect(expandButton, findsOneWidget);

      final buttonRect = tester.getRect(expandButton);
      expect(buttonRect.left, lessThan(100.0)); // Situated near the left edge

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(expandButton));
      await tester.pumpAndSettle();

      expect(find.text('Start Feedback Mode'), findsOneWidget);
      final tooltipTextPos = tester.getTopLeft(find.text('Start Feedback Mode'));

      // Since there are not enough pixels on the left, the tooltip dynamically positions on the right of the button!
      expect(tooltipTextPos.dx, greaterThan(buttonRect.right));
      expect(tooltipTextPos.dx, greaterThan(0.0));
    });

    testWidgets('hovering minimized button at bottom-right corner positions tooltip on left side', (tester) async {
      final controller = AgentationController();
      controller.setToolbarMinimized(true);

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
      await tester.pumpAndSettle();

      final expandButton = find.byKey(const ValueKey('toolbar_expand'));
      expect(expandButton, findsOneWidget);

      final buttonRect = tester.getRect(expandButton);
      expect(buttonRect.right, greaterThan(700.0)); // Situated near the right edge of 800w screen

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(expandButton));
      await tester.pumpAndSettle();

      expect(find.text('Start Feedback Mode'), findsOneWidget);
      final tooltipTextPos = tester.getTopLeft(find.text('Start Feedback Mode'));

      // Positions on the left of the button
      expect(tooltipTextPos.dx, lessThan(buttonRect.left));
      expect(tooltipTextPos.dx, greaterThan(0.0));
    });

    testWidgets('when toolbar is near top of screen, buttons configure tooltips with preferBelow: true and upward pointing beak', (tester) async {
      final controller = AgentationController();
      controller.setToolbarMinimized(false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AgentationScope(
                  controller: controller,
                  child: const AgentationToolbar(
                    initialAlignment: Alignment.topCenter,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final tooltips = tester.widgetList<Tooltip>(find.byType(Tooltip)).toList();
      expect(tooltips, isNotEmpty);

      // Verify settings tooltip has preferBelow: true and upward beak
      final settingsTooltip = tooltips.firstWhere(
        (t) => (t.richMessage?.toPlainText() ?? '').contains('Settings'),
      );
      expect(settingsTooltip.preferBelow, isTrue);

      final deco = settingsTooltip.decoration as ShapeDecoration;
      final shape = deco.shape as dynamic;
      expect(shape.beakDirection, equals(TooltipBeakDirection.up));
    });

    testWidgets('tooltips use TooltipTriggerMode.manual and copy action does not display toast', (tester) async {
      final controller = AgentationController();
      await controller.createAnnotation(comment: 'Issue for copy test');

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
      await tester.pumpAndSettle();

      // Verify all toolbar tooltips have manual triggerMode (never trigger as touch toast)
      final tooltips = tester.widgetList<Tooltip>(find.byType(Tooltip)).toList();
      for (final t in tooltips) {
        expect(t.triggerMode, equals(TooltipTriggerMode.manual));
      }

      // Tap copy button
      final copyFinder = find.byKey(const ValueKey('toolbar_copy'));
      await tester.tap(copyFinder);
      await tester.pump();

      // Verify tooltip label is still 'Copy feedback' (never 'Copied!' toast)
      final updatedTooltips = tester.widgetList<Tooltip>(find.byType(Tooltip)).toList();
      expect(updatedTooltips.any((t) => (t.richMessage?.toPlainText() ?? '').contains('Copied!')), isFalse);

      await tester.pump(const Duration(milliseconds: 1600));
      controller.dispose();
    });
  });
}


