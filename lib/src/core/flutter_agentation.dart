import 'package:flutter/material.dart';
import '../models/toolbar_settings.dart';
import '../models/widget_inspection_result.dart';
import '../networking/agent_sync_client.dart';
import '../overlay/highlight_style.dart';
import '../overlay/inspection_overlay.dart';
import '../toolbar/agentation_toolbar.dart';
import '../toolbar/settings_panel.dart';
import 'agentation_controller.dart';
import 'agentation_scope.dart';

/// The top-level wrapper widget for FlutterAgentation inspection and visual tooling.
///
/// Wrap your root application widget or page with [FlutterAgentation]:
/// ```dart
/// FlutterAgentation(
///   endpoint: "http://localhost:4747",
///   child: MyApp(),
/// )
/// ```
class FlutterAgentation extends StatefulWidget {
  const FlutterAgentation({
    super.key,
    required this.child,
    this.controller,
    this.highlightStyle = const HighlightStyle(),
    this.showToolbar = true,
    this.initialToolbarAlignment = Alignment.bottomRight,
    this.onWidgetSelected,
    this.endpoint,
    this.webhookUrl,
    this.appName,
    this.identifyingAttributes,
    this.onOpenSource,
    this.initialDetailLevel,
  });

  /// The root application child widget tree.
  final Widget child;

  /// Optional external controller for programmatic inspection control.
  final AgentationController? controller;

  /// Styling configuration for bounding boxes and identification badges.
  final HighlightStyle highlightStyle;

  /// Whether to display the floating on-screen toolbar.
  final bool showToolbar;

  /// Initial screen quadrant alignment for the floating toolbar.
  final Alignment initialToolbarAlignment;

  /// Optional callback invoked whenever a widget is selected.
  final void Function(WidgetInspectionResult result)? onWidgetSelected;

  /// Optional Model Context Protocol (MCP) server endpoint (e.g. `http://localhost:4747`).
  final String? endpoint;

  /// Optional webhook URL for asynchronous event notification.
  final String? webhookUrl;

  /// Optional application name for session branding and MCP registration.
  final String? appName;

  /// Optional widget attributes to prioritize for identification (e.g. `['key', 'semanticLabel', 'tooltip']`).
  final List<String>? identifyingAttributes;

  /// Optional callback to open source files in the user's IDE or editor.
  final void Function(String sourceFile, int? line)? onOpenSource;

  /// Initial detail level for markdown export formatting.
  final OutputDetailLevel? initialDetailLevel;

  @override
  State<FlutterAgentation> createState() => _FlutterAgentationState();
}

class _FlutterAgentationState extends State<FlutterAgentation> {
  AgentationController? _internalController;
  bool _isSettingsOpen = false;

  AgentationController get _effectiveController =>
      widget.controller ?? (_internalController ??= AgentationController());

  @override
  void initState() {
    super.initState();
    _configureController();
  }

  void _configureController() {
    final controller = _effectiveController;
    if (widget.initialDetailLevel != null) {
      controller.setDetailLevel(widget.initialDetailLevel!);
    }
    if (widget.endpoint != null && widget.endpoint!.isNotEmpty) {
      final client = AgentSyncClient(
        endpoint: widget.endpoint!,
        webhookUrl: widget.webhookUrl,
      );
      controller.setSyncClient(client);
      controller.updateSettings(
        controller.settings.copyWith(
          mcpEndpoint: widget.endpoint,
        ),
      );
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
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _effectiveController;

    return AgentationScope(
      controller: controller,
      child: InspectionOverlay(
        controller: controller,
        highlightStyle: widget.highlightStyle,
        onWidgetSelected: widget.onWidgetSelected,
        overlayChild: widget.showToolbar
            ? Stack(
                children: [
                  AgentationToolbar(
                    controller: controller,
                    initialAlignment: widget.initialToolbarAlignment,
                    onOpenSettings: () {
                      setState(() {
                        _isSettingsOpen = !_isSettingsOpen;
                      });
                    },
                  ),
                  if (_isSettingsOpen)
                    Positioned(
                      top: 60.0,
                      right: 16.0,
                      child: SettingsPanel(
                        controller: controller,
                        onClose: () {
                          setState(() {
                            _isSettingsOpen = false;
                          });
                        },
                      ),
                    ),
                ],
              )
            : null,
        child: widget.child,
      ),
    );
  }
}
