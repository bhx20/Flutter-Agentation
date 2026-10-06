import 'dart:async';
import 'package:flutter/material.dart';
import '../models/annotation.dart';
import '../models/toolbar_settings.dart';
import '../models/widget_inspection_result.dart';
import '../overlay/highlight_style.dart';
import '../overlay/inspection_overlay.dart';
import '../toolbar/agentation_toolbar.dart';
import 'agentation_controller.dart';
import 'agentation_keymap.dart';
import 'agentation_scope.dart';

/// The top-level wrapper widget for FlutterAgentation visual feedback tooling.
///
/// Designed to match the official Agentation architecture. Supports:
/// - **Zero-config local mode**: Just wrap with `<FlutterAgentation(child: child)>`
/// - **MCP Agent Sync mode**: Provide `endpoint: "http://localhost:4747"` to stream to AI agents
/// - **Submit & Webhooks**: Provide `onSubmit` or `webhookUrl` to enable toolbar Send button
///
/// Place at the `builder` level of your [MaterialApp] or root application:
/// ```dart
/// MaterialApp(
///   builder: (context, child) => FlutterAgentation(child: child),
///   home: const MyHomePage(),
/// )
/// ```
class FlutterAgentation extends StatefulWidget {
  const FlutterAgentation({
    super.key,
    this.child,
    this.controller,
    this.endpoint,
    this.sessionId,
    this.onSessionCreated,
    this.webhookUrl,
    this.appName,
    this.copyToClipboard = true,
    this.enableKeyboardShortcuts = true,
    this.onAnnotationAdd,
    this.onAnnotationDelete,
    this.onAnnotationUpdate,
    this.onAnnotationsClear,
    this.onCopy,
    this.onSubmit,
    this.onOpenSource,
    this.initialDetailLevel,
    this.copyFormat,
    this.showToolbar = true,
    this.initialToolbarAlignment = Alignment.bottomRight,
    this.highlightStyle = const HighlightStyle(),
    this.onWidgetSelected,
  });

  /// The root application child widget tree.
  ///
  /// Typically provided by [MaterialApp.builder] as the `child` argument, or passed
  /// directly when wrapping a specific subtree or page.
  final Widget? child;

  /// Creates a [TransitionBuilder] for direct use in [MaterialApp.builder] or [WidgetsApp.builder].
  ///
  /// Placing [FlutterAgentation] at the `builder` level ensures that the inspection overlay,
  /// floating toolbar, drawing canvas, and spatial annotations persist across all routes,
  /// modals, dialogs, and navigation transitions.
  ///
  /// ```dart
  /// MaterialApp(
  ///   builder: FlutterAgentation.builder(),
  ///   home: const HomeScreen(),
  /// )
  /// ```
  static TransitionBuilder builder({
    Key? key,
    AgentationController? controller,
    String? endpoint,
    String? sessionId,
    void Function(String sessionId)? onSessionCreated,
    String? webhookUrl,
    String? appName,
    bool copyToClipboard = true,
    bool enableKeyboardShortcuts = true,
    void Function(Annotation annotation)? onAnnotationAdd,
    void Function(Annotation annotation)? onAnnotationDelete,
    void Function(Annotation annotation)? onAnnotationUpdate,
    void Function(List<Annotation> annotations)? onAnnotationsClear,
    void Function(String output)? onCopy,
    FutureOr<void> Function(String output, List<Annotation> annotations)? onSubmit,
    void Function(String sourceFile)? onOpenSource,
    OutputDetailLevel? initialDetailLevel,
    CopyFormat? copyFormat,
    bool showToolbar = true,
    Alignment initialToolbarAlignment = Alignment.bottomRight,
    HighlightStyle highlightStyle = const HighlightStyle(),
    void Function(WidgetInspectionResult result)? onWidgetSelected,
  }) {
    return (BuildContext context, Widget? child) {
      return FlutterAgentation(
        key: key,
        controller: controller,
        endpoint: endpoint,
        sessionId: sessionId,
        onSessionCreated: onSessionCreated,
        webhookUrl: webhookUrl,
        appName: appName,
        copyToClipboard: copyToClipboard,
        enableKeyboardShortcuts: enableKeyboardShortcuts,
        onAnnotationAdd: onAnnotationAdd,
        onAnnotationDelete: onAnnotationDelete,
        onAnnotationUpdate: onAnnotationUpdate,
        onAnnotationsClear: onAnnotationsClear,
        onCopy: onCopy,
        onSubmit: onSubmit,
        onOpenSource: onOpenSource,
        initialDetailLevel: initialDetailLevel,
        copyFormat: copyFormat,
        showToolbar: showToolbar,
        initialToolbarAlignment: initialToolbarAlignment,
        highlightStyle: highlightStyle,
        onWidgetSelected: onWidgetSelected,
        child: child,
      );
    };
  }

  /// Optional external controller for programmatic inspection control.
  final AgentationController? controller;

  /// Server URL for sync (e.g., "http://localhost:4747"). If omitted, operates in local mode.
  final String? endpoint;

  /// Pre-existing session ID to join. If not provided with endpoint, creates a new session.
  final String? sessionId;

  /// Called when a new session is created.
  final void Function(String sessionId)? onSessionCreated;

  /// Webhook URL to receive annotation events.
  final String? webhookUrl;

  /// Optional app name included in copied and submitted feedback header.
  final String? appName;

  /// Whether to copy to clipboard when the copy button is clicked. Defaults to true.
  final bool copyToClipboard;

  /// Enable global keyboard shortcuts. Defaults to true.
  final bool enableKeyboardShortcuts;

