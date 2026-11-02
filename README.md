# Flutter Agentation

[![pub package](https://img.shields.io/pub/v/flutter_agentation.svg)](https://pub.dev/packages/flutter_agentation)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://pub.dev/packages/flutter_agentation/license)
[![platforms](https://img.shields.io/badge/platforms-flutter%20%7C%20android%20%7C%20ios%20%7C%20web%20%7C%20macos%20%7C%20windows%20%7C%20linux-lightgrey.svg)](https://pub.dev/packages/flutter_agentation)

A developer-first visual inspection, layout wireframing, and Model Context Protocol (MCP) context engine for Flutter applications.

Instead of manually hunting for widget source files and copying layout dimensions to explain UI bugs, Flutter Agentation lets you click any element in your running app, write a note or sketch, and stream the exact source file path, line number, widget tree hierarchy, and bounding box directly to your AI coding agent (Cursor, Claude Desktop, Windsurf, VS Code, or Antigravity) via the Model Context Protocol (JSON-RPC 2.0) or webhooks.

---

## Architecture Overview

```
+-------------------------------------------------------------------+
|                        Running Flutter App                        |
|                                                                   |
|   1. Click / hover any widget element                             |
|   2. Add feedback note, sketch, or skeleton wireframe             |
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
| Reads feedback via MCP tools  |
| and edits the code directly!  |
+-------------------------------+
```

---

## Key Features

- **Deep Widget Inspection**: Resolves exact `RenderBox` bounds, ancestor breadcrumb trees, semantics, developer keys, and source file line numbers (`lib/screens/home.dart:42`).
- **Universal Model Context Protocol (MCP)**: Native embedded SSE and JSON-RPC 2.0 streaming on port 4747, compatible with Cursor, Claude Desktop, Windsurf, VS Code (Cline/Roo), and Antigravity.
- **Spec-Kit Promptless Workflow**: Pre-configured slash commands (`/flutter-agentation-check-mcp`, `/flutter-agentation-review-feedback`) that allow agents to inspect feedback and apply fixes without prompt engineering.
- **Visual Wireframing & Layout Mode**: Drag-and-drop realistic skeleton components (Buttons, Cards, Inputs, Lists) onto the live UI with interactive counter-question dialogs for precise AI specifications.
- **Draft Annotation Protection**: In-memory safety keeping annotations as private drafts until explicitly submitted, preventing premature code edits when Auto-Send is disabled.
- **Multi-Mode Canvas**: Single widget inspect, marquee rectangular multi-selection, grouped multi-element picking, and freehand pencil sketching.
- **Animation Freeze**: Pause running tickers, transitions, loaders, and snackbars using Flutter native `TickerMode` for effortless inspection of transient UI states.
- **Zero Release Overhead**: Automatically compiles out in release builds (`debugOnly: true` by default), rendering zero widgets and consuming zero runtime resources in production.

---

## Quickstart

### 1. Add Dependency

In your Flutter project terminal, run:

```bash
flutter pub add flutter_agentation
```

Or add it directly to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_agentation: ^0.1.0
```

### 2. Wrap Your App

In `lib/main.dart`, wrap your `MaterialApp` or `CupertinoApp` using `FlutterAgentation.builder()`:

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
      // Attach at the builder level to persist across all routes and modals:
      builder: FlutterAgentation.builder(),
      home: const HomeScreen(),
    );
  }
}
```

*Note: `debugOnly: true` is enabled by default. In release mode (`kDebugMode == false`), Flutter Agentation returns the child widget tree directly with zero performance overhead.*

### 3. Run the CLI Setup (`setupmcp`)

In your workspace root terminal, run:

```bash
dart run flutter_agentation:setupmcp
```

This single command sets up both MCP configuration and AI agent skills directly inside `.flutter_agentation/`:

- `.flutter_agentation/mcp.json`: Universal MCP configuration for your IDE.
- `.flutter_agentation/config.json`: Runtime port and endpoint metadata.
- `.flutter_agentation/tools.json`: LLM tool schemas for inspection and annotation operations.
- `.flutter_agentation/llm_instructions.md`: Ready-to-use prompt and system instructions for AI models.
- `.flutter_agentation/SKILL.md`: Spec-Kit-style agent skill defining the feedback lifecycle.
- `.flutter_agentation/commands/`: Pre-configured slash commands for agent chats.

Everything is isolated entirely in `.flutter_agentation/` and registered for IDE discovery.

### 4. Run App and Inspect

Run your Flutter application on any platform (Mobile, Desktop, or Web):

```bash
flutter run
```

A floating toolbar appears on your screen. Tap the crosshair icon or press `Ctrl+Shift+A` (`Cmd+Shift+A` on macOS) to begin inspecting widgets.

---

## Spec-Kit AI Agent Workflow

Flutter Agentation provides a promptless workflow inspired by GitHub Spec-Kit. Once `setupmcp` is executed, your AI agent has predefined slash commands to inspect, navigate, and edit code autonomously.

### Available Slash Commands

#### 1. `/flutter-agentation-check-mcp`
Checks MCP connection status across all platforms and outputs diagnostic details:

```bash
/flutter-agentation-check-mcp
```

Reports:
- **Status**: Live & Connected (Toggle ON) or Inactive (Toggle OFF)
- **Auto-Send State**: ON (instant submission) or OFF (manual send button)
- **Port & Transports**: SSE (`:4747/sse`) and HTTP (`:4747/mcp`)
- **Submitted Pins**: Count of annotations ready for agent review
- **Draft Pins**: Count of local unsent annotations waiting in app

#### 2. `/flutter-agentation-review-feedback`
Directs your agent to review submitted visual annotations and apply code modifications:

```bash
/flutter-agentation-review-feedback
```

When invoked, the agent executes the review lifecycle:
1. **Fetch**: Retrieves submitted feedback pins with exact widget types, source locations (`lib/screens/home.dart:42`), and user notes.
2. **Context**: Examines widget hierarchy, parent tree, comments, sketches, and severity.
3. **Edit**: Opens the source file at the exact line number and applies the requested modifications.
4. **Verify**: Flutter Hot Reload immediately reflects changes on the running device/browser.
5. **Resolve**: Marks the issue resolved and immediately removes the pin from the running application.

---

## AI Agent IDE Setup

When you run `dart run flutter_agentation:setupmcp`, `.flutter_agentation/mcp.json` is generated automatically. To configure your editor manually:

### Cursor IDE

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

### Windsurf IDE

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

### Claude Desktop

Add to your `claude_desktop_config.json` (`%APPDATA%\Claude` on Windows, `~/Library/Application Support/Claude` on macOS):

```json
{
  "mcpServers": {
    "flutter-agentation": {
      "url": "http://127.0.0.1:4747/sse"
    }
  }
}
```

### VS Code (Cline, Roo Code, Continue)

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

### Claude Code CLI

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

---

## Target Platform Transports

Flutter Agentation MCP server runs natively on all major operating systems:

| Platform | Command | Connection Method |
|---|---|---|
| **Windows** | `flutter run -d windows` | Direct localhost (`http://127.0.0.1:4747/sse`) |
| **Linux** | `flutter run -d linux` | Direct localhost (`http://127.0.0.1:4747/sse`) |
| **macOS** | `flutter run -d macos` | Direct localhost (`http://127.0.0.1:4747/sse`) |
| **Android (Device & Emulator)** | `flutter run -d <device>` | Forward port via ADB: `adb forward tcp:4747 tcp:4747` |
| **iOS Simulator** | `flutter run -d <simulator>` | Direct localhost (`http://127.0.0.1:4747/sse`) |
| **iOS Physical Device** | `flutter run -d <device>` | Connect via local Wi-Fi IP (`http://<device-ip>:4747/sse`) |
| **Web (Chrome / Edge)** | `flutter run -d chrome` | Automated via MCP config (`command: dart run flutter_agentation:mcp`) |

### Android ADB Port Forwarding

When running on Android (emulator or physical phone over USB), run this command once in your terminal so your desktop AI agent can reach the Android app:

```bash
adb forward tcp:4747 tcp:4747
```

*(This is also configured automatically if ADB is detected when you run `dart run flutter_agentation:setupmcp`.)*

### Customizing the MCP Port

By default, the MCP server runs on port `4747`. To use a custom port (e.g. `4848`):

In terminal:
```bash
dart run flutter_agentation:setupmcp --port 4848
```

In code:
```dart
FlutterAgentation(
  mcpPort: 4848,
  child: child,
)
```

---

## Webhooks Flow

If your team uses automated pipelines, Slack notifications, or custom agent proxies, you can configure webhooks to push annotations instantly.

### Setting Up Webhooks

#### In Code
```dart
FlutterAgentation(
  webhookUrl: 'https://your-server.com/api/agentation-webhook',
  autoSendWebhooks: true, // Dispatch automatically on every new annotation
  child: child,
)
```

#### In the In-App Toolbar
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

## In-App Toolbar Modes

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
   Drag skeleton wireframe components (Button, Input, Card, Text, Avatar, Image) onto your live app, or reposition existing widgets to generate coordinate delta diffs for your agent.
6. **Animation Freeze (Pause/Play Icon)**:
   Freezes running tickers, transitions, and loaders using Flutter native `TickerMode`. Inspect transient snackbars, dialogs, and animations without them closing.

---

## Output Detail Levels

Click the detail level pill on the toolbar to cycle between 4 formats:

- **Compact**: Essential summary (Widget type + comment).
- **Standard**: Clean report with key attributes, coordinates, and comment.
- **Detailed**: Comprehensive report with parent breadcrumbs, padding, constraints, and source file locations.
- **Forensic**: Full debugging tree payload with all ancestor elements, identifying attributes, and raw metrics.

When you click **Copy**, formatted markdown is copied to your clipboard, ready to paste into any chat if you are not using the direct MCP connection.

---

## Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| `Ctrl+Shift+A` / `Cmd+Shift+A` | Toggle Agentation inspection mode |
| `Ctrl+Shift+F` / `Cmd+Shift+F` | Toggle feedback overlay |
| `Alt+I` | Toggle inspect mode |
| `L` | Toggle layout wireframing palette |
| `P` | Pause / freeze running animations |
| `H` / `Alt+V` | Toggle comments & markers visibility |
| `C` | Copy annotations as Markdown to clipboard |
| `S` | Submit draft annotations to agent transport |
| `X` | Clear all annotations |
| `Delete` / `Backspace` | Delete selected feedback pin or skeleton |
| `Ctrl+Enter` / `Cmd+Enter` | Submit active annotation modal |
| `Escape` | Close active dialog / clear selection |
| `Ctrl+Z` / `Cmd+Z` | Undo last action |
| `Ctrl+Shift+Z` / `Cmd+Y` | Redo last action |
| `Arrow Keys` | Nudge selected marker position |

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

## Example Project

The `example/` folder contains a full demonstration app featuring an unboxed, editorial minimalist landing page and an interactive target playground with live counter, controls, and telemetry inspector.

To run the example:

```bash
cd example
flutter run
```

---

## Verification & Testing

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
