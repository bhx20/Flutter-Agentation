import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../core/agentation_controller.dart';
import '../core/agentation_keymap.dart';
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

class _DrawingCanvasState {
  final List<DrawingStroke> completedStrokes;
  final List<Offset> activeStrokePoints;

  const _DrawingCanvasState({
    required this.completedStrokes,
    required this.activeStrokePoints,
  });

  bool get isNotEmpty => completedStrokes.isNotEmpty || activeStrokePoints.isNotEmpty;
}

class _InspectionOverlayState extends State<InspectionOverlay> {
  final GlobalKey _hostAppKey = GlobalKey();
  final AreaSelectionHandler _areaHandler = AreaSelectionHandler();
  final ValueNotifier<_DrawingCanvasState> _drawingNotifier =
      ValueNotifier<_DrawingCanvasState>(
    const _DrawingCanvasState(completedStrokes: [], activeStrokePoints: []),
  );
  final ValueNotifier<WidgetBounds?> _activeMarqueeBoundsNotifier =
      ValueNotifier<WidgetBounds?>(null);
  final ValueNotifier<bool> _showComponentPaletteNotifier =
      ValueNotifier<bool>(true);
  final ValueNotifier<SkeletonTemplate?> _selectedTemplateNotifier =
      ValueNotifier<SkeletonTemplate?>(null);
  final RearrangeController _rearrangeController = RearrangeController();
  final ValueNotifier<WidgetInspectionResult?> _activeRearrangeTargetNotifier =
      ValueNotifier<WidgetInspectionResult?>(null);
  final ValueNotifier<WidgetBounds?> _activeRearrangeBoundsNotifier =
      ValueNotifier<WidgetBounds?>(null);
  Offset? _lastHoverPosition;
  DateTime? _lastHoverTime;
  Timer? _hoverThrottleTimer;

  @override
  void dispose() {
    _hoverThrottleTimer?.cancel();
    _drawingNotifier.dispose();
    _activeMarqueeBoundsNotifier.dispose();
    _showComponentPaletteNotifier.dispose();
    _selectedTemplateNotifier.dispose();
    _activeRearrangeTargetNotifier.dispose();
    _activeRearrangeBoundsNotifier.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(InspectionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller.toolMode == AnnotationToolMode.design &&
        oldWidget.controller.toolMode != AnnotationToolMode.design) {
      _showComponentPaletteNotifier.value = true;
    }
  }

  RenderObject? get _hostRenderObject =>
      _hostAppKey.currentContext?.findRenderObject();

  void _handlePointerDown(PointerDownEvent event) {
    if (!widget.controller.isInspecting || widget.controller.isToolbarMinimized) return;

    final toolMode = widget.controller.toolMode;

    if (toolMode == AnnotationToolMode.design) {
      final selectedTemplate = _selectedTemplateNotifier.value;
      if (selectedTemplate != null) {
        widget.controller.createPlacementAnnotation(
          placement: selectedTemplate.toPlacementData(),
          position: event.position,
          comment: 'Add ${selectedTemplate.label} here',
        );
        _selectedTemplateNotifier.value = null;
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
          _activeRearrangeTargetNotifier.value = result;
          _activeRearrangeBoundsNotifier.value = result.bounds;
          return;
        }
      } catch (_) {}
      return;
    }

    if (toolMode == AnnotationToolMode.area) {
      _areaHandler.onPanStart(event.position);
      _activeMarqueeBoundsNotifier.value = _areaHandler.currentBounds;
      return;
    }

    if (toolMode == AnnotationToolMode.draw) {
      _drawingNotifier.value = _DrawingCanvasState(
        completedStrokes: _drawingNotifier.value.completedStrokes,
        activeStrokePoints: [event.position],
      );
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
        widget.controller.selectTargetHierarchy(primary, hierarchy);
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
      _activeMarqueeBoundsNotifier.value = _areaHandler.currentBounds;
      return;
    }

    if (toolMode == AnnotationToolMode.design && _rearrangeController.isDragging) {
      _rearrangeController.updateDrag(event.position);
      _activeRearrangeBoundsNotifier.value = _rearrangeController.currentBounds;
      return;
    }

