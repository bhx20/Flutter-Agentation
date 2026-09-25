import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/inspection/flutter_inspection_engine.dart';

void main() {
  group('Defensive Inspection & Edge Cases', () {
    late FlutterInspectionEngine engine;

    setUp(() {
      engine = FlutterInspectionEngine();
    });

    testWidgets('handles extreme and NaN coordinates without crashing host', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Test')),
          ),
        ),
      );

      final nanResult = engine.inspectAt(const Offset(double.nan, double.nan));
      expect(nanResult.isAvailable, isFalse);

      final infinityResult = engine.inspectAt(const Offset(double.infinity, -double.infinity));
      expect(infinityResult.isAvailable, isFalse);

      final negativeResult = engine.inspectAt(const Offset(-1000.0, -1000.0));
      expect(negativeResult.isAvailable, isFalse);
    });

    testWidgets('inspectAllAt resolves multiple overlapping widgets in a Stack', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    key: const ValueKey('background_container'),
                    width: 200,
                    height: 200,
                    color: Colors.red,
                  ),
                  ElevatedButton(
                    key: const ValueKey('foreground_button'),
                    onPressed: () {},
                    child: const Text('Top Button'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final buttonFinder = find.byKey(const ValueKey('foreground_button'));
      final center = tester.getCenter(buttonFinder);

      final allResults = engine.inspectAllAt(center);
      expect(allResults.isNotEmpty, isTrue);

      final types = allResults.map((r) => r.identity.widgetType).toList();
      expect(types, contains('ElevatedButton'));
    });

    testWidgets('handles CustomScrollView with Slivers defensively', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: const Text('Sliver Title'),
                  expandedHeight: 150.0,
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ListTile(
                      key: ValueKey('item_$index'),
                      title: Text('Item $index'),
                    ),
                    childCount: 50,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Inspect visible first item
      final firstItemFinder = find.byKey(const ValueKey('item_0'));
      final center = tester.getCenter(firstItemFinder);

      final result = engine.inspectAt(center);
      expect(result.isAvailable, isTrue);
      expect(result.text, contains('Item 0'));

      // Inspect off-screen coordinate outside visible window
      final offscreen = engine.inspectAt(const Offset(200.0, 5000.0));
      expect(offscreen.isAvailable, isFalse);
    });
  });
}
