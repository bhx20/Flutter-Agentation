# Flutter Agentation

[![pub package](https://img.shields.io/pub/v/flutter_agentation.svg)](https://pub.dev/packages/flutter_agentation)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://pub.dev/packages/flutter_agentation/license)
[![platforms](https://img.shields.io/badge/platforms-flutter%20%7C%20android%20%7C%20ios%20%7C%20web%20%7C%20macos%20%7C%20windows%20%7C%20linux-lightgrey.svg)](https://pub.dev/packages/flutter_agentation)

A developer-first visual inspection, layout wireframing, and Model Context Protocol (MCP) context engine for Flutter applications.

Instead of manually hunting for widget source files and copying layout dimensions to explain UI bugs, Flutter Agentation lets you click any element in your running app, write a note or sketch, and stream the exact source file path, line number, widget tree hierarchy, and bounding box directly to your AI coding agent (Cursor, Claude Desktop, Windsurf, VS Code, or Antigravity) via the Model Context Protocol (JSON-RPC 2.0) or webhooks.

---

## Installation

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
  flutter_agentation: ^1.0.0
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

## Architecture Overview

```
+---------------------------------------------------------------------------------------------------------+
|                                    RUNNING FLUTTER APPLICATION                                          |
|                                                                                                         |
|   +------------------------------------+  +----------------------------------+  +-------------------+   |
|   |   Visual Ingestion & Overlay       |  |   Visual Wireframing & Design    |  |  Runtime Control  |   |
|   |   - Element Inspection (Crosshair) |  |   - Skeleton Component Palette   |  |  - Keymap (Ctrl+  |   |
|   |   - Marquee Area Selection         |  |   - Drag & Drop Placement        |  |     Shift+A, S, C) |   |
|   |   - Multi-Element Grouping         |  |   - Relative Coordinate Diffs    |  |  - Animation      |   |
|   |   - Freehand Pencil Sketching      |  |   - Counter-Question Dialogs     |  |     Freeze Mode   |   |
|   +-----------------+------------------+  +-----------------+----------------+  +---------+---------+   |
|                     |                                       |                             |             |
|                     +-------------------+-------------------+-----------------------------+             |
|                                         |                                                               |
|                                         v                                                               |
|   +-------------------------------------------------------------------------------------------------+   |
|   |                            CONTEXT & SOURCE RESOLUTION ENGINE                                   |   |
|   |                                                                                                 |   |
|   |   - HitTestEngine: Traverses render object trees & resolves RenderBox global bounds             |   |
|   |   - SourceLocationResolver: Walks Element ancestors to resolve file:line (e.g. home.dart:42)    |   |
|   |   - WidgetPathResolver: Extracts breadcrumb hierarchy (MaterialApp > Scaffold > ... > Button)   |   |
|   |   - SourceCodeExtractor: Reads local Dart source snippet around identified line number          |   |
|   |   - Semantics & Text Resolver: Extracts developer keys, semantic labels, and text contents       |   |
|   +-------------------------------------+-----------------------------------------------------------+   |
|                                         |                                                               |
|                                         v                                                               |
|   +-------------------------------------------------------------------------------------------------+   |
|   |                          STATE STORAGE & DRAFT PROTECTION LAYER                                 |   |
|   |                                                                                                 |   |
|   |   - Draft Protection: autoSendMcp=false keeps pins as private drafts until explicit submission  |   |
|   |   - Local Storage: In-memory & JSON file persistence across Flutter Hot Reloads                  |   |
|   |   - Output Adapters: 4 Detail Levels (Compact, Standard, Detailed, Forensic)                   |   |
|   +-------------------------------------+-----------------------------------------------------------+   |
+-----------------------------------------|---------------------------------------------------------------+
                                          |
               +--------------------------+--------------------------+
               |                                                     |
               v                                                     v
+-------------------------------+                     +-------------------------------+
|      NATIVE MCP SERVER        |                     |      WEBHOOK DISPATCHER       |
|    (JSON-RPC 2.0 via SSE)     |                     |     (Automated HTTP POST)     |
|                               |                     |                               |
|   - Port 4747 (/sse, /mcp)    |                     |   - CI/CD Automated Pipelines |
|   - 6 Native LLM Tools:       |                     |   - Slack / Discord Bot Hooks |
|     * list_annotations        |                     |   - Proxy Endpoints & PRs     |
|     * get_app_state           |                     +-------------------------------+
|     * inspect_widget          |                                    |
|     * add_annotation          |                                    |
|     * clear_annotations       |                     +--------------v----------------+
|     * take_screenshot         |                     |      CLIPBOARD EXPORTER       |
+---------------+---------------+                     |  (Markdown & JSON Envelopes)  |
                |                                     +-------------------------------+
                v
+---------------------------------------------------------------------------------------------------------+
|                                MULTI-PLATFORM TRANSPORT GATEWAY                                         |
|                                                                                                         |
|   +-------------------+  +-------------------+  +-------------------+  +----------------------------+   |
|   |      Desktop      |  |      Android      |  |        iOS        |  |       Web (Browser)        |   |
|   | (macOS/Win/Linux) |  | (Device/Emulator) |  | (Simulator/Device)|  | (Chrome, Edge, Safari)     |   |
|   | Direct TCP Socket |  | ADB Port Forward  |  | Localhost / Wi-Fi |  | Background Bridge Process  |   |
|   |   port :4747      |  | tcp:4747 tcp:4747 |  |  LAN IP port 4747 |  | dart run ..:mcp --port 4747|   |
|   +---------+---------+  +---------+---------+  +---------+---------+  +--------------+-------------+   |
+-------------|----------------------|----------------------|---------------------------|-----------------+
              +----------------------+----------------------+---------------------------+
                                     |
                                     v
+---------------------------------------------------------------------------------------------------------+
|                                     AI CODING AGENTS & SPEC-KIT                                         |
|                                                                                                         |
|     Cursor  |  Claude Desktop  |  Windsurf  |  VS Code (Cline / Roo)  |  Antigravity                    |
|                                                                                                         |
|   Automated Slash Commands:                                                                             |
|   * /flutter-agentation-check-mcp: Queries port health, SSE transports, submitted vs draft pins         |
|   * /flutter-agentation-review-feedback: Reads annotations, opens source file, modifies code,           |
|                                         triggers Hot Reload, and automatically resolves pin             |
+---------------------------------------------------------------------------------------------------------+
```

### Architectural Subsystems

1. **Ingestion & Visual Overlay Canvas (`lib/src/ui/`)**:
   - Injected globally via `FlutterAgentation.builder()` across all screens, modals, and route navigations.
   - Provides 5 interactive inspection modes: single element inspection, marquee bounding box selection, multi-element picking, freehand pencil sketching, and layout wireframing.
   - Embeds the floating, draggable `AgentationToolbar` with interactive minimization, color marker selection, and theme-adaptive styling.
   - Houses the `AnimationFreeze` controller using Flutter's native `TickerMode` to pause and inspect transient loaders, snackbars, and animations in place.

2. **Context & Source Resolution Engine (`lib/src/inspection/` & `lib/src/source_location/`)**:
   - `HitTestEngine`: Performs deep hit-testing against active render object trees and computes exact global `Rect` bounds via `BoundsResolver`.
   - `SourceLocationResolver`: Walks up the widget Element hierarchy to discover author code files, extracting file paths and source line numbers (e.g. `lib/views/home.dart:42`).
   - `WidgetPathResolver`: Builds complete ancestor breadcrumb paths (`MaterialApp > Scaffold > SafeArea > Column > ElevatedButton`).
   - `WidgetCodeResolver` & `SourceCodeExtractor`: Extracts surrounding source code context around the widget declaration for instant AI model comprehension.
   - `SemanticsResolver`: Captures accessibility labels, values, flags, and developer keys.

3. **State Management & Draft Safety Protection (`lib/src/core/` & `lib/src/domain/`)**:
   - `AgentationController`: Unified central controller managing mode transitions, selection bounds, and annotation lifecycles.
   - **Draft Protection Barrier**: Annotations remain local drafts when `autoSendMcp` is disabled. Prevents AI agents from reading work-in-progress or unapproved notes until the user explicitly presses `S` or taps the Send button.
   - `AgentationFormatAdapter`: Formats annotations into 4 discrete detail levels (`Compact`, `Standard`, `Detailed`, `Forensic`).

4. **Dual Dispatch & Networking Gateway (`lib/src/networking/`)**:
   - **Native Model Context Protocol (MCP) Server**: Embedded HTTP/SSE JSON-RPC 2.0 server operating on port 4747. Exposes 6 LLM tools (`list_annotations`, `get_app_state`, `inspect_widget`, `add_annotation`, `clear_annotations`, `take_screenshot`).
   - **Webhook Dispatcher**: Dispatches asynchronous JSON HTTP POST payloads directly to CI/CD pipelines, automated PR bots, Slack, or proxy endpoints.
   - **Clipboard Exporter**: One-click export of AI-ready Markdown and structured JSON payloads directly to system clipboard.

5. **Multi-Platform Transport Gateway**:
   - **Desktop (Windows, macOS, Linux)**: Direct TCP socket listening on `127.0.0.1:4747`.
   - **Android (Emulator & Physical Device)**: Automated ADB reverse port forwarding (`adb forward tcp:4747 tcp:4747`).
   - **iOS (Simulator & Physical Device)**: Direct localhost socket on Simulator; local Wi-Fi LAN IP on physical device.
   - **Web (Chrome, Edge, Safari)**: Automated background sync bridge (`dart run flutter_agentation:mcp --port 4747`).

6. **AI Agent & Spec-Kit Orchestration (`.flutter_agentation/`)**:
   - Configured via `dart run flutter_agentation:setupmcp`.
   - Dispatches slash commands (`/flutter-agentation-check-mcp`, `/flutter-agentation-review-feedback`) natively supported by Cursor, Claude Desktop, Windsurf, VS Code (Cline/Roo), and Antigravity.

---

### Use-Case Coverage Matrix

| Use Case | Trigger | Subsystems Involved | Output / Result |
|---|---|---|---|
| **1. Widget Bug Reporting & Source Mapping** | Click widget in inspection mode | `HitTestEngine`, `BoundsResolver`, `SourceLocationResolver` | Captures widget type, exact `file:line`, hierarchy, and bounds. |
| **2. Autonomous AI Code Fixes (MCP)** | `/flutter-agentation-review-feedback` | MCP Server, `list_annotations`, `clear_annotations` | AI agent reads pin, locates source line, edits code, hot reloads, and clears pin. |
| **3. Spec-Kit Health & Transport Diagnostics** | `/flutter-agentation-check-mcp` | MCP Server, `get_app_state` | Reports connection status, port health, draft pins, and submitted pins. |
| **4. Visual Wireframing & Layout Drafting** | Drag skeleton component from palette | Design Mode, `ComponentCounterQuestionDialog` | Drops skeleton (Button, Card, Input) and captures relative coordinates & spec requirements. |
| **5. Transient Animation & Loader Freeze** | Tap Pause icon or press `P` | `TickerMode`, `InspectionOverlay` | Freezes transitions, loaders, and closing dialogs for inspection. |
| **6. Multi-Widget & Area Issue Grouping** | Drag marquee box or multi-click | Marquee selector, Grouped annotation model | Bundles multiple widgets into a single composite issue ticket. |
| **7. Freehand Drawing & Visual Alignment** | Draw with pen tool | `DrawingStroke`, `CustomPainter` | Renders freehand callouts and circles on screen, exported in Markdown report. |
| **8. Automated CI/CD & Webhook Pipelines** | Submit annotation with Webhook URL | `WebhookDispatcher`, HTTP Client | Sends instant JSON payload to remote servers, Slack bots, or PR generators. |
| **9. Manual Prompt Copy-Paste Fallback** | Tap Copy or press `C` | `ClipboardExporter`, `AnnotationMarkdownEncoder` | Copies AI-ready Markdown report to clipboard for manual chat pasting. |
| **10. Zero-Overhead Production Builds** | `kDebugMode == false` (Release build) | `FlutterAgentation.builder(debugOnly: true)` | Bypasses all overlays, listeners, and servers; returns child widget directly. |

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

## In-App Toolbar Modes & Controls

The floating toolbar combines **5 interactive canvas inspection modes** with **8 quick-action control tools**:

### 1. Interactive Canvas Modes

1. **Element Inspect (Pointer Tool)**:
   Hover over any widget to view real-time bounding box highlights, widget type, and ancestor breadcrumbs. Click to drop a pin, write feedback, and view exact Dart source line numbers.
2. **Area Selection (Marquee Tool)**:
   Click and drag a marquee rectangle across any region of the screen to capture and inspect multiple widgets simultaneously (ideal for complex card layouts or list views).
3. **Multi-Select Picking**:
   Click multiple distinct widgets across the viewport to bundle related UI components into a single composite feedback item.
4. **Freehand Drawing (Sketch Tool)**:
   Draw directly over your application UI using a pencil canvas to circle visual bugs, sketch alignment arrows, or highlight spacing issues.
5. **Visual Wireframing & Design Mode (`L`)**:
   Open a palette of drag-and-drop skeleton components (Button, Input, Card, Text, Avatar, Image) onto the live UI. Dropping a skeleton opens interactive counter-question dialogs to specify requirements and calculates relative coordinate deltas for your AI agent.

### 2. Toolbar Quick-Action Controls

| Icon / Control | Shortcut | Function |
|---|---|---|
| **Pause / Resume (Pause / Play)** | `P` | Freezes or resumes running transitions, loaders, tickers, and closing dialogs using Flutter's native `TickerMode` for in-place inspection. |
| **Component Palette** | `L` | Toggles the visual wireframing skeleton palette for dragging UI components directly onto your live layout. |
| **Show / Hide Markers (Eye)** | `H` / `Alt+V` | Toggles on-screen feedback pins and drawing strokes without deleting them, allowing you to view the clean UI underneath. |
| **Copy Feedback** | `C` | Exports all active annotations as structured, AI-ready Markdown or JSON directly to your system clipboard. |
| **Send Annotations (Paper Plane)** | `S` | Submits local draft annotations to the native MCP server and webhooks. Displays a live badge counter indicating unsubmitted drafts. |
| **Clear All (Trash)** | `X` | Wipes all active markers, pins, skeleton placements, and drawing strokes from the screen. |
| **Settings (Gear)** | None | Opens the configuration flyout with a live MCP connection status indicator dot (Connected / Connecting / Inactive), port settings, and webhook management. |
| **Morphing End-Cap Toggle** | `Esc` / `Ctrl+Shift+A` | Minimizes the toolbar into a compact circular badge or expands it into the full action bar. |

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
// 1. Retrieve controller from context
final controller = AgentationController.of(context);
// or:
final controller = AgentationScope.of(context);

// 2. Control inspection overlay state
controller.activate(freeze: false); // Activate inspection mode
controller.deactivate();            // Deactivate overlay
controller.toggle();                // Toggle between inspecting and inactive

// 3. Switch interaction tool modes
controller.setToolMode(AnnotationToolMode.pointer);     // Single element inspector
controller.setToolMode(AnnotationToolMode.area);        // Marquee bounding box
controller.setToolMode(AnnotationToolMode.multiSelect); // Multi-widget picker
controller.setToolMode(AnnotationToolMode.draw);        // Freehand pencil sketch
controller.setToolMode(AnnotationToolMode.design);      // Wireframe layout skeleton

// 4. Freeze / resume tickers & animations (TickerMode)
controller.toggleFreeze();
controller.freeze();
controller.unfreeze();

// 5. Toggle layout palette, markers, and settings
controller.toggleLayoutMode();          // Open/close wireframe skeleton palette
controller.toggleCommentsVisibility();  // Show/hide on-screen markers
controller.toggleSettings();            // Open/close settings & MCP flyout
controller.toggleToolbarMinimized();    // Collapse/expand floating toolbar

// 6. Manage output detail levels
controller.cycleDetailLevel();                          // Cycle through levels
controller.setDetailLevel(OutputDetailLevel.detailed);  // compact, standard, detailed, forensic

// 7. Export, copy, and submit annotations
final markdown = await controller.copyToClipboard(format: ExportFormat.markdown);
final json = await controller.copyToClipboard(format: ExportFormat.json);
await controller.submitAnnotations(); // Submit unsent drafts to MCP server & webhooks
await controller.clearAnnotations();  // Clear all annotations from screen

// 8. Reactive state listening (AgentationController is a ChangeNotifier)
controller.addListener(() {
  final state = controller.state;
  debugPrint('Mode: ${state.mode}, Tool: ${state.toolMode}, Frozen: ${state.isFrozen}');
  debugPrint('Total Annotations: ${controller.annotations.length}');
  debugPrint('Unsent Drafts: ${controller.unsentAnnotations.length}');
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

```
MIT License

Copyright (c) 2026 Flutter Agentation Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
