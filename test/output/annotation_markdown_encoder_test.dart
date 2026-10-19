import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/domain/annotation.dart';
import 'package:flutter_agentation/src/domain/annotation_intent.dart';
import 'package:flutter_agentation/src/domain/annotation_severity.dart';
import 'package:flutter_agentation/src/domain/annotation_status.dart';
import 'package:flutter_agentation/src/domain/widget_bounds.dart';
import 'package:flutter_agentation/src/domain/widget_identity.dart';
import 'package:flutter_agentation/src/domain/toolbar_settings.dart';
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

    test('formatDocument resolves exact parent placement rather than repeating widgetType', () {
      final placementAnn = Annotation(
        id: 'ann_place_1',
        comment: 'Place Icon Button as first child of Stack',
        timestamp: DateTime.now(),
        targetWidget: const WidgetIdentity(
          id: 'IconButton',
          widgetType: 'IconButton',
        ),
        bounds: const WidgetBounds(x: 20, y: 40, width: 48, height: 48),
        kind: AnnotationKind.placement,
        metadata: const {
          'parentBreadcrumb': 'Scaffold > Stack',
          'treePlacement': 'as first child of Stack',
        },
      );

      final doc = encoder.formatDocument([placementAnn]);
      expect(doc, contains('### 1. IconButton'));
      expect(doc, contains('**Location:** Scaffold > Stack (as first child of Stack)'));
      expect(doc, isNot(contains('**Location:** IconButton')));
    });

    test('formatDocument resolves enclosing container for AreaSelection instead of generic label', () {
      final areaAnn = Annotation(
        id: 'ann_area_1',
        comment: 'make this box as per the same height',
        timestamp: DateTime.now(),
        targetWidget: const WidgetIdentity(
          id: 'area_1',
          widgetType: 'AreaSelection',
        ),
        bounds: const WidgetBounds(x: 50, y: 100, width: 200, height: 150),
        metadata: const {
          'path': 'Area in LandingPage > Column > Container',
        },
      );

      final doc = encoder.formatDocument([areaAnn]);
      expect(doc, contains('### 1. AreaSelection'));
      expect(doc, contains('**Location:** Area in LandingPage > Column > Container'));
      expect(doc, isNot(contains('**Location:** AreaSelection\n')));
    });

    test('compact detail level matches agentation-main standard including 30-char truncated selection', () {
      final ann = Annotation(
        id: 'ann_c1',
        comment: 'Change label to Confirm Order',
        timestamp: DateTime.now(),
        targetWidget: const WidgetIdentity(
          id: 'submit_btn',
          widgetType: 'ElevatedButton',
        ),
        bounds: const WidgetBounds(x: 20, y: 100, width: 120, height: 48),
        sourceFile: 'lib/cart_view.dart:88',
        selectedText: 'Click here to place your complete checkout order immediately',
      );

      final output = encoder.formatDocument(
        [ann],
        detailLevel: OutputDetailLevel.compact,
        pathname: '/cart',
      );

      expect(output, contains('## Page Feedback: /cart'));
      expect(output, isNot(contains('**Viewport:**')));
      expect(
        output,
        contains(
          '1. **ElevatedButton** (lib/cart_view.dart:88): Change label to Confirm Order (re: "Click here to place your compl...")',
        ),
      );
    });

    test('standard detail level includes location, source, flutter hierarchy, selected text and feedback', () {
      final ann = Annotation(
        id: 'ann_s1',
        comment: 'Needs 8px more padding',
        timestamp: DateTime.now(),
        targetWidget: const WidgetIdentity(
          id: 'primary_card',
          widgetType: 'Card',
        ),
        bounds: const WidgetBounds(x: 16, y: 80, width: 358, height: 120),
        sourceFile: 'lib/card.dart:22',
        selectedText: 'Balance',
        metadata: const {
          'path': 'HomeScreen > Column > Card',
          'flutterComponents': 'HomeScreen > Column > Card',
        },
      );

      final output = encoder.formatDocument(
        [ann],
        detailLevel: OutputDetailLevel.standard,
        pathname: '/home',
        appName: 'My App [Beta]',
      );

      expect(output, contains('## Page Feedback: /home'));
      expect(output, contains(r'**App:** My App \[Beta\]'));
      expect(output, contains('**Viewport:** 390×844'));
      expect(output, contains('### 1. Card'));
      expect(output, contains('**Location:** HomeScreen > Column > Card'));
      expect(output, contains('**Source:** lib/card.dart:22'));
      expect(output, contains('**Flutter:** HomeScreen > Column > Card'));
      expect(output, contains('**Selected text:** "Balance"'));
      expect(output, contains('**Feedback:** Needs 8px more padding'));
    });

    test('detailed detail level includes classes, bounding box position, and truncated context', () {
      final ann = Annotation(
        id: 'ann_d1',
        comment: 'Color contrast is too low',
        timestamp: DateTime.now(),
        targetWidget: const WidgetIdentity(
          id: 'subtext',
          widgetType: 'Text',
        ),
        bounds: const WidgetBounds(x: 24, y: 150, width: 200, height: 24),
        sourceFile: 'lib/subtext.dart:10',
        text: 'This is a secondary description text that explains how the billing cycle works in complete detail over several months.',
        metadata: const {
          'path': 'Profile > Subtext',
          'classes': 'profile-subtitle text-muted',
        },
      );

      final output = encoder.formatDocument(
        [ann],
        detailLevel: OutputDetailLevel.detailed,
        pathname: '/profile',
      );

      expect(output, contains('### 1. Text'));
      expect(output, contains('**Classes:** profile-subtitle text-muted'));
      expect(output, contains('**Position:** 24px, 150px (200×24px)'));
      expect(
        output,
        contains(
          '**Context:** This is a secondary description text that explains how the billing cycle works in complete detail ov',
        ),
      );
      expect(output, contains('**Feedback:** Color contrast is too low'));
    });

    test('forensic detail level outputs complete environment and forensic inspector data', () {
      final ann = Annotation(
        id: 'ann_f1',
        comment: 'Critical overlap detected',
        timestamp: DateTime.now(),
        targetWidget: const WidgetIdentity(
          id: 'pay_btn',
          widgetType: 'ElevatedButton',
        ),
        bounds: const WidgetBounds(x: 50, y: 200, width: 100, height: 50),
        sourceFile: 'lib/pay.dart:45',
        isMultiSelect: true,
        metadata: const {
          'fullPath': 'MaterialApp > CheckoutView > Stack > ElevatedButton',
          'cssClasses': 'btn btn-primary',
          'computedStyles': 'color: #ffffff; background: #6200ee; border-radius: 8px',
          'accessibility': 'Double tap to proceed to checkout',
          'nearbyElements': 'Text("Total"), Icon(Icons.lock)',
          'flutterComponents': 'CheckoutView > Stack > ElevatedButton',
        },
      );

      final output = encoder.generateOutput(
        [ann],
        '/checkout',
        detailLevel: OutputDetailLevel.forensic,
        platform: 'Android 14',
        devicePixelRatio: 3.0,
        url: 'https://app.local/checkout',
        userAgent: 'Dart/3.4 (dart:io)',
        timestamp: DateTime.parse('2026-10-20T12:00:00Z'),
      );

      expect(output, contains('## Page Feedback: /checkout'));
      expect(output, contains('**Environment:**'));
      expect(output, contains('- Viewport: 390×844'));
      expect(output, contains('- URL: https://app.local/checkout'));
      expect(output, contains('- Platform: Android 14'));
      expect(output, contains('- User Agent: Dart/3.4 (dart:io)'));
      expect(output, contains('- Timestamp: 2026-10-20T12:00:00.000Z'));
      expect(output, contains('- Device Pixel Ratio: 3'));
      expect(output, contains('---'));

      expect(output, contains('### 1. ElevatedButton'));
      expect(output, contains('*Forensic data shown for first element of selection*'));
      expect(output, contains('**Full DOM Path:** MaterialApp > CheckoutView > Stack > ElevatedButton'));
      expect(output, contains('**CSS Classes:** btn btn-primary'));
      expect(output, contains('**Position:** x:50, y:200 (100×50px)'));
      expect(output, contains('**Annotation at:** 12.8% from left, 200px from top'));
      expect(output, contains('**Computed Styles:** color: #ffffff; background: #6200ee; border-radius: 8px'));
      expect(output, contains('**Accessibility:** Double tap to proceed to checkout'));
      expect(output, contains('**Nearby Elements:** Text("Total"), Icon(Icons.lock)'));
      expect(output, contains('**Source:** lib/pay.dart:45'));
      expect(output, contains('**Flutter:** CheckoutView > Stack > ElevatedButton'));
      expect(output, contains('**Feedback:** Critical overlap detected'));
    });

    test('outputToFlutterMode and outputDetailOptions match agentation-main options', () {
      expect(outputDetailOptions.map((o) => o.label).toList(), [
        'Compact',
        'Standard',
        'Detailed',
        'Forensic',
      ]);
      expect(outputToFlutterMode[OutputDetailLevel.compact], FlutterComponentMode.off);
      expect(outputToFlutterMode[OutputDetailLevel.standard], FlutterComponentMode.filtered);
      expect(outputToFlutterMode[OutputDetailLevel.detailed], FlutterComponentMode.smart);
      expect(outputToFlutterMode[OutputDetailLevel.forensic], FlutterComponentMode.all);
    });
  });
}


