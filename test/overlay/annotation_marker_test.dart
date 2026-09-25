import 'package:flutter/material.dart';
import 'package:flutter_agentation/src/models/annotation.dart';
import 'package:flutter_agentation/src/models/annotation_severity.dart';
import 'package:flutter_agentation/src/models/widget_bounds.dart';
import 'package:flutter_agentation/src/models/widget_identity.dart';
import 'package:flutter_agentation/src/overlay/annotation_marker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnnotationMarker', () {
    final dummyAnnotation = Annotation(
      id: 'ann_marker_1',
      comment: 'Check contrast',
      timestamp: DateTime.now(),
      targetWidget: const WidgetIdentity(id: 'btn', widgetType: 'Button'),
      bounds: const WidgetBounds(x: 100, y: 150, width: 80, height: 40),
      severity: AnnotationSeverity.high,
    );

    testWidgets('renders index number and severity color', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AnnotationMarker(
                  index: 1,
                  annotation: dummyAnnotation,
                  onTap: () => tapped = true,
                ),
              ],
            ),
          ),
        ),
      );

      // Verify number text 1
      expect(find.text('1'), findsOneWidget);

      // Tap marker
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });
}
