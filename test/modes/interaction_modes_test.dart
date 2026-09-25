import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/core/agentation_scope.dart';
import 'package:flutter_agentation/src/core/agentation_state.dart';
import 'package:flutter_agentation/src/models/drawing_stroke.dart';
import 'package:flutter_agentation/src/models/widget_bounds.dart';
import 'package:flutter_agentation/src/models/widget_context.dart';
import 'package:flutter_agentation/src/models/widget_identity.dart';
import 'package:flutter_agentation/src/models/widget_inspection_result.dart';
import 'package:flutter_agentation/src/modes/area_selection_handler.dart';
import 'package:flutter_agentation/src/modes/draw_canvas_painter.dart';
import 'package:flutter_agentation/src/modes/multi_select_handler.dart';
import 'package:flutter_agentation/src/overlay/inspection_overlay.dart';
import 'package:flutter_agentation/src/storage/memory_annotation_storage.dart';

void main() {
  group('Interaction Modes (Area, Multi-Select, Draw)', () {
    late MemoryAnnotationStorage storage;
    late AgentationController controller;

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

    test('controller supports switching AnnotationToolMode', () {
      expect(controller.toolMode, equals(AnnotationToolMode.pointer));

      controller.setToolMode(AnnotationToolMode.area);
      expect(controller.toolMode, equals(AnnotationToolMode.area));

      controller.setToolMode(AnnotationToolMode.multiSelect);
      expect(controller.toolMode, equals(AnnotationToolMode.multiSelect));

      controller.setToolMode(AnnotationToolMode.draw);
      expect(controller.toolMode, equals(AnnotationToolMode.draw));

      controller.setToolMode(AnnotationToolMode.design);
      expect(controller.toolMode, equals(AnnotationToolMode.design));
    });

    test('AreaSelectionHandler computes correct normalized WidgetBounds from drag', () {
      final handler = AreaSelectionHandler();
      expect(handler.isDragging, isFalse);

      handler.onPanStart(const Offset(50.0, 100.0));
      expect(handler.isDragging, isTrue);

      handler.onPanUpdate(const Offset(250.0, 300.0));
      final bounds = handler.currentBounds;
      expect(bounds.x, equals(50.0));
      expect(bounds.y, equals(100.0));
      expect(bounds.width, equals(200.0));
      expect(bounds.height, equals(200.0));

      final completedBounds = handler.onPanEnd();
      expect(handler.isDragging, isFalse);
      expect(completedBounds?.width, equals(200.0));
    });

    test('AreaSelectionHandler handles reverse dragging (bottom-right to top-left)', () {
      final handler = AreaSelectionHandler();
      handler.onPanStart(const Offset(300.0, 400.0));
      handler.onPanUpdate(const Offset(100.0, 200.0));

      final bounds = handler.currentBounds;
      expect(bounds.x, equals(100.0));
      expect(bounds.y, equals(200.0));
      expect(bounds.width, equals(200.0));
      expect(bounds.height, equals(200.0));
    });

    test('MultiSelectHandler tracks and toggles multi-selected candidate widgets', () {
      final handler = MultiSelectHandler();

      final res1 = WidgetInspectionResult(
        identity: const WidgetIdentity(id: 'btn1', widgetType: 'ElevatedButton'),
        bounds: const WidgetBounds(x: 10, y: 10, width: 80, height: 40),
        context: const WidgetContext.empty(),
        ancestors: const [],
      );
      final res2 = WidgetInspectionResult(
        identity: const WidgetIdentity(id: 'btn2', widgetType: 'OutlinedButton'),
        bounds: const WidgetBounds(x: 100, y: 10, width: 80, height: 40),
        context: const WidgetContext.empty(),
        ancestors: const [],
      );

      handler.toggleSelection(res1);
      expect(handler.selectedCount, equals(1));
      expect(handler.isSelected(res1), isTrue);

      handler.toggleSelection(res2);
      expect(handler.selectedCount, equals(2));

      // Toggling res1 again deselects it
      handler.toggleSelection(res1);
      expect(handler.selectedCount, equals(1));
      expect(handler.isSelected(res1), isFalse);
      expect(handler.isSelected(res2), isTrue);

      handler.clear();
      expect(handler.selectedCount, equals(0));
    });

    test('DrawCanvasPainter renders strokes without throwing', () {
      const stroke1 = DrawingStroke(
        points: [Offset(10, 10), Offset(20, 20), Offset(30, 15)],
        color: Colors.red,
        strokeWidth: 3.0,
      );
      const stroke2 = DrawingStroke(
        points: [Offset(100, 100), Offset(150, 120)],
        color: Colors.blue,
        strokeWidth: 5.0,
      );

      final painter = DrawCanvasPainter(
        strokes: [stroke1, stroke2],
        currentStrokePoints: [const Offset(40, 40), const Offset(50, 50)],
        activeColor: Colors.green,
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, const Size(500, 500));
      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    testWidgets('InspectionOverlay with Area mode allows dragging marquee rectangle', (tester) async {
      controller.setToolMode(AnnotationToolMode.area);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentationScope(
              controller: controller,
              child: InspectionOverlay(
                controller: controller,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      );

      // Perform drag gesture across screen
      final gesture = await tester.startGesture(const Offset(50, 50));
      await tester.pump();
      await gesture.moveTo(const Offset(250, 200));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      // Controller should now have a selectedResult with bounds matching the area drag
      expect(controller.selectedResult, isNotNull);
      expect(controller.selectedResult?.bounds.width, equals(200.0));
      expect(controller.selectedResult?.bounds.height, equals(150.0));
      expect(controller.selectedResult?.identity.widgetType, equals('AreaSelection'));
    });
  });
}
