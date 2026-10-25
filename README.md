# Flutter Agentation

A developer-first visual inspection, annotation, and AI context engine for Flutter applications.

Instead of manually hunting for widget source files and copying layout dimensions to explain UI bugs, Flutter Agentation lets you click any element in your running app, write a note, and instantly stream the exact source file, line number, widget tree hierarchy, and bounding box directly to your AI coding agent (Cursor, Claude Desktop, Windsurf, VS Code, or Antigravity) via the Model Context Protocol (MCP) or webhooks.

---

## How It Works

```
+-------------------------------------------------------------------+
|                        Running Flutter App                        |
|                                                                   |
|   1. Click / hover any widget                                     |
|   2. Add note or sketch                                           |
|   3. Flutter Agentation captures source path, line, bounds & tree |
+---------------------------------+---------------------------------+
                                  |
         +------------------------+------------------------+
         |                                                 |
         v                                                 v
+-------------------------------+         +-------------------------------+
|       Native MCP Server       |         |       Webhook Dispatcher      |
|    (SSE / JSON-RPC :4747)     |         |     (HTTP POST to any URL)    |
+---------------+---------------+         +---------------+---------------+
                |                                                 |
                v                                                 v
+-------------------------------+                 +---------------+---------------+
| AI Agents (Cursor, Claude,    |                 | Custom Bot / Slack / CI       |
| Windsurf, VS Code, etc.)      |                 | Automated PR generation       |
|                               |                 +-------------------------------+
| Calls `list_annotations`      |
| and edits the code directly!  |
+-------------------------------+
```

---

## 5-Minute Quickstart

### Step 1: Add Dependency

In your Flutter project root, run:

```bash
flutter pub add flutter_agentation
```

Or add it directly to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_agentation: ^0.0.1
```

### Step 2: Wrap Your Application

In `lib/main.dart`, wrap your `MaterialApp` or `CupertinoApp` using the `FlutterAgentation.builder()` helper:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_agentation/flutter_agentation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      // Attach FlutterAgentation at the builder level to persist across all screens:
      builder: FlutterAgentation.builder(),
      home: const HomeScreen(),
    );
  }
}
```

*Tip: Wrapping at the `builder` level ensures the floating toolbar remains visible across all routes, modals, bottom sheets, and dialogs.*

#### Automatic Release Mode Protection (`debugOnly`)
By default, `debugOnly: true` is configured out of the box on both `FlutterAgentation` and `FlutterAgentation.builder()`. When your application is built for release or profile mode (`kDebugMode == false`), Flutter Agentation completely disables itself:
- No inspection overlays or floating toolbars are rendered.
- No keyboard shortcuts or background controllers are registered.
- No network listeners or MCP servers are started.
- Your app's widget tree is returned directly with zero performance overhead.

You do **not** need to wrap your code in manual `if (kDebugMode)` checks. If you wish to test Agentation in a release build, set `debugOnly: false`.

### Step 3: Run the MCP Setup Command (`setupmcp`)

Run the `setupmcp` command in your workspace terminal:

```bash
dart run flutter_agentation:setupmcp
```

This initializes a clean `.flutter_agentation/` directory directly in your project root containing:
- `mcp.json`: The universal MCP server configuration ready for any agent.
- `config.json`: Runtime port and endpoint metadata.
- `tools.json`: LLM tool schemas for inspection and annotation operations.
- `llm_instructions.md`: Ready-to-use prompt and system instructions for AI models.

No external IDE directories are created or modified—your project stays completely clean with only `.flutter_agentation/` added.

*(Note: `dart run flutter_agentation:setup_mcp` and `dart run flutter_agentation:setup` are also supported as aliases.)*

### Step 4: Run Your App and Inspect

Run your Flutter application:

```bash
flutter run
```

A floating pill toolbar appears at the bottom-right of your screen. Click the target icon to inspect any widget, or use keyboard shortcut `Ctrl+Shift+A` (`Cmd+Shift+A` on macOS).

---

## Working With AI Agents (The MCP Flow)

The Model Context Protocol (MCP) gives your AI agent direct access to your running Flutter app via Server-Sent Events (SSE).

### How the Interaction Works

1. Ensure your Flutter app is running (`flutter run`).
2. Run `dart run flutter_agentation:setupmcp` to generate `.flutter_agentation/mcp.json`.
3. In your app, click any widget and write your feedback (for example: *"Make this button secondary style with 12px horizontal padding"*).
4. In your AI agent chat (Cursor, Claude, Windsurf, or VS Code), send:
   > "Check the active annotations from flutter-agentation and apply the requested changes."
5. The AI agent calls the `list_annotations` tool, reads the source file path and line number (e.g. `lib/views/login_view.dart:45`), and edits the code directly.

---

## Manual MCP Configuration

If you prefer to configure your editor manually without using the CLI setup command, add the `flutter-agentation` server to your agent configuration file:

### 1. Cursor IDE

Add to `.cursor/mcp.json` in your project root:

