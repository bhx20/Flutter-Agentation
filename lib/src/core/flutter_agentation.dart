import 'package:flutter/material.dart';
import '../models/widget_inspection_result.dart';
import '../overlay/highlight_style.dart';
import '../overlay/inspection_overlay.dart';
import '../toolbar/agentation_toolbar.dart';
import 'agentation_controller.dart';
import 'agentation_scope.dart';

/// The top-level wrapper widget for FlutterAgentation inspection and visual tooling.
///
/// Wrap your root application widget or page with [FlutterAgentation]:
/// ```dart
/// FlutterAgentation(
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

  @override
  State<FlutterAgentation> createState() => _FlutterAgentationState();
}

class _FlutterAgentationState extends State<FlutterAgentation> {
  AgentationController? _internalController;

  AgentationController get _effectiveController =>
      widget.controller ?? (_internalController ??= AgentationController());

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
            ? AgentationToolbar(
                controller: controller,
                initialAlignment: widget.initialToolbarAlignment,
              )
            : null,
        child: widget.child,
      ),
    );
  }
}
