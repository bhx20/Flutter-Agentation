import 'package:flutter_agentation/src/models/annotation.dart';
import 'package:flutter_agentation/src/models/annotation_intent.dart';
import 'package:flutter_agentation/src/models/annotation_severity.dart';
import 'package:flutter_agentation/src/models/annotation_status.dart';
import 'package:flutter_agentation/src/models/widget_bounds.dart';
import 'package:flutter_agentation/src/models/widget_identity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Annotation Model', () {
    test('instantiates with expected properties and defaults', () {
      final now = DateTime.now();
      final ann = Annotation(
        id: 'ann_1',
        comment: 'Needs extra top padding',
        timestamp: now,
        targetWidget: const WidgetIdentity(
          id: 'login_btn',
          widgetType: 'ElevatedButton',
        ),
        bounds: const WidgetBounds(x: 10, y: 20, width: 120, height: 48),
      );

      expect(ann.id, equals('ann_1'));
      expect(ann.comment, equals('Needs extra top padding'));
      expect(ann.intent, equals(AnnotationIntent.suggestion));
      expect(ann.severity, equals(AnnotationSeverity.suggestion));
      expect(ann.status, equals(AnnotationStatus.pending));
      expect(ann.selectedWidgets, isEmpty);
    });

    test('serializes to and from JSON accurately', () {
      final now = DateTime.utc(2026, 9, 25, 12, 0, 0);
      final original = Annotation(
        id: 'ann_roundtrip',
        comment: 'Fix typo in heading',
        timestamp: now,
        targetWidget: const WidgetIdentity(
          id: 'title_text',
          keyString: 'heading_key',
          widgetType: 'Text',
          isExplicitTarget: true,
        ),
        bounds: const WidgetBounds(x: 50, y: 100, width: 250, height: 32),
        route: '/home',
        text: 'Welcome to App',
        intent: AnnotationIntent.bug,
        severity: AnnotationSeverity.high,
        status: AnnotationStatus.inProgress,
        selectedText: 'Welcome',
        selectedWidgets: const [
          WidgetIdentity(id: 'w1', widgetType: 'Row'),
        ],
        metadata: const {'reviewer': 'team_lead'},
      );

      final json = original.toJson();
      final reconstructed = Annotation.fromJson(json);

      expect(reconstructed, equals(original));
      expect(reconstructed.id, equals(original.id));
      expect(reconstructed.intent, equals(AnnotationIntent.bug));
      expect(reconstructed.severity, equals(AnnotationSeverity.high));
      expect(reconstructed.status, equals(AnnotationStatus.inProgress));
      expect(reconstructed.selectedWidgets.length, equals(1));
      expect(reconstructed.metadata['reviewer'], equals('team_lead'));
    });

    test('copyWith updates specified fields only', () {
      final now = DateTime.now();
      final ann = Annotation(
        id: 'ann_copy',
        comment: 'Original comment',
        timestamp: now,
        targetWidget: const WidgetIdentity(id: '1', widgetType: 'Button'),
        bounds: const WidgetBounds.zero(),
      );

      final updated = ann.copyWith(
        comment: 'Updated comment',
        status: AnnotationStatus.resolved,
      );

      expect(updated.id, equals('ann_copy'));
      expect(updated.comment, equals('Updated comment'));
      expect(updated.status, equals(AnnotationStatus.resolved));
      expect(updated.targetWidget, equals(ann.targetWidget));
    });
  });
}
