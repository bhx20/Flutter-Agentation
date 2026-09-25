# MASTER PROMPT

## Build a Production-Grade Flutter Visual Inspection & Annotation Package

You are a senior Flutter framework engineer and package architect.

I want you to build a **production-grade Flutter package inspired by the capabilities described in the provided Agentation research report**, but implemented as a **Flutter-native solution**.

The most important architectural decision is:

> **The Flutter Inspection Engine is the foundation of the entire package.**

Do NOT treat widget inspection as a secondary feature.

The package must be designed to inspect arbitrary Flutter applications with minimal integration and should work across common Flutter architectures and workflows.

The package must be designed as a reusable developer tool/package, not as an application-specific implementation.

---

# 1. PRIMARY OBJECTIVE

Build a Flutter package that allows developers to add:

```dart
FlutterAgentation(
  child: MyApp(),
)
```

and then inspect their running Flutter application visually.

The developer should be able to:

1. Activate inspection mode.
2. Tap any visible Flutter widget.
3. Detect the corresponding Flutter `Element` / `RenderObject`.
4. Determine the widget type.
5. Determine its bounds and global coordinates.
6. Determine its widget ancestry/path.
7. Detect available `Key` information.
8. Extract useful text/content information.
9. Extract semantic/accessibility information where available.
10. Capture route/page information.
11. Create an annotation against that widget.
12. Display an annotation marker.
13. Edit/delete the annotation.
14. Export annotations as JSON and Markdown.
15. Persist annotations locally.
16. Support multiple annotation modes.
17. Eventually synchronize annotations with an AI/MCP backend.

The first priority is **reliable Flutter widget inspection**.

---

# 2. IMPORTANT ARCHITECTURAL PRINCIPLE

Do NOT build the package around manually wrapping every widget.

The package must attempt to inspect existing Flutter applications automatically.

The preferred flow is:

```text
Flutter Application
        ↓
FlutterAgentation
        ↓
Inspection Overlay
        ↓
Pointer/Gesture Detection
        ↓
Flutter Element Tree
        ↓
RenderObject
        ↓
Widget Inspection Engine
        ↓
Widget Context
        ↓
Annotation Engine
        ↓
Annotation Output
```

Manual instrumentation should be an optional enhancement, not a requirement.

---

# 3. PACKAGE NAME

Use:

```text
flutter_agentation
```

If the name is already unavailable or inappropriate, use:

```text
flutter_visual_inspector
```

but keep the architecture independent from the final package name.

---

# 4. PROJECT STARTUP

First create a complete Flutter package project.

Use:

```bash
flutter create --template=package flutter_agentation
```

Then create a dedicated example application.

The repository should contain:

```text
flutter_agentation/
│
├── lib/
│   ├── flutter_agentation.dart
│   │
│   └── src/
│
├── example/
│   ├── lib/
│   ├── test/
│   └── pubspec.yaml
│
├── test/
│
├── integration_test/
│
├── README.md
├── CHANGELOG.md
├── LICENSE
├── pubspec.yaml
├── analysis_options.yaml
└── .github/
    └── workflows/
```

The package must compile immediately after project creation.

Before implementing features:

```bash
flutter pub get
flutter analyze
flutter test
```

must succeed.

---

# 5. CORE PACKAGE ARCHITECTURE

Use this architecture:

