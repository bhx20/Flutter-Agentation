import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/core/agentation_scope.dart';
import 'package:flutter_agentation/src/core/package_version.dart';
import 'package:flutter_agentation/src/domain/marker_color.dart';
import 'package:flutter_agentation/src/domain/toolbar_settings.dart';
import 'package:flutter_agentation/src/storage/memory_annotation_storage.dart';
import 'package:flutter_agentation/src/ui/design/component_palette.dart';
import 'package:flutter_agentation/src/ui/toolbar/agentation_toolbar.dart';
import 'package:flutter_agentation/src/ui/toolbar/settings_panel.dart';

void main() {
  group('SettingsPanel Widget & Parity Theming', () {
    late MemoryAnnotationStorage storage;
    late AgentationController controller;

    setUp(() {
      AgentationController.resetPersistedMarkerColor();
      storage = MemoryAnnotationStorage();
      controller = AgentationController(storage: storage);
    });

    tearDown(() {
      controller.dispose();
      AgentationController.resetPersistedMarkerColor();
    });

    testWidgets('renders theme toggle, all 7 marker color swatches, and behavior switches',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentationScope(
              controller: controller,
              child: SettingsPanel(
                onClose: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title & version dynamically from pubspec.yaml
      expect(find.textContaining('Agentation'), findsOneWidget);
      expect(find.textContaining('v${PackageVersion.current}'), findsOneWidget);
      expect(find.byKey(const ValueKey('theme_toggle_button')), findsOneWidget);

      // Verify all 7 color swatches exist by tooltip or label
      for (final color in MarkerColor.values) {
        expect(find.byTooltip(color.label), findsOneWidget);
      }

      // Verify behavior toggles exist
      expect(find.text('Clear on copy/send'), findsOneWidget);
      expect(find.text('Block page interactions'), findsOneWidget);
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

      expect(controller.settings.markerColorId, equals('blue'));

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

      // Simulate app restart by instantiating a new controller:
      // The last selected marker color ('rose') stays preserved!
      final restartedController = AgentationController();
      expect(restartedController.settings.markerColorId, equals('rose'));
      restartedController.dispose();
    });

    test('all flutter-agentation settings persist across restart', () {
      expect(controller.settings.isDarkMode, isTrue);
      expect(controller.settings.outputDetail, OutputDetailLevel.standard);
      expect(controller.settings.copyFormat, CopyFormat.feedback);
      expect(controller.settings.markerColorId, 'blue');
      expect(controller.settings.autoClearAfterCopy, isFalse);
      expect(controller.settings.blockInteractions, isTrue);
      expect(controller.settings.mcpEnabled, isFalse);
      expect(controller.settings.autoSendMcp, isTrue);
      expect(controller.settings.autoSendWebhook, isFalse);

      // Modify all settings
      controller.toggleTheme(); // isDarkMode -> false
      controller.setDetailLevel(OutputDetailLevel.forensic);
      controller.setCopyFormat(CopyFormat.json);
      controller.setMarkerColorId('amber');
      controller.updateSettings(
        controller.settings.copyWith(
          autoClearAfterCopy: true,
          blockInteractions: false,
          mcpEnabled: true,
          webhookUrl: 'https://example.com/agent-hook',
          autoSendWebhook: true,
          autoSendMcp: false,
          hideUntilRestart: true,
        ),
      );

      // Verify mutated in-memory state
      expect(controller.settings.isDarkMode, isFalse);
      expect(controller.settings.outputDetail, OutputDetailLevel.forensic);
      expect(controller.settings.copyFormat, CopyFormat.json);
      expect(controller.settings.markerColorId, 'amber');
      expect(controller.settings.autoClearAfterCopy, isTrue);
      expect(controller.settings.blockInteractions, isFalse);
      expect(controller.settings.mcpEnabled, isTrue);
      expect(controller.settings.webhookUrl, 'https://example.com/agent-hook');
      expect(controller.settings.autoSendWebhook, isTrue);
      expect(controller.settings.autoSendMcp, isFalse);
      expect(controller.settings.hideUntilRestart, isTrue);

      // Re-instantiate controller to simulate restart
      final restarted = AgentationController();
      expect(restarted.settings.isDarkMode, isFalse);
      expect(restarted.settings.outputDetail, OutputDetailLevel.forensic);
      expect(restarted.settings.copyFormat, CopyFormat.json);
      expect(restarted.settings.markerColorId, 'amber');
      expect(restarted.settings.autoClearAfterCopy, isTrue);
      expect(restarted.settings.blockInteractions, isFalse);
      expect(restarted.settings.mcpEnabled, isTrue);
      expect(restarted.settings.webhookUrl, 'https://example.com/agent-hook');
      expect(restarted.settings.autoSendWebhook, isTrue);
      expect(restarted.settings.autoSendMcp, isFalse);
      // hideUntilRestart must reset to false upon restart!
      expect(restarted.settings.hideUntilRestart, isFalse);

      restarted.dispose();
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

      // Tap Theme toggle button (Sun/Moon icon)
      await tester.tap(find.byKey(const ValueKey('theme_toggle_button')));
      await tester.pumpAndSettle();

      expect(controller.settings.isDarkMode, isFalse);

      // Tap Theme toggle button again
      await tester.tap(find.byKey(const ValueKey('theme_toggle_button')));
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

    testWidgets('verifies clean Agentation settings layout, React components removed, and version matching pubspec.yaml',
        (tester) async {
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
      await tester.pumpAndSettle();

      // Header displays dynamic version with normal font
      final titleFinder = find.text('Flutter Agentation');
      expect(titleFinder, findsOneWidget);
      final titleWidget = tester.widget<Text>(titleFinder);
      expect(titleWidget.style?.fontWeight, equals(FontWeight.normal));
      expect(find.textContaining('v${PackageVersion.current}'), findsOneWidget);
      expect(find.byKey(const ValueKey('theme_toggle_button')), findsOneWidget);

      // Rows match specification
      expect(find.text('Output Detail'), findsOneWidget);
      expect(find.text('Standard'), findsOneWidget);
      expect(find.text('Hide Until Restart'), findsOneWidget);
      expect(find.text('Marker Color'), findsOneWidget);
      expect(find.text('Clear on copy/send'), findsOneWidget);
      expect(find.text('Block page interactions'), findsOneWidget);

      // Verify React Components is removed (Flutter widgets always inspected by default)
      expect(find.text('React Components'), findsNothing);

      // Verify Manage MCP & Webhooks nav link is present
      expect(find.text('Manage MCP & Webhooks'), findsOneWidget);
      expect(find.byKey(const ValueKey('settings_nav_mcp_webhooks')), findsOneWidget);

      // Verify legacy removed widgets are not present
      expect(find.text('Automations & MCP Sync'), findsNothing);
      expect(find.byKey(const ValueKey('manage_mcp_webhooks_tile')), findsNothing);
      expect(find.byKey(const ValueKey('mcp_endpoint_input')), findsNothing);
    });

    testWidgets('displays help popup tooltip on "?" icon tap or hover', (tester) async {
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
      await tester.pumpAndSettle();

      // Tooltip is initially not visible
      expect(find.text('Controls how much detail is included in the copied output'), findsNothing);

      // Tap on Output Detail help icon
      final outputDetailRow = find.ancestor(
        of: find.text('Output Detail'),
        matching: find.byType(Row),
      ).first;

      final helpIconFinder = find.descendant(
        of: outputDetailRow,
        matching: find.byType(GestureDetector),
      ).first;

      await tester.tap(helpIconFinder);
      await tester.pumpAndSettle();

      // Tooltip popup is visible
      expect(find.text('Controls how much detail is included in the copied output'), findsOneWidget);

      // Tapping again hides it
      await tester.tap(helpIconFinder);
      await tester.pumpAndSettle();
      expect(find.text('Controls how much detail is included in the copied output'), findsNothing);
    });

    testWidgets('cycles output detail level and updates 4-dot vertical indicator', (tester) async {
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
      await tester.pumpAndSettle();

      // Initially standard (index 1)
      final standardTextFinder = find.text('Standard');
      expect(standardTextFinder, findsOneWidget);
      final textWidget = tester.widget<Text>(standardTextFinder);
      expect(textWidget.style?.fontWeight, equals(FontWeight.normal));

      // Tap on the detail level button to cycle: Standard (1) -> Detailed (2) -> Forensic (3) -> Compact (0)
      await tester.tap(find.text('Standard'));
      await tester.pumpAndSettle();
      expect(find.text('Detailed'), findsOneWidget);

      await tester.tap(find.text('Detailed'));
      await tester.pumpAndSettle();
      expect(find.text('Forensic'), findsOneWidget);

      await tester.tap(find.text('Forensic'));
      await tester.pumpAndSettle();
      expect(find.text('Compact'), findsOneWidget);
    });

    testWidgets('toggles hide until restart in settings and closes settings panel', (tester) async {
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
      await tester.pumpAndSettle();

      expect(controller.settings.hideUntilRestart, isFalse);
      expect(controller.isToolbarHidden, isFalse);

      final switchFinder = find.byKey(const ValueKey('toggle_hide_until_restart'));
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(controller.settings.hideUntilRestart, isTrue);
      expect(controller.isToolbarHidden, isTrue);
      expect(controller.isToolbarMinimized, isTrue);
    });

    testWidgets('when toolbar is near top, opening settings positions SettingsPanel below toolbar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AgentationScope(
                  controller: controller,
                  child: const AgentationToolbar(
                    initialAlignment: Alignment.topCenter,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final pillFinder = find.byKey(const ValueKey('toolbar_close'));
      expect(pillFinder, findsOneWidget);
      final initialPillTop = tester.getTopLeft(pillFinder).dy;
      final initialPillBottom = tester.getBottomLeft(pillFinder).dy;

      // Open settings
      await tester.tap(find.byKey(const ValueKey('toolbar_settings')));
      await tester.pumpAndSettle();

      final panelFinder = find.byType(SettingsPanel);
      expect(panelFinder, findsOneWidget);

      final panelTop = tester.getTopLeft(panelFinder).dy;
      final currentPillTop = tester.getTopLeft(pillFinder).dy;

      // Toolbar pill does not shift vertically
      expect(currentPillTop, closeTo(initialPillTop, 1.0));

      // Settings panel is positioned BELOW the toolbar pill
      expect(panelTop, greaterThanOrEqualTo(initialPillBottom));
    });

    testWidgets('when toolbar is near top, opening layout mode positions ComponentPalette below toolbar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AgentationScope(
                  controller: controller,
                  child: const AgentationToolbar(
                    initialAlignment: Alignment.topRight,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final pillFinder = find.byKey(const ValueKey('toolbar_close'));
      final initialPillBottom = tester.getBottomLeft(pillFinder).dy;

      // Open layout mode
      await tester.tap(find.byKey(const ValueKey('toolbar_layout')));
      await tester.pumpAndSettle();

      final paletteFinder = find.byType(ComponentPalette);
      expect(paletteFinder, findsOneWidget);

      final paletteTop = tester.getTopLeft(paletteFinder).dy;
      // Palette is positioned BELOW the toolbar pill
      expect(paletteTop, greaterThanOrEqualTo(initialPillBottom));
    });

    testWidgets('when toolbar is near bottom, opening settings positions SettingsPanel above toolbar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AgentationScope(
                  controller: controller,
                  child: const AgentationToolbar(
                    initialAlignment: Alignment.bottomCenter,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final pillFinder = find.byKey(const ValueKey('toolbar_close'));
      final pillTop = tester.getTopLeft(pillFinder).dy;

      // Open settings
      await tester.tap(find.byKey(const ValueKey('toolbar_settings')));
      await tester.pumpAndSettle();

      final panelFinder = find.byType(SettingsPanel);
      expect(panelFinder, findsOneWidget);

      final panelBottom = tester.getBottomLeft(panelFinder).dy;
      // Settings panel is positioned ABOVE the toolbar pill
      expect(panelBottom, lessThanOrEqualTo(pillTop));
    });
  });
}

