import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/models/annotation.dart';
import 'package:flutter_agentation/src/models/annotation_intent.dart';
import 'package:flutter_agentation/src/models/annotation_severity.dart';
import 'package:flutter_agentation/src/models/annotation_status.dart';
import 'package:flutter_agentation/src/models/widget_bounds.dart';
import 'package:flutter_agentation/src/models/widget_identity.dart';
import 'package:flutter_agentation/src/output/annotation_markdown_encoder.dart';

void main() {
  group('AnnotationMarkdownEncoder', () {
    const encoder = AnnotationMarkdownEncoder();

    final testAnnotation1 = Annotation(
      id: 'ann_x001',
      comment: 'Make the login button green.',
      timestamp: DateTime.fromMillisecondsSinceEpoch(1700000000000),
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

    final testAnnotation2 = Annotation(
      id: 'ann_x002',
      comment: 'Header text is misaligned on small screens.',
      timestamp: DateTime.fromMillisecondsSinceEpoch(1700000001000),
      targetWidget: const WidgetIdentity(
        id: 'welcome_title',
        widgetType: 'Text',
      ),
      bounds: const WidgetBounds(x: 24.0, y: 80.0, width: 300.0, height: 32.0),
      route: '/login',
      text: 'Welcome back!',
      intent: AnnotationIntent.bug,
      severity: AnnotationSeverity.critical,
      status: AnnotationStatus.inProgress,
      metadata: const {
        'path': 'LoginPage > Header > welcome_title',
      },
    );

    test('encodes a single annotation with all fields matching Section 27', () {
      final md = encoder.encode(testAnnotation1, index: 1);

      expect(md, contains('## Annotation #1'));
      expect(md, contains('Comment:\nMake the login button green.'));
      expect(md, contains('Widget:\nElevatedButton'));
      expect(md, contains('Identifier:\nlogin_button'));
      expect(md, contains('Path:\nLoginPage > LoginForm > login_button'));
      expect(md, contains('Route:\n/login'));
      expect(md, contains('Bounds:\nx=120 y=430 width=180 height=48'));
      expect(md, contains('Text:\nLogin'));
      expect(md, contains('Severity:\nsuggestion'));
      expect(md, contains('Status:\npending'));
    });

    test('encodes multiple annotations with sequential numbering', () {
      final md = encoder.encodeAll([testAnnotation1, testAnnotation2]);

      expect(md, contains('## Annotation #1'));
      expect(md, contains('## Annotation #2'));
      expect(md, contains('ElevatedButton'));
      expect(md, contains('Header text is misaligned on small screens.'));
      expect(md, contains('critical'));
      expect(md, contains('inProgress'));
    });

    test('handles empty list gracefully', () {
      final md = encoder.encodeAll([]);
      expect(md, equals('_No annotations recorded._'));
    });

    test('handles optional missing fields without emitting null strings', () {
      final minimalAnnotation = Annotation(
        id: 'ann_min',
        comment: 'Minimal test comment',
        timestamp: DateTime.fromMillisecondsSinceEpoch(1700000000000),
        targetWidget: const WidgetIdentity.empty(),
        bounds: const WidgetBounds.zero(),
      );

      final md = encoder.encode(minimalAnnotation, index: 1);

      expect(md, contains('## Annotation #1'));
      expect(md, contains('Comment:\nMinimal test comment'));
      expect(md, isNot(contains('null')));
    });
  });
}