```text
lib/
└── src/
    │
    ├── core/
    │   ├── flutter_agentation.dart
    │   ├── agentation_controller.dart
    │   ├── agentation_scope.dart
    │   ├── agentation_config.dart
    │   └── agentation_state.dart
    │
    ├── inspection/
    │   ├── flutter_inspection_engine.dart
    │   ├── element_inspector.dart
    │   ├── render_object_inspector.dart
    │   ├── widget_inspector.dart
    │   ├── widget_path_resolver.dart
    │   ├── widget_identity_resolver.dart
    │   ├── bounds_resolver.dart
    │   ├── text_resolver.dart
    │   ├── semantics_resolver.dart
    │   ├── route_resolver.dart
    │   ├── key_resolver.dart
    │   └── inspection_result.dart
    │
    ├── models/
    │   ├── widget_context.dart
    │   ├── widget_info.dart
    │   ├── widget_bounds.dart
    │   ├── widget_identity.dart
    │   ├── annotation.dart
    │   ├── annotation_session.dart
    │   ├── annotation_status.dart
    │   ├── annotation_intent.dart
    │   └── annotation_severity.dart
    │
    ├── annotation/
    │   ├── annotation_engine.dart
    │   ├── annotation_controller.dart
    │   ├── annotation_repository.dart
    │   └── annotation_manager.dart
    │
    ├── modes/
    │   ├── inspection_mode.dart
    │   ├── element_mode.dart
    │   ├── text_mode.dart
    │   ├── area_mode.dart
    │   └── multi_select_mode.dart
    │
    ├── overlay/
    │   ├── inspection_overlay.dart
    │   ├── widget_highlight.dart
    │   ├── annotation_marker.dart
    │   ├── selection_overlay.dart
    │   └── annotation_popup.dart
    │
    ├── toolbar/
    │   ├── agentation_toolbar.dart
    │   ├── toolbar_controller.dart
    │   └── toolbar_action.dart
    │
    ├── storage/
    │   ├── annotation_storage.dart
    │   ├── memory_annotation_storage.dart
    │   └── local_annotation_storage.dart
    │
    ├── output/
    │   ├── annotation_json_encoder.dart
    │   ├── annotation_markdown_encoder.dart
    │   └── agentation_format_adapter.dart
    │
    ├── networking/
    │   ├── annotation_sync_client.dart
    │   ├── webhook_client.dart
    │   └── realtime_client.dart
    │
    └── utils/
        ├── geometry_utils.dart
        ├── coordinate_utils.dart
        ├── platform_utils.dart
        └── debug_utils.dart
```

Do not create one giant Dart file.

Keep responsibilities isolated.

---

# 6. FLUTTER INSPECTION ENGINE

This is the highest-priority subsystem.

Create:

```dart
class FlutterInspectionEngine
```

It should be responsible for converting a user interaction into structured Flutter widget information.

Conceptually:

```text
Pointer position
      ↓
Hit testing
      ↓
RenderObject
      ↓
Element
      ↓
Widget
      ↓
WidgetContext
```

The engine must NOT depend on the application's state-management solution.

It must work with:

```text
setState
Provider
Riverpod
Bloc
Cubit
GetX
MobX
Redux
InheritedWidget
ValueNotifier
ChangeNotifier
custom state management
```

The inspection engine should operate at the Flutter framework/rendering layer.

---

# 7. INSPECTION RESULT

Create a strong immutable model:

```dart
class WidgetInspectionResult {
  final WidgetIdentity identity;
  final WidgetBounds bounds;
  final WidgetContext context;
  final String? route;
  final String? text;
  final List<String> ancestors;
  final Map<String, dynamic> metadata;
}
```

Do not expose internal framework objects outside the inspection layer unless absolutely necessary.

Avoid leaking:

```text
BuildContext
Element
RenderObject
```

into public package APIs wherever possible.

Convert framework objects into immutable inspection models.

---

# 8. WIDGET IDENTITY

The engine should resolve widget identity using multiple strategies.

Priority:

```text
1. Explicit Agentation identifier
2. Key
3. ValueKey
4. ObjectKey where safely representable
5. Widget runtime type
6. Widget ancestry
7. RenderObject information
```

Example:

```text
LoginPage
 └── LoginForm
      └── ElevatedButton
```

should produce:

```text
LoginPage > LoginForm > ElevatedButton
```

If:

```dart
ValueKey('login_button')
```

exists:

```text
LoginPage > LoginForm > login_button
```

If the developer explicitly provides:

```dart
AgentationTarget(
  id: 'login_button',
  child: ...
)
```

that should become the preferred identity.

---

# 9. OPTIONAL EXPLICIT TARGET

Provide:

```dart
AgentationTarget(
  id: 'login_button',
  child: ElevatedButton(
    onPressed: ...,
    child: const Text('Login'),
  ),
)
```

This is optional.

The package must still function without it.

The purpose is to provide deterministic identity in complex applications.

---

# 10. BOUNDS RESOLUTION

The inspection engine must calculate:

```text
x
y
width
height
left
top
right
bottom
```

using Flutter rendering information.

Support:

```text
RenderBox
RenderObject
globalToLocal
localToGlobal
paint bounds
```

Create:

