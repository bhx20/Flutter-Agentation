import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/inspection/flutter_inspection_engine.dart';
import 'package:flutter_agentation/src/core/agentation_scope.dart';
import '../helpers/test_inspection_app.dart';

void main() {
  testWidgets('Verify individual widgets are selected on hover and Scrollbar is never resolved', (tester) async {
    final engine = FlutterInspectionEngine();

    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    await tester.pumpWidget(const InspectionDemoApp());
    await tester.pump(const Duration(milliseconds: 100));

    final controller = AgentationScope.of(tester.element(find.byType(InspectionDemoScreen)));
    controller.activate();
    await tester.pump(const Duration(milliseconds: 100));

    final screenElement = tester.element(find.byType(InspectionDemoScreen));
    final screenRO = screenElement.findRenderObject();

    // 1. Hover on 'Primary Action' button
    final btnCenter = tester.getCenter(find.text('Primary Action'));
    final btnResult = engine.inspectAt(btnCenter, rootRenderObject: screenRO, rootElement: screenElement);
    debugPrint('Primary Action hovered -> widgetType=${btnResult.identity.widgetType}, bounds=${btnResult.bounds}');
    expect(btnResult.identity.widgetType, equals('ElevatedButton'));
    expect(btnResult.identity.widgetType, isNot(equals('Scrollbar')));

    // 2. Hover on a FilterChip
    final chipCenter = tester.getCenter(find.byType(FilterChip).first);
    final chipResult = engine.inspectAt(chipCenter, rootRenderObject: screenRO, rootElement: screenElement);
    debugPrint('FilterChip hovered -> widgetType=${chipResult.identity.widgetType}, bounds=${chipResult.bounds}');
    expect(chipResult.identity.widgetType, isNot(equals('Scrollbar')));
    expect(chipResult.bounds.width, lessThan(400.0)); // Not the full screen!

    // 3. Hover on text inside Hero Banner
    final bannerText = tester.getCenter(find.text('Visual Inspection, Toolbar & Annotation System'));
    final bannerResult = engine.inspectAt(bannerText, rootRenderObject: screenRO, rootElement: screenElement);
    debugPrint('Banner Text hovered -> widgetType=${bannerResult.identity.widgetType}, bounds=${bannerResult.bounds}');
    expect(bannerResult.identity.widgetType, anyOf(equals('Text'), equals('Container')));
    expect(bannerResult.identity.widgetType, isNot(equals('Scrollbar')));

    // 4. Test 10 diverse coordinates across the scrollable page
    final positions = [
      const Offset(50, 100),
      const Offset(200, 150),
      const Offset(100, 260),
      const Offset(300, 260),
      const Offset(150, 480),
      const Offset(250, 480),
      const Offset(80, 520),
      const Offset(400, 400),
      const Offset(500, 500),
      const Offset(20, 300),
    ];

    for (final pos in positions) {
      final res = engine.inspectAt(pos, rootRenderObject: screenRO, rootElement: screenElement);
      if (res.isAvailable) {
        expect(res.identity.widgetType, isNot(equals('Scrollbar')),
            reason: 'Position $pos should never resolve to Scrollbar');
        expect(res.identity.widgetType, isNot(equals('RawScrollbar')),
            reason: 'Position $pos should never resolve to RawScrollbar');
      }
    }

    debugDefaultTargetPlatformOverride = null;
  });
}

