import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/core/agentation_scope.dart';
import 'package:flutter_agentation/src/core/agentation_state.dart';
import 'package:flutter_agentation/src/models/annotation.dart';
import 'package:flutter_agentation/src/models/toolbar_settings.dart';
import 'package:flutter_agentation/src/models/widget_bounds.dart';
import 'package:flutter_agentation/src/models/widget_identity.dart';
import 'package:flutter_agentation/src/output/annotation_markdown_encoder.dart';
import 'package:flutter_agentation/src/storage/memory_annotation_storage.dart';
import 'package:flutter_agentation/src/toolbar/agentation_toolbar.dart';
import 'package:flutter_agentation/src/toolbar/output_detail_button.dart';

void main() {
  group('Comprehensive Toolbar & Detail Level Cycling', () {
    late MemoryAnnotationStorage storage;
    late AgentationController controller;

    final dummyAnnotation = Annotation(
      id: 'ann_test_01',
      comment: 'Button needs bigger padding',
      timestamp: DateTime.parse('2026-09-25T12:00:00Z'),
      targetWidget: const WidgetIdentity(id: 'btn_id', widgetType: 'ElevatedButton'),
      bounds: const WidgetBounds(x: 20, y: 150, width: 120, height: 48),
      route: '/checkout',
      sourceFile: 'lib/screens/checkout.dart:54',
      text: 'Place Order',
      metadata: {'path': 'MaterialApp > Scaffold > ElevatedButton'},
    );

    setUp(() {
      storage = MemoryAnnotationStorage();
      controller = AgentationController(
        storage: storage,
        initialMode: InspectionMode.inspecting,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('AnnotationMarkdownEncoder encodes compact detail level', () {
      final encoder = const AnnotationMarkdownEncoder();
      final output = encoder.formatDocument(
        [dummyAnnotation],
        detailLevel: OutputDetailLevel.compact,
        pathname: '/checkout',
      );

      expect(output, contains('## Page Feedback: /checkout'));
      expect(output, contains('1. **ElevatedButton** (lib/screens/checkout.dart:54): Button needs bigger padding'));
    });

    test('AnnotationMarkdownEncoder encodes detailed and forensic levels', () {
      final encoder = const AnnotationMarkdownEncoder();

      final detailed = encoder.formatDocument(
        [dummyAnnotation],
        detailLevel: OutputDetailLevel.detailed,
        pathname: '/checkout',
      );
      expect(detailed, contains('**Location:** MaterialApp > Scaffold > ElevatedButton'));
      expect(detailed, contains('**Position:** 20px, 150px (120×48px)'));
      expect(detailed, contains('**Feedback:** Button needs bigger padding'));

      final forensic = encoder.formatDocument(
        [dummyAnnotation],
        detailLevel: OutputDetailLevel.forensic,
        pathname: '/checkout',
      );
      expect(forensic, contains('**Environment:**'));
      expect(forensic, contains('**Position:** x:20, y:150 (120×48px)'));
      expect(forensic, contains('**Source:** lib/screens/checkout.dart:54'));
    });

    testWidgets('OutputDetailButton renders active level and advances on tap', (tester) async {
      OutputDetailLevel active = OutputDetailLevel.standard;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return OutputDetailButton(
                  detailLevel: active,
                  onChanged: (next) {
                    setState(() => active = next);
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Standard'), findsOneWidget);

      await tester.tap(find.byType(OutputDetailButton));
      await tester.pumpAndSettle();
      expect(active, equals(OutputDetailLevel.detailed));
      expect(find.text('Detailed'), findsOneWidget);

      await tester.tap(find.byType(OutputDetailButton));
      await tester.pumpAndSettle();
      expect(active, equals(OutputDetailLevel.forensic));
      expect(find.text('Forensic'), findsOneWidget);

      await tester.tap(find.byType(OutputDetailButton));
      await tester.pumpAndSettle();
      expect(active, equals(OutputDetailLevel.compact));
      expect(find.text('Compact'), findsOneWidget);
    });

    testWidgets('AgentationToolbar renders tool mode selectors and switches mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AgentationScope(
                  controller: controller,
                  child: const AgentationToolbar(),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify mode icons/tooltips exist
      expect(find.byIcon(Icons.near_me_outlined), findsOneWidget); // Pointer
      expect(find.byIcon(Icons.crop_free), findsOneWidget); // Area
      expect(find.byIcon(Icons.select_all), findsOneWidget); // Multi-Select
      expect(find.byIcon(Icons.gesture), findsOneWidget); // Draw

      // Tap Area mode button
      await tester.tap(find.byIcon(Icons.crop_free));
      await tester.pump();
      expect(controller.toolMode, equals(AnnotationToolMode.area));

      // Tap Draw mode button
      await tester.tap(find.byIcon(Icons.gesture));
      await tester.pump();
      expect(controller.toolMode, equals(AnnotationToolMode.draw));
    });

    testWidgets('AgentationToolbar cycles detail level and triggers undo/redo', (tester) async {
      await storage.save(dummyAnnotation);
      final initialAnnotations = await storage.getAll();
      expect(initialAnnotations.length, equals(1));

      // Re-create controller to populate from storage
      controller = AgentationController(
        storage: storage,
        initialMode: InspectionMode.inspecting,
      );
      // Wait for async load if needed, or invoke createAnnotation
      await controller.createAnnotation(comment: 'Second comment');
      expect(controller.annotations.length, equals(2));
      expect(controller.canUndo, isTrue);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AgentationScope(
                  controller: controller,
                  child: const AgentationToolbar(),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify OutputDetailButton is embedded in toolbar
      expect(find.byType(OutputDetailButton), findsOneWidget);
      expect(find.text('Standard'), findsOneWidget);

      // Tap OutputDetailButton in toolbar
      await tester.tap(find.byType(OutputDetailButton));
      await tester.pumpAndSettle();
      expect(controller.settings.outputDetail, equals(OutputDetailLevel.detailed));
      expect(find.text('Detailed'), findsOneWidget);

      // Verify Undo button exists and tap it
      expect(find.byIcon(Icons.undo), findsOneWidget);
      await tester.tap(find.byIcon(Icons.undo));
      await tester.pumpAndSettle();

      expect(controller.annotations.length, equals(1));
      expect(controller.canRedo, isTrue);

      // Tap Redo button
      expect(find.byIcon(Icons.redo), findsOneWidget);
      await tester.tap(find.byIcon(Icons.redo));
      await tester.pumpAndSettle();

      expect(controller.annotations.length, equals(2));
    });
  });
}
