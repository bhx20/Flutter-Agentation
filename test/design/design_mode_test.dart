import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/core/agentation_scope.dart';
import 'package:flutter_agentation/src/core/agentation_state.dart';
import 'package:flutter_agentation/src/ui/design/component_palette.dart';
import 'package:flutter_agentation/src/ui/design/rearrange_controller.dart';
import 'package:flutter_agentation/src/ui/design/skeleton_templates.dart';
import 'package:flutter_agentation/src/ui/design/spatial_guide_painter.dart';
import 'package:flutter_agentation/src/domain/annotation.dart';
import 'package:flutter_agentation/src/domain/placement_data.dart';
import 'package:flutter_agentation/src/domain/rearrange_data.dart';
import 'package:flutter_agentation/src/domain/widget_bounds.dart';
import 'package:flutter_agentation/src/domain/widget_identity.dart';
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

    testWidgets('ComponentPalette isolates scrolling and does not scroll main screen', (tester) async {
      final mainScreenController = ScrollController();
      controller.setLayoutModeOpen(true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                // Host screen scrollable
                ListView.builder(
                  controller: mainScreenController,
                  itemCount: 100,
                  itemBuilder: (context, index) => ListTile(title: Text('Host Item $index')),
                ),
                // Layout Mode ComponentPalette popup overlay
                Positioned(
                  left: 20,
                  top: 50,
                  child: AgentationScope(
                    controller: controller,
                    child: ComponentPalette(
                      controller: controller,
                      onSelectTemplate: (_) {},
                      onClose: () => controller.closeLayoutMode(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify flyoutBounds is tracked
      expect(controller.flyoutBounds, isNotNull);
      expect(controller.flyoutBounds!.width, greaterThan(0));

      // Initial main screen offset is 0.0
      expect(mainScreenController.offset, equals(0.0));

      // Drag/scroll inside the ComponentPalette list
      final paletteFinder = find.byType(SingleChildScrollView).last;
      await tester.drag(paletteFinder, const Offset(0, -300));
      await tester.pumpAndSettle();

      // Main screen must remain un-scrolled
      expect(mainScreenController.offset, equals(0.0));

      // Close layout mode
      controller.closeLayoutMode();
      await tester.pumpAndSettle();

      expect(controller.flyoutBounds, isNull);
      mainScreenController.dispose();
    });

    testWidgets('on mobile, ComponentPalette uses LongPressDraggable so touch swipes scroll and holding drags', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Scaffold(
            body: AgentationScope(
              controller: controller,
              child: ComponentPalette(
                controller: controller,
                onSelectTemplate: (_) {},
                onClose: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify LongPressDraggable is used for mobile items
      expect(find.byType(LongPressDraggable<SkeletonTemplate>), findsWidgets);
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

    testWidgets('ComponentPalette displays Component header, subtitle, removes wireframe, and close button has hover decoration', (tester) async {
      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentationScope(
              controller: controller,
              child: ComponentPalette(
                controller: controller,
                onSelectTemplate: (_) {},
                onClose: () {
                  closed = true;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header is "Component"
      expect(find.text('Component'), findsOneWidget);
      // Subtitle is "Drag the component to the page"
      expect(find.text('Drag the component to the page'), findsOneWidget);
      // "Wireframe New Page" is removed
      expect(find.text('Wireframe New Page'), findsNothing);

      // Verify close icon and hover interaction
      final closeIconFinder = find.byIcon(Icons.close);
      expect(closeIconFinder, findsOneWidget);

      final closeGestureFinder = find.ancestor(
        of: closeIconFinder,
        matching: find.byType(GestureDetector),
      ).first;

      final animatedContainerFinder = find.descendant(
        of: closeGestureFinder,
        matching: find.byType(AnimatedContainer),
      );
      expect(animatedContainerFinder, findsOneWidget);

      final initialContainer = tester.widget<AnimatedContainer>(animatedContainerFinder);
      final initialBg = (initialContainer.decoration as BoxDecoration).color;
      expect(initialBg, equals(Colors.transparent));

      // Hover over close button
      final mouseGesture = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
      await mouseGesture.addPointer(location: Offset.zero);
      await mouseGesture.moveTo(tester.getCenter(closeIconFinder));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 160));

      final hoveredContainer = tester.widget<AnimatedContainer>(animatedContainerFinder);
      final hoveredBg = (hoveredContainer.decoration as BoxDecoration).color;
      expect(hoveredBg, isNot(equals(Colors.transparent)));

      // Tap close button
      await tester.tap(closeIconFinder);
      await tester.pumpAndSettle();
      expect(closed, isTrue);

      await mouseGesture.removePointer();
    });
  });
}

