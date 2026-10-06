# Flutter Agentation 🎯

> **Zero-dependency, production-grade visual inspection and annotation engine for Flutter applications.** Turn UI feedback, bug reports, and design tweaks into structured context your AI coding agent (Claude, Cursor, Copilot, Antigravity) can understand and implement with surgical precision.

Inspired by [Agentation](https://github.com/agentation), **Flutter Agentation** brings 100% of the desktop/web visual feedback workflow natively into Flutter for iOS, Android, macOS, Windows, Linux, and Web.

---

## ✨ Features at a Glance

### 1. 🔍 Multi-Mode Interaction Engine

- **Widget Inspect**: Hover highlight with live bounding boxes, click to pin comment, breadcrumb widget hierarchy trail, and auto-extracted properties (widget type, key, text, bounds, constraints).
- **Area Selection (Marquee)**: Click and drag rectangular regions to annotate complex layouts or multiple elements at once.
- **Multi-Select**: Group non-contiguous widgets across the screen into a single linked annotation.
- **Freehand Drawing Canvas**: Draw arrows, circles, and sketch notes directly over the running application with custom stroke colors and widths.

### 2. 🎨 Visual Design Mode

- **Component Palette**: Drag-and-drop 6 wireframe skeleton widgets (**Button**, **Input Field**, **Card**, **Text Block**, **Avatar**, **Image**) onto your live app.
- **Spatial Alignment Guides**: Real-time crosshairs, snap lines, and coordinate dimension indicators during drag operations.
- **Rearrange Controller**: Drag and reposition existing widgets on screen, generating structured `rearrange` annotations showing source coordinates, target coordinates, and Euclidean distance moved.

### 3. ⏸️ Animation Freeze Controller

- **Instant Pause / Resume**: Dynamically pauses tickers, transitions, and loading spinners using Flutter's native `TickerMode` without blocking the UI thread or crashing the host app. Inspect transient states, sheets, and micro-interactions effortlessly.

### 4. 🎛️ Floating Pill Toolbar & Detail Levels

- **Quick Controls**: Segmented mode switchers, freeze toggle, undo/redo history, copy button, and clear actions.
- **Detail Level Cycling**: Cycle between 4 output formats tailored for human review or LLM prompts:
  - `Compact`: Minimal summary with widget type and user comment.
  - `Standard`: Clean readable overview with key attributes and coordinates.
  - `Detailed`: Full structural report with parent breadcrumbs and box constraints.
  - `Forensic`: Deep debugging payload including complete widget tree path, identifying attributes, and raw metrics.
- **Multi-Format Export**: Copy annotations directly to clipboard as **Markdown**, **JSON**, **Agentation Protocol**, **Source Links**, or **Attributes**.

### 5. ⚙️ Slide-Out Settings & Theming

- **Dark & Light Mode**: Sleek glassmorphic theme designed to blend seamlessly with any app.
- **6 Curated Swatches**: Coral Red, Sky Blue, Emerald Green, Amber Gold, Violet Purple, and Slate Grey.
- **Interaction Blocking**: Prevent accidental taps into underlying app widgets while annotating.
- **Auto-Clear on Copy**: Automatically reset annotations after copying to streamline rapid feedback loops.

### 6. 🤖 Agent Sync & Model Context Protocol (MCP)

- **Direct MCP Integration**: Zero-dependency HTTP client connecting your app directly to `agentation-mcp` servers (`/sessions`, `/sessions/:id/annotations`, `/sessions/:id/action`).
- **Webhooks**: Automatic dispatching of new annotations to webhooks or local LLM proxies.
- **Conversational Threads**: Two-way chat messages attached to any annotation card, allowing AI agents to ask clarifying questions and human developers to reply inline.

### 7. 🛡️ Zero Dependencies & Performance

- Built **100% on the core Flutter and Dart SDKs** (`dart:io`, `dart:convert`, `dart:ui`).
- No external packages, no dependency conflicts, no framework leaks.

---

## 🚀 Quick Start

### 1. Add to `pubspec.yaml`

```yaml
dependencies:
  flutter_agentation:
    path: ../flutter_agentation # or git/pub reference
```

### 2. Wrap Your App

Wrap your app or screen with `FlutterAgentation`:

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
      // Place FlutterAgentation on the builder level to persist across all routes, modals, and dialogs:
      builder: (context, child) {
        return FlutterAgentation(

          child: child,
        );
      },
      home: const HomeScreen(),
    );
  }
}
```

Or using the concise `FlutterAgentation.builder` shortcut:

```dart
MaterialApp(
  title: 'My App',
  builder: FlutterAgentation.builder(),
  home: const HomeScreen(),
)
```

That's it! When running your app, the floating pill toolbar will appear at the bottom-right of the screen and persist seamlessly across all routes and navigation stacks.

---

## 📖 Usage Guide

### Programmatic Control

Access `AgentationController` anywhere in your widget tree:

```dart
// Open or toggle inspection overlay
AgentationController.of(context).toggle();

// Switch interaction modes
AgentationController.of(context).setMode(InspectionMode.area);
AgentationController.of(context).setMode(InspectionMode.draw);
AgentationController.of(context).setMode(InspectionMode.design);

// Freeze / Resume animations
AgentationController.of(context).toggleFreeze();

// Cycle output detail level
AgentationController.of(context).cycleDetailLevel();

// Copy annotations formatted for AI agents
final markdown = await AgentationController.of(context).copyToClipboard(
  format: ExportFormat.markdown,
);
```

---

### Customizing Settings & Defaults

```dart
builder: (context, child) {
  return FlutterAgentation(
    initialDetailLevel: OutputDetailLevel.detailed,
    initialToolbarAlignment: Alignment.bottomRight,
    showToolbar: true,
    highlightStyle: const HighlightStyle(),
    onWidgetSelected: (result) {
      print('Selected: ${result.identity.widgetType} (${result.identity.id})');
    },
    child: child,
  );
}
```

---

## 🛠️ Testing

The package includes comprehensive unit, widget, and integration tests:

```bash
# Run all tests
flutter test

# Run analyzer
flutter analyze
```

---

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.