```dart
class WidgetBounds {
  final double x;
  final double y;
  final double width;
  final double height;
}
```

Handle:

- nested transforms
- scrolling
- overlays
- nested navigators
- dialogs
- bottom sheets
- transformed widgets
- partially visible widgets
- off-screen widgets where possible

Do not assume every widget is a simple rectangular box.

---

# 11. HIT TESTING

Implement reliable pointer-to-widget resolution.

The package should not simply inspect the top-level `GestureDetector`.

Use Flutter's rendering/hit-testing capabilities to identify the render object beneath the pointer.

Create a dedicated service:

```dart
class FlutterHitTestEngine
```

Responsibilities:

```text
pointer position
        ↓
Flutter hit test
        ↓
candidate RenderObjects
        ↓
candidate Elements
        ↓
select inspectable target
```

Provide a mechanism to navigate through overlapping candidates if necessary.

Example:

```text
Tap
 ↓
IgnorePointer
 ↓
GestureDetector
 ↓
InkWell
 ↓
Container
 ↓
Text
```

The user should be able to inspect meaningful widgets rather than receiving an arbitrary internal render object.

---

# 12. WIDGET PATH RESOLUTION

Create:

```dart
class WidgetPathResolver
```

It should generate a stable human-readable hierarchy.

Example:

```text
MaterialApp
 > HomePage
 > Scaffold
 > SafeArea
 > Column
 > LoginForm
 > ElevatedButton
```

Avoid relying exclusively on `toString()`.

The resolver should gracefully handle:

```text
anonymous widgets
private widgets
closures
builder widgets
slivers
render-object widgets
platform widgets
custom widgets
```

---

# 13. TEXT EXTRACTION

Create:

```dart
class TextResolver
```

Attempt to extract visible user-facing text from the selected widget.

Support common Flutter widgets:

```text
Text
SelectableText
RichText
TextField
TextFormField
Button widgets
Tooltip
Semantics
EditableText
```

For unsupported widgets:

```text
null
```

Do not crash.

---

# 14. SEMANTICS / ACCESSIBILITY

Create:

```dart
class SemanticsResolver
```

Capture available information such as:

```text
label
hint
button
textField
enabled
checked
selected
toggled
```

Do not require accessibility to be enabled for the entire package.

Treat semantics as optional context.

---

# 15. ROUTE DETECTION

Create:

```dart
class RouteResolver
```

Attempt to identify:

```text
Navigator route
ModalRoute
route name
page identity
```

Support common navigation approaches without coupling to:

```text
go_router
auto_route
GetX
Navigator 1.0
Navigator 2.0
```

If a route cannot be determined:

```text
null
```

Never fail inspection because route detection is unavailable.

---

# 16. INSPECTION CONTEXT

Create:

```dart
class FlutterWidgetContext
```

with information such as:

```dart
class FlutterWidgetContext {
  final String widgetType;
  final String? key;
  final String? identifier;
  final String widgetPath;
  final String? route;
  final WidgetBounds bounds;
  final String? text;
  final SemanticsContext? semantics;
  final List<String> ancestors;
  final Map<String, dynamic> metadata;
}
```

This object should become the primary context attached to annotations.

---

# 17. ANNOTATION MODEL

Create:

```dart
class Annotation
```

with:

```text
id
comment
timestamp
widget context
position
bounds
route
widget identity
intent
severity
status
selected text
selected widgets
thread
metadata
```

Example:

```json
{
  "id": "ann_x001",
  "comment": "Make this button green",
  "timestamp": 1700000000000,
  "widget": {
    "type": "ElevatedButton",
    "identifier": "login_button",
    "path": "LoginPage > LoginForm > login_button"
  },
  "bounds": {
    "x": 120,
    "y": 430,
    "width": 180,
    "height": 48
  },
  "route": "/login",
  "text": "Login",
  "intent": "change",
  "severity": "suggestion",
  "status": "pending"
}
```

Use immutable models.

Provide:

```dart
toJson()
fromJson()
copyWith()
```

and equality.

---

# 18. ANNOTATION MODES

Implement modes as separate strategies.

```dart
enum AnnotationMode {
  element,
  text,
  area,
  multiSelect,
}
```

Do not implement mode-specific logic directly inside the toolbar.

Use:

```dart
AnnotationModeStrategy
```

or equivalent architecture.

---

# 19. ELEMENT MODE

Flow:

```text
Enable inspector
 ↓
Pointer moves
 ↓
Highlight candidate widget
 ↓
Tap
 ↓
Inspect widget
 ↓
Show annotation popup
 ↓
Enter comment
 ↓
Create annotation
 ↓
Render marker
```

The hover highlight should be optional on platforms where pointer hover exists.

Touch-only platforms should use tap inspection.

---

# 20. AREA MODE

Allow:

```text
drag from x1,y1
to x2,y2
```

Then:

```text
Area rectangle
 ↓
find intersecting widgets
 ↓
inspect widgets
 ↓
create area annotation
```

The annotation should retain:

```text
area bounds
selected widgets
```

---

# 21. MULTI-SELECT

Allow the user to select multiple widgets.

Example:

```text
Widget A
Widget B
Widget C
```

The annotation contains:

```json
{
  "selectedWidgets": [
    {...},
    {...},
    {...}
  ]
}
```

Do not duplicate huge widget trees unnecessarily.

Use stable identifiers wherever possible.

---

# 22. TEXT MODE

Support text selection where Flutter makes the text accessible.

Capture:

```text
selectedText
widget
text range where possible
```

If the package cannot determine the exact range, retain the selected text without crashing.

---

# 23. INSPECTION OVERLAY

Build a dedicated overlay layer.

Concept:

```text
Application
   │
   ▼
Stack
 ├── Application
 └── AgentationOverlay
       ├── HoverHighlight
       ├── SelectionBox
       ├── AnnotationMarkers
       ├── Toolbar
       └── Popup
```

The overlay must not interfere with normal application interaction when inspection mode is disabled.

When enabled, carefully control pointer interception.

---

# 24. TOOLBAR

Create a floating toolbar.

Initial actions:

```text
Inspect
Pause
Copy
Clear
Settings
```

Later:

```text
Send
Layout
Session
```

Toolbar position should be configurable.

Support:

```text
top-left
top-right
bottom-left
bottom-right
```

Desktop users should be able to drag it.

---

# 25. ANNOTATION MARKERS

Each annotation should have a marker.

Example:

```text
        ①
        │
┌──────────────────────┐
│                      │
│       Login          │
│                      │
└──────────────────────┘
```

Clicking marker:

```text
opens annotation
```

Marker should display:

```text
number
status
severity
```

where appropriate.

---

# 26. LOCAL STORAGE

Start with an abstract repository:

```dart
abstract class AnnotationStorage {
  Future<void> save(Annotation annotation);
  Future<void> delete(String id);
  Future<List<Annotation>> getAll();
  Future<void> clear();
}
```

Implement:

```text
MemoryAnnotationStorage
```

first.

Then:

```text
LocalAnnotationStorage
```

using an appropriate lightweight persistence mechanism.

Do NOT couple the core engine directly to Hive/SharedPreferences.

---

# 27. OUTPUT

Support:

```text
JSON
Markdown
```

Create:

```dart
AnnotationJsonEncoder
AnnotationMarkdownEncoder
```

Example Markdown:

```md
## Annotation #1

Comment:
Make the login button green.

Widget:
ElevatedButton

Identifier:
login_button

Path:
LoginPage > LoginForm > login_button

Route:
/login

Bounds:
x=120 y=430 width=180 height=48

Text:
Login

Severity:
suggestion

Status:
pending
```

---

# 28. AGENTATION COMPATIBILITY

Create an adapter:

```dart
AgentationFormatAdapter
```

Do not make the entire package dependent on Agentation's schema.

The adapter should convert:

```text
Flutter Annotation
        ↓
Agentation-compatible representation
```

This allows future AI integrations without compromising the Flutter-native architecture.

---

# 29. AI / MCP

Do NOT implement MCP in the first milestone.

Design the package so it can later support:

```text
Flutter Package
      ↓
HTTP/WebSocket
      ↓
Agentation Server
      ↓
MCP
      ↓
AI Agent
```

Create interfaces now:

```dart
abstract class AnnotationSyncClient {
  Future<void> send(Annotation annotation);
  Stream<AnnotationEvent> events();
}
```

but don't introduce unnecessary backend dependencies into V1.

---

