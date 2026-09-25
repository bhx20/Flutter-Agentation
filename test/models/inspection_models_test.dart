import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/models/widget_bounds.dart';
import 'package:flutter_agentation/src/models/widget_context.dart';
import 'package:flutter_agentation/src/models/widget_identity.dart';
import 'package:flutter_agentation/src/models/widget_inspection_result.dart';

void main() {
  group('WidgetBounds', () {
    test('computes correct edge coordinates and center', () {
      const bounds = WidgetBounds(x: 10.0, y: 20.0, width: 100.0, height: 50.0);

      expect(bounds.left, 10.0);
      expect(bounds.top, 20.0);
      expect(bounds.right, 110.0);
      expect(bounds.bottom, 70.0);
      expect(bounds.center, const Offset(60.0, 45.0));
      expect(bounds.size, const Size(100.0, 50.0));
      expect(bounds.rect, const Rect.fromLTWH(10.0, 20.0, 100.0, 50.0));
    });

    test('WidgetBounds.zero produces empty bounding box', () {
      const bounds = WidgetBounds.zero();

      expect(bounds.x, 0.0);
      expect(bounds.y, 0.0);
      expect(bounds.width, 0.0);
      expect(bounds.height, 0.0);
      expect(bounds.center, Offset.zero);
    });

    test('fromRect correctly constructs bounds', () {
      const rect = Rect.fromLTWH(15.0, 25.0, 80.0, 40.0);
      final bounds = WidgetBounds.fromRect(rect);

      expect(bounds.x, 15.0);
      expect(bounds.y, 25.0);
      expect(bounds.width, 80.0);
      expect(bounds.height, 40.0);
    });

    test('serializes to JSON correctly', () {
      const bounds = WidgetBounds(x: 5.0, y: 10.0, width: 20.0, height: 30.0);
      final json = bounds.toJson();

      expect(json['x'], 5.0);
      expect(json['y'], 10.0);
      expect(json['width'], 20.0);
      expect(json['height'], 30.0);
      expect(json['right'], 25.0);
      expect(json['bottom'], 40.0);
    });
  });

  group('WidgetIdentity', () {
    test('constructs and serializes correctly', () {
      const identity = WidgetIdentity(
        id: 'submit_btn',
        keyString: '[<submit_btn>]',
        widgetType: 'ElevatedButton',
        isExplicitTarget: true,
      );

      expect(identity.id, 'submit_btn');
      expect(identity.keyString, '[<submit_btn>]');
      expect(identity.widgetType, 'ElevatedButton');
      expect(identity.isExplicitTarget, true);

      final json = identity.toJson();
      expect(json['id'], 'submit_btn');
      expect(json['widgetType'], 'ElevatedButton');
      expect(json['isExplicitTarget'], true);
    });

    test('WidgetIdentity.empty produces safe defaults', () {
      const identity = WidgetIdentity.empty();

      expect(identity.id, '');
      expect(identity.keyString, isNull);
      expect(identity.widgetType, 'Unknown');
      expect(identity.isExplicitTarget, false);
    });
  });

  group('WidgetContext', () {
    test('constructs and serializes correctly', () {
      const context = WidgetContext(
        route: '/home',
        semanticsLabel: 'Submit action',
        semanticsHint: 'Double tap to activate',
        packageSource: 'flutter_agentation',
        depth: 5,
      );

      expect(context.route, '/home');
      expect(context.semanticsLabel, 'Submit action');
      expect(context.depth, 5);

      final json = context.toJson();
      expect(json['route'], '/home');
      expect(json['depth'], 5);
    });

    test('WidgetContext.empty produces safe defaults', () {
      const context = WidgetContext.empty();

      expect(context.route, isNull);
      expect(context.semanticsLabel, isNull);
      expect(context.depth, 0);
    });
  });

  group('WidgetInspectionResult', () {
    test('successful result populates all fields and formats path', () {
      const result = WidgetInspectionResult(
        identity: WidgetIdentity(
          id: 'btn_1',
          widgetType: 'ElevatedButton',
        ),
        bounds: WidgetBounds(x: 10, y: 20, width: 100, height: 40),
        context: WidgetContext(route: '/login', depth: 4),
        route: '/login',
        text: 'Login',
        ancestors: ['MaterialApp', 'Scaffold', 'LoginForm', 'ElevatedButton'],
      );

      expect(result.isAvailable, true);
      expect(result.text, 'Login');
      expect(result.route, '/login');
      expect(result.pathString, 'MaterialApp > Scaffold > LoginForm > ElevatedButton');

      final json = result.toJson();
      expect(json['isAvailable'], true);
      expect(json['text'], 'Login');
      expect(json['pathString'], 'MaterialApp > Scaffold > LoginForm > ElevatedButton');
    });

    test('unavailable fallback produces empty/safe state without throwing', () {
      const unavailable = WidgetInspectionResult.unavailable();

      expect(unavailable.isAvailable, false);
      expect(unavailable.text, isNull);
      expect(unavailable.route, isNull);
      expect(unavailable.ancestors, isEmpty);
      expect(unavailable.pathString, 'Unknown');
      expect(unavailable.bounds, const WidgetBounds.zero());
      expect(unavailable.identity, const WidgetIdentity.empty());
    });
  });
}
