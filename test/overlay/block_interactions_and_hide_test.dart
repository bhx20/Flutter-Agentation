import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/flutter_agentation.dart';
// ignore: avoid_relative_lib_imports
import '../../example/lib/main.dart';

void main() {
  group('Block Page Interactions & Hide Until Restart', () {
    testWidgets('blockInteractions = true blocks host button click while selecting in Agentation', (tester) async {
      int hostClicks = 0;
      final controller = AgentationController();

      await tester.pumpWidget(
        MaterialApp(
          home: FlutterAgentation(
            controller: controller,
            child: Scaffold(
              body: Center(
                child: ElevatedButton(
                  key: const ValueKey('host_button'),
                  onPressed: () {
                    hostClicks++;
                  },
                  child: const Text('Host Button'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure inspecting mode is active and blockInteractions is true
      controller.activate();
      expect(controller.settings.blockInteractions, isTrue);
      await tester.pumpAndSettle();

      // Tap on the host button (warnIfMissed: false since overlay intercepts when blockInteractions is true)
      await tester.tap(find.byKey(const ValueKey('host_button')), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Host click MUST be blocked
      expect(hostClicks, equals(0), reason: 'Host button click should be blocked when blockInteractions is true');

      // But Agentation MUST have inspected and selected the element
      expect(controller.selectedResult, isNotNull);
      expect(controller.selectedResult!.text, contains('Host Button'));
    });

    testWidgets('user flow: expand toolbar, open settings, toggle blockInteractions, tap host button', (tester) async {
      int hostClicks = 0;
      final controller = AgentationController();

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => FlutterAgentation(
            controller: controller,
            child: child,
          ),
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                key: const ValueKey('host_button'),
                onPressed: () {
                  hostClicks++;
                },
                child: const Text('Host Button'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially minimized
      expect(controller.isToolbarMinimized, isTrue);

      // Tap pill to expand
      await tester.tap(find.byKey(const ValueKey('toolbar_expand')));
      await tester.pumpAndSettle();
      expect(controller.isToolbarMinimized, isFalse);
      expect(controller.isInspecting, isTrue);

      // Open settings
      await tester.tap(find.byKey(const ValueKey('toolbar_settings')));
      await tester.pumpAndSettle();
      expect(controller.isSettingsOpen, isTrue);

      // Toggle block interactions (turn off then on, or ensure on)
      expect(controller.settings.blockInteractions, isTrue);

      // Tap host button
      await tester.tap(find.byKey(const ValueKey('host_button')), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(hostClicks, equals(0), reason: 'Host button click must be blocked when blockInteractions is enabled');
    });

    testWidgets('InspectionDemoApp: AppBar theme button click is blocked when blockInteractions is true', (tester) async {
      await tester.pumpWidget(const InspectionDemoApp());
      await tester.pump(const Duration(milliseconds: 100));

      final controller = AgentationScope.of(tester.element(find.byType(InspectionDemoScreen)));

      // Expand toolbar
      controller.activate();
      await tester.pump(const Duration(milliseconds: 100));

      expect(controller.settings.blockInteractions, isTrue);

      // Verify theme is initially light
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.appBar, isNotNull);

      // Find dark mode toggle button in AppBar
      final themeButton = find.byIcon(Icons.dark_mode);
      expect(themeButton, findsOneWidget);

      // Tap on AppBar theme button
      await tester.tap(themeButton, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 100));

      // Theme MUST NOT have toggled! (Still light mode, icon is still dark_mode)
      expect(find.byIcon(Icons.dark_mode), findsOneWidget, reason: 'Theme button must not have toggled when blockInteractions is true');
      expect(find.byIcon(Icons.light_mode), findsNothing);

      // And Agentation must have selected the tapped widget
      expect(controller.selectedResult, isNotNull);
    });

    testWidgets('InspectionDemoApp: FilterChip selection is blocked when blockInteractions is true', (tester) async {
      await tester.pumpWidget(const InspectionDemoApp());
      await tester.pump(const Duration(milliseconds: 100));

      final controller = AgentationScope.of(tester.element(find.byType(InspectionDemoScreen)));
      controller.activate();
      await tester.pump(const Duration(milliseconds: 100));

      expect(controller.settings.blockInteractions, isTrue);

      // Find the 'Basic & Boxes' filter chip
      final basicChip = find.widgetWithText(FilterChip, 'Basic & Boxes');
      expect(basicChip, findsOneWidget);

      // Tap on 'Basic & Boxes' filter chip
      await tester.tap(basicChip, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 100));

      // The filter chip MUST NOT be selected!
      final chipWidget = tester.widget<FilterChip>(basicChip);
      expect(chipWidget.selected, isFalse, reason: 'FilterChip must not be selected when blockInteractions is true');
    });

    testWidgets('blockInteractions = false allows host button click while still selecting in Agentation', (tester) async {
      int hostClicks = 0;
      final controller = AgentationController();

      await tester.pumpWidget(
        MaterialApp(
          home: FlutterAgentation(
            controller: controller,
            child: Scaffold(
              body: Center(
                child: ElevatedButton(
                  key: const ValueKey('host_button'),
                  onPressed: () {
                    hostClicks++;
                  },
                  child: const Text('Host Button'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Disable block interactions
      controller.updateSettings(
        controller.settings.copyWith(blockInteractions: false),
      );
      controller.activate();
      expect(controller.settings.blockInteractions, isFalse);
      await tester.pumpAndSettle();

      // Tap on the host button
      await tester.tap(find.byKey(const ValueKey('host_button')));
      await tester.pumpAndSettle();

      // Host click MUST have fired
      expect(hostClicks, equals(1), reason: 'Host button click should be allowed when blockInteractions is false');

      // And Agentation MUST still have inspected and selected the element
      expect(controller.selectedResult, isNotNull);
      expect(controller.selectedResult!.text, contains('Host Button'));
    });

    testWidgets('hideUntilRestart hides toolbar and markers until restart', (tester) async {
      final controller = AgentationController();

      await tester.pumpWidget(
        MaterialApp(
          home: FlutterAgentation(
            controller: controller,
            child: Scaffold(
              body: Center(
                child: ElevatedButton(
                  key: const ValueKey('host_button'),
                  onPressed: () {},
                  child: const Text('Target Widget'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially toolbar is present
      expect(find.byType(AgentationToolbar), findsOneWidget);

      // Create an annotation so a marker exists
      controller.activate();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('host_button')), warnIfMissed: false);
      await tester.pumpAndSettle();
      await controller.createAnnotation(
        comment: 'Test annotation marker',
        targetResult: controller.selectedResult,
      );
      await tester.pumpAndSettle();

      expect(find.byType(AnnotationMarker), findsOneWidget);

      // Trigger hideUntilRestart
      controller.setHideUntilRestart(true);
      await tester.pumpAndSettle();

      // Toolbar is removed from overlay Child
      expect(find.byType(AgentationToolbar), findsNothing);
      // Markers are hidden
      expect(find.byType(AnnotationMarker), findsNothing);
      // isToolbarHidden is true
      expect(controller.isToolbarHidden, isTrue);
      expect(controller.shouldShowMarkers, isFalse);
    });
  });
}
