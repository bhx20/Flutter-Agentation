import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/inspection/flutter_inspection_engine.dart';
import 'package:flutter_agentation/src/inspection/element_inspector.dart';

void main() {
  group('Hierarchical Widget Inspection', () {
    late FlutterInspectionEngine engine;
    late ElementInspector inspector;

    setUp(() {
      inspector = ElementInspector();
      engine = FlutterInspectionEngine(elementInspector: inspector);
    });

    testWidgets('inspectHierarchyAt resolves ancestors, primary target, and children for compound widget', (tester) async {
      final hostKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyedSubtree(
              key: hostKey,
              child: Center(
                child: Card(
                  key: const ValueKey('demo_card'),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('Card Title', key: ValueKey('title_text')),
                        SizedBox(height: 8.0),
                        Text('Card Subtitle', key: ValueKey('subtitle_text')),
                        Icon(Icons.star, key: ValueKey('star_icon')),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final titleFinder = find.byKey(const ValueKey('title_text'));
      expect(titleFinder, findsOneWidget);
      final titlePos = tester.getCenter(titleFinder);

      final hostContext = hostKey.currentContext as Element?;
      final hostRenderObject = hostKey.currentContext?.findRenderObject();

      final hierarchy = engine.inspectHierarchyAt(
        titlePos,
        rootElement: hostContext,
        rootRenderObject: hostRenderObject,
      );

      expect(hierarchy.isAvailable, isTrue);
      // Primary target should be Text or Column/Card
      expect(hierarchy.primaryTarget.isAvailable, isTrue);

      // Ancestors should include Card
      final ancestorTypes = hierarchy.ancestors.map((a) => a.identity.widgetType).toList();
      expect(ancestorTypes, contains('Card'));

      // Children or candidates should contain sibling/child elements
      final allTypes = hierarchy.allSelectableWidgets.map((w) => w.identity.widgetType).toSet();
      expect(allTypes, contains('Text'));
      expect(allTypes, contains('Card'));
    });

    testWidgets('findMeaningfulChildren finds child widgets within a parent container', (tester) async {
      final cardKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Card(
              key: cardKey,
              child: Column(
                children: const [
                  Text('Child 1'),
                  Text('Child 2'),
                  Icon(Icons.check),
                ],
              ),
            ),
          ),
        ),
      );

      final cardElement = cardKey.currentContext as Element;
      final children = inspector.findMeaningfulChildren(cardElement);

      expect(children.isNotEmpty, isTrue);
      final childTypes = children.map((c) => c.widget.runtimeType.toString()).toList();
      expect(childTypes, contains('Text'));
      expect(childTypes, contains('Icon'));
    });

    testWidgets('inspectHierarchyAt on empty background area resolves layout container fallback', (tester) async {
      final hostKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            key: hostKey,
            body: const SizedBox.expand(),
          ),
        ),
      );

      final centerPos = tester.getCenter(find.byType(Scaffold));
      final hostContext = hostKey.currentContext as Element?;
      final hostRenderObject = hostKey.currentContext?.findRenderObject();

      final hierarchy = engine.inspectHierarchyAt(
        centerPos,
        rootElement: hostContext,
        rootRenderObject: hostRenderObject,
      );

      expect(hierarchy.isAvailable, isTrue);
      expect(hierarchy.primaryTarget.isAvailable, isTrue);
      expect(
        ['Scaffold', 'SizedBox', 'Material', 'ColoredBox'].contains(hierarchy.primaryTarget.identity.widgetType) ||
            hierarchy.ancestors.any((a) => a.identity.widgetType == 'Scaffold'),
        isTrue,
      );
    });
  });
}