# 30. CONFIGURATION

Provide:

```dart
FlutterAgentationConfig(
  enabled: true,
  showToolbar: true,
  enableElementMode: true,
  enableTextMode: true,
  enableAreaMode: true,
  enableMultiSelect: true,
  enablePersistence: true,
  storage: ...,
  toolbarPosition: ...,
)
```

Everything should have sensible defaults.

---

# 31. DEVELOPMENT MODE

The package should support:

```dart
enabled: kDebugMode
```

Example:

```dart
FlutterAgentation(
  enabled: kDebugMode,
  child: const MyApp(),
)
```

Production builds should allow the developer to completely disable the system.

When disabled:

```text
zero visible UI
minimal overhead
no inspection listeners
no annotation storage
no network
```

---

# 32. PERFORMANCE REQUIREMENTS

This is extremely important.

Do NOT continuously walk the entire widget tree every frame.

Never implement:

```text
every frame
 → inspect entire widget tree
```

Instead:

```text
pointer event
 ↓
targeted hit test
 ↓
inspect only candidate
```

Cache information where safe.

Do not create hundreds of `GlobalKey`s unnecessarily.

Do not trigger rebuilds of the application tree when an annotation changes.

Keep the annotation UI isolated.

The application should remain responsive when Agentation is enabled.

---

# 33. MEMORY REQUIREMENTS

Avoid retaining:

```text
BuildContext
Element
RenderObject
Widget
```

inside long-lived annotation objects.

Convert them to immutable serializable information.

This is critical to avoid memory leaks.

---

# 34. PLATFORM SUPPORT

Design for:

```text
Android
iOS
Web
Windows
macOS
Linux
```

Feature availability can differ.

For example:

```text
Hover → desktop/web
Touch → mobile
Keyboard shortcuts → desktop/web
```

Never crash because a platform-specific feature is unavailable.

---

# 35. TEST-FIRST DEVELOPMENT

This project MUST be developed with extensive tests.

Do not implement the entire package first and test later.

Every subsystem must have tests.

---

# 36. TEST STRUCTURE

Create:

```text
test/
│
├── core/
│
├── inspection/
│   ├── widget_inspection_engine_test.dart
│   ├── hit_test_engine_test.dart
│   ├── widget_path_resolver_test.dart
│   ├── bounds_resolver_test.dart
│   ├── text_resolver_test.dart
│   ├── semantics_resolver_test.dart
│   ├── route_resolver_test.dart
│   └── key_resolver_test.dart
│
├── annotation/
│   ├── annotation_test.dart
│   ├── annotation_manager_test.dart
│   └── annotation_repository_test.dart
│
├── modes/
│
├── storage/
│
├── output/
│   ├── json_encoder_test.dart
│   └── markdown_encoder_test.dart
│
└── widgets/
    ├── toolbar_test.dart
    ├── overlay_test.dart
    ├── marker_test.dart
    └── popup_test.dart
```

Also create:

```text
integration_test/
├── basic_inspection_test.dart
├── annotation_flow_test.dart
├── navigation_test.dart
├── scrolling_test.dart
├── dialog_test.dart
└── complex_widget_tree_test.dart
```

---

# 37. INSPECTION TEST APPLICATION

Create a dedicated test/demo application containing:

```text
SimpleScreen
ComplexScreen
FormScreen
ScrollableScreen
DialogScreen
BottomSheetScreen
NestedNavigatorScreen
OverlayScreen
CustomWidgetScreen
ListScreen
GridScreen
SliverScreen
TextSelectionScreen
AccessibilityScreen
TransformScreen
```

The package must be tested against these real Flutter structures.

---

# 38. REQUIRED INSPECTION TEST CASES

Test at minimum:

### Basic widgets

```text
Container
Text
Icon
Image
Padding
Center
SizedBox
Column
Row
Stack
```

### Interactive widgets

```text
ElevatedButton
TextButton
IconButton
GestureDetector
InkWell
Checkbox
Switch
Slider
```

### Forms

```text
TextField
TextFormField
Form
DropdownButton
```

### Complex structures

```text
ListView
GridView
CustomScrollView
SliverList
SliverGrid
NestedScrollView
```

### Navigation

```text
Navigator
Named routes
Nested Navigator
Dialogs
Bottom sheets
```

