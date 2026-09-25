import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/core/agentation_scope.dart';
import 'package:flutter_agentation/src/models/marker_color.dart';
import 'package:flutter_agentation/src/storage/memory_annotation_storage.dart';
import 'package:flutter_agentation/src/toolbar/settings_panel.dart';

void main() {
  group('SettingsPanel Widget & Parity Theming', () {
    late MemoryAnnotationStorage storage;
    late AgentationController controller;

    setUp(() {
      storage = MemoryAnnotationStorage();
      controller = AgentationController(storage: storage);
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders theme toggle, all 6 marker color swatches, and behavior switches',
        (tester) async {
      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentationScope(
              controller: controller,
              child: SettingsPanel(
                onClose: () => closed = true,
              ),
            ),
          ),
        ),
      );

      // Verify title & close button
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      // Verify Theme selector exists
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);

      // Verify all 6 color swatches exist by tooltip or label
      for (final color in MarkerColor.values) {
        expect(find.byTooltip(color.label), findsOneWidget);
      }

      // Verify behavior toggles exist
      expect(find.text('Clear after copy'), findsOneWidget);
      expect(find.text('Block page interactions'), findsOneWidget);

      // Verify Automations sub-panel exists
      expect(find.text('Automations & MCP Sync'), findsOneWidget);

      // Verify close callback
      await tester.tap(find.byIcon(Icons.close));
      expect(closed, isTrue);
    });

    testWidgets('selecting marker color swatch updates controller settings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentationScope(
              controller: controller,
              child: SettingsPanel(onClose: () {}),
            ),
          ),
        ),
      );

      expect(controller.settings.markerColorId, equals('indigo'));

      // Tap Emerald swatch
      final emeraldFinder = find.byTooltip('Emerald');
      expect(emeraldFinder, findsOneWidget);
      await tester.tap(emeraldFinder);
      await tester.pumpAndSettle();

      expect(controller.settings.markerColorId, equals('emerald'));

      // Tap Rose swatch
      final roseFinder = find.byTooltip('Rose');
      expect(roseFinder, findsOneWidget);
      await tester.tap(roseFinder);
      await tester.pumpAndSettle();

      expect(controller.settings.markerColorId, equals('rose'));
    });

    testWidgets('toggling theme updates controller dark mode setting', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentationScope(
              controller: controller,
              child: SettingsPanel(onClose: () {}),
            ),
          ),
        ),
      );

      expect(controller.settings.isDarkMode, isTrue);

      // Tap Light mode toggle
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();

      expect(controller.settings.isDarkMode, isFalse);

      // Tap Dark mode toggle
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(controller.settings.isDarkMode, isTrue);
    });

    testWidgets('toggling behavior options updates controller settings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentationScope(
              controller: controller,
              child: SettingsPanel(onClose: () {}),
            ),
          ),
        ),
      );

      expect(controller.settings.autoClearAfterCopy, isFalse);
      expect(controller.settings.blockInteractions, isTrue);

      // Toggle auto-clear checkbox
      final autoClearFinder = find.byKey(const ValueKey('toggle_auto_clear'));
      expect(autoClearFinder, findsOneWidget);
      await tester.tap(autoClearFinder);
      await tester.pumpAndSettle();

      expect(controller.settings.autoClearAfterCopy, isTrue);

      // Toggle block interactions
      final blockFinder = find.byKey(const ValueKey('toggle_block_interactions'));
      expect(blockFinder, findsOneWidget);
      await tester.tap(blockFinder);
      await tester.pumpAndSettle();

      expect(controller.settings.blockInteractions, isFalse);
    });
  });
}
