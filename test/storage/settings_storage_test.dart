import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/core/agentation_widget.dart';
import 'package:flutter_agentation/src/domain/marker_color.dart';
import 'package:flutter_agentation/src/domain/toolbar_settings.dart';
import 'package:flutter_agentation/src/storage/settings_storage_io.dart' as io_storage;
import 'package:flutter_agentation/src/storage/settings_storage_stub.dart' as stub_storage;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Cross-Platform Settings Storage & Persistence Test Suite', () {
    setUp(() {
      AgentationController.resetPersistedSettings();
      io_storage.debugForceDiskIo = false;
    });

    tearDown(() {
      AgentationController.resetPersistedSettings();
      io_storage.debugForceDiskIo = false;
      io_storage.clearStoredSettings();
    });

    group('ToolbarSettings JSON parity & serialization', () {
      test('serializes all 14 setting fields to JSON and deserializes accurately', () {
        const settings = ToolbarSettings(
          outputDetail: OutputDetailLevel.forensic,
          copyFormat: CopyFormat.markdown,
          isDarkMode: false,
          markerColorId: 'emerald',
          autoClearAfterCopy: true,
          blockInteractions: false,
          flutterComponentsEnabled: false,
          hideUntilRestart: true,
          mcpEndpoint: 'http://localhost:4747',
          sessionId: 'test-session-123',
          webhookUrl: 'https://webhook.site/test',
          mcpEnabled: true,
          mcpPort: 4848,
          autoSendWebhook: true,
          autoSendMcp: false,
        );

        final json = settings.toJson();

        expect(json['outputDetail'], equals('forensic'));
        expect(json['copyFormat'], equals('markdown'));
        expect(json['isDarkMode'], isFalse);
        expect(json['markerColorId'], equals('emerald'));
        expect(json['autoClearAfterCopy'], isTrue);
        expect(json['blockInteractions'], isFalse);
        expect(json['flutterComponentsEnabled'], isFalse);
        expect(json['mcpEndpoint'], equals('http://localhost:4747'));
        expect(json['sessionId'], equals('test-session-123'));
        expect(json['webhookUrl'], equals('https://webhook.site/test'));
        expect(json['mcpEnabled'], isTrue);
        expect(json['mcpPort'], equals(4848));
        expect(json['autoSendWebhook'], isTrue);
        expect(json['autoSendMcp'], isFalse);
        // hideUntilRestart is intentionally excluded from persisted JSON
        expect(json.containsKey('hideUntilRestart'), isFalse);

        final restored = ToolbarSettings.fromJson(json);

        expect(restored.outputDetail, equals(OutputDetailLevel.forensic));
        expect(restored.copyFormat, equals(CopyFormat.markdown));
        expect(restored.isDarkMode, isFalse);
        expect(restored.markerColorId, equals('emerald'));
        expect(restored.autoClearAfterCopy, isTrue);
        expect(restored.blockInteractions, isFalse);
        expect(restored.flutterComponentsEnabled, isFalse);
        expect(restored.mcpEndpoint, equals('http://localhost:4747'));
        expect(restored.sessionId, equals('test-session-123'));
        expect(restored.webhookUrl, equals('https://webhook.site/test'));
        expect(restored.mcpEnabled, isTrue);
        expect(restored.mcpPort, equals(4848));
        expect(restored.autoSendWebhook, isTrue);
        expect(restored.autoSendMcp, isFalse);
        // hideUntilRestart resets to false on restart
        expect(restored.hideUntilRestart, isFalse);
      });

      test('supports all OutputDetailLevel and CopyFormat enum variants', () {
        for (final detail in OutputDetailLevel.values) {
          final json = ToolbarSettings(outputDetail: detail).toJson();
          final restored = ToolbarSettings.fromJson(json);
          expect(restored.outputDetail, equals(detail));
        }

        for (final format in CopyFormat.values) {
          final json = ToolbarSettings(copyFormat: format).toJson();
          final restored = ToolbarSettings.fromJson(json);
          expect(restored.copyFormat, equals(format));
        }

        for (final color in MarkerColor.values) {
          final json = ToolbarSettings(markerColorId: color.id).toJson();
          final restored = ToolbarSettings.fromJson(json);
          expect(restored.markerColorId, equals(color.id));
        }
      });

      test('mergeFromJson updates only present keys and leaves unspecified keys intact', () {
        const initial = ToolbarSettings(
          isDarkMode: true,
          markerColorId: 'cyan',
          blockInteractions: true,
          mcpEnabled: true,
          mcpPort: 4747,
        );

        final merged = initial.mergeFromJson({
          'isDarkMode': false,
          'markerColorId': 'rose',
        });

        expect(merged.isDarkMode, isFalse);
        expect(merged.markerColorId, equals('rose'));
        // Unspecified keys retain original values
        expect(merged.blockInteractions, isTrue);
        expect(merged.mcpEnabled, isTrue);
        expect(merged.mcpPort, equals(4747));
      });
    });

    group('Physical Disk IO Persistence (settings_storage_io.dart)', () {
      test('writes settings to physical file on disk and reads back', () {
        io_storage.debugForceDiskIo = true;

        final testData = {
          'isDarkMode': false,
          'markerColorId': 'amber',
          'mcpEnabled': false,
          'autoSendMcp': false,
          'webhookUrl': 'https://api.example.com/agent',
        };

        io_storage.saveStoredSettings(testData);

        final loaded = io_storage.loadStoredSettings();
        expect(loaded, isNotNull);
        expect(loaded!['isDarkMode'], isFalse);
        expect(loaded['markerColorId'], equals('amber'));
        expect(loaded['mcpEnabled'], isFalse);
        expect(loaded['autoSendMcp'], isFalse);
        expect(loaded['webhookUrl'], equals('https://api.example.com/agent'));

        // Test marker color convenience methods directly on physical disk
        expect(io_storage.loadStoredMarkerColor(), equals('amber'));
        io_storage.saveStoredMarkerColor('rose');
        expect(io_storage.loadStoredMarkerColor(), equals('rose'));

        // Clear settings deletes the file
        io_storage.clearStoredSettings();
        expect(io_storage.loadStoredSettings(), isNull);
        expect(io_storage.loadStoredMarkerColor(), isNull);
      });

      test('gracefully handles corrupted or malformed file on disk without crash', () {
        io_storage.debugForceDiskIo = true;

        final tempDir = Directory.systemTemp.path;
        final file = File('$tempDir/flutter_agentation_settings.json');
        file.writeAsStringSync('MALFORMED_NON_JSON_CONTENT{{{');

        // Should not throw, returns null
        expect(io_storage.loadStoredSettings(), isNull);
        expect(io_storage.loadStoredMarkerColor(), isNull);

        // Saving over corrupted file repairs it cleanly
        io_storage.saveStoredSettings({'markerColorId': 'blue'});
        expect(io_storage.loadStoredMarkerColor(), equals('blue'));

        file.deleteSync();
      });
    });

    group('Stub / Fallback Platform Storage (settings_storage_stub.dart)', () {
      test('stub methods execute safely without errors or unhandled exceptions', () {
        expect(stub_storage.loadStoredSettings(), isNull);
        expect(stub_storage.loadStoredMarkerColor(), isNull);

        // Safe no-ops
        stub_storage.saveStoredSettings({'isDarkMode': true});
        stub_storage.saveStoredMarkerColor('blue');
        stub_storage.clearStoredSettings();
        stub_storage.clearStoredMarkerColor();

        expect(stub_storage.loadStoredSettings(), isNull);
      });
    });

    group('Full Controller & Widget Restart Lifecycle', () {
      test('all settings persist across complete AgentationController restart', () {
        final controller = AgentationController();

        // Verify clean default state
        expect(controller.settings.isDarkMode, isTrue);
        expect(controller.settings.outputDetail, equals(OutputDetailLevel.standard));
        expect(controller.settings.copyFormat, equals(CopyFormat.feedback));
        expect(controller.settings.markerColorId, equals('blue'));
        expect(controller.settings.autoClearAfterCopy, isFalse);
        expect(controller.settings.blockInteractions, isTrue);
        expect(controller.settings.mcpEnabled, isFalse);
        expect(controller.settings.mcpPort, equals(4747));
        expect(controller.settings.autoSendMcp, isTrue);
        expect(controller.settings.autoSendWebhook, isFalse);
        expect(controller.settings.webhookUrl, isNull);

        // Mutate EVERY setting
        controller.toggleTheme(); // isDarkMode -> false
        controller.setDetailLevel(OutputDetailLevel.compact);
        controller.setCopyFormat(CopyFormat.agentationJson);
        controller.setMarkerColorId('purple');
        controller.updateSettings(
          controller.settings.copyWith(
            autoClearAfterCopy: true,
            blockInteractions: false,
            mcpEnabled: true,
            mcpPort: 5050,
            mcpEndpoint: 'http://127.0.0.1:5050',
            sessionId: 'session-persist-test',
            webhookUrl: 'https://webhook.local/dispatch',
            autoSendWebhook: true,
            autoSendMcp: false,
            hideUntilRestart: true,
          ),
        );

        // Verify state is stored in memory and storage
        expect(controller.settings.isDarkMode, isFalse);
        expect(controller.settings.outputDetail, equals(OutputDetailLevel.compact));
        expect(controller.settings.copyFormat, equals(CopyFormat.agentationJson));
        expect(controller.settings.markerColorId, equals('purple'));
        expect(controller.settings.autoClearAfterCopy, isTrue);
        expect(controller.settings.blockInteractions, isFalse);
        expect(controller.settings.mcpEnabled, isTrue);
        expect(controller.settings.mcpPort, equals(5050));
        expect(controller.settings.mcpEndpoint, equals('http://127.0.0.1:5050'));
        expect(controller.settings.sessionId, equals('session-persist-test'));
        expect(controller.settings.webhookUrl, equals('https://webhook.local/dispatch'));
        expect(controller.settings.autoSendWebhook, isTrue);
        expect(controller.settings.autoSendMcp, isFalse);
        expect(controller.settings.hideUntilRestart, isTrue);

        controller.dispose();

        // Simulate application hot restart: new controller instance created
        final restartedController = AgentationController();

        expect(restartedController.settings.isDarkMode, isFalse);
        expect(restartedController.settings.outputDetail, equals(OutputDetailLevel.compact));
        expect(restartedController.settings.copyFormat, equals(CopyFormat.agentationJson));
        expect(restartedController.settings.markerColorId, equals('purple'));
        expect(restartedController.settings.autoClearAfterCopy, isTrue);
        expect(restartedController.settings.blockInteractions, isFalse);
        expect(restartedController.settings.mcpEnabled, isTrue);
        expect(restartedController.settings.mcpPort, equals(5050));
        expect(restartedController.settings.mcpEndpoint, equals('http://127.0.0.1:5050'));
        expect(restartedController.settings.sessionId, equals('session-persist-test'));
        expect(restartedController.settings.webhookUrl, equals('https://webhook.local/dispatch'));
        expect(restartedController.settings.autoSendWebhook, isTrue);
        expect(restartedController.settings.autoSendMcp, isFalse);
        // hideUntilRestart must cleanly reset to false
        expect(restartedController.settings.hideUntilRestart, isFalse);

        restartedController.dispose();
      });

      testWidgets('FlutterAgentation widget preserves all settings across reassemble and hot restart', (tester) async {
        final controller = AgentationController();
        controller.updateSettings(
          controller.settings.copyWith(
            isDarkMode: false,
            markerColorId: 'cyan',
            outputDetail: OutputDetailLevel.detailed,
            autoClearAfterCopy: true,
            blockInteractions: false,
            mcpEnabled: false,
            autoSendMcp: false,
            autoSendWebhook: true,
            webhookUrl: 'https://persisted.test.com/hook',
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: FlutterAgentation(
              controller: controller,
              child: const Scaffold(body: Text('Active App')),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Trigger reassemble (Hot Reload)
        tester.binding.reassembleApplication();
        await tester.pumpAndSettle();

        expect(controller.settings.isDarkMode, isFalse);
        expect(controller.settings.markerColorId, equals('cyan'));
        expect(controller.settings.outputDetail, equals(OutputDetailLevel.detailed));
        expect(controller.settings.autoClearAfterCopy, isTrue);
        expect(controller.settings.blockInteractions, isFalse);
        expect(controller.settings.mcpEnabled, isFalse);
        expect(controller.settings.autoSendMcp, isFalse);
        expect(controller.settings.autoSendWebhook, isTrue);
        expect(controller.settings.webhookUrl, equals('https://persisted.test.com/hook'));

        // Mount new widget with fresh controller (Hot Restart)
        final restartedController = AgentationController();
        await tester.pumpWidget(
          MaterialApp(
            home: FlutterAgentation(
              controller: restartedController,
              child: const Scaffold(body: Text('Restarted App')),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(restartedController.settings.isDarkMode, isFalse);
        expect(restartedController.settings.markerColorId, equals('cyan'));
        expect(restartedController.settings.outputDetail, equals(OutputDetailLevel.detailed));
        expect(restartedController.settings.autoClearAfterCopy, isTrue);
        expect(restartedController.settings.blockInteractions, isFalse);
        expect(restartedController.settings.mcpEnabled, isFalse);
        expect(restartedController.settings.autoSendMcp, isFalse);
        expect(restartedController.settings.autoSendWebhook, isTrue);
        expect(restartedController.settings.webhookUrl, equals('https://persisted.test.com/hook'));

        restartedController.dispose();
      });
    });
  });
}
