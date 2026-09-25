import 'package:flutter/material.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/core/agentation_scope.dart';
import 'package:flutter_agentation/src/core/agentation_state.dart';
import 'package:flutter_agentation/src/models/widget_bounds.dart';
import 'package:flutter_agentation/src/models/widget_context.dart';
import 'package:flutter_agentation/src/models/widget_identity.dart';
import 'package:flutter_agentation/src/models/widget_inspection_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgentationController', () {
    test('initial state defaults to inactive with empty selection', () {
      final controller = AgentationController();

      expect(controller.mode, equals(InspectionMode.inactive));
      expect(controller.isInspecting, isFalse);
      expect(controller.isInactive, isTrue);
      expect(controller.isPaused, isFalse);
      expect(controller.selectedResult, isNull);
      expect(controller.hoveredResult, isNull);
      expect(controller.toolbarOffset, equals(Offset.zero));
      expect(controller.isToolbarMinimized, isFalse);
    });

    test('mode transitions notify listeners', () {
      final controller = AgentationController();
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.activate();
      expect(controller.isInspecting, isTrue);
      expect(notifyCount, equals(1));

      // Redundant activate does not notify
      controller.activate();
      expect(notifyCount, equals(1));

      controller.pause();
      expect(controller.isPaused, isTrue);
      expect(notifyCount, equals(2));

      controller.resume();
      expect(controller.isInspecting, isTrue);
      expect(notifyCount, equals(3));

      controller.toggleInspect();
      expect(controller.isInactive, isTrue);
      expect(notifyCount, equals(4));

      controller.toggleInspect();
      expect(controller.isInspecting, isTrue);
      expect(notifyCount, equals(5));
    });

    test('selection and hover mutation functions correctly', () {
      final controller = AgentationController();
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      const dummyResult = WidgetInspectionResult(
        identity: WidgetIdentity(
          id: 'btn_1',
          widgetType: 'ElevatedButton',
        ),
        bounds: WidgetBounds(x: 10, y: 20, width: 100, height: 40),
        context: WidgetContext(depth: 3),
        ancestors: ['MaterialApp', 'Scaffold', 'ElevatedButton'],
      );

      controller.selectResult(dummyResult);
      expect(controller.selectedResult, equals(dummyResult));
      expect(notifyCount, equals(1));

      controller.setHoveredResult(dummyResult);
      expect(controller.hoveredResult, equals(dummyResult));
      expect(notifyCount, equals(2));

      controller.clearSelection();
      expect(controller.selectedResult, isNull);
      expect(controller.hoveredResult, isNull);
      expect(notifyCount, equals(3));
    });

    test('toolbar offset and minimized state toggle', () {
      final controller = AgentationController();
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.updateToolbarOffset(const Offset(50, 100));
      expect(controller.toolbarOffset, equals(const Offset(50, 100)));
      expect(notifyCount, equals(1));

      controller.toggleToolbarMinimized();
      expect(controller.isToolbarMinimized, isTrue);
      expect(notifyCount, equals(2));
    });
  });

  group('AgentationScope', () {
    testWidgets('provides controller to descendant widgets', (tester) async {
      final controller = AgentationController();
      AgentationController? extractedController;

      await tester.pumpWidget(
        AgentationScope(
          controller: controller,
          child: Builder(
            builder: (context) {
              extractedController = AgentationScope.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(extractedController, equals(controller));
    });
  });
}
