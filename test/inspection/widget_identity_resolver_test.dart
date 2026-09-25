import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/inspection/widget_identity_resolver.dart';

void main() {
  group('WidgetIdentityResolver', () {
    final resolver = WidgetIdentityResolver();

    testWidgets('prioritizes explicit AgentationTarget over keys and types', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AgentationTarget(
                id: 'custom_login_button',
                child: ElevatedButton(
                  key: const ValueKey('button_key'),
                  onPressed: () {},
                  child: const Text('Login'),
                ),
              ),
            ),
          ),
        ),
      );

      final buttonFinder = find.byType(ElevatedButton);
      final element = tester.element(buttonFinder);

      final identity = resolver.resolveIdentity(element);

      expect(identity.id, 'custom_login_button');
      expect(identity.isExplicitTarget, isTrue);
      expect(identity.widgetType, 'ElevatedButton');
    });

    testWidgets('uses explicit ValueKey when AgentationTarget is absent', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Container(
                key: const ValueKey('content_box'),
                child: const Text('Content'),
              ),
            ),
          ),
        ),
      );

      final containerFinder = find.byKey(const ValueKey('content_box'));
      final element = tester.element(containerFinder);

      final identity = resolver.resolveIdentity(element);

      expect(identity.id, contains('content_box'));
      expect(identity.keyString, contains('content_box'));
      expect(identity.widgetType, 'Container');
      expect(identity.isExplicitTarget, isFalse);
    });

    testWidgets('falls back to widgetType and element hash when no keys are defined', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Plain Text'),
            ),
          ),
        ),
      );

      final textFinder = find.text('Plain Text');
      final element = tester.element(textFinder);

      final identity = resolver.resolveIdentity(element);

      expect(identity.widgetType, 'Text');
      expect(identity.id, startsWith('Text_'));
      expect(identity.keyString, isNull);
      expect(identity.isExplicitTarget, isFalse);
    });
  });
}
