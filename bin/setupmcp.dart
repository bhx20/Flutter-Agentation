// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'mcp.dart' as mcp;

void main(List<String> args) async {
  if (args.contains('--serve') ||
      args.contains('-s') ||
      args.contains('serve')) {
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
  print(
    '\x1B[1m\x1B[36m╭─────────────────────────────────────────────────────────────╮\x1B[0m',
  );
  print(
    '\x1B[1m\x1B[36m│              Flutter Agentation MCP Server Setup            │\x1B[0m',
  );
  print(
    '\x1B[1m\x1B[36m╰─────────────────────────────────────────────────────────────╯\x1B[0m',
  );
  print('');

  final currentDir = Directory.current.path;
  final sseUrl = 'http://127.0.0.1:$port/sse';
  final httpUrl = 'http://127.0.0.1:$port/mcp';
  final statusUrl = 'http://127.0.0.1:$port/status';

  print('Workspace:    $currentDir');
  print('MCP Protocol: Model Context Protocol (JSON-RPC 2.0 via SSE)');
  print('SSE Endpoint: $sseUrl\n');

  // ── Create Centralized .flutter_agentation/ Directory in Project Root ──
  final agentationDir = Directory(
    '${Directory.current.path}/.flutter_agentation',
  );
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
        'description':
            'Flutter Agentation visual inspection and annotation server for AI coding agents',
      },
    },
  };
  _writeJsonFile('${agentationDir.path}/mcp.json', mcpConfig);
  print(
    '\x1B[32m  ✓ Created .flutter_agentation/mcp.json (Central MCP Config)\x1B[0m',
  );

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
  print(
    '\x1B[32m  ✓ Generated .flutter_agentation/config.json (Runtime Endpoints)\x1B[0m',
  );

  // 3. Tool Schemas for LLM function calling: .flutter_agentation/tools.json
  final toolsSchema = _buildToolsSchema(port);
  _writeJsonFile('${agentationDir.path}/tools.json', toolsSchema);
  print(
    '\x1B[32m  ✓ Exported .flutter_agentation/tools.json (LLM Function Call Schemas)\x1B[0m',
  );

  // 4. Instructions for LLMs / Agents: .flutter_agentation/llm_instructions.md
  _writeLlmInstructions(
    '${agentationDir.path}/llm_instructions.md',
    port,
    sseUrl,
  );
  print(
    '\x1B[32m  ✓ Created .flutter_agentation/llm_instructions.md (LLM System Prompt & Context)\x1B[0m',
  );

  // 5. Agent Skill & Slash Commands: .flutter_agentation/SKILL.md & commands/
  _writeAgentSkill(agentationDir.path, port, sseUrl);
  print(
    '\x1B[32m  ✓ Created .flutter_agentation/SKILL.md (Agent Slash Command & Workflow Skill)\x1B[0m',
  );
  print(
    '\x1B[32m  ✓ Created .flutter_agentation/commands/ (Spec-Kit Slash Commands)\x1B[0m',
  );
  print(
    '\x1B[32m  ✓ Registered Chat Slash Suggestions in .agents/skills/ (Antigravity & Cursor)\x1B[0m',
  );

  // Check and configure Android ADB port forwarding if ADB is available and not in test environment
  final isTestEnv = Platform.environment.containsKey('FLUTTER_TEST');
  if (!isTestEnv) {
    try {
      final adbCheck = Process.runSync(Platform.isWindows ? 'where' : 'which', [
        'adb',
      ], runInShell: true);
      if (adbCheck.exitCode == 0) {
        final forwardResult = Process.runSync('adb', [
          'forward',
          'tcp:$port',
          'tcp:$port',
        ], runInShell: true);
        if (forwardResult.exitCode == 0) {
          print(
            '\x1B[32m  ✓ Configured Android ADB port forward: adb forward tcp:$port tcp:$port\x1B[0m',
          );
        }
      }
    } catch (_) {}
  }

  print('');
  print(
    '\x1B[32m✔ .flutter_agentation workspace directory configured successfully!\x1B[0m',
  );
  print('');
  print('How to connect your AI agent:');
  print('  • MCP Config File: \x1B[1m.flutter_agentation/mcp.json\x1B[0m');
  print('  • SSE Endpoint:    \x1B[36m$sseUrl\x1B[0m');
  print(
    '  • Point your IDE (Cursor, Claude, Windsurf, VS Code) to .flutter_agentation/mcp.json',
  );
  print('');
  print('Supported Platforms:');
  print('  • Windows:         flutter run -d windows (direct connection)');
  print(
    '  • Android:         flutter run -d <device> (auto-forwarded or run "adb forward tcp:$port tcp:$port")',
  );
  print('  • iOS Simulator:   flutter run -d <simulator> (direct connection)');
  print(
    '  • iOS Device:      flutter run -d <device> (connect via local Wi-Fi IP)',
  );
  print('  • Linux:           flutter run -d linux (direct connection)');
  print('  • macOS:           flutter run -d macos (direct connection)');
  print(
    '  • Web (Chrome):    Use built-in Webhook dispatcher in toolbar settings\n',
  );
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
        'description':
            'Retrieves all pending annotations from the active Flutter application inspection canvas.',
        'parameters': {
          'type': 'object',
          'properties': {
            'format': {
              'type': 'string',
              'enum': ['json', 'markdown'],
              'description':
                  'Output format (json or markdown table). Defaults to json.',
            },
          },
        },
      },
      {
        'name': 'agentation_reply',
        'description':
            'Appends an AI agent response into an existing annotation thread in the Flutter UI.',
        'parameters': {
          'type': 'object',
          'required': ['id', 'message'],
          'properties': {
            'id': {'type': 'string', 'description': 'The annotation ID.'},
            'message': {
              'type': 'string',
              'description': 'The reply message text.',
            },
          },
        },
      },
      {
        'name': 'agentation_resolve',
        'description':
            'Resolves and clears an annotation once the requested code fix or inspection change has been completed.',
        'parameters': {
          'type': 'object',
          'required': ['id'],
          'properties': {
            'id': {
              'type': 'string',
              'description': 'The annotation ID to resolve.',
            },
          },
        },
      },
      {
        'name': 'agentation_create_annotation',
        'description':
            'Programmatically creates a new visual annotation card at specified screen coordinates in the Flutter app.',
        'parameters': {
          'type': 'object',
          'required': ['comment', 'x', 'y'],
          'properties': {
            'comment': {
              'type': 'string',
              'description': 'Annotation comment text.',
            },
            'x': {'type': 'number', 'description': 'Global X coordinate.'},
            'y': {'type': 'number', 'description': 'Global Y coordinate.'},
            'element': {
              'type': 'string',
              'description': 'Target widget description or name.',
            },
          },
        },
      },
      {
        'name': 'agentation_get_app_info',
        'description':
            'Retrieves runtime application metadata (platform, screen size, active route, theme).',
        'parameters': {'type': 'object', 'properties': {}},
      },
      {
        'name': 'agentation_watch_annotations',
        'description':
            'Subscribes to live visual inspection events via SSE stream.',
        'parameters': {'type': 'object', 'properties': {}},
      },
    ],
  };
}

