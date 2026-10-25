import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/core/agentation_widget.dart';
import 'package:flutter_agentation/src/inspection/widget_path_resolver.dart';
import '../helpers/inspection_test_harness.dart';

void main() {
  group('WidgetPathResolver', () {
    final resolver = WidgetPathResolver();

    testWidgets('resolves clear breadcrumb ancestry for standard hierarchy', (tester) async {
      await InspectionTestHarness.pumpStandardTree(
        tester,
        targetKey: const ValueKey('button_target'),
      );

      final buttonFinder = find.byKey(const ValueKey('button_target'));
      final element = tester.element(buttonFinder);

      final ancestors = resolver.resolveAncestors(element);
      final pathString = resolver.resolvePathString(element);

      expect(ancestors, contains('MaterialApp'));
      expect(ancestors, contains('Scaffold'));
      expect(ancestors, contains('ElevatedButton'));
      expect(pathString, contains('MaterialApp > Scaffold'));
      expect(pathString, endsWith('ElevatedButton'));
    });

    testWidgets('resolves deep widget hierarchy without crashing or omitting leaf', (tester) async {
      await InspectionTestHarness.pumpDeepHierarchy(tester, depth: 30);

      final leafFinder = find.byKey(const ValueKey('deep_leaf_container'));
      final element = tester.element(leafFinder);

      final ancestors = resolver.resolveAncestors(element);
      expect(ancestors.isNotEmpty, isTrue);
      expect(ancestors.last, 'Container');
    });

    testWidgets('omits Agentation internal wrappers and halts at FreezeOverlay host boundary', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FlutterAgentation(
            child: Scaffold(
              body: Column(
                children: [
                  ElevatedButton(
                    key: const ValueKey('test_btn'),
                    onPressed: () {},
                    child: const Text('Click'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final btnFinder = find.byKey(const ValueKey('test_btn'));
      final element = tester.element(btnFinder);

      final ancestors = resolver.resolveAncestors(element);
      final pathString = resolver.resolvePathString(element);

      // Must not contain any Agentation overlay or freeze wrapper widgets
      expect(ancestors, isNot(contains('FlutterAgentation')));
      expect(ancestors, isNot(contains('InspectionOverlay')));
      expect(ancestors, isNot(contains('FreezeOverlay')));
      expect(ancestors, isNot(contains('AgentationShortcuts')));
      expect(ancestors, isNot(contains('SnapshotWidget')));

      // Must cleanly contain host application hierarchy
      expect(pathString, contains('Scaffold > Column > ElevatedButton'));
    });
  });
}