```json
{
  "mcpServers": {
    "flutter-agentation": {
      "url": "http://127.0.0.1:4747/sse"
    }
  }
}
```

### 2. Windsurf IDE

Add to `.windsurf/mcp.json` in your project root, or globally in `~/.codeium/windsurf/mcp_config.json`:

```json
{
  "mcpServers": {
    "flutter-agentation": {
      "url": "http://127.0.0.1:4747/sse"
    }
  }
}
```

### 3. Claude Desktop

Add to your `claude_desktop_config.json`:
- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`
- **Linux**: `~/.config/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "flutter-agentation": {
      "url": "http://127.0.0.1:4747/sse"
    }
  }
}
```

### 4. VS Code (Cline, Roo Code, Continue)

Add to `.vscode/mcp.json` in your project root:

```json
{
  "mcpServers": {
    "flutter-agentation": {
      "url": "http://127.0.0.1:4747/sse"
    }
  }
}
```

### 5. Claude Code CLI

Run in your terminal:

```bash
claude mcp add --transport sse flutter-agentation http://127.0.0.1:4747/sse
```

---

## Available MCP Tools

Your AI agent has access to 6 specialized inspection and control tools over the MCP connection:

| Tool Name | Parameters | Purpose |
|---|---|---|
| `list_annotations` | None | Returns all pending and submitted annotations with widget types, source paths, line numbers, and comments. |
| `get_app_state` | None | Returns current route, theme mode (dark/light), screen resolution, and toolbar state. |
| `inspect_widget` | `x`, `y` or `widgetType` | Performs a live hit-test at coordinates or finds a widget by type/key, returning exact bounds and hierarchy. |
| `add_annotation` | `comment`, `x`, `y` | Programmatically pins an annotation from the agent directly onto the user's running app screen. |
| `clear_annotations` | None | Clears all annotations and drawings after the agent completes the code edit. |
| `take_screenshot` | None | Captures a base64 PNG of the current screen so the agent can visually verify its own work. |

### Customizing the MCP Port

By default, the MCP server runs on port `4747`. To use a custom port (e.g. `4949`):

CLI:
```bash
dart run flutter_agentation:setupmcp --port 4949 --agent=cursor
```

FlutterApp:
```dart
FlutterAgentation(
  mcpPort: 4949,
  child: child,
)
```

---

## Platform Support & Connectivity

Flutter Agentation MCP server runs natively on all major operating systems:

| Platform | Command | Connection Method |
|---|---|---|
| **Windows** | `flutter run -d windows` | Direct localhost (`http://127.0.0.1:4747/sse`) |
| **Linux** | `flutter run -d linux` | Direct localhost (`http://127.0.0.1:4747/sse`) |
| **macOS** | `flutter run -d macos` | Direct localhost (`http://127.0.0.1:4747/sse`) |
| **Android (Emulator & Device)** | `flutter run -d <device>` | Forward port via ADB: `adb forward tcp:4747 tcp:4747` |
| **iOS Simulator** | `flutter run -d <simulator>` | Direct localhost (`http://127.0.0.1:4747/sse`) |
| **iOS Physical Device** | `flutter run -d <device>` | Connect via local Wi-Fi IP (`http://<device-ip>:4747/sse`) |
| **Web (Chrome / Edge)** | `flutter run -d chrome` | Run bridge: `dart run flutter_agentation:mcp` |

### Web Setup (Chrome / Edge)
To use MCP while running your Flutter app in Chrome or Edge, launch the Universal MCP Bridge in your terminal:

```bash
dart run flutter_agentation:mcp
```

Your Flutter Web application automatically connects and syncs annotations with this local bridge. Cursor, Claude Desktop, Windsurf, and VS Code connect to `http://127.0.0.1:4747/sse` with full MCP capabilities.

### Android Setup Tip
When running on Android (emulator or physical phone over USB), run this once in your terminal so your desktop AI agent can reach the Android app:

```bash
adb forward tcp:4747 tcp:4747
```

*(This is also configured automatically if ADB is detected when you run `dart run flutter_agentation:setupmcp`.)*

## Webhooks Flow

If your team uses automated pipelines, Slack notifications, or custom agent proxies, you can configure webhooks to push annotations instantly.

### Setting Up Webhooks

#### Option A: In Code
```dart
FlutterAgentation(
  webhookUrl: 'https://your-server.com/api/agentation-webhook',
  autoSendWebhooks: true, // Dispatch automatically on every new annotation
  child: child,
)
```

#### Option B: In the In-App Toolbar
1. Tap the gear icon on the floating toolbar to open **Settings**.
2. Tap **Manage MCP & Webhooks**.
3. Paste your Webhook URL.
4. Toggle **Auto-Send Annotations** or click **Test Connection**.

### Sample Webhook Payload

When an annotation is submitted, an HTTP `POST` request is sent with `Content-Type: application/json`:

```json
{
  "event": "annotation_created",
  "timestamp": "2026-10-25T13:45:00.000Z",
  "annotation": {
    "id": "ann_1729864200000",
    "comment": "Change background to surface container high and reduce corner radius to 8",
    "detailLevel": "detailed",
    "coordinates": { "x": 140.0, "y": 280.0 },
    "widget": {
      "type": "ElevatedButton",
      "key": "action_button",
      "text": "Get Started",
      "sourceLocation": "lib/screens/onboarding_screen.dart:64",
      "bounds": { "x": 32.0, "y": 260.0, "width": 310.0, "height": 48.0 },
      "hierarchy": ["MaterialApp", "Scaffold", "SafeArea", "Column", "ElevatedButton"]
    }
  },
  "appContext": {
    "currentRoute": "/onboarding",
    "themeMode": "dark",
    "screenSize": { "width": 393.0, "height": 852.0 }
  }
}
```

---

## In-App Toolbar & Interaction Modes

The floating toolbar gives you five inspection modes:

1. **Element Inspect (Target Icon)**:
   Hover over any widget to see its bounding box and widget type. Click to place a pin, write a comment, or inspect its parent hierarchy breadcrumbs.
2. **Area Selection (Marquee Icon)**:
   Click and drag a rectangle to select multiple widgets at once (useful for complex layout cards or lists).
3. **Multi-Select (Plus-Box Icon)**:
   Click multiple separate widgets across the screen to bundle them into a single grouped issue.
4. **Freehand Drawing (Pen Icon)**:
   Draw directly over your UI to highlight alignment issues, circle glitches, or sketch arrows.
5. **Visual Design Mode (Palette Icon)**:
   - Drag skeleton wireframe components (Button, Input, Card, Text, Avatar, Image) onto your app.
   - Drag and reposition existing widgets on screen to generate coordinate delta diffs for your agent.
6. **Animation Freeze Controller (Pause/Play Icon)**:
   Freezes running tickers, transitions, and loaders using Flutter's native `TickerMode`. Inspect transient snackbars, dialogs, and animations without them closing or disappearing.

---

## Output Detail Levels

Click the detail level pill on the toolbar to cycle between 4 formats:

- **Compact**: Essential summary (Widget type + your comment).
- **Standard**: Clean report with key attributes, coordinates, and comment.
- **Detailed**: Comprehensive report with parent breadcrumbs, padding, constraints, and source file locations.
- **Forensic**: Full debugging tree payload with all ancestor elements, identifying attributes, and raw metrics.

When you click **Copy**, the formatted markdown is copied to your clipboard, ready to paste into any chat if you are not using the direct MCP connection.

---

## Production Best Practice (Debug Only)

To ensure Flutter Agentation is only active during development and never included in release builds, configure it conditionally using `kDebugMode`:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agentation/flutter_agentation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      builder: (context, child) {
        if (!kDebugMode) {
          return child ?? const SizedBox.shrink();
        }
        return FlutterAgentation(
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const HomeScreen(),
    );
  }
}
```

---

## Programmatic API Reference

You can access and control Flutter Agentation from anywhere in your widget tree:

```dart
// Retrieve controller from context
final controller = AgentationController.of(context);

// Show / Hide / Toggle overlay
controller.activate();
controller.deactivate();
controller.toggle();

// Switch modes
controller.setMode(InspectionMode.inspect);
controller.setMode(InspectionMode.draw);
controller.setMode(InspectionMode.design);

// Freeze / Unfreeze animations
controller.toggleFreeze();

// Cycle detail level
controller.cycleDetailLevel();

// Copy to clipboard programmatically
final markdown = await controller.copyToClipboard(format: ExportFormat.markdown);

// Clear annotations
controller.clearAnnotations();

// Listen to state changes
controller.stateNotifier.addListener(() {
  final state = controller.stateNotifier.value;
  debugPrint('Active mode: ${state.mode}, Annotations: ${state.annotations.length}');
});
```

---

## Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| `Ctrl+Shift+A` / `Cmd+Shift+A` | Toggle Agentation inspection mode |
| `Escape` | Cancel current selection / close active dialog |
| `Ctrl+Z` / `Cmd+Z` | Undo last annotation or drawing stroke |
| `Ctrl+Shift+Z` / `Cmd+Shift+Z` | Redo last action |

---

## Troubleshooting & FAQ

#### The MCP server cannot connect or port 4747 is already in use
Run the setup command with a custom port:
```bash
dart run flutter_agentation:setup --port 4848
```
And specify `mcpPort: 4848` in your `FlutterAgentation` widget.

#### Source code locations show line numbers but file names are missing
Ensure you are running in debug mode (`flutter run` without `--release`). Flutter's widget inspector metadata is available in debug mode.

#### The floating toolbar covers an important button in my app
The toolbar is draggable. Long-press or drag the grip handle to reposition it anywhere on your screen. You can also minimize it into a small circle by tapping the minimize button.

---

## Contributing & Testing

Run the test suite and analyzer:

```bash
# Run all unit, widget, and integration tests
flutter test

# Run code analysis
flutter analyze
```

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
