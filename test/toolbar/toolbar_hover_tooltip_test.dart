import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/core/agentation_scope.dart';
import 'package:flutter_agentation/src/toolbar/agentation_toolbar.dart';

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
      expect(layoutTooltip.verticalOffset, equals(22.0));
      expect(layoutTooltip.padding, equals(const EdgeInsets.symmetric(horizontal: 7.0, vertical: 8.5)));
      final darkShapeDeco = layoutTooltip.decoration as ShapeDecoration;
      expect(darkShapeDeco.color, equals(const Color(0xFF18181B)));

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

    testWidgets('Minimized toolbar renders vibrant blue badge (#0088FF) anchored top-right with annotation count', (tester) async {
      final controller = AgentationController();
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

      // Badge displays '1' with white text inside vibrant blue container
      expect(find.text('1'), findsOneWidget);
      final badgeContainerFinder = find.ancestor(
        of: find.text('1'),
        matching: find.byType(Container),
      ).first;
      final badgeContainer = tester.widget<Container>(badgeContainerFinder);
      final badgeDeco = badgeContainer.decoration as BoxDecoration?;
      expect(badgeDeco?.color, equals(const Color(0xFF0088FF)));

      // Positioned at top: -4.0, right: -4.0
      final positionedFinder = find.ancestor(
        of: badgeContainerFinder,
        matching: find.byType(Positioned),
      ).first;
      final positioned = tester.widget<Positioned>(positionedFinder);
      expect(positioned.top, equals(-4.0));
      expect(positioned.right, equals(-4.0));
    });
  });
}