void _writeLlmInstructions(String path, int port, String sseUrl) {
  final content =
      '''# Flutter Agentation — LLM & AI Agent Communication Guide

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
  if (commandsDir.existsSync()) {
    try {
      commandsDir.deleteSync(recursive: true);
    } catch (_) {}
  }
  commandsDir.createSync(recursive: true);

  final oldSkillsDir = Directory('$agentationDirPath/skills');
  if (oldSkillsDir.existsSync()) {
    try {
      oldSkillsDir.deleteSync(recursive: true);
    } catch (_) {}
  }

  final rootDir = Directory(agentationDirPath).parent;
  final agentsSkillsDir = Directory('${rootDir.path}/.agents/skills');
  agentsSkillsDir.createSync(recursive: true);

  // Clean up any old legacy skills
  for (final legacy in [
    'flutter-agentation',
    'flutter-agentation-feedback',
    'flutter-agentation-fix-feedback',
    'flutter-agentation-update-status',
    'flutter-agentation-watch',
    'flutter-agentation-inspect',
  ]) {
    final legacyDir = Directory('${agentsSkillsDir.path}/$legacy');
    if (legacyDir.existsSync()) {
      try {
        legacyDir.deleteSync(recursive: true);
      } catch (_) {}
    }
  }

  // ── Skill 1: Check MCP Connection Status ──
  final checkMcpSkillContent = '''---
name: flutter-agentation-check-mcp
description: >-
  Check Flutter Agentation MCP server connection status across all platforms (Web, Mobile, Desktop) and view runtime details (port, endpoints, connected clients, app route, and pending annotations count).
  Trigger with `/flutter-agentation-check-mcp` or `/check-mcp`.
---

# MANDATORY AGENT DIRECTIVE — EXECUTE IMMEDIATELY
DO NOT summarize or describe Flutter Agentation.
DO NOT recommend one platform over another. Flutter Agentation works seamlessly across all platforms: Web, Android, iOS, Windows, macOS, and Linux.
DO NOT output tutorial text or explore framework code.
You MUST IMMEDIATELY query the MCP status and report the connection details.

## STEP 1: QUERY MCP STATUS
Run the status check immediately using shell or PowerShell:
- Primary Check: `curl.exe -s --max-time 2 http://127.0.0.1:$port/status` (or PowerShell `Invoke-RestMethod -Uri "http://127.0.0.1:$port/status" -TimeoutSec 2`)
- Check Pending Annotations: `curl.exe -s --max-time 2 http://127.0.0.1:$port/pending` and read `.flutter_agentation/annotations.json`

## STEP 2: AUTO-START SERVER IF NOT YET RUNNING
If the status check fails (connection refused or timeout):
The universal MCP server can be auto-started in the background:
- On Windows PowerShell: `Start-Process dart -ArgumentList "run","flutter_agentation:mcp" -WindowStyle Hidden`
- On macOS / Linux: `nohup dart run flutter_agentation:mcp > /dev/null 2>&1 &`
Wait 2 seconds, then re-query `http://127.0.0.1:$port/status`.

## STEP 3: PARSE JSON & PRESENT STATUS REPORT
Examine the returned JSON fields `status`, `appMcpEnabled`, and `mcpConnected`:

### Case A: If MCP is Toggled OFF in App (`status == "disabled"` or `appMcpEnabled == false`):
Display:
> **Flutter Agentation MCP Status: Inactive / Disabled in App (Toggle is OFF)**
>
> - **Server**: Running on port $port
> - **In-App Toggle**: **OFF** (The grey dot shown in settings)
> - **Pending Pins**: `<annotationsCount>` pins stored
>
> **How to Enable:**
> 1. In your running Flutter app, tap the **gear icon** on the floating toolbar (or go to **Manage MCP & Webhooks**).
> 2. Switch the **MCP Connection** toggle to **ON** (the indicator dot will turn **green**).
> 3. Run `/flutter-agentation-check-mcp` again to confirm live agent sync.

### Case B: If Server is Waiting for App (`status == "waiting"` or `webClientConnected == false` with no app active):
Display:
> **Flutter Agentation MCP Status: Waiting for Flutter App**
>
> - **Server**: Running on port $port
> - **App Connection**: No active Flutter app is currently sending heartbeats.
> - **Next Step**: Launch your Flutter app on any platform (`flutter run`) and ensure **MCP Connection** is toggled ON.

### Case C: If MCP is Live & Toggled ON (`status == "connected"` or `appMcpEnabled == true`):
Display a structured status card:
- **Status**: Live & Connected (Toggle is ON - Green Dot Active)
- **Auto-Send**: `<autoSendMcp>` (ON: auto-sent / OFF: manual send)
- **Port**: $port
- **SSE Transport**: `http://127.0.0.1:$port/sse`
- **HTTP / MCP Transport**: `http://127.0.0.1:$port/mcp`
- **Connected Clients**: `<connectedClientsCount>`
- **Active Route**: `<route>` (if available)
- **Theme Mode**: `<themeMode>`
- **Submitted Annotations (Ready for Agent)**: `<submittedCount>` feedback pins
- **Draft Pins (Unsent in App)**: `<unsentCount>` pins waiting to be sent
- **Next Step**:
  - If `<submittedCount> > 0`: Run `/flutter-agentation-review-feedback` to review and implement code fixes.
  - If `<submittedCount> == 0 && <unsentCount> > 0`: Tap the **Send button** (paper plane icon with badge `<unsentCount>`) on the floating toolbar or press **S** to submit your feedback to the agent!

### Case D: If MCP Server Cannot Be Reached (Connection Refused or Timeout):
Display:
> **MCP Server Status: Stopped / Disconnected**
>
> Could not connect to Flutter Agentation on `http://127.0.0.1:$port`.
>
> 1. Start the universal MCP server in your terminal:
>    ```bash
>    dart run flutter_agentation:mcp
>    ```
> 2. On your running Flutter app (any platform: Web, Android, iOS, Windows, macOS, Linux), tap the **Agent Sync** (gear icon) so it shows a **green dot**.
> 3. Run `/flutter-agentation-check-mcp` again.
''';

  // ── Skill 2: Review All Available Feedback & Fix Code ──
  final reviewFeedbackSkillContent = '''---
name: flutter-agentation-review-feedback
description: >-
  Review all available visual feedback pins and annotations from the running Flutter application,
  display structured feedback details, locate source code, apply code modifications, and mark items resolved.
  Trigger with `/flutter-agentation-review-feedback`, `/review-feedback`, or `/flutter-agentation-fix-feedback`.
---

# MANDATORY AGENT DIRECTIVE — START WORK IMMEDIATELY
DO NOT summarize, describe, or explain the Flutter Agentation workflow or architecture.
DO NOT output conversational filler, tutorials, or guides.

CRITICAL INSTRUCTIONS:
- DO NOT explore, analyze, or list files in the `flutter_agentation` package, `bin/mcp.dart`, or framework internals.
- DO NOT attempt to run or compile the MCP server. The running Flutter app already hosts it.
- DO NOT search for "4747" in the Flutter SDK or package sources.
- YOUR SOLE TASK IS TO RETRIEVE ALL AVAILABLE FEEDBACK, REVIEW IT, AND MODIFY THE USER'S APPLICATION CODE.

## STEP 1: FETCH ALL AVAILABLE FEEDBACK
Attempt the following retrieval methods in priority order until annotations are found:

1. **Local Workspace File (Fastest & Direct)**: Read `.flutter_agentation/annotations.json` in the current project root using `read_file`. Filter for active items where `status != 'resolved'` and `status != 'rejected'`.
2. **HTTP REST Endpoint**: Run shell command `curl.exe -s --max-time 2 http://127.0.0.1:$port/pending` (or PowerShell `Invoke-RestMethod -Uri "http://127.0.0.1:$port/pending" -TimeoutSec 2`). Check `.flutter_agentation/config.json` for custom port if $port fails.
3. **Auto-Start Server if stopped**: If the endpoint fails and `.flutter_agentation/annotations.json` does not exist, run:
   - PowerShell: `Start-Process dart -ArgumentList "run","flutter_agentation:mcp" -WindowStyle Hidden`
   - Unix: `nohup dart run flutter_agentation:mcp > /dev/null 2>&1 &`
   Wait 2 seconds and re-check `http://127.0.0.1:$port/pending`.
4. **OS Temp Storage File**: Read `%TEMP%\\flutter_agentation_annotations.json` (Windows) or `/tmp/flutter_agentation_annotations.json` (macOS/Linux).
5. **MCP Tool Call**: If tool `agentation_get_all_pending` or `mcp_flutter_agentation_agentation_get_all_pending` is available in your tool declaration list, call it immediately.

## STEP 2: HANDLE RESULTS

### If No Pending Annotations Are Found (count == 0 or empty list):
Check if there are unsent draft annotations in the response (`unsentCount > 0`):
If `unsentCount > 0`:
Output ONLY the following message and stop immediately (do NOT modify code without permission):
> **No submitted feedback annotations found.**
>
> You currently have **`<unsentCount>` draft annotations** in your running app, but **Auto-Send is OFF** and you have not submitted them to the agent yet.
>
> **How to Submit:**
> 1. In your running Flutter app, tap the **Send button** (paper plane icon with badge `<unsentCount>` on the floating toolbar) or press **S**.
> 2. Once submitted, run `/flutter-agentation-review-feedback` again and the agent will implement your requested changes.
> *(Tip: If you want all feedback sent automatically without manually clicking Send, open Settings > Manage MCP & Webhooks and turn ON Auto-Send).*

Otherwise (both count == 0 and unsentCount == 0):
Output ONLY the following message and stop immediately:
> **No pending visual feedback annotations found.**
>
> 1. Ensure your Flutter app is running (`flutter run`).
> 2. Ensure MCP Connection is toggled ON in your app toolbar.
> 3. Click on any widget in your app and add your feedback note.
> 4. If Auto-Send is OFF, tap the Send button (paper plane icon) to submit.
> 5. Run `/flutter-agentation-review-feedback` again.

### If Pending Annotations Are Found:
Display all active feedback items immediately in a clear review table:

| ID | Target Widget | Source Location | Feedback / Comment |
| :--- | :--- | :--- | :--- |
| `<id>` | `<widgetType>` | `<sourceLocation>` | `<comment>` |

## STEP 3: NAVIGATE TO SOURCE & APPLY FIX IMMEDIATELY
For each feedback item:
1. Open and read the source file specified in `sourceLocation` (e.g. `lib/screens/home_page.dart` at the target line) using `read_file`.
2. Locate the target widget and implement the user's requested visual, styling, or logic changes.
3. Save the file. Flutter Hot Reload immediately reflects the updates on screen.

## STEP 4: MARK RESOLVED & REMOVE PIN FROM RUNNING APP
Once the code change has been applied:
- Call tool `agentation_resolve` with `{"annotationId": "<id>", "summary": "<summary of fix>"}`
- Or run command: `curl -s -X PATCH http://127.0.0.1:$port/annotations/<id> -H "Content-Type: application/json" -d "{\\"status\\": \\"resolved\\"}"`
- Update `.flutter_agentation/annotations.json` if modifying directly.
- The pin marker is immediately removed from the running panel.
- Present a concise summary with clickable file links: `[FileName.dart](file:///path/to/file#Lline)`.
''';

  // 1. Central .flutter_agentation/SKILL.md
  File('$agentationDirPath/SKILL.md').writeAsStringSync(reviewFeedbackSkillContent);

  // 2. Central .flutter_agentation/commands/
  for (final filename in [
    'flutter_agentation_check_mcp.md',
    'check_mcp.md',
  ]) {
    File('${commandsDir.path}/$filename').writeAsStringSync(checkMcpSkillContent);
  }

  for (final filename in [
    'flutter_agentation_review_feedback.md',
    'review_feedback.md',
    'flutter_agentation_fix_feedback.md',
    'fix_feedback.md',
    'flutter_agentation.md',
  ]) {
    File('${commandsDir.path}/$filename').writeAsStringSync(reviewFeedbackSkillContent);
  }

  // 3. Register exactly the 2 skills in .agents/skills/
  final checkMcpDir = Directory('${agentsSkillsDir.path}/flutter-agentation-check-mcp');
  checkMcpDir.createSync(recursive: true);
  File('${checkMcpDir.path}/SKILL.md').writeAsStringSync(checkMcpSkillContent);

  final reviewFeedbackDir = Directory('${agentsSkillsDir.path}/flutter-agentation-review-feedback');
  reviewFeedbackDir.createSync(recursive: true);
  File('${reviewFeedbackDir.path}/SKILL.md').writeAsStringSync(reviewFeedbackSkillContent);
}
