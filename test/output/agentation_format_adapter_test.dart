import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/models/annotation.dart';
import 'package:flutter_agentation/src/models/annotation_intent.dart';
import 'package:flutter_agentation/src/models/annotation_severity.dart';
import 'package:flutter_agentation/src/models/annotation_status.dart';
import 'package:flutter_agentation/src/models/widget_bounds.dart';
import 'package:flutter_agentation/src/models/widget_identity.dart';
import 'package:flutter_agentation/src/output/agentation_format_adapter.dart';

void main() {
  group('AgentationFormatAdapter', () {
    const adapter = AgentationFormatAdapter();

    final testAnnotation = Annotation(
      id: 'ann_x001',
      comment: 'Make the login button green.',
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
      metadata: const {
        'path': 'LoginPage > LoginForm > login_button',
      },
    );

    test('adapts a single Flutter annotation to canonical Agentation format map', () {
      final adapted = adapter.adapt(testAnnotation);

      expect(adapted['id'], equals('ann_x001'));
      expect(adapted['type'], equals('annotation'));
      expect(adapted['platform'], equals('flutter'));
      expect(adapted['comment'], equals('Make the login button green.'));
      expect(adapted['intent'], equals('change'));
      expect(adapted['severity'], equals('suggestion'));
      expect(adapted['status'], equals('pending'));

      final element = adapted['element'] as Map<String, dynamic>;
      expect(element['type'], equals('ElevatedButton'));
      expect(element['identifier'], equals('login_button'));
      expect(element['key'], equals('Key("login_btn")'));
      expect(element['path'], equals('LoginPage > LoginForm > login_button'));
      expect(element['text'], equals('Login'));
      expect(element['route'], equals('/login'));

      final bounds = adapted['bounds'] as Map<String, dynamic>;
      expect(bounds['x'], equals(120.0));
      expect(bounds['y'], equals(430.0));
      expect(bounds['width'], equals(180.0));
      expect(bounds['height'], equals(48.0));
    });

    test('adapts multiple annotations into full Agentation session payload', () {
      final annotations = [testAnnotation, testAnnotation.copyWith(id: 'ann_x002')];
      final payload = adapter.adaptAll(
        annotations,
        sessionMetadata: {'appVersion': '1.0.0', 'device': 'Pixel 7'},
      );

      expect(payload['version'], equals('1.0'));
      expect(payload['source'], equals('flutter_agentation'));
      expect(payload['count'], equals(2));
      expect(payload['session']['appVersion'], equals('1.0.0'));
      expect((payload['annotations'] as List).length, equals(2));
    });
  });
}
