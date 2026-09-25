import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/models/annotation.dart';
import 'package:flutter_agentation/src/models/annotation_intent.dart';
import 'package:flutter_agentation/src/models/annotation_severity.dart';
import 'package:flutter_agentation/src/models/widget_bounds.dart';
import 'package:flutter_agentation/src/models/widget_context.dart';
import 'package:flutter_agentation/src/models/widget_identity.dart';
import 'package:flutter_agentation/src/models/widget_inspection_result.dart';
import 'package:flutter_agentation/src/storage/memory_annotation_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgentationController Annotation Management', () {
    test('creates and stores annotation from selected inspection result',
        () async {
      final storage = MemoryAnnotationStorage();
      final controller = AgentationController(storage: storage);

      const dummyResult = WidgetInspectionResult(
        identity: WidgetIdentity(id: 'btn_1', widgetType: 'ElevatedButton'),
        bounds: WidgetBounds(x: 10, y: 20, width: 100, height: 40),
        context: WidgetContext(depth: 3),
        ancestors: ['MaterialApp', 'ElevatedButton'],
      );

      controller.selectResult(dummyResult);

      final annotation = await controller.createAnnotation(
        comment: 'Adjust button padding',
        intent: AnnotationIntent.change,
        severity: AnnotationSeverity.medium,
      );

      expect(annotation.comment, equals('Adjust button padding'));
      expect(annotation.targetWidget.widgetType, equals('ElevatedButton'));
      expect(annotation.intent, equals(AnnotationIntent.change));
      expect(controller.annotations.length, equals(1));
      expect(controller.annotations.first, equals(annotation));

      // Storage should also have it
      final inStorage = await storage.getById(annotation.id);
      expect(inStorage, equals(annotation));
    });

    test('deleting an annotation updates controller and storage', () async {
      final storage = MemoryAnnotationStorage();
      final controller = AgentationController(storage: storage);

      const dummyResult = WidgetInspectionResult(
        identity: WidgetIdentity(id: 'btn_2', widgetType: 'TextButton'),
        bounds: WidgetBounds.zero(),
        context: WidgetContext.empty(),
        ancestors: ['TextButton'],
      );

      controller.selectResult(dummyResult);
      final created = await controller.createAnnotation(comment: 'Test note');
      expect(controller.annotations.length, equals(1));

      final deleted = await controller.deleteAnnotation(created.id);
      expect(deleted, isTrue);
      expect(controller.annotations, isEmpty);
      expect(await storage.getById(created.id), isNull);
    });

    test('viewAnnotation sets active annotation detail view', () async {
      final controller = AgentationController();
      final dummy = Annotation(
        id: 'ann_view',
        comment: 'Detail note',
        timestamp: DateTime.now(),
        targetWidget: const WidgetIdentity(id: '1', widgetType: 'Card'),
        bounds: const WidgetBounds.zero(),
      );

      int notifies = 0;
      controller.addListener(() => notifies++);

      controller.viewAnnotation(dummy);
      expect(controller.activeAnnotation, equals(dummy));
      expect(notifies, equals(1));

      controller.viewAnnotation(null);
      expect(controller.activeAnnotation, isNull);
      expect(notifies, equals(2));
    });
  });
}
