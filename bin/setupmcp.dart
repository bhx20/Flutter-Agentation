// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'mcp.dart' as mcp;

void main(List<String> args) async {
  if (args.contains('--serve') || args.contains('-s') || args.contains('serve')) {
    await mcp.main(args);
    return;
  }

  int port = 4747;

  for (int i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--port' && i + 1 < args.length) {
      port = int.tryParse(args[i + 1]) ?? 4747;
    } else if (arg.startsWith('--port=')) {
      port = int.tryParse(arg.split('=')[1]) ?? 4747;
    }
  }

  print('');
  print('\x1B[1m\x1B[36m╭─────────────────────────────────────────────────────────────╮\x1B[0m');
  print('\x1B[1m\x1B[36m│              Flutter Agentation MCP Server Setup            │\x1B[0m');
  print('\x1B[1m\x1B[36m╰─────────────────────────────────────────────────────────────╯\x1B[0m');
  print('');

  final currentDir = Directory.current.path;
  final sseUrl = 'http://127.0.0.1:$port/sse';
  final httpUrl = 'http://127.0.0.1:$port/mcp';
  final statusUrl = 'http://127.0.0.1:$port/status';

  print('Workspace:    $currentDir');
  print('MCP Protocol: Model Context Protocol (JSON-RPC 2.0 via SSE)');
  print('SSE Endpoint: $sseUrl\n');

  // ── Create Centralized .flutter_agentation/ Directory in Project Root ──
  final agentationDir = Directory('${Directory.current.path}/.flutter_agentation');
  if (!agentationDir.existsSync()) {
    agentationDir.createSync(recursive: true);
  }

  // 1. Central MCP configuration: .flutter_agentation/mcp.json
  final mcpConfig = {
    'mcpServers': {
      'flutter-agentation': {
        'url': sseUrl,
        'description': 'Flutter Agentation visual inspection and annotation server for AI coding agents',
      },
    },
  };
  _writeJsonFile('${agentationDir.path}/mcp.json', mcpConfig);
  print('\x1B[32m  ✓ Created .flutter_agentation/mcp.json (Central MCP Config)\x1B[0m');

  // 2. Environment & metadata: .flutter_agentation/config.json
  final runtimeConfig = {
    'name': 'flutter-agentation',
    'version': '0.0.1',
    'port': port,
    'endpoints': {
      'sse': sseUrl,
      'http': httpUrl,
      'status': statusUrl,
      'pending': 'http://127.0.0.1:$port/pending',
      'sessions': 'http://127.0.0.1:$port/sessions',
    },
    'timestamp': DateTime.now().toIso8601String(),
  };
  _writeJsonFile('${agentationDir.path}/config.json', runtimeConfig);
  print('\x1B[32m  ✓ Generated .flutter_agentation/config.json (Runtime Endpoints)\x1B[0m');

  // 3. Tool Schemas for LLM function calling: .flutter_agentation/tools.json
  final toolsSchema = _buildToolsSchema(port);
  _writeJsonFile('${agentationDir.path}/tools.json', toolsSchema);
  print('\x1B[32m  ✓ Exported .flutter_agentation/tools.json (LLM Function Call Schemas)\x1B[0m');

  // 4. Instructions for LLMs / Agents: .flutter_agentation/llm_instructions.md
  _writeLlmInstructions('${agentationDir.path}/llm_instructions.md', port, sseUrl);
  print('\x1B[32m  ✓ Created .flutter_agentation/llm_instructions.md (LLM System Prompt & Context)\x1B[0m');

  // Check and configure Android ADB port forwarding if ADB is available
  try {
    final adbCheck = Process.runSync(
      Platform.isWindows ? 'where' : 'which',
      ['adb'],
      runInShell: true,
    );
    if (adbCheck.exitCode == 0) {
      final forwardResult = Process.runSync(
        'adb',
        ['forward', 'tcp:$port', 'tcp:$port'],
        runInShell: true,
      );
      if (forwardResult.exitCode == 0) {
        print('\x1B[32m  ✓ Configured Android ADB port forward: adb forward tcp:$port tcp:$port\x1B[0m');
      }
    }
  } catch (_) {}

  print('');
  print('\x1B[32m✔ .flutter_agentation workspace directory configured successfully!\x1B[0m');
  print('');
  print('How to connect your AI agent:');
  print('  • MCP Config File: \x1B[1m.flutter_agentation/mcp.json\x1B[0m');
  print('  • SSE Endpoint:    \x1B[36m$sseUrl\x1B[0m');
  print('  • Point your IDE (Cursor, Claude, Windsurf, VS Code) to .flutter_agentation/mcp.json');
  print('');
  print('Supported Platforms:');
  print('  • Windows:         flutter run -d windows (direct connection)');
  print('  • Android:         flutter run -d <device> (auto-forwarded or run "adb forward tcp:$port tcp:$port")');
  print('  • iOS Simulator:   flutter run -d <simulator> (direct connection)');
  print('  • iOS Device:      flutter run -d <device> (connect via local Wi-Fi IP)');
  print('  • Linux:           flutter run -d linux (direct connection)');
  print('  • macOS:           flutter run -d macos (direct connection)');
  print('  • Web (Chrome):    Use built-in Webhook dispatcher in toolbar settings\n');
}

