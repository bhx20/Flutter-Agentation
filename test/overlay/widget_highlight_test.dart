import 'package:flutter/material.dart';
import 'package:flutter_agentation/src/models/widget_bounds.dart';
import 'package:flutter_agentation/src/models/widget_context.dart';
import 'package:flutter_agentation/src/models/widget_identity.dart';
import 'package:flutter_agentation/src/models/widget_inspection_result.dart';
import 'package:flutter_agentation/src/overlay/highlight_style.dart';
import 'package:flutter_agentation/src/overlay/widget_highlight.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WidgetHighlight', () {
    testWidgets('renders nothing when result is unavailable', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                WidgetHighlight(
                  result: WidgetInspectionResult.unavailable(),
                ),
              ],
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WidgetHighlight),
          matching: find.byType(CustomPaint),
        ),
        findsNothing,
      );
      expect(find.text('ElevatedButton'), findsNothing);
    });

    testWidgets('renders bounding box and identifier badge when result is valid',
        (tester) async {
      const result = WidgetInspectionResult(
        identity: WidgetIdentity(
          id: 'btn_submit',
          keyString: 'submit_key',
          widgetType: 'ElevatedButton',
          isExplicitTarget: true,
        ),
        bounds: WidgetBounds(x: 50, y: 120, width: 200, height: 48),
        context: WidgetContext(depth: 5),
        ancestors: ['MaterialApp', 'Scaffold', 'ElevatedButton'],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                WidgetHighlight(
                  result: result,
                  style: HighlightStyle(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify custom painter renders
      expect(
        find.descendant(
          of: find.byType(WidgetHighlight),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );

      // Verify badge text displays widget type and key
      expect(find.text('ElevatedButton'), findsOneWidget);
      expect(find.text('submit_key'), findsOneWidget);
    });

    testWidgets('adjusts badge placement if target is near top screen edge',
        (tester) async {
      const topResult = WidgetInspectionResult(
        identity: WidgetIdentity(
          id: 'app_bar_title',
          widgetType: 'Text',
        ),
        bounds: WidgetBounds(x: 20, y: 10, width: 150, height: 30),
        context: WidgetContext(depth: 3),
        ancestors: ['AppBar', 'Text'],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                WidgetHighlight(
                  result: topResult,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Text'), findsOneWidget);
    });

    testWidgets('selection highlight uses transparent fill color and thin stroke width by default',
        (tester) async {
      const result = WidgetInspectionResult(
        identity: WidgetIdentity(
          id: 'card_id',
          widgetType: 'Card',
        ),
        bounds: WidgetBounds(x: 10, y: 10, width: 100, height: 100),
        context: WidgetContext(depth: 2),
        ancestors: ['Card'],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                WidgetHighlight(
                  result: result,
                  isHover: false,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final customPaintFinder = find.descendant(
        of: find.byType(WidgetHighlight),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintFinder, findsOneWidget);

      final customPaint = tester.widget<CustomPaint>(customPaintFinder);
      final painter = customPaint.painter as HighlightPainter;
      expect(painter.fillColor, equals(Colors.transparent));
      expect(painter.strokeWidth, equals(1.5));
    });
  });
}