    if (toolMode == AnnotationToolMode.draw && _drawingNotifier.value.activeStrokePoints.isNotEmpty) {
      _drawingNotifier.value = _DrawingCanvasState(
        completedStrokes: _drawingNotifier.value.completedStrokes,
        activeStrokePoints: [..._drawingNotifier.value.activeStrokePoints, event.position],
      );
      return;
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (!widget.controller.isInspecting) return;

    final toolMode = widget.controller.toolMode;

    if (toolMode == AnnotationToolMode.design && _rearrangeController.isDragging) {
      final rearrangeData = _rearrangeController.endDrag();
      final target = _activeRearrangeTargetNotifier.value;
      _activeRearrangeTargetNotifier.value = null;
      _activeRearrangeBoundsNotifier.value = null;
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
      _activeMarqueeBoundsNotifier.value = null;

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

    if (toolMode == AnnotationToolMode.draw && _drawingNotifier.value.activeStrokePoints.isNotEmpty) {
      final activeMarkerColor =
          MarkerColor.findById(widget.controller.settings.markerColorId).color;
      final stroke = DrawingStroke(
        points: List.unmodifiable(_drawingNotifier.value.activeStrokePoints),
        color: activeMarkerColor,
      );
      _drawingNotifier.value = _DrawingCanvasState(
        completedStrokes: [..._drawingNotifier.value.completedStrokes, stroke],
        activeStrokePoints: const [],
      );

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
    if (!widget.controller.isInspecting || widget.controller.isToolbarMinimized) return;
    if (widget.controller.toolMode == AnnotationToolMode.draw ||
        widget.controller.toolMode == AnnotationToolMode.area ||
        widget.controller.toolMode == AnnotationToolMode.design) {
      return;
    }

    final currentHover = widget.controller.hoveredResult;
    // Fast path: if the cursor is still inside the current hovered widget bounds
    // and hasn't moved substantially (< 4px), skip costly tree re-inspection.
    if (currentHover != null &&
        _lastHoverPosition != null &&
        (event.position - _lastHoverPosition!).distanceSquared < 16.0 &&
        currentHover.bounds.toRect().inflate(4.0).contains(event.position)) {
      return;
    }

    _lastHoverPosition = event.position;

    // Rate-limit hover inspection to at most ~120 FPS (8ms)
    final now = DateTime.now();
    if (_lastHoverTime != null &&
        now.difference(_lastHoverTime!).inMilliseconds < 8) {
      _hoverThrottleTimer?.cancel();
      _hoverThrottleTimer = Timer(const Duration(milliseconds: 8), () {
        if (!mounted || !widget.controller.isInspecting) return;
        _executeHoverInspection(event.position);
      });
      return;
    }

    _lastHoverTime = now;
    _executeHoverInspection(event.position);
  }

  void _executeHoverInspection(Offset position) {
    try {
      final result = widget.controller.engine.inspectAt(
        position,
        rootRenderObject: _hostRenderObject,
        rootElement: _hostAppKey.currentContext as Element?,
        resolveSourceLocation: false,
        lightweight: true,
      );
      if (result.isAvailable) {
        final current = widget.controller.hoveredResult;
        if (current == null ||
            current.identity.id != result.identity.id ||
            current.bounds != result.bounds) {
          widget.controller.setHoveredResult(result);
        }
      } else {
        if (widget.controller.hoveredResult != null) {
          widget.controller.setHoveredResult(null);
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final isInspecting = widget.controller.isInspecting && !widget.controller.isToolbarMinimized;
        final toolMode = widget.controller.toolMode;
        final settings = widget.controller.settings;
        final markerColor = MarkerColor.findById(settings.markerColorId).color;

        final effectiveHighlightStyle =
            widget.highlightStyle.strokeColor == const Color(0xFF6366F1)
                ? HighlightStyle(
                    strokeColor: markerColor,
                    fillColor: Colors.transparent,
                    strokeWidth: widget.highlightStyle.strokeWidth,
                    borderRadius: widget.highlightStyle.borderRadius,
                    hoverStrokeColor: markerColor.withValues(alpha: 0.6),
                    hoverFillColor: markerColor.withValues(alpha: 0.08),
                    badgeBackgroundColor: settings.isDarkMode
                        ? const Color(0xFF1E1B4B)
                        : const Color(0xFF312E81),
                  )
                : widget.highlightStyle;

        return AgentationShortcuts(
          controller: widget.controller,
          child: Stack(
            fit: StackFit.expand,
            children: [
            // Underlying application with dynamic animation freezing and paint boundary isolation
            RepaintBoundary(
              child: KeyedSubtree(
                key: _hostAppKey,
                child: FreezeOverlay(
                  controller: widget.controller,
                  child: widget.child,
                ),
              ),
            ),

            // Gesture interception layer (only active when inspecting and blocking interactions)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !isInspecting || !settings.blockInteractions,
                child: MouseRegion(
                  onExit: (_) {
                    _hoverThrottleTimer?.cancel();
                    _lastHoverPosition = null;
                    widget.controller.setHoveredResult(null);
                  },
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
            if (isInspecting)
              ValueListenableBuilder<_DrawingCanvasState>(
                valueListenable: _drawingNotifier,
                builder: (context, drawingState, _) {
                  if (!drawingState.isNotEmpty) return const SizedBox.shrink();
                  return Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: DrawCanvasPainter(
                          strokes: drawingState.completedStrokes,
                          currentStrokePoints: drawingState.activeStrokePoints,
                        ),
                      ),
                    ),
                  );
                },
              ),

            // In-flight Area marquee drag highlight
            if (isInspecting)
              ValueListenableBuilder<WidgetBounds?>(
                valueListenable: _activeMarqueeBoundsNotifier,
                builder: (context, activeMarqueeBounds, _) {
                  if (activeMarqueeBounds == null) return const SizedBox.shrink();
                  return Positioned(
                    left: activeMarqueeBounds.x,
                    top: activeMarqueeBounds.y,
                    width: activeMarqueeBounds.width,
                    height: activeMarqueeBounds.height,
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
                  );
                },
              ),

            // Hover candidate highlight (skip if already selected)
            if (isInspecting &&
                toolMode == AnnotationToolMode.pointer &&
                widget.controller.hoveredResult != null &&
                widget.controller.hoveredResult?.identity.id != widget.controller.selectedResult?.identity.id)
              RepaintBoundary(
                child: WidgetHighlight(
                  result: widget.controller.hoveredResult,
                  style: effectiveHighlightStyle,
                  isHover: true,
                ),
              ),

            // Active selected widget highlight
            if (!widget.controller.isInactive &&
                widget.controller.selectedResult != null)
              RepaintBoundary(
                child: WidgetHighlight(
                  result: widget.controller.selectedResult,
                  style: effectiveHighlightStyle,
                  isHover: false,
                  showBadge: false,
                ),
              ),

            // Multi-selected items highlights
            if (isInspecting && toolMode == AnnotationToolMode.multiSelect)
              for (final selected in widget.controller.multiSelection)
                RepaintBoundary(
                  child: WidgetHighlight(
                    result: selected,
                    style: effectiveHighlightStyle,
                    isHover: false,
                  ),
                ),

            // Annotation creation popup when an element is actively selected
            if (isInspecting && widget.controller.selectedResult != null)
              Positioned.fill(
                child: RepaintBoundary(
                  child: AnnotationPopup(
                    key: ValueKey(widget.controller.selectedResult!.identity.id),
                    result: widget.controller.selectedResult!,
                    onClose: widget.controller.clearSelection,
                  ),
                ),
              ),

            // Numbered spatial annotation markers
            if (widget.controller.areCommentsVisible)
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
            if (widget.controller.areCommentsVisible && widget.controller.activeAnnotation != null)
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
            if (isInspecting && toolMode == AnnotationToolMode.design)
              ValueListenableBuilder<WidgetBounds?>(
                valueListenable: _activeRearrangeBoundsNotifier,
                builder: (context, rearrangeBounds, _) {
                  if (rearrangeBounds == null) return const SizedBox.shrink();
                  return Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: SpatialGuidePainter(
                          activeBounds: rearrangeBounds,
                          guideColor: markerColor,
                        ),
                      ),
                    ),
                  );
                },
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

            // Wireframe skeleton palette panel (only shown if no toolbar overlay child manages it)
            if (widget.overlayChild == null &&
                isInspecting &&
                toolMode == AnnotationToolMode.design)
              ValueListenableBuilder<bool>(
                valueListenable: _showComponentPaletteNotifier,
                builder: (context, showPalette, _) {
                  if (!showPalette) return const SizedBox.shrink();
                  return Positioned(
                    left: 16.0,
                    top: 72.0,
                    child: ComponentPalette(
                      controller: widget.controller,
                      onSelectTemplate: (template) {
                        _selectedTemplateNotifier.value = template;
                      },
                      onClose: () {
                        _showComponentPaletteNotifier.value = false;
                      },
                    ),
                  );
                },
              ),

            // Additional overlay elements (e.g. toolbar)
            if (widget.overlayChild != null)
              RepaintBoundary(
                child: widget.overlayChild!,
              ),
          ],
        ),
      );
      },
    );
  }
}
