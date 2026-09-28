import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/inspection/flutter_inspection_engine.dart';

void main() {
  group('Deep Widget Inspection Test', () {
    testWidgets('inspectAt on ListTile title text without ANY keys resolves Text', (tester) async {
      final hostKey = GlobalKey();
      final engine = FlutterInspectionEngine();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyedSubtree(
              key: hostKey,
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.star),
                    title: const Text('FAQ Title'),
                    subtitle: const Text('FAQ Subtitle'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final titleFinder = find.text('FAQ Title');
      expect(titleFinder, findsOneWidget);
      final titlePos = tester.getCenter(titleFinder);

      final hostContext = hostKey.currentContext as Element?;
      final hostRenderObject = hostKey.currentContext?.findRenderObject();

      final result = engine.inspectAt(
        titlePos,
        rootElement: hostContext,
        rootRenderObject: hostRenderObject,
      );

      expect(result.isAvailable, isTrue);
      expect(result.identity.widgetType, equals('Text'));
      expect(result.text, equals('FAQ Title'));
    });

    testWidgets('inspectAt on ListTile title text resolves Text even when ListTile has an explicit Key', (tester) async {
      final hostKey = GlobalKey();
      final engine = FlutterInspectionEngine();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyedSubtree(
              key: hostKey,
              child: ListView(
                children: [
                  ListTile(
                    key: const ValueKey('parent_list_tile_key'),
                    leading: const Icon(Icons.star),
                    title: const Text('FAQ Title'),
                    subtitle: const Text('FAQ Subtitle'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final titleFinder = find.text('FAQ Title');
      expect(titleFinder, findsOneWidget);
      final titlePos = tester.getCenter(titleFinder);

      final hostContext = hostKey.currentContext as Element?;
      final hostRenderObject = hostKey.currentContext?.findRenderObject();

      final result = engine.inspectAt(
        titlePos,
        rootElement: hostContext,
        rootRenderObject: hostRenderObject,
      );

      expect(result.isAvailable, isTrue);
      expect(result.identity.widgetType, equals('Text'));
      expect(result.text, equals('FAQ Title'));
    });

    testWidgets('inspectAt on ListTile leading icon resolves Icon even when ListTile has an explicit Key', (tester) async {
      final hostKey = GlobalKey();
      final engine = FlutterInspectionEngine();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyedSubtree(
              key: hostKey,
              child: ListView(
                children: [
                  ListTile(
                    key: const ValueKey('parent_list_tile_key'),
                    leading: const Icon(Icons.star),
                    title: const Text('FAQ Title'),
                    subtitle: const Text('FAQ Subtitle'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final iconFinder = find.byIcon(Icons.star);
      expect(iconFinder, findsOneWidget);
      final iconPos = tester.getCenter(iconFinder);

      final hostContext = hostKey.currentContext as Element?;
      final hostRenderObject = hostKey.currentContext?.findRenderObject();

      final result = engine.inspectAt(
        iconPos,
        rootElement: hostContext,
        rootRenderObject: hostRenderObject,
      );

      expect(result.isAvailable, isTrue);
      expect(result.identity.widgetType, equals('Icon'));
    });

    testWidgets('inspectHierarchyAt on ListTile exposes ListTile ancestor and sibling child widgets', (tester) async {
      final hostKey = GlobalKey();
      final engine = FlutterInspectionEngine();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyedSubtree(
              key: hostKey,
              child: ListView(
                children: [
                  ListTile(
                    key: const ValueKey('parent_list_tile_key'),
                    leading: const Icon(Icons.star),
                    title: const Text('FAQ Title'),
                    subtitle: const Text('FAQ Subtitle'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final titleFinder = find.text('FAQ Title');
      final titlePos = tester.getCenter(titleFinder);

      final hostContext = hostKey.currentContext as Element?;
      final hostRenderObject = hostKey.currentContext?.findRenderObject();

      final hierarchy = engine.inspectHierarchyAt(
        titlePos,
        rootElement: hostContext,
        rootRenderObject: hostRenderObject,
      );

      expect(hierarchy.isAvailable, isTrue);
      expect(hierarchy.primaryTarget.identity.widgetType, equals('Text'));

      // Ancestors should include ListTile
      final ancestorTypes = hierarchy.ancestors.map((a) => a.identity.widgetType).toList();
      expect(ancestorTypes, contains('ListTile'));

      // Children should include sibling items (Icon, subtitle Text, trailing Icon)
      final childTypes = hierarchy.children.map((c) => c.identity.widgetType).toList();
      expect(childTypes, contains('Icon'));
      expect(childTypes, contains('Text'));
    });
  });
}
