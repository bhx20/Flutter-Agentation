import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/models/annotation.dart';
import 'package:flutter_agentation/src/models/drawing_stroke.dart';
import 'package:flutter_agentation/src/models/marker_color.dart';
import 'package:flutter_agentation/src/models/placement_data.dart';
import 'package:flutter_agentation/src/models/rearrange_data.dart';
import 'package:flutter_agentation/src/models/thread_message.dart';
import 'package:flutter_agentation/src/models/toolbar_settings.dart';
import 'package:flutter_agentation/src/models/widget_bounds.dart';
import 'package:flutter_agentation/src/models/widget_identity.dart';

void main() {
  group('Parity Models Test Suite', () {
    test('DrawingStroke serializes and deserializes correctly', () {
      const stroke = DrawingStroke(
        points: [Offset(10.0, 20.0), Offset(30.0, 40.0)],
        color: Color(0xFF6366F1),
        strokeWidth: 4.0,
      );

      final json = stroke.toJson();
      expect(json['points'], isA<List>());
      expect((json['points'] as List).length, equals(2));
      expect(json['color'], equals(0xFF6366F1));
      expect(json['strokeWidth'], equals(4.0));

      final deserialized = DrawingStroke.fromJson(json);
      expect(deserialized.points.length, equals(2));
      expect(deserialized.points.first.dx, equals(10.0));
      expect(deserialized.points.first.dy, equals(20.0));
      expect(deserialized.color.toARGB32(), equals(0xFF6366F1));
      expect(deserialized.strokeWidth, equals(4.0));
    });

    test('PlacementData serializes and deserializes correctly', () {
      const placement = PlacementData(
        componentType: 'ElevatedButton',
        width: 140.0,
        height: 48.0,
        text: 'Submit Order',
        prompt: 'Add secondary action button below',
      );

      final json = placement.toJson();
      expect(json['componentType'], equals('ElevatedButton'));
      expect(json['width'], equals(140.0));
      expect(json['height'], equals(48.0));
      expect(json['text'], equals('Submit Order'));
      expect(json['prompt'], equals('Add secondary action button below'));

      final deserialized = PlacementData.fromJson(json);
      expect(deserialized.componentType, equals('ElevatedButton'));
      expect(deserialized.width, equals(140.0));
      expect(deserialized.height, equals(48.0));
      expect(deserialized.text, equals('Submit Order'));
      expect(deserialized.prompt, equals('Add secondary action button below'));
    });

    test('RearrangeData serializes and deserializes correctly', () {
      const rearrange = RearrangeData(
        selector: 'ElevatedButton#submit_btn',
        label: 'Submit Button',
        originalRect: WidgetBounds(x: 20.0, y: 100.0, width: 120.0, height: 40.0),
        currentRect: WidgetBounds(x: 20.0, y: 160.0, width: 120.0, height: 40.0),
      );

      final json = rearrange.toJson();
      expect(json['selector'], equals('ElevatedButton#submit_btn'));
      expect(json['label'], equals('Submit Button'));
      expect(json['originalRect'], isA<Map<String, dynamic>>());
      expect(json['currentRect'], isA<Map<String, dynamic>>());

      final deserialized = RearrangeData.fromJson(json);
      expect(deserialized.selector, equals('ElevatedButton#submit_btn'));
      expect(deserialized.label, equals('Submit Button'));
      expect(deserialized.originalRect.y, equals(100.0));
      expect(deserialized.currentRect.y, equals(160.0));
    });

    test('ThreadMessage serializes and deserializes correctly', () {
      final now = DateTime.now();
      final msg = ThreadMessage(
        id: 'msg_001',
        role: 'human',
        content: 'Please adjust typography',
        timestamp: now,
      );

      final json = msg.toJson();
      expect(json['id'], equals('msg_001'));
      expect(json['role'], equals('human'));
      expect(json['content'], equals('Please adjust typography'));
      expect(json['timestamp'], equals(now.millisecondsSinceEpoch));

      final deserialized = ThreadMessage.fromJson(json);
      expect(deserialized.id, equals('msg_001'));
      expect(deserialized.role, equals('human'));
      expect(deserialized.content, equals('Please adjust typography'));
      expect(deserialized.timestamp.millisecondsSinceEpoch, equals(now.millisecondsSinceEpoch));
    });

    test('MarkerColor palette contains all 6 curated colors', () {
      expect(MarkerColor.values.length, equals(6));
      expect(MarkerColor.values.map((c) => c.id).toList(),
          containsAll(['indigo', 'emerald', 'amber', 'rose', 'cyan', 'purple']));

      final indigo = MarkerColor.findById('indigo');
      expect(indigo.label, equals('Indigo'));
      expect(indigo.color, equals(const Color(0xFF6366F1)));

      final fallback = MarkerColor.findById('unknown_id');
      expect(fallback.id, equals('indigo'));
    });

    test('ToolbarSettings defaults and copyWith work properly', () {
      const settings = ToolbarSettings();
      expect(settings.outputDetail, equals(OutputDetailLevel.standard));
      expect(settings.isDarkMode, isTrue);
      expect(settings.markerColorId, equals('indigo'));
      expect(settings.autoClearAfterCopy, isFalse);
      expect(settings.blockInteractions, isTrue);
      expect(settings.mcpEndpoint, isNull);

      final updated = settings.copyWith(
        outputDetail: OutputDetailLevel.forensic,
        isDarkMode: false,
        markerColorId: 'emerald',
        mcpEndpoint: 'http://localhost:4747',
      );
      expect(updated.outputDetail, equals(OutputDetailLevel.forensic));
      expect(updated.isDarkMode, isFalse);
      expect(updated.markerColorId, equals('emerald'));
      expect(updated.mcpEndpoint, equals('http://localhost:4747'));
    });

    test('Annotation model parity fields and serialization', () {
      final now = DateTime.now();
      final annotation = Annotation(
        id: 'ann_parity_001',
        comment: 'Full parity test',
        timestamp: now,
        targetWidget: const WidgetIdentity(id: 'btn_id', widgetType: 'Button'),
        bounds: const WidgetBounds(x: 10, y: 20, width: 100, height: 40),
        kind: AnnotationKind.placement,
        sourceFile: 'lib/main.dart:45',
        sessionId: 'sess_123',
        isMultiSelect: true,
        elementBoundingBoxes: const [
          WidgetBounds(x: 10, y: 20, width: 40, height: 40),
          WidgetBounds(x: 60, y: 20, width: 40, height: 40),
        ],
        strokes: const [
          DrawingStroke(points: [Offset(5, 5), Offset(15, 15)]),
        ],
        placement: const PlacementData(
          componentType: 'Card',
          width: 200,
          height: 100,
        ),
        thread: [
          ThreadMessage(
            id: 'm1',
            role: 'agent',
            content: 'Ready to build',
            timestamp: now,
          ),
        ],
      );

      final json = annotation.toJson();
      expect(json['kind'], equals('placement'));
      expect(json['sourceFile'], equals('lib/main.dart:45'));
      expect(json['sessionId'], equals('sess_123'));
      expect(json['isMultiSelect'], isTrue);
      expect(json['elementBoundingBoxes'], hasLength(2));
      expect(json['strokes'], hasLength(1));
      expect(json['placement'], isNotNull);
      expect(json['thread'], hasLength(1));

      final deserialized = Annotation.fromJson(json);
      expect(deserialized.id, equals('ann_parity_001'));
      expect(deserialized.kind, equals(AnnotationKind.placement));
      expect(deserialized.sourceFile, equals('lib/main.dart:45'));
      expect(deserialized.sessionId, equals('sess_123'));
      expect(deserialized.isMultiSelect, isTrue);
      expect(deserialized.elementBoundingBoxes.length, equals(2));
      expect(deserialized.strokes.length, equals(1));
      expect(deserialized.placement?.componentType, equals('Card'));
      expect(deserialized.thread.length, equals(1));
    });
  });
}
