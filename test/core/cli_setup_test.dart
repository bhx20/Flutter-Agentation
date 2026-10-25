import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import '../../bin/setup.dart' as setup;
import '../../bin/setupmcp.dart' as setupmcp;
import '../../bin/setup_mcp.dart' as setup_mcp;

void main() {
  group('CLI Setupmcp Command Tests', () {
    test('setupmcp creates .flutter_agentation workspace directory and does not create other agent directories', () async {
      final originalDir = Directory.current;
      final tempDir = Directory.systemTemp.createTempSync('agentation_cli_test_');

      try {
        Directory.current = tempDir;
        setupmcp.main(['--port=4848']);

        // 1. Central .flutter_agentation/ directory
        final agentationDir = Directory('${tempDir.path}/.flutter_agentation');
        expect(agentationDir.existsSync(), isTrue);

        // 1a. .flutter_agentation/mcp.json
        final mcpFile = File('${tempDir.path}/.flutter_agentation/mcp.json');
        expect(mcpFile.existsSync(), isTrue);
        final mcpData = jsonDecode(mcpFile.readAsStringSync());
        expect(mcpData['mcpServers']['flutter-agentation']['url'], equals('http://127.0.0.1:4848/sse'));

        // 1b. .flutter_agentation/config.json
        final configFile = File('${tempDir.path}/.flutter_agentation/config.json');
        expect(configFile.existsSync(), isTrue);
        final configData = jsonDecode(configFile.readAsStringSync());
        expect(configData['port'], equals(4848));
        expect(configData['endpoints']['sse'], equals('http://127.0.0.1:4848/sse'));

        // 1c. .flutter_agentation/tools.json
        final toolsFile = File('${tempDir.path}/.flutter_agentation/tools.json');
        expect(toolsFile.existsSync(), isTrue);
        final toolsData = jsonDecode(toolsFile.readAsStringSync());
        expect(toolsData['tools'], isNotEmpty);
        expect((toolsData['tools'] as List).any((t) => t['name'] == 'agentation_get_all_pending'), isTrue);

        // 1d. .flutter_agentation/llm_instructions.md
        final instructionsFile = File('${tempDir.path}/.flutter_agentation/llm_instructions.md');
        expect(instructionsFile.existsSync(), isTrue);
        final instructionsContent = instructionsFile.readAsStringSync();
        expect(instructionsContent, contains('agentation_get_all_pending'));
        expect(instructionsContent, contains('4848'));

        // 2. Ensure NO external agent directories were created in root
        expect(Directory('${tempDir.path}/.cursor').existsSync(), isFalse);
        expect(Directory('${tempDir.path}/.vscode').existsSync(), isFalse);
        expect(Directory('${tempDir.path}/.windsurf').existsSync(), isFalse);
        expect(Directory('${tempDir.path}/.agents').existsSync(), isFalse);
      } finally {
        Directory.current = originalDir;
        try {
          tempDir.deleteSync(recursive: true);
        } catch (_) {}
      }
    });

    test('setup and setup_mcp aliases work identically to setupmcp', () async {
      final originalDir = Directory.current;
      final tempDir = Directory.systemTemp.createTempSync('setup_alias_test_');

      try {
        Directory.current = tempDir;
        setup.main(['--port=4949']);

        final mcpFile = File('${tempDir.path}/.flutter_agentation/mcp.json');
        expect(mcpFile.existsSync(), isTrue);
        final mcpData = jsonDecode(mcpFile.readAsStringSync());
        expect(mcpData['mcpServers']['flutter-agentation']['url'], equals('http://127.0.0.1:4949/sse'));

        setup_mcp.main(['--port=5050']);
        final updatedData = jsonDecode(mcpFile.readAsStringSync());
        expect(updatedData['mcpServers']['flutter-agentation']['url'], equals('http://127.0.0.1:5050/sse'));
      } finally {
        Directory.current = originalDir;
        try {
          tempDir.deleteSync(recursive: true);
        } catch (_) {}
      }
    });
  });
}
