import 'package:flutter/material.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/core/agentation_scope.dart';
import 'package:flutter_agentation/src/models/widget_bounds.dart';
import 'package:flutter_agentation/src/models/widget_context.dart';
import 'package:flutter_agentation/src/models/widget_identity.dart';
import 'package:flutter_agentation/src/models/widget_inspection_result.dart';
import 'package:flutter_agentation/src/toolbar/agentation_toolbar.dart';
import 'package:flutter_agentation/src/toolbar/toolbar_action_button.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgentationToolbar', () {
    testWidgets('renders action buttons and toggles inspection on tap',
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

      // Verify action buttons exist
      expect(find.byType(ToolbarActionButton), findsWidgets);
      expect(find.byIcon(Icons.ads_click), findsOneWidget);

      // Tap Inspect toggle
      await tester.tap(find.byIcon(Icons.ads_click));
      await tester.pumpAndSettle();

      expect(controller.isInspecting, isTrue);

      // Tapping again deactivates
      await tester.tap(find.byType(ToolbarActionButton).first);
      await tester.pumpAndSettle();

      expect(controller.isInactive, isTrue);
    });

    testWidgets('clear action clears active selection in controller',
        (tester) async {
      final controller = AgentationController();
      controller.selectResult(const WidgetInspectionResult(
        identity: WidgetIdentity(id: '1', widgetType: 'Button'),
        bounds: WidgetBounds.zero(),
        context: WidgetContext.empty(),
        ancestors: ['Button'],
      ));

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

      expect(controller.selectedResult, isNotNull);

      // Tap clear button
      final clearFinder = find.byTooltip('Clear Selection');
      expect(clearFinder, findsOneWidget);
      await tester.tap(clearFinder);
      await tester.pumpAndSettle();

      expect(controller.selectedResult, isNull);
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

      final minimizeFinder = find.byTooltip('Minimize Toolbar');
      expect(minimizeFinder, findsOneWidget);

      await tester.tap(minimizeFinder);
      await tester.pumpAndSettle();

      expect(controller.isToolbarMinimized, isTrue);

      // In minimized state, expand tooltip should be available
      final expandFinder = find.byTooltip('Expand Toolbar');
      expect(expandFinder, findsOneWidget);

      await tester.tap(expandFinder);
      await tester.pumpAndSettle();

      expect(controller.isToolbarMinimized, isFalse);
    });
  });
}
