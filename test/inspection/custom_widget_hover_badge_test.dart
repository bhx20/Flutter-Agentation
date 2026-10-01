import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/inspection/flutter_inspection_engine.dart';
import 'package:flutter_agentation/src/models/widget_bounds.dart';
import 'package:flutter_agentation/src/models/widget_context.dart';
import 'package:flutter_agentation/src/models/widget_identity.dart';
import 'package:flutter_agentation/src/models/widget_inspection_result.dart';
import 'package:flutter_agentation/src/overlay/widget_highlight.dart';

class AppHeadingText extends StatelessWidget {
  final String text;
  const AppHeadingText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text);
  }
}

void main() {
  group('Custom Widget & Hover Badge Display Test', () {
    testWidgets('hovering direct Text resolves Text widgetType and renders badge', (tester) async {
      final hostKey = GlobalKey();
      final engine = FlutterInspectionEngine();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyedSubtree(
              key: hostKey,
              child: Column(
                children: const [
                  Text('sanket'),
                ],
              ),
            ),
          ),
        ),
      );

      final textFinder = find.text('sanket');
      expect(textFinder, findsOneWidget);
      final textPos = tester.getCenter(textFinder);

      final hostContext = hostKey.currentContext as Element?;
      final hostRenderObject = hostKey.currentContext?.findRenderObject();

      final result = engine.inspectAt(
        textPos,
        rootElement: hostContext,
        rootRenderObject: hostRenderObject,
      );

      expect(result.isAvailable, isTrue);
      expect(result.identity.widgetType, equals('Text'));

      // Verify WidgetHighlight displays badge on hover
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                WidgetHighlight(
                  result: result,
                  isHover: true,
                  showBadge: true,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Badge displays the widget type 'Text'
      expect(find.text('Text'), findsOneWidget);
    });

    testWidgets('hovering custom AppHeadingText resolves AppHeadingText widgetType and renders badge', (tester) async {
      final hostKey = GlobalKey();
      final engine = FlutterInspectionEngine();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyedSubtree(
              key: hostKey,
              child: Column(
                children: const [
                  AppHeadingText('sanket'),
                ],
              ),
            ),
          ),
        ),
      );

      final textFinder = find.text('sanket');
      expect(textFinder, findsOneWidget);
      final textPos = tester.getCenter(textFinder);

      final hostContext = hostKey.currentContext as Element?;
      final hostRenderObject = hostKey.currentContext?.findRenderObject();

      final result = engine.inspectAt(
        textPos,
        rootElement: hostContext,
        rootRenderObject: hostRenderObject,
      );

      expect(result.isAvailable, isTrue);
      expect(result.identity.widgetType, equals('AppHeadingText'));

      // Verify WidgetHighlight displays badge with custom widget type name on hover
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                WidgetHighlight(
                  result: result,
                  isHover: true,
                  showBadge: true,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('AppHeadingText'), findsOneWidget);
    });

    testWidgets('hover badge renders at top-right on wide elements', (tester) async {
      const wideResult = WidgetInspectionResult(
        identity: WidgetIdentity(
          id: 'list_item_id',
          widgetType: 'list item',
        ),
        bounds: WidgetBounds(x: 20.0, y: 100.0, width: 300.0, height: 40.0),
        context: const WidgetContext(depth: 1),
        ancestors: ['Column', 'ListTile'],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                WidgetHighlight(
                  result: wideResult,
                  isHover: true,
                  showBadge: true,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('list item'), findsOneWidget);
      final badgeFinder = find.ancestor(
        of: find.text('list item'),
        matching: find.byType(Positioned),
      );
      expect(badgeFinder, findsOneWidget);
      final positioned = tester.widget<Positioned>(badgeFinder);
      expect(positioned.right, isNotNull);
    });
  });
}
