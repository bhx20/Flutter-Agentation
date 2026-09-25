import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/core/agentation_scope.dart';
import 'package:flutter_agentation/src/core/agentation_state.dart';
import 'package:flutter_agentation/src/design/component_palette.dart';
import 'package:flutter_agentation/src/design/rearrange_controller.dart';
import 'package:flutter_agentation/src/design/skeleton_templates.dart';
import 'package:flutter_agentation/src/design/spatial_guide_painter.dart';
import 'package:flutter_agentation/src/models/annotation.dart';
import 'package:flutter_agentation/src/models/placement_data.dart';
import 'package:flutter_agentation/src/models/rearrange_data.dart';
import 'package:flutter_agentation/src/models/widget_bounds.dart';
import 'package:flutter_agentation/src/models/widget_identity.dart';
import 'package:flutter_agentation/src/storage/memory_annotation_storage.dart';

void main() {
  group('Visual Design Mode & Skeletons Palette (User Story 5)', () {
    late MemoryAnnotationStorage storage;
    late AgentationController controller;

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

    test('SkeletonTemplates contains all 6 core wireframe templates', () {
      final templates = SkeletonTemplate.defaultTemplates;
      expect(templates.length, greaterThanOrEqualTo(6));

      final types = templates.map((t) => t.componentType).toSet();
      expect(types, containsAll(['Button', 'Input', 'Card', 'Text', 'Avatar', 'Image']));

      for (final t in templates) {
        expect(t.defaultWidth, greaterThan(0.0));
        expect(t.defaultHeight, greaterThan(0.0));
        expect(t.label.isNotEmpty, isTrue);
      }
    });

    test('SpatialGuidePainter renders crosshair guides and dimensions cleanly', () {
      final painter = SpatialGuidePainter(
        targetBounds: const WidgetBounds(x: 100, y: 150, width: 200, height: 50),
        screenSize: const Size(800, 600),
        accentColor: const Color(0xFF6366F1),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, const Size(800, 600));
      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    testWidgets('ComponentPalette renders all templates and triggers onSelect', (tester) async {
      SkeletonTemplate? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentationScope(
              controller: controller,
              child: ComponentPalette(
                onSelectTemplate: (t) => selected = t,
                onClose: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Component Palette'), findsOneWidget);
      expect(find.text('Button'), findsOneWidget);
      expect(find.text('Input Field'), findsOneWidget);

      await tester.tap(find.text('Button'));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.componentType, equals('Button'));
    });

    test('controller creates placement annotation with kind: placement', () async {
      final placement = const PlacementData(
        componentType: 'Button',
        width: 120.0,
        height: 44.0,
        text: 'Checkout Now',
        prompt: 'Add primary action button below cart total',
      );

      final ann = await controller.createPlacementAnnotation(
        placement: placement,
        position: const Offset(40, 300),
        comment: 'Add primary action button below cart total',
      );

      expect(ann.kind, equals(AnnotationKind.placement));
      expect(ann.placement, isNotNull);
      expect(ann.placement!.componentType, equals('Button'));
      expect(ann.bounds.width, equals(120.0));
      expect(ann.bounds.height, equals(44.0));
      expect(ann.bounds.x, equals(40.0));
      expect(ann.bounds.y, equals(300.0));
      expect(controller.annotations.length, equals(1));
    });

    test('controller creates rearrange annotation with kind: rearrange', () async {
      const orig = WidgetBounds(x: 20, y: 100, width: 200, height: 40);
      const next = WidgetBounds(x: 20, y: 220, width: 200, height: 40);

      final rearrange = const RearrangeData(
        originalBounds: orig,
        newBounds: next,
        direction: 'after',
        relativeTarget: 'Header',
      );

      final ann = await controller.createRearrangeAnnotation(
        rearrange: rearrange,
        targetIdentity: const WidgetIdentity(id: 'search_bar', widgetType: 'TextField'),
        comment: 'Move search bar below Header',
      );

      expect(ann.kind, equals(AnnotationKind.rearrange));
      expect(ann.rearrange, isNotNull);
      expect(ann.rearrange!.originalBounds.y, equals(100));
      expect(ann.rearrange!.newBounds.y, equals(220));
      expect(ann.rearrange!.direction, equals('after'));
      expect(controller.annotations.length, equals(1));
    });

    test('RearrangeController computes drag offset and produces RearrangeData', () {
      final rearrangeCtrl = RearrangeController(
        initialBounds: const WidgetBounds(x: 50, y: 50, width: 100, height: 30),
      );

      rearrangeCtrl.startDrag(const Offset(50, 50));
      rearrangeCtrl.updateDrag(const Offset(50, 150)); // Moved down by 100px

      final current = rearrangeCtrl.currentBounds;
      expect(current.x, equals(50));
      expect(current.y, equals(150));

      final data = rearrangeCtrl.endDrag(relativeTarget: 'Navigation');
      expect(data.originalBounds.y, equals(50));
      expect(data.newBounds.y, equals(150));
      expect(data.direction, equals('after'));
      expect(data.relativeTarget, equals('Navigation'));
    });
  });
}
