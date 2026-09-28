import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../core/agentation_controller.dart';
import '../core/agentation_logger.dart';
import '../core/agentation_state.dart';
import '../models/drawing_stroke.dart';
import '../models/marker_color.dart';
import '../models/widget_bounds.dart';
import '../models/widget_context.dart';
import '../models/widget_identity.dart';
import '../models/widget_inspection_result.dart';
import '../modes/area_selection_handler.dart';
import '../modes/draw_canvas_painter.dart';
import '../design/component_palette.dart';
import '../design/rearrange_controller.dart';
import '../design/skeleton_templates.dart';
import '../design/spatial_guide_painter.dart';
import 'annotation_marker.dart';
import 'annotation_popup.dart';
import 'freeze_overlay.dart';
import 'highlight_style.dart';
import 'widget_highlight.dart';

/// Overlay widget managing gesture interception, pointer inspection, and multi-mode presentation.
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
  final AreaSelectionHandler _areaHandler = AreaSelectionHandler();
  final List<DrawingStroke> _completedStrokes = [];
  List<Offset> _activeStrokePoints = [];
  WidgetBounds? _activeMarqueeBounds;
  bool _showComponentPalette = true;
  SkeletonTemplate? _selectedTemplate;
  final RearrangeController _rearrangeController = RearrangeController();
  WidgetInspectionResult? _activeRearrangeTarget;

  @override
  void didUpdateWidget(InspectionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller.toolMode == AnnotationToolMode.design &&
        oldWidget.controller.toolMode != AnnotationToolMode.design) {
      _showComponentPalette = true;
    }
  }

  RenderObject? get _hostRenderObject =>
      _hostAppKey.currentContext?.findRenderObject();

  void _handlePointerDown(PointerDownEvent event) {
    if (!widget.controller.isInspecting) return;

    final toolMode = widget.controller.toolMode;

    if (toolMode == AnnotationToolMode.design) {
      if (_selectedTemplate != null) {
        widget.controller.createPlacementAnnotation(
          placement: _selectedTemplate!.toPlacementData(),
          position: event.position,
          comment: 'Add ${_selectedTemplate!.label} here',
        );
        setState(() {
          _selectedTemplate = null;
        });
        return;
      }

      try {
        final result = widget.controller.engine.inspectAt(
          event.position,
          rootRenderObject: _hostRenderObject,
          rootElement: _hostAppKey.currentContext as Element?,
        );
        if (result.isAvailable) {
          _rearrangeController.startDrag(event.position, bounds: result.bounds);
          setState(() {
            _activeRearrangeTarget = result;
          });
          return;
        }
      } catch (_) {}
      return;
    }

    if (toolMode == AnnotationToolMode.area) {
      _areaHandler.onPanStart(event.position);
      setState(() {
        _activeMarqueeBounds = _areaHandler.currentBounds;
      });
      return;
    }

    if (toolMode == AnnotationToolMode.draw) {
      setState(() {
        _activeStrokePoints = [event.position];
      });
      return;
    }

    try {
      final hierarchy = widget.controller.engine.inspectHierarchyAt(
        event.position,
        rootRenderObject: _hostRenderObject,
        rootElement: _hostAppKey.currentContext as Element?,
      );
      final primary = hierarchy.primaryTarget;

      if (toolMode == AnnotationToolMode.multiSelect) {
        if (primary.isAvailable) {
          widget.controller.toggleMultiSelection(primary);
        }
        return;
      }

      if (primary.isAvailable) {
        widget.controller.setActiveHierarchy(hierarchy);
        widget.controller.selectResult(primary);
        widget.onWidgetSelected?.call(primary);
      } else {
        widget.controller.clearSelection();
      }
    } catch (e, stack) {
      AgentationLogger.error('Failed to inspect at ${event.position}', e, stack);
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!widget.controller.isInspecting) return;

    final toolMode = widget.controller.toolMode;

    if (toolMode == AnnotationToolMode.area && _areaHandler.isDragging) {
      _areaHandler.onPanUpdate(event.position);
      setState(() {
        _activeMarqueeBounds = _areaHandler.currentBounds;
      });
      return;
    }

    if (toolMode == AnnotationToolMode.design && _rearrangeController.isDragging) {
      _rearrangeController.updateDrag(event.position);
      setState(() {});
      return;
    }

    if (toolMode == AnnotationToolMode.draw && _activeStrokePoints.isNotEmpty) {
      setState(() {
        _activeStrokePoints.add(event.position);
      });
      return;
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (!widget.controller.isInspecting) return;

    final toolMode = widget.controller.toolMode;

    if (toolMode == AnnotationToolMode.design && _rearrangeController.isDragging) {
      final rearrangeData = _rearrangeController.endDrag();
      final target = _activeRearrangeTarget;
      setState(() {
        _activeRearrangeTarget = null;
      });
      if (target != null && rearrangeData.distanceMoved > 5.0) {
        widget.controller.createRearrangeAnnotation(
          rearrange: rearrangeData,
          targetIdentity: target.identity,
          comment:
              'Move ${target.identity.widgetType} ${rearrangeData.direction ?? "element"}',
        );
      }
      return;
    }

    if (toolMode == AnnotationToolMode.area && _areaHandler.isDragging) {
      final completed = _areaHandler.onPanEnd();
      setState(() {
        _activeMarqueeBounds = null;
      });

      if (completed != null) {
        final areaResult = WidgetInspectionResult(
          identity: WidgetIdentity(
            id: 'area_${DateTime.now().millisecondsSinceEpoch}',
            widgetType: 'AreaSelection',
          ),
          bounds: completed,
          context: const WidgetContext.empty(),
          ancestors: const [],
        );
        widget.controller.selectResult(areaResult);
        widget.onWidgetSelected?.call(areaResult);
      }
      return;
    }

    if (toolMode == AnnotationToolMode.draw && _activeStrokePoints.isNotEmpty) {
      final activeMarkerColor =
          MarkerColor.findById(widget.controller.settings.markerColorId).color;
      final stroke = DrawingStroke(
        points: List.unmodifiable(_activeStrokePoints),
        color: activeMarkerColor,
      );
      setState(() {
        _completedStrokes.add(stroke);
        _activeStrokePoints = [];
      });

      final double minX = stroke.points.map((p) => p.dx).reduce(math.min);
      final double maxX = stroke.points.map((p) => p.dx).reduce(math.max);
      final double minY = stroke.points.map((p) => p.dy).reduce(math.min);
      final double maxY = stroke.points.map((p) => p.dy).reduce(math.max);

      final drawResult = WidgetInspectionResult(
        identity: WidgetIdentity(
          id: 'draw_${DateTime.now().millisecondsSinceEpoch}',
          widgetType: 'FreehandDrawing',
        ),
        bounds: WidgetBounds(
          x: minX,
          y: minY,
          width: math.max(20.0, maxX - minX),
          height: math.max(20.0, maxY - minY),
        ),
        context: const WidgetContext.empty(),
        ancestors: const [],
      );
      widget.controller.selectResult(drawResult);
      return;
    }
  }

  void _handlePointerHover(PointerHoverEvent event) {
    if (!widget.controller.isInspecting) return;
    if (widget.controller.toolMode == AnnotationToolMode.draw ||
        widget.controller.toolMode == AnnotationToolMode.area ||
        widget.controller.toolMode == AnnotationToolMode.design) {
      return;
    }

    try {
      final result = widget.controller.engine.inspectAt(
        event.position,
        rootRenderObject: _hostRenderObject,
        rootElement: _hostAppKey.currentContext as Element?,
        resolveSourceLocation: false,
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
        final toolMode = widget.controller.toolMode;
        final settings = widget.controller.settings;
        final markerColor = MarkerColor.findById(settings.markerColorId).color;

        final effectiveHighlightStyle =
            widget.highlightStyle.strokeColor == const Color(0xFF6366F1)
                ? HighlightStyle(
                    strokeColor: markerColor,
                    fillColor: markerColor.withValues(alpha: 0.15),
                    hoverStrokeColor: markerColor.withValues(alpha: 0.6),
                    hoverFillColor: markerColor.withValues(alpha: 0.08),
                    badgeBackgroundColor: settings.isDarkMode
                        ? const Color(0xFF1E1B4B)
                        : const Color(0xFF312E81),
                  )
                : widget.highlightStyle;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Underlying application with dynamic animation freezing
            KeyedSubtree(
              key: _hostAppKey,
              child: FreezeOverlay(
                controller: widget.controller,
                child: widget.child,
              ),
            ),

            // Gesture interception layer (only active when inspecting and blocking interactions)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !isInspecting || !settings.blockInteractions,
                child: MouseRegion(
                  onExit: (_) => widget.controller.setHoveredResult(null),
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: _handlePointerDown,
                    onPointerMove: _handlePointerMove,
                    onPointerUp: _handlePointerUp,
                    onPointerHover: _handlePointerHover,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),

            // Active freehand drawing canvas
            if (isInspecting &&
                (_completedStrokes.isNotEmpty || _activeStrokePoints.isNotEmpty))
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: DrawCanvasPainter(
                      strokes: _completedStrokes,
                      currentStrokePoints: _activeStrokePoints,
                    ),
                  ),
                ),
              ),

            // In-flight Area marquee drag highlight
            if (isInspecting && _activeMarqueeBounds != null)
              Positioned(
                left: _activeMarqueeBounds!.x,
                top: _activeMarqueeBounds!.y,
                width: _activeMarqueeBounds!.width,
                height: _activeMarqueeBounds!.height,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      color: markerColor.withValues(alpha: 0.15),
                      border: Border.all(
                        color: markerColor,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ),
              ),

            // Hover candidate highlight
            if (isInspecting &&
                toolMode == AnnotationToolMode.pointer &&
                widget.controller.hoveredResult != null)
              WidgetHighlight(
                result: widget.controller.hoveredResult,
                style: effectiveHighlightStyle,
                isHover: true,
              ),

            // Active selected widget highlight
            if (!widget.controller.isInactive &&
                widget.controller.selectedResult != null)
              WidgetHighlight(
                result: widget.controller.selectedResult,
                style: effectiveHighlightStyle,
                isHover: false,
                showBadge: false,
              ),

            // Multi-selected items highlights
            if (isInspecting && toolMode == AnnotationToolMode.multiSelect)
              for (final selected in widget.controller.multiSelection)
                WidgetHighlight(
                  result: selected,
                  style: effectiveHighlightStyle,
                  isHover: false,
                ),

            // Annotation creation popup when an element is actively selected
            if (isInspecting && widget.controller.selectedResult != null)
              Positioned.fill(
                child: AnnotationPopup(
                  key: ValueKey(widget.controller.selectedResult!.identity.id),
                  result: widget.controller.selectedResult!,
                  onClose: widget.controller.clearSelection,
                ),
              ),

            // Numbered spatial annotation markers
            for (int i = 0; i < widget.controller.annotations.length; i++)
              AnnotationMarker(
                index: i + 1,
                annotation: widget.controller.annotations[i],
                accentColor: markerColor,
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
                accentColor: markerColor,
                isDark: settings.isDarkMode,
                onClose: () => widget.controller.viewAnnotation(null),
                onDelete: () => widget.controller
                    .deleteAnnotation(widget.controller.activeAnnotation!.id),
              ),

            // Spatial guide crosshairs when dragging to rearrange in Design Mode
            if (isInspecting &&
                toolMode == AnnotationToolMode.design &&
                _rearrangeController.isDragging)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: SpatialGuidePainter(
                      activeBounds: _rearrangeController.currentBounds,
                      guideColor: markerColor,
                    ),
                  ),
                ),
              ),

            // Drop target for dragging wireframe skeletons from the palette
            if (isInspecting && toolMode == AnnotationToolMode.design)
              Positioned.fill(
                child: DragTarget<SkeletonTemplate>(
                  onAcceptWithDetails: (details) {
                    widget.controller.createPlacementAnnotation(
                      placement: details.data.toPlacementData(),
                      position: details.offset,
                      comment: 'Add ${details.data.label} here',
                    );
                  },
                  builder: (context, candidateData, rejectedData) {
                    if (candidateData.isNotEmpty && candidateData.first != null) {
                      final template = candidateData.first!;
                      return CustomPaint(
                        painter: SpatialGuidePainter(
                          activeBounds: WidgetBounds(
                            x: 0,
                            y: 0,
                            width: template.defaultWidth,
                            height: template.defaultHeight,
                          ),
                          guideColor: markerColor,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),

            // Wireframe skeleton palette panel
            if (isInspecting &&
                toolMode == AnnotationToolMode.design &&
                _showComponentPalette)
              Positioned(
                left: 16.0,
                top: 72.0,
                child: ComponentPalette(
                  controller: widget.controller,
                  onSelectTemplate: (template) {
                    setState(() {
                      _selectedTemplate = template;
                    });
                  },
                  onClose: () {
                    setState(() {
                      _showComponentPalette = false;
                    });
                  },
                ),
              ),

            // Additional overlay elements (e.g. toolbar)
            if (widget.overlayChild != null) widget.overlayChild!,
          ],
        );
      },
    );
  }
}
