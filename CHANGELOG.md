## 1.0.0

* First official stable release of Flutter Agentation.
* Comprehensive Model Context Protocol (MCP) server supporting JSON-RPC 2.0 via SSE & Stdio on port 4747.
* Spec-Kit promptless workflow with native slash commands (`/flutter-agentation-check-mcp`, `/flutter-agentation-review-feedback`).
* Visual Wireframing & Layout Mode with realistic skeleton components and counter-question dialogs.
* Deep Widget Inspection resolving RenderBox bounds, ancestor breadcrumbs, and exact Dart source line mapping.
* Draft Annotation Protection preventing unsent feedback from leaking to AI agents when Auto-Send is disabled.
* Animation Freeze controller using Flutter's native `TickerMode`.
* Multi-platform support across Windows, macOS, Linux, Android (ADB reverse port forwarding), iOS, and Web.
* Zero-overhead release compilation (`debugOnly: true` by default).

## 0.1.0

* Initial production release of Flutter Agentation.
* **Visual UI Inspection Engine**: Click or hover any widget to inspect bounding boxes, exact source file, line number, and widget hierarchy.
* **Floating Annotation Toolbar**: Morphing pill toolbar with Inspection, Drawing/Sketching, Wireframe Placement, Layout Rearrange, and Settings panels.
* **Model Context Protocol (MCP) Server**: Built-in HTTP and SSE transports (`:4747`) allowing AI coding agents (Cursor, Claude Desktop, Windsurf, VS Code, Antigravity) to query active UI state and annotations.
* **Auto-Send & Draft Control**: Support for both instant streaming (Auto-Send ON) and manual batch submission (Auto-Send OFF with toolbar Send button and badge counter).
* **Cross-Platform Compatibility**: Full support across Web (Chrome, Edge, Safari, Firefox), Desktop (Windows, macOS, Linux), and Mobile (Android, iOS).
* **CLI Setup Tool**: `dart run flutter_agentation:setupmcp` to generate agent configuration, skill files, and slash commands in `.flutter_agentation/`.
* **Zero-Overhead Release Protection**: Automatically disables in release builds (`debugOnly: true`) with zero performance cost.
* **Webhook & Export Integrations**: Real-time webhook dispatching and clipboard exports (Markdown, JSON, HTML).