void _writeJsonFile(String path, Map<String, dynamic> data) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  const encoder = JsonEncoder.withIndent('  ');
  file.writeAsStringSync('${encoder.convert(data)}\n');
}

Map<String, dynamic> _buildToolsSchema(int port) {
  return {
    'version': '1.0',
    'transport': 'sse',
    'url': 'http://127.0.0.1:$port/sse',
    'tools': [
      {
        'name': 'agentation_get_all_pending',
        'description': 'Retrieves all pending annotations from the active Flutter application inspection canvas.',
        'parameters': {
          'type': 'object',
          'properties': {
            'format': {
              'type': 'string',
              'enum': ['json', 'markdown'],
              'description': 'Output format (json or markdown table). Defaults to json.',
            },
          },
        },
      },
      {
        'name': 'agentation_reply',
        'description': 'Appends an AI agent response into an existing annotation thread in the Flutter UI.',
        'parameters': {
          'type': 'object',
          'required': ['id', 'message'],
          'properties': {
            'id': {'type': 'string', 'description': 'The annotation ID.'},
            'message': {'type': 'string', 'description': 'The reply message text.'},
          },
        },
      },
      {
        'name': 'agentation_resolve',
        'description': 'Resolves and clears an annotation once the requested code fix or inspection change has been completed.',
        'parameters': {
          'type': 'object',
          'required': ['id'],
          'properties': {
            'id': {'type': 'string', 'description': 'The annotation ID to resolve.'},
          },
        },
      },
      {
        'name': 'agentation_create_annotation',
        'description': 'Programmatically creates a new visual annotation card at specified screen coordinates in the Flutter app.',
        'parameters': {
          'type': 'object',
          'required': ['comment', 'x', 'y'],
          'properties': {
            'comment': {'type': 'string', 'description': 'Annotation comment text.'},
            'x': {'type': 'number', 'description': 'Global X coordinate.'},
            'y': {'type': 'number', 'description': 'Global Y coordinate.'},
            'element': {'type': 'string', 'description': 'Target widget description or name.'},
          },
        },
      },
      {
        'name': 'agentation_get_app_info',
        'description': 'Retrieves runtime application metadata (platform, screen size, active route, theme).',
        'parameters': {'type': 'object', 'properties': {}},
      },
      {
        'name': 'agentation_watch_annotations',
        'description': 'Subscribes to live visual inspection events via SSE stream.',
        'parameters': {'type': 'object', 'properties': {}},
      },
    ],
  };
}

void _writeLlmInstructions(String path, int port, String sseUrl) {
  final content = '''# Flutter Agentation — LLM & AI Agent Communication Guide

This project is connected to the **Flutter Agentation** inspection engine.
When the Flutter app is running, an embedded Model Context Protocol (MCP) server runs locally at:
- **SSE Transport:** `$sseUrl`
- **HTTP / JSON-RPC Transport:** `http://127.0.0.1:$port/mcp`
- **Health / Status Endpoint:** `http://127.0.0.1:$port/status`

---

## How Any LLM Communicates With the App

### 1. Via MCP (Model Context Protocol)
If your AI agent / IDE supports MCP (Cursor, Claude Code, Antigravity, VS Code Roo/Cline, Windsurf), point its configuration to:
`.flutter_agentation/mcp.json`

The following tools are automatically exposed:
1. **`agentation_get_all_pending`**: Inspect active annotations, widget type, source file path, and line numbers.
2. **`agentation_reply(id, message)`**: Reply directly to the annotation thread inside the Flutter UI.
3. **`agentation_resolve(id)`**: Mark an issue resolved after editing the code.
4. **`agentation_get_app_info()`**: Read platform, route, and resolution info.

---

## 2. Direct HTTP / REST (For Custom LLMs, Scripts & Prompts)
Any LLM that does not use native MCP can inspect and interact using direct HTTP calls:

### Get All Pending Annotations
```bash
curl http://127.0.0.1:$port/pending
```

### Get App Info
```bash
curl http://127.0.0.1:$port/status
```

### JSON-RPC Call (Reply to Annotation)
```bash
curl -X POST http://127.0.0.1:$port/mcp \\
  -H "Content-Type: application/json" \\
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/call",
    "params": {
      "name": "agentation_reply",
      "arguments": {
        "id": "ANNOTATION_ID",
        "message": "Fixed the padding in buttons_section.dart"
      }
    }
  }'
```

### JSON-RPC Call (Resolve Annotation)
```bash
curl -X POST http://127.0.0.1:$port/mcp \\
  -H "Content-Type: application/json" \\
  -d '{
    "jsonrpc": "2.0",
    "id": 2,
    "method": "tools/call",
    "params": {
      "name": "agentation_resolve",
      "arguments": {
        "id": "ANNOTATION_ID"
      }
    }
  }'
```
''';

  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(content);
}