  /// Callback fired when an annotation is created.
  final void Function(Annotation annotation)? onAnnotationAdd;

  /// Callback fired when an annotation is deleted.
  final void Function(Annotation annotation)? onAnnotationDelete;

  /// Callback fired when an annotation comment or message is edited.
  final void Function(Annotation annotation)? onAnnotationUpdate;

  /// Callback fired when all annotations are cleared.
  final void Function(List<Annotation> annotations)? onAnnotationsClear;

  /// Callback fired after a Copy attempt with formatted output.
  final void Function(String output)? onCopy;

  /// Callback fired when "Send Annotations" is clicked.
  final FutureOr<void> Function(String output, List<Annotation> annotations)? onSubmit;

  /// Callback fired when "Open in editor" is clicked for source code navigation.
  final void Function(String sourceFile)? onOpenSource;

  /// Initial detail level for markdown export formatting.
  final OutputDetailLevel? initialDetailLevel;

  /// Format for copied output (markdown, feedback, json, source, attributes).
  final CopyFormat? copyFormat;

  /// Styling configuration for bounding boxes and identification badges.
  final HighlightStyle highlightStyle;

  /// Whether to display the floating on-screen toolbar.
  final bool showToolbar;

  /// Initial screen quadrant alignment for the floating toolbar.
  final Alignment initialToolbarAlignment;

  /// Optional callback invoked whenever a widget is selected.
  final void Function(WidgetInspectionResult result)? onWidgetSelected;

  @override
  State<FlutterAgentation> createState() => _FlutterAgentationState();
}

class _FlutterAgentationState extends State<FlutterAgentation> {
  AgentationController? _internalController;

  AgentationController get _effectiveController =>
      widget.controller ?? (_internalController ??= AgentationController());

  @override
  void initState() {
    super.initState();
    _configureController();
    if (widget.showToolbar &&
        !_effectiveController.isToolbarMinimized &&
        !_effectiveController.isInspecting) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            !_effectiveController.isToolbarMinimized &&
            !_effectiveController.isInspecting) {
          _effectiveController.activate();
        }
      });
    }
  }

  void _configureController() {
    final controller = _effectiveController;
    if (widget.appName != null) {
      controller.setAppName(widget.appName);
    }
    if (widget.initialDetailLevel != null) {
      controller.setDetailLevel(widget.initialDetailLevel!);
    }
    if (widget.copyFormat != null) {
      controller.setCopyFormat(widget.copyFormat!);
    }
    controller.shouldCopyToClipboard = widget.copyToClipboard;
    controller.enableKeyboardShortcuts = widget.enableKeyboardShortcuts;

    controller.onAnnotationAdd = widget.onAnnotationAdd;
    controller.onAnnotationDelete = widget.onAnnotationDelete;
    controller.onAnnotationUpdate = widget.onAnnotationUpdate;
    controller.onAnnotationsClear = widget.onAnnotationsClear;
    controller.onCopy = widget.onCopy;
    controller.onSubmit = widget.onSubmit;
    controller.onSessionCreated = widget.onSessionCreated;
    controller.onOpenSource = widget.onOpenSource;

    if (widget.endpoint != null || widget.webhookUrl != null || widget.sessionId != null) {
      controller.updateSettings(
        controller.settings.copyWith(
          mcpEndpoint: widget.endpoint,
          webhookUrl: widget.webhookUrl,
          sessionId: widget.sessionId,
        ),
      );
      if (widget.endpoint != null && widget.endpoint!.isNotEmpty) {
        controller.ensureActiveSession(customSessionId: widget.sessionId);
      }
    }
  }

  @override
  void didUpdateWidget(FlutterAgentation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _internalController?.dispose();
        _internalController = null;
      }
    }
    _configureController();
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _effectiveController;

    final body = InspectionOverlay(
      controller: controller,
      highlightStyle: widget.highlightStyle,
      onWidgetSelected: widget.onWidgetSelected,
      overlayChild: widget.showToolbar
          ? AgentationToolbar(
              key: const ValueKey('agentation_floating_toolbar'),
              controller: controller,
              initialAlignment: widget.initialToolbarAlignment,
            )
          : null,
      child: widget.child ?? const SizedBox.shrink(),
    );

    final content = widget.enableKeyboardShortcuts
        ? AgentationShortcuts(
            controller: controller,
            child: body,
          )
        : body;

    return _OverlayHost(
      child: AgentationScope(
        controller: controller,
        child: content,
      ),
    );
  }
}

/// Provides an [Overlay] when [FlutterAgentation] is placed at [MaterialApp.builder] level,
/// ensuring text editing handles, popups, and floating overlays have an [Overlay] ancestor.
class _OverlayHost extends StatefulWidget {
  final Widget child;
  const _OverlayHost({required this.child});

  @override
  State<_OverlayHost> createState() => _OverlayHostState();
}

class _OverlayHostState extends State<_OverlayHost> {
  late final OverlayEntry _entry;

  @override
  void initState() {
    super.initState();
    _entry = OverlayEntry(
      builder: (context) => _OverlayChildWidget(state: this),
    );
  }

  @override
  void didUpdateWidget(_OverlayHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_entry.mounted) {
      _entry.markNeedsBuild();
    }
  }

  @override
  void dispose() {
    try {
      _entry.remove();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Overlay.maybeOf(context) != null) {
      return widget.child;
    }
    return Overlay(
      initialEntries: [_entry],
    );
  }
}

class _OverlayChildWidget extends StatelessWidget {
  final _OverlayHostState state;
  const _OverlayChildWidget({required this.state});

  @override
  Widget build(BuildContext context) {
    return state.widget.child;
  }
}

