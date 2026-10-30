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
        'command': 'dart',
        'args': ['run', 'flutter_agentation:mcp', '--port', '$port'],
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

  // 5. Agent Skill & Slash Commands: .flutter_agentation/SKILL.md & commands/
  _writeAgentSkill(agentationDir.path, port, sseUrl);
  print('\x1B[32m  ✓ Created .flutter_agentation/SKILL.md (Agent Slash Command & Workflow Skill)\x1B[0m');
  print('\x1B[32m  ✓ Created .flutter_agentation/commands/ (Spec-Kit Slash Commands)\x1B[0m');
  print('\x1B[32m  ✓ Registered Chat Slash Suggestions in .agents/skills/ (Antigravity & Cursor)\x1B[0m');

  // Check and configure Android ADB port forwarding if ADB is available and not in test environment
  final isTestEnv = Platform.environment.containsKey('FLUTTER_TEST');
  if (!isTestEnv) {
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
  }

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

void _writeAgentSkill(String agentationDirPath, int port, String sseUrl) {
  final commandsDir = Directory('$agentationDirPath/commands');
  commandsDir.createSync(recursive: true);

  final nestedSkillDir = Directory('$agentationDirPath/skills/flutter-agentation');
  final nestedCommandsDir = Directory('${nestedSkillDir.path}/commands');
  nestedCommandsDir.createSync(recursive: true);

  // 1. Root SKILL.md
  final skillContent = '''---
name: flutter-agentation
description: >-
  Advanced visual UI inspection, feedback review, code editing, and annotation workflow for Flutter applications.
  Use when the user asks to review UI feedback, inspect Flutter widgets, apply changes from flutter-agentation annotations,
  or mentions "/flutter-agentation-review-feedback", "/flutter-agentation-update-status", "/flutter-agentation-watch",
  "/flutter-agentation-inspect", or "flutter-agentation".
---

# Flutter Agentation — Spec-Driven Agent Workflow & Tooling

Flutter Agentation connects running Flutter applications directly to AI coding agents through the Model Context Protocol (MCP).

This skill provides native slash commands and advanced workflows (similar to GitHub Spec Kit) specifically designed for Flutter Agentation:

```
+--------------------------------------------------------------------------------------------------------------------+
|                                    Flutter Agentation Advanced Workflow Lifecycle                                  |
+--------------------------------------------------------------------------------------------------------------------+
|                                                                                                                    |
|  1. /flutter-agentation-review-feedback  --->  Pulls pins, widget tree, source paths, lines & notes via MCP        |
|  2. /flutter-agentation-inspect          --->  Live inspection of runtime widget properties, routes & metrics       |
|  3. Autonomous Code Modification         --->  Applies edits directly to target Dart file (Hot Reload updates UI)  |
|  4. /flutter-agentation-update-status    --->  Marks pin resolved, updates progress, or posts in-app thread reply  |
|  5. /flutter-agentation-watch            --->  Hands-free continuous background listener for incoming visual pins  |
|                                                                                                                    |
+--------------------------------------------------------------------------------------------------------------------+
```

---

## Available Slash Commands

| Slash Command | Primary Purpose | Reference |
| :--- | :--- | :--- |
| **`/flutter-agentation-review-feedback`** | Comprehensive 6-stage review lifecycle: fetch, acknowledge, locate line, edit code, hot reload, and resolve. | [commands/flutter_agentation_review_feedback.md](commands/flutter_agentation_review_feedback.md) |
| **`/flutter-agentation-update-status`** | Updates pin state (`resolved`, `inProgress`, `rejected`) or adds an agent reply to the in-app discussion thread. | [commands/flutter_agentation_update_status.md](commands/flutter_agentation_update_status.md) |
| **`/flutter-agentation-watch`** | Continuous hands-free pairing loop: automatically wakes up and implements changes as you annotate in-app. | [commands/flutter_agentation_watch.md](commands/flutter_agentation_watch.md) |
| **`/flutter-agentation-inspect`** | Queries active app route, screen dimensions, theme mode, and live widget properties via MCP. | [commands/flutter_agentation_inspect.md](commands/flutter_agentation_inspect.md) |

*(Convenience short aliases: `/review-feedback`, `/update-status`, `/watch-feedback`, `/inspect-widget`)*

---

## Step-by-Step Agent Procedure

### Phase 1: Review Feedback (`/flutter-agentation-review-feedback`)
1. Read the server endpoint from `.flutter_agentation/mcp.json` in the project root.
2. Call tool `agentation_get_all_pending` (or HTTP GET `http://127.0.0.1:$port/pending`).
3. For each pending item:
   - Identify `targetWidget` and `sourceLocation` (e.g. `lib/screens/login_view.dart:45`).
   - Read the user's `comment`, severity, and bounding coordinates.
   - (Optional) Call `agentation_acknowledge(annotationId)` to badge the pin as "In Progress" in-app.
   - Open and edit the source file. Hot Reload updates the running Flutter app immediately.
   - Call tool `agentation_resolve(annotationId, summary)` to mark the pin as complete.

### Phase 2: Update Status / Conversational Clarification (`/flutter-agentation-update-status`)
1. If clarification is needed, call `agentation_reply(annotationId, message)` to ask questions in the in-app card.
2. If the user marks an issue dismissed or duplicate, call `agentation_dismiss(annotationId, reason)`.

### Phase 3: Continuous Watch Mode (`/flutter-agentation-watch`)
1. Call `agentation_watch_annotations(batchWindowSeconds: 5, timeoutSeconds: 120)`.
2. As soon as new pins are submitted on the running Flutter app, automatically process them and apply code changes.

---

## Configuration Location
- Central MCP Config: `.flutter_agentation/mcp.json`
- Tools Schema: `.flutter_agentation/tools.json`
- Runtime Endpoints: `.flutter_agentation/config.json`
- Agent Instructions: `.flutter_agentation/llm_instructions.md`
- Skill Definition: `.flutter_agentation/SKILL.md`
- Workflows & Commands: `.flutter_agentation/commands/`
''';

  File('$agentationDirPath/SKILL.md').writeAsStringSync(skillContent);
  File('${nestedSkillDir.path}/SKILL.md').writeAsStringSync(skillContent);

  // 2. commands/flutter_agentation_review_feedback.md
  final reviewCommandContent = '''---
name: flutter-agentation-review-feedback
description: >-
  Inspect running Flutter application, retrieve active visual annotations and UI feedback pins,
  locate source code, apply code modifications, and mark items resolved via Model Context Protocol (MCP).
  Trigger with `/flutter-agentation-review-feedback`, `/flutter-agentation:review`, or `/review-feedback`.
---

# Review Feedback — Flutter Agentation Workflow

This workflow guides the AI coding agent to inspect all live visual feedback annotations from the Flutter Agentation toolbar, navigate directly to the requested widget source code, apply the fixes, and update the annotation state.

---

## Slash Commands
- `/flutter-agentation-review-feedback`
- `/flutter-agentation:review`
- `/review-feedback`

---

## Execution Steps

### 1. Connect & Fetch Pending Annotations
Read the server endpoint from `.flutter_agentation/mcp.json` (or use active MCP connection `flutter-agentation`).
Call the MCP tool:
```json
{
  "name": "agentation_get_all_pending"
}
```
*(Fallback REST endpoint: `http://127.0.0.1:$port/pending`)*

If `count == 0` or no pending annotations exist:
Inform the user: *"No pending visual feedback annotations found in Flutter Agentation."* and stop.

---

### 2. Acknowledge Each Item (Optional)
For each pending annotation, let the user know in the app interface that work has started:
```json
{
  "name": "agentation_acknowledge",
  "arguments": {
    "annotationId": "<ANNOTATION_ID>"
  }
}
```

---

### 3. Review Widget Context & Source Location
Examine the returned annotation properties:
- `comment`: User's requested change or feedback.
- `sourceLocation`: Exact file path and line number (e.g., `lib/screens/home_page.dart:45`).
- `widget`: Target widget type, key, and text content.
- `hierarchy`: Ancestor widgets for nesting and layout context.
- `bounds`: Exact pixel coordinates and dimensions on screen.

---

### 4. Implement Code Changes
1. Open the file specified in `sourceLocation`.
2. Locate the widget and apply the user's requested visual, styling, layout, or logic changes.
3. Save the file. Flutter Hot Reload immediately reflects the changes on the running device/emulator.

---

### 5. Mark Annotation Resolved
Once verified, mark the feedback item as resolved:
```json
{
  "name": "agentation_resolve",
  "arguments": {
    "annotationId": "<ANNOTATION_ID>",
    "summary": "Applied requested changes"
  }
}
```
If clarification is needed instead, reply to the annotation thread in-app:
```json
{
  "name": "agentation_reply",
  "arguments": {
    "annotationId": "<ANNOTATION_ID>",
    "message": "Question regarding design or behavior"
  }
}
```

---

### 6. Summary Output
Provide the developer with a clear breakdown of the feedback addressed and clickable links to modified files.
''';

  // Write both prefixed and standard filenames for maximum compatibility
  for (final filename in ['flutter_agentation_review_feedback.md', 'review_feedback.md']) {
    File('${commandsDir.path}/$filename').writeAsStringSync(reviewCommandContent);
    File('${nestedCommandsDir.path}/$filename').writeAsStringSync(reviewCommandContent);
  }

  // 3. commands/flutter_agentation_update_status.md
  final updateStatusCommandContent = '''---
name: flutter-agentation-update-status
description: >-
  Update the status or post conversational updates/clarifications to visual annotations in Flutter Agentation.
  Trigger with `/flutter-agentation-update-status`, `/flutter-agentation:update-status`, or `/update-status`.
---

# Update Feedback Status — Flutter Agentation Workflow

This workflow enables the AI agent to update annotation progress (`inProgress`, `resolved`, `rejected`) or reply directly to the visual annotation thread in the running Flutter app.

---

## Slash Commands
- `/flutter-agentation-update-status`
- `/flutter-agentation:update-status`
- `/update-status`
- `/flutter-agentation-reply`

---

## Arguments
- `id` (or `annotationId`): Target annotation identifier (e.g., `ann_1729864200000`).
- `status`: New state (`resolved`, `inProgress`, `rejected`).
- `message`: Text message or resolution summary.

---

## Execution Steps

### 1. Resolve Feedback
When resolving an item:
```json
{
  "name": "agentation_resolve",
  "arguments": {
    "annotationId": "<id>",
    "summary": "<message>"
  }
}
```

### 2. Reply to Feedback Thread
When asking the developer for clarification:
```json
{
  "name": "agentation_reply",
  "arguments": {
    "annotationId": "<id>",
    "message": "<message>"
  }
}
```

### 3. Dismiss Feedback
When an annotation cannot or should not be completed:
```json
{
  "name": "agentation_dismiss",
  "arguments": {
    "annotationId": "<id>",
    "reason": "<message>"
  }
}
```

### 4. Direct REST Fallback
If MCP is not directly connected:
- **PATCH** `http://127.0.0.1:$port/annotations/<id>` with `{"status": "resolved"}`
- **POST** `http://127.0.0.1:$port/annotations/<id>/thread` with `{"content": "<message>", "role": "agent"}`
''';

  for (final filename in ['flutter_agentation_update_status.md', 'update_status.md']) {
    File('${commandsDir.path}/$filename').writeAsStringSync(updateStatusCommandContent);
    File('${nestedCommandsDir.path}/$filename').writeAsStringSync(updateStatusCommandContent);
  }

  // 4. commands/flutter_agentation_watch.md (Hands-free autonomous watch mode)
  final watchCommandContent = '''---
name: flutter-agentation-watch
description: >-
  Continuously watch and listen for new visual feedback pins in the running Flutter application,
  automatically implementing requested code changes in real time.
  Trigger with `/flutter-agentation-watch`, `/flutter-agentation:watch`, or `/watch-feedback`.
---

# Continuous Feedback Watch — Flutter Agentation Workflow

This command activates hands-free pairing mode: the AI agent stays connected to the Flutter application and listens for incoming annotations in real time.

---

## Slash Commands
- `/flutter-agentation-watch`
- `/flutter-agentation:watch`
- `/watch-feedback`

---

## Execution Steps

1. Connect to the MCP server from `.flutter_agentation/mcp.json`.
2. Call `agentation_watch_annotations`:
```json
{
  "name": "agentation_watch_annotations",
  "arguments": {
    "batchWindowSeconds": 5,
    "timeoutSeconds": 120
  }
}
```
3. When new annotations are returned, execute the `/flutter-agentation-review-feedback` workflow for each item.
4. After resolving all items, repeat the watch call to continue listening.
''';

  for (final filename in ['flutter_agentation_watch.md', 'watch_feedback.md']) {
    File('${commandsDir.path}/$filename').writeAsStringSync(watchCommandContent);
    File('${nestedCommandsDir.path}/$filename').writeAsStringSync(watchCommandContent);
  }

  // 5. commands/flutter_agentation_inspect.md
  final inspectCommandContent = '''---
name: flutter-agentation-inspect
description: >-
  Inspect active Flutter application state, screen dimensions, theme mode, and widget hierarchy via Model Context Protocol (MCP).
  Trigger with `/flutter-agentation-inspect`, `/flutter-agentation:inspect`, or `/inspect-widget`.
---

# Inspect Application — Flutter Agentation Workflow

Queries live runtime telemetry and widget hierarchy information from the running Flutter app.

---

## Slash Commands
- `/flutter-agentation-inspect`
- `/flutter-agentation:inspect`
- `/inspect-widget`

---

## Execution Steps

1. Call `agentation_get_app_info` to retrieve platform, route, and theme mode:
```json
{
  "name": "agentation_get_app_info"
}
```
2. Call `agentation_get_all_pending` to retrieve all currently marked widget targets.
3. Present a structured overview of the application status to the user.
''';

  for (final filename in ['flutter_agentation_inspect.md', 'inspect_widget.md']) {
    File('${commandsDir.path}/$filename').writeAsStringSync(inspectCommandContent);
    File('${nestedCommandsDir.path}/$filename').writeAsStringSync(inspectCommandContent);
  }

  // 6. Spec-Kit-style agent chat suggestion skills in .agents/skills/
  // Enables instant slash command suggestions in Antigravity, Cursor, and Claude Code chat UI.
  final rootDir = Directory(agentationDirPath).parent;
  final agentsSkillsDir = Directory('${rootDir.path}/.agents/skills');

  final individualSkills = <String, String>{
    'flutter-agentation': skillContent,
    'flutter-agentation-review-feedback': reviewCommandContent,
    'flutter-agentation-update-status': updateStatusCommandContent,
    'flutter-agentation-watch': watchCommandContent,
    'flutter-agentation-inspect': inspectCommandContent,
  };

  for (final entry in individualSkills.entries) {
    final dir = Directory('${agentsSkillsDir.path}/${entry.key}');
    dir.createSync(recursive: true);
    File('${dir.path}/SKILL.md').writeAsStringSync(entry.value);
  }
}