### Layout

```text
Expanded
Flexible
Align
FractionallySizedBox
AspectRatio
FittedBox
Transform
```

### Custom widgets

```text
StatelessWidget
StatefulWidget
InheritedWidget
custom RenderObjectWidget
```

---

# 39. EDGE CASE TESTING

Explicitly test:

```text
Widget without Key
Widget with ValueKey
Duplicate Keys
Private widget classes
Builder widgets
Anonymous closures
Offstage widgets
Opacity 0
IgnorePointer
AbsorbPointer
Transform
Scrollable content
Nested overlays
Dialogs
Bottom sheets
Keyboard
SafeArea
RTL layouts
Different device pixel ratios
Different screen sizes
Web
Desktop
Mobile
```

The package must fail gracefully.

---

# 40. TEST INVARIANTS

Create assertions such as:

```text
Inspection never throws for unsupported widgets.

Inspection result is immutable.

Annotation does not retain BuildContext.

Annotation does not retain Element.

Annotation does not retain RenderObject.

Disabled Agentation produces no overlay.

Disabled Agentation produces no network calls.

Annotation serialization is deterministic.

Widget bounds remain valid after scrolling.

Widget path remains readable.

Duplicate annotations receive unique IDs.

Deleting annotation removes its marker.

Clearing annotations removes all markers.

Switching routes updates session context correctly.
```

---

# 41. GOLDEN TESTS

Use Flutter golden tests for:

```text
Toolbar
Widget highlight
Annotation marker
Annotation popup
Selection rectangle
Settings panel
Dark mode
Light mode
```

Keep visual output stable.

---

# 42. PERFORMANCE TESTS

Create benchmarks for:

```text
10 annotations
50 annotations
100 annotations
500 annotations
large widget tree
deep widget tree
scrolling screen
animation-heavy screen
```

Measure:

```text
frame time
widget rebuild count
memory
annotation creation time
inspection latency
```

Do not optimize prematurely, but establish measurable baselines.

---

# 43. PUBLIC API

Keep the public API extremely small.

Prefer:

```dart
import 'package:flutter_agentation/flutter_agentation.dart';
```

Public:

```text
FlutterAgentation
FlutterAgentationConfig
AgentationController
Annotation
AnnotationMode
WidgetInspectionResult
AgentationTarget
```

Keep implementation classes under:

```text
src/
```

private unless there is a strong reason to expose them.

---

# 44. DOCUMENTATION

Create a professional README containing:

```text
What is Flutter Agentation?
Features
Installation
Quick start
Inspection engine
Annotation modes
AgentationTarget
Output formats
Configuration
Architecture
Testing
Performance
Platform support
AI/MCP integration
Security
Roadmap
```

Include examples.

---

# 45. DEVELOPMENT PHASES

Implement in this exact order.

## PHASE 1 — Project Foundation

```text
Package creation
Example application
Architecture
Models
Configuration
Controller
Tests
CI
```

Acceptance:

```bash
flutter analyze
flutter test
```

passes.

---

## PHASE 2 — Flutter Inspection Engine

Implement:

```text
hit testing
Element resolution
RenderObject resolution
widget identity
key resolution
widget path
bounds
text
semantics
route
```

This is the most important milestone.

Acceptance:

```text
Tap any supported widget
→ receive reliable WidgetInspectionResult
```

---

## PHASE 3 — Visual Inspection Overlay

Implement:

```text
overlay
hover highlight
selection rectangle
toolbar
inspection mode
```

Acceptance:

```text
Developer can visually select widgets.
```

---

## PHASE 4 — Annotation Engine

Implement:

```text
annotation model
popup
markers
edit
delete
clear
session
```

Acceptance:

```text
Select widget
→ add comment
→ marker appears
→ reopen comment
→ edit/delete
```

---

## PHASE 5 — Output & Storage

Implement:

```text
JSON
Markdown
local storage
clipboard
```

Acceptance:

```text
Annotations survive app restart.
```

---

## PHASE 6 — Advanced Modes

Implement:

```text
text
area
multi-select
keyboard shortcuts
```

---

## PHASE 7 — Integration

Implement interfaces for:

```text
webhooks
HTTP sync
WebSocket/SSE
MCP adapter
```

Do not tightly couple these into the core.

---

