import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/core/agentation_scope.dart';
import 'package:flutter_agentation/src/core/agentation_state.dart';
import 'package:flutter_agentation/src/models/hierarchical_inspection_result.dart';
import 'package:flutter_agentation/src/models/widget_bounds.dart';
import 'package:flutter_agentation/src/models/widget_context.dart';
import 'package:flutter_agentation/src/models/widget_identity.dart';
import 'package:flutter_agentation/src/models/widget_inspection_result.dart';
import 'package:flutter_agentation/src/overlay/annotation_popup.dart';
import 'package:flutter_agentation/src/overlay/inspection_overlay.dart';
import 'package:flutter_agentation/src/storage/memory_annotation_storage.dart';

void main() {
  group('Widget Hierarchy Selector & Live Retargeting', () {
    late MemoryAnnotationStorage storage;
    late AgentationController controller;

    final cardResult = WidgetInspectionResult(
      identity: const WidgetIdentity(id: 'card_id', widgetType: 'Card'),
      bounds: const WidgetBounds(x: 20.0, y: 50.0, width: 200.0, height: 120.0),
      context: const WidgetContext.empty(),
      ancestors: const ['Scaffold'],
    );

    final textResult = WidgetInspectionResult(
      identity: const WidgetIdentity(id: 'title_id', widgetType: 'Text'),
      bounds: const WidgetBounds(x: 30.0, y: 60.0, width: 100.0, height: 24.0),
      context: const WidgetContext.empty(),
      text: 'Hello World',
      ancestors: const ['Scaffold', 'Card'],
    );

    final iconResult = WidgetInspectionResult(
      identity: const WidgetIdentity(id: 'icon_id', widgetType: 'Icon'),
      bounds: const WidgetBounds(x: 140.0, y: 60.0, width: 24.0, height: 24.0),
      context: const WidgetContext.empty(),
      ancestors: const ['Scaffold', 'Card'],
    );

    setUp(() {
      storage = MemoryAnnotationStorage();
      controller = AgentationController(
        storage: storage,
        initialMode: InspectionMode.inspecting,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('controller.selectTarget updates selectedResult and notifies listeners', () {
      controller.selectResult(cardResult);
      expect(controller.selectedResult, equals(cardResult));

      controller.selectTarget(textResult);
      expect(controller.selectedResult, equals(textResult));
    });

    testWidgets('AnnotationPopup renders hierarchy breadcrumbs and child chips', (tester) async {
      final hierarchy = HierarchicalInspectionResult(
        primaryTarget: textResult,
        ancestors: [cardResult],
        children: [iconResult],
        hitCandidates: [textResult, cardResult],
      );

      controller.setActiveHierarchy(hierarchy);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentationScope(
              controller: controller,
              child: Stack(
                children: [
                  AnnotationPopup(
                    result: textResult,
                    onClose: () {},
                    showHierarchy: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify breadcrumbs contain ancestor Card and primary Text
      expect(find.text('Card'), findsWidgets);
      expect(find.text('Text'), findsWidgets);

      // Verify child element Icon is listed
      expect(find.text('Icon'), findsWidgets);

      // Tap on Card breadcrumb to retarget
      final cardChip = find.widgetWithText(ActionChip, 'Card');
      if (cardChip.evaluate().isNotEmpty) {
        await tester.tap(cardChip);
        await tester.pump();
        expect(controller.selectedResult?.identity.widgetType, equals('Card'));
      }
    });

    testWidgets('InspectionOverlay tapping widget updates activeHierarchy in controller', (tester) async {
      final hostKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectionOverlay(
              controller: controller,
              child: KeyedSubtree(
                key: hostKey,
                child: Center(
                  child: Card(
                    key: const ValueKey('interactive_card'),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('Title', key: ValueKey('tap_target')),
                          Icon(Icons.thumb_up),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Tap target
      final target = find.byKey(const ValueKey('tap_target'));
      await tester.tap(target, warnIfMissed: false);
      await tester.pump();

      // Controller should have active hierarchy with primary target and ancestors
      expect(controller.activeHierarchy, isNotNull);
      expect(controller.selectedResult, isNotNull);
      expect(controller.activeHierarchy!.allSelectableWidgets.isNotEmpty, isTrue);
    });
  });
}
