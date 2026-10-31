import 'package:flutter/material.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/core/agentation_widget.dart';
import 'package:flutter_agentation/src/domain/annotation.dart';
import 'package:flutter_agentation/src/domain/widget_bounds.dart';
import 'package:flutter_agentation/src/domain/widget_context.dart';
import 'package:flutter_agentation/src/domain/widget_identity.dart';
import 'package:flutter_agentation/src/domain/widget_inspection_result.dart';
import 'package:flutter_agentation/src/storage/annotations_storage_io.dart' as io_storage;
import 'package:flutter_agentation/src/storage/annotations_storage_stub.dart' as stub_storage;
import 'package:flutter_agentation/src/storage/local_annotation_storage.dart';
import 'package:flutter_agentation/src/ui/overlay/annotation_marker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Cross-Platform Annotation Storage & Hot Restart Persistence Test Suite', () {
    setUp(() {
      AgentationController.resetPersistedAnnotations();
      io_storage.persistAnnotationsInTest = true;
      io_storage.debugForceDiskIo = false;
    });

    tearDown(() {
      AgentationController.resetPersistedAnnotations();
      io_storage.persistAnnotationsInTest = false;
      io_storage.debugForceDiskIo = false;
      io_storage.clearStoredAnnotationsJson();
    });

    group('LocalAnnotationStorage Unit Tests', () {
      test('stores annotations and restores them in a fresh LocalAnnotationStorage instance', () async {
        final storage = LocalAnnotationStorage();
        expect(await storage.getAll(), isEmpty);

        final now = DateTime.now();
        final ann1 = Annotation(
          id: 'ann_1',
          comment: 'Primary comment',
          timestamp: now,
          targetWidget: const WidgetIdentity(id: 'btn_1', widgetType: 'ElevatedButton'),
          bounds: const WidgetBounds(x: 10, y: 20, width: 100, height: 40),
          tapPosition: const Offset(50, 40),
          route: '/home',
        );

        final ann2 = Annotation(
          id: 'ann_2',
          comment: 'Second feedback note',
          timestamp: now.add(const Duration(seconds: 1)),
          targetWidget: const WidgetIdentity(id: 'txt_1', widgetType: 'Text'),
          bounds: const WidgetBounds(x: 10, y: 70, width: 200, height: 24),
          tapPosition: const Offset(60, 80),
          route: '/settings',
        );

        await storage.save(ann1);
        await storage.save(ann2);

        final loaded = await storage.getAll();
        expect(loaded.length, equals(2));
        expect(loaded.first.id, equals('ann_1'));
        expect(loaded.first.comment, equals('Primary comment'));
        expect(loaded.first.tapPosition, equals(const Offset(50, 40)));
        expect(loaded.last.id, equals('ann_2'));

        // Query by route
        final homeItems = await storage.getByRoute('/home');
        expect(homeItems.length, equals(1));
        expect(homeItems.first.id, equals('ann_1'));

        // Simulate fresh storage instance created after application restart
        final restartedStorage = LocalAnnotationStorage();
        final restored = restartedStorage.getAllSync();
        expect(restored.length, equals(2));
        expect(restored[0].id, equals('ann_1'));
        expect(restored[0].comment, equals('Primary comment'));
        expect(restored[0].tapPosition, equals(const Offset(50, 40)));
        expect(restored[1].id, equals('ann_2'));
        expect(restored[1].comment, equals('Second feedback note'));

        // Deleting from restarted storage updates persistence
        final deleted = await restartedStorage.delete('ann_1');
        expect(deleted, isTrue);

        final thirdStorage = LocalAnnotationStorage();
        final remaining = await thirdStorage.getAll();
        expect(remaining.length, equals(1));
        expect(remaining.first.id, equals('ann_2'));

        // Clear removes all persisted annotations
        await thirdStorage.clear();
        final emptyStorage = LocalAnnotationStorage();
        expect(await emptyStorage.getAll(), isEmpty);
      });
    });

    group('AgentationController Hot Restart Lifecycle', () {
      test('comments created via controller persist across complete controller hot restart', () async {
        final controller = AgentationController();
        expect(controller.annotations, isEmpty);

        const targetBounds = WidgetBounds(x: 40, y: 80, width: 120, height: 50);
        final targetResult = WidgetInspectionResult(
          identity: const WidgetIdentity(id: 'test_card', widgetType: 'Card'),
          bounds: targetBounds,
          context: const WidgetContext(depth: 2),
          ancestors: const ['MaterialApp', 'Scaffold', 'Card'],
        );

        controller.selectResult(targetResult);
        final created = await controller.createAnnotation(
          comment: 'Buttons need higher contrast',
          targetResult: targetResult,
          tapPosition: const Offset(100, 105),
        );

        expect(controller.annotations.length, equals(1));
        expect(controller.annotations.first.comment, equals('Buttons need higher contrast'));
        expect(controller.annotations.first.tapPosition, equals(const Offset(100, 105)));

        controller.dispose();

        // Simulate Hot Restart: brand new AgentationController instantiated
        final restartedController = AgentationController();

        expect(restartedController.annotations.length, equals(1));
        final restoredAnn = restartedController.annotations.first;
        expect(restoredAnn.id, equals(created.id));
        expect(restoredAnn.comment, equals('Buttons need higher contrast'));
        expect(restoredAnn.targetWidget.widgetType, equals('Card'));
        expect(restoredAnn.tapPosition, equals(const Offset(100, 105)));
        expect(restoredAnn.bounds.x, equals(40));

        // Updating comment persists across another restart
        await restartedController.updateAnnotation(created.id, comment: 'Updated: Use dark purple contrast');
        restartedController.dispose();

        final secondRestartController = AgentationController();
        expect(secondRestartController.annotations.length, equals(1));
        expect(secondRestartController.annotations.first.comment, equals('Updated: Use dark purple contrast'));

        // Clearing annotations clears storage and resets cleanly
        await secondRestartController.clearAnnotations();
        expect(secondRestartController.annotations, isEmpty);
        secondRestartController.dispose();

        final thirdRestartController = AgentationController();
        expect(thirdRestartController.annotations, isEmpty);
        thirdRestartController.dispose();
      });
    });

    group('FlutterAgentation Widget Hot Restart & Reassemble Lifecycle', () {
      testWidgets('FlutterAgentation preserves and renders comment markers across reassemble and hot restart', (tester) async {
        final controller = AgentationController();
        controller.setToolbarMinimized(false);

        // Create an annotation on screen
        const bounds = WidgetBounds(x: 80, y: 120, width: 150, height: 60);
        await controller.createAnnotation(
          comment: 'Persistent comment note',
          targetResult: WidgetInspectionResult(
            identity: const WidgetIdentity(id: 'btn_submit', widgetType: 'ElevatedButton'),
            bounds: bounds,
            context: const WidgetContext(depth: 3),
            ancestors: const ['ElevatedButton'],
          ),
          tapPosition: const Offset(155, 150),
        );

        expect(controller.annotations.length, equals(1));

        // Mount widget with the controller
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlutterAgentation(
                controller: controller,
                showToolbar: false,
                child: const Center(child: Text('Main Screen Content')),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify AnnotationMarker pin is rendered on screen
        expect(find.byType(AnnotationMarker), findsOneWidget);

        // Simulate Hot Reload (reassemble)
        tester.binding.reassembleApplication();
        await tester.pumpAndSettle();

        expect(find.byType(AnnotationMarker), findsOneWidget);
        expect(controller.annotations.length, equals(1));

        // Simulate Hot Restart: Unmount, dispose old controller, instantiate new FlutterAgentation
        await tester.pumpWidget(const SizedBox());
        controller.dispose();

        // New widget tree created after hot restart
        final restartedController = AgentationController();
        restartedController.setToolbarMinimized(false);
        expect(restartedController.annotations.length, equals(1));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlutterAgentation(
                controller: restartedController,
                showToolbar: false,
                child: const Center(child: Text('Main Screen Content')),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Marker pin must still be present and rendered right after hot restart!
        expect(find.byType(AnnotationMarker), findsOneWidget);
        restartedController.dispose();
      });
    });

    group('Physical Disk IO Persistence', () {
      test('writes and reads real file on disk when debugForceDiskIo is enabled', () async {
        io_storage.debugForceDiskIo = true;
        io_storage.clearStoredAnnotationsJson();

        final storage = LocalAnnotationStorage();
        expect(await storage.getAll(), isEmpty);

        final diskAnn = Annotation(
          id: 'disk_1',
          comment: 'Written to physical file',
          timestamp: DateTime.now(),
          targetWidget: const WidgetIdentity(id: 'disk_box', widgetType: 'Container'),
          bounds: const WidgetBounds(x: 5, y: 15, width: 80, height: 50),
        );

        await storage.save(diskAnn);

        // Verify fresh storage reads directly from the physical file
        final restoredStorage = LocalAnnotationStorage();
        final loaded = await restoredStorage.getAll();
        expect(loaded.length, equals(1));
        expect(loaded.first.id, equals('disk_1'));
        expect(loaded.first.comment, equals('Written to physical file'));

        // Clean up disk file
        await restoredStorage.clear();
        final cleanStorage = LocalAnnotationStorage();
        expect(await cleanStorage.getAll(), isEmpty);
      });
    });

    group('Stub Fallback Tests (annotations_storage_stub.dart)', () {
      test('stub storage methods execute safely without errors or unhandled exceptions', () {
        expect(stub_storage.loadStoredAnnotationsJson(), isNull);
        stub_storage.saveStoredAnnotationsJson([{'id': 'stub_1'}]);
        stub_storage.clearStoredAnnotationsJson();
        expect(stub_storage.loadStoredAnnotationsJson(), isNull);
      });
    });
  });
}
