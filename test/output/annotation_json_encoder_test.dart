import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/models/annotation.dart';
import 'package:flutter_agentation/src/models/annotation_intent.dart';
import 'package:flutter_agentation/src/models/annotation_severity.dart';
import 'package:flutter_agentation/src/models/annotation_status.dart';
import 'package:flutter_agentation/src/models/widget_bounds.dart';
import 'package:flutter_agentation/src/models/widget_identity.dart';
import 'package:flutter_agentation/src/output/annotation_json_encoder.dart';

void main() {
  group('AnnotationJsonEncoder', () {
    const encoder = AnnotationJsonEncoder();

    final testAnnotation = Annotation(
      id: 'ann_x001',
      comment: 'Make this button green',
      timestamp: DateTime.parse('2026-09-25T12:00:00.000Z'),
      targetWidget: const WidgetIdentity(
        id: 'login_button',
        widgetType: 'ElevatedButton',
        keyString: 'Key("login_btn")',
      ),
      bounds: const WidgetBounds(x: 120.0, y: 430.0, width: 180.0, height: 48.0),
      route: '/login',
      text: 'Login',
      intent: AnnotationIntent.change,
      severity: AnnotationSeverity.suggestion,
      status: AnnotationStatus.pending,
      metadata: const {'source': 'inspector'},
    );

    test('encodes single annotation as pretty-printed JSON by default', () {
      final jsonStr = encoder.encode(testAnnotation);

      expect(jsonStr, contains('\n'));
      expect(jsonStr, contains('  "id": "ann_x001"'));
      expect(jsonStr, contains('  "comment": "Make this button green"'));

      // Validate JSON syntax
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final restored = Annotation.fromJson(decoded);
      expect(restored, equals(testAnnotation));
    });

    test('encodes single annotation as compact JSON when pretty is false', () {
      final jsonStr = encoder.encode(testAnnotation, pretty: false);

      expect(jsonStr.contains('\n'), isFalse);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      expect(decoded['id'], equals('ann_x001'));
      expect(Annotation.fromJson(decoded), equals(testAnnotation));
    });

    test('encodes list of annotations as JSON array', () {
      final annotations = [testAnnotation, testAnnotation.copyWith(id: 'ann_x002')];
      final jsonStr = encoder.encodeAll(annotations, pretty: true);

      final decoded = jsonDecode(jsonStr) as List<dynamic>;
      expect(decoded.length, equals(2));
      expect(decoded[0]['id'], equals('ann_x001'));
      expect(decoded[1]['id'], equals('ann_x002'));
    });

    test('encodes empty list as empty JSON array', () {
      final jsonStr = encoder.encodeAll([], pretty: true);
      expect(jsonStr, equals('[]'));
    });

    test('encodeMap handles generic map encoding', () {
      final map = {'status': 'ok', 'count': 42};
      final pretty = encoder.encodeMap(map, pretty: true);
      expect(pretty, contains('\n'));
      final compact = encoder.encodeMap(map, pretty: false);
      expect(compact, equals('{"status":"ok","count":42}'));
    });
  });
}
