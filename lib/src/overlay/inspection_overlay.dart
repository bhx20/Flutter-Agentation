import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../core/agentation_controller.dart';
import '../core/agentation_logger.dart';
import '../models/widget_inspection_result.dart';
import 'annotation_marker.dart';
import 'annotation_popup.dart';
import 'highlight_style.dart';
import 'widget_highlight.dart';

/// Overlay widget managing gesture interception, pointer inspection, and highlight presentation.
class InspectionOverlay extends StatefulWidget {
  const InspectionOverlay({
    super.key,
    required this.child,
    required this.controller,
    this.highlightStyle = const HighlightStyle(),
    this.onWidgetSelected,
    this.overlayChild,
  });

  /// The underlying host application widget tree.
  final Widget child;

  /// The inspection controller.
  final AgentationController controller;

  /// Presentation styling for highlights.
  final HighlightStyle highlightStyle;

  /// Optional callback invoked when a widget is inspected and selected.
  final void Function(WidgetInspectionResult result)? onWidgetSelected;

  /// Optional widget displayed in the overlay above the gesture layer (e.g. floating toolbar).
  final Widget? overlayChild;

  @override
  State<InspectionOverlay> createState() => _InspectionOverlayState();
}

class _InspectionOverlayState extends State<InspectionOverlay> {
  final GlobalKey _hostAppKey = GlobalKey();

  RenderObject? get _hostRenderObject =>
      _hostAppKey.currentContext?.findRenderObject();

  void _handlePointerDown(PointerDownEvent event) {
    if (!widget.controller.isInspecting) return;

    try {
      final hierarchy = widget.controller.engine.inspectHierarchyAt(
        event.position,
        rootRenderObject: _hostRenderObject,
        rootElement: _hostAppKey.currentContext as Element?,
      );
      final primary = hierarchy.primaryTarget;
      widget.controller.setActiveHierarchy(hierarchy);
      widget.controller.selectResult(primary);
      if (primary.isAvailable) {
        widget.onWidgetSelected?.call(primary);
      }
    } catch (e, stack) {
      AgentationLogger.error('Failed to inspect at ${event.position}', e, stack);
    }
  }

  void _handlePointerHover(PointerHoverEvent event) {
    if (!widget.controller.isInspecting) return;

    try {
      final result = widget.controller.engine.inspectAt(
        event.position,
        rootRenderObject: _hostRenderObject,
        rootElement: _hostAppKey.currentContext as Element?,
      );
      if (result.isAvailable) {
        widget.controller.setHoveredResult(result);
      } else {
        widget.controller.setHoveredResult(null);
      }
    } catch (e) {
      // Suppress hover inspection errors silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final isInspecting = widget.controller.isInspecting;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Underlying application
            KeyedSubtree(
              key: _hostAppKey,
              child: widget.child,
            ),

            // Gesture interception layer (only active when inspecting)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !isInspecting,
                child: MouseRegion(
                  onExit: (_) => widget.controller.setHoveredResult(null),
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: _handlePointerDown,
                    onPointerHover: _handlePointerHover,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),

            // Hover candidate highlight
            if (isInspecting && widget.controller.hoveredResult != null)
              WidgetHighlight(
                result: widget.controller.hoveredResult,
                style: widget.highlightStyle,
                isHover: true,
              ),

            // Active selected widget highlight
            if (!widget.controller.isInactive && widget.controller.selectedResult != null)
              WidgetHighlight(
                result: widget.controller.selectedResult,
                style: widget.highlightStyle,
                isHover: false,
              ),

            // Annotation creation popup when an element is actively selected
            if (isInspecting && widget.controller.selectedResult != null)
              AnnotationPopup(
                result: widget.controller.selectedResult!,
                onClose: widget.controller.clearSelection,
              ),

            // Numbered spatial annotation markers
            for (int i = 0; i < widget.controller.annotations.length; i++)
              AnnotationMarker(
                index: i + 1,
                annotation: widget.controller.annotations[i],
                isSelected: widget.controller.activeAnnotation?.id ==
                    widget.controller.annotations[i].id,
                onTap: () => widget.controller
                    .viewAnnotation(widget.controller.annotations[i]),
              ),

            // Annotation detail card when a marker is clicked
            if (widget.controller.activeAnnotation != null)
              AnnotationDetailCard(
                index: widget.controller.annotations
                        .indexOf(widget.controller.activeAnnotation!) +
                    1,
                annotation: widget.controller.activeAnnotation!,
                onClose: () => widget.controller.viewAnnotation(null),
                onDelete: () => widget.controller
                    .deleteAnnotation(widget.controller.activeAnnotation!.id),
              ),

            // Additional overlay elements (e.g. toolbar)
            if (widget.overlayChild != null) widget.overlayChild!,
          ],
        );
      },
    );
  }
}