# 46. CODING RULES

Follow these rules throughout development:

### Rule 1

Do not make assumptions about the host application.

### Rule 2

Do not require a specific state-management package.

### Rule 3

Do not require developers to manually wrap every widget.

### Rule 4

Do not retain framework objects longer than necessary.

### Rule 5

Do not perform full-tree inspection every frame.

### Rule 6

Do not put networking logic inside inspection logic.

### Rule 7

Do not put persistence logic inside UI widgets.

### Rule 8

Do not put annotation state directly inside toolbar widgets.

### Rule 9

Keep models immutable.

### Rule 10

Every new feature requires tests.

---

# 47. ERROR HANDLING

Inspection must be defensive.

For unsupported structures:

```dart
try {
  ...
} catch (_) {
  return InspectionResult.unavailable();
}
```

Do not let the developer tool crash the host application.

The application's stability always takes priority over inspection accuracy.

---

# 48. LOGGING

Create an internal debug logger:

```dart
AgentationLogger
```

Support:

```text
disabled
errors
warnings
debug
verbose
```

Never print sensitive application data by default.

---

# 49. SECURITY

Default behavior must be:

```text
LOCAL ONLY
```

No external requests unless explicitly configured.

Do not send:

```text
source code
widget internals
user input
application data
```

to external services automatically.

The developer must explicitly enable remote synchronization.

---

# 50. FINAL ACCEPTANCE CRITERIA

The project is considered successful only when:

### Installation

```dart
FlutterAgentation(
  child: MyApp(),
)
```

works.

### Inspection

A developer can tap a widget and receive:

```text
widget type
key
identifier
widget path
bounds
route
text
semantics
```

where available.

### Annotation

A developer can:

```text
select
comment
save
edit
delete
clear
```

annotations.

### Output

Annotations can be exported to:

```text
JSON
Markdown
```

### Persistence

Annotations can persist locally.

### Compatibility

The package works with applications using different:

```text
state management
navigation
widget structures
platforms
```

### Safety

Inspection failures never crash the host application.

### Performance

The package does not continuously traverse the entire widget tree.

### Testing

The package has:

```text
unit tests
widget tests
golden tests
integration tests
performance tests
```

and:

```bash
flutter analyze
flutter test
```

must pass.

---

# 51. IMPORTANT DEVELOPMENT BEHAVIOR

Do not generate the entire implementation blindly in one step.

Work incrementally.

For each phase:

1. Create the required files.
2. Implement the smallest working version.
3. Add tests.
4. Run analyzer.
5. Run tests.
6. Fix all failures.
7. Verify the example application.
8. Only then continue to the next phase.

When a framework API is uncertain, inspect the actual Flutter SDK/API available in the environment rather than inventing APIs.

Prefer stable Flutter APIs.

Avoid private Flutter APIs unless absolutely necessary.

If a feature cannot be implemented reliably using public APIs, document the limitation and provide an abstraction so the implementation can evolve later.

---

# 52. FIRST TASK — DO THIS NOW

Do NOT start implementing advanced annotations, MCP, layout mode, Firebase, or networking.

Start with only:

```text
1. Create the Flutter package.
2. Create the example application.
3. Create the architecture above.
4. Implement the core configuration/controller.
5. Implement the first version of FlutterInspectionEngine.
6. Implement hit testing.
7. Implement Element → Widget → RenderObject inspection.
8. Implement WidgetIdentityResolver.
9. Implement WidgetPathResolver.
10. Implement BoundsResolver.
11. Implement basic TextResolver.
12. Create WidgetInspectionResult.
13. Create comprehensive inspection tests.
14. Create the inspection demo screen.
15. Run:
      flutter analyze
      flutter test
16. Fix all issues.
17. Report exactly what was implemented and what remains.
```

Do not move to annotation UI until the **Flutter Inspection Engine is proven by tests**.

The inspection engine is the foundation of the product.

The final goal is:

```text
ANY FLUTTER APP
      ↓
FlutterAgentation
      ↓
USER TAPS UI
      ↓
FLUTTER INSPECTION ENGINE
      ↓
STRUCTURED WIDGET CONTEXT
      ↓
ANNOTATION
      ↓
JSON / MARKDOWN
      ↓
AI AGENT
```

Build the foundation correctly first.
