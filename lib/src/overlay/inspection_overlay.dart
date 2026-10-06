import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../core/agentation_controller.dart';
import '../core/agentation_keymap.dart';
import '../core/agentation_logger.dart';
import '../core/agentation_state.dart';
import '../models/annotation.dart';
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
  Offset? _pointerDownPosition;
  Offset? _lastDragPosition;
  bool _isDraggingToScroll = false;
  ScrollPosition? _dragScrollPosition;

  ScrollPosition? _findScrollPositionAt(
    Offset position, {
    Axis axis = Axis.vertical,
    double? delta,
  }) {
    try {
      final targetBox = widget.controller.engine.hitTestEngine.findTargetRenderBox(
        position,
        rootRenderObject: _hostRenderObject,
        ignoredRenderObjects: widget.controller.engine.ignoredRenderObjects,
      );
      if (targetBox != null) {
        Element? element = widget.controller.engine.elementInspector.findElementForRenderObject(
          targetBox,
          rootElement: _hostAppKey.currentContext as Element?,
        );
        Element? currentElement = element;
        ScrollPosition? candidate;
        while (currentElement != null) {
          final scrollable = Scrollable.maybeOf(currentElement);
          if (scrollable != null) {
            final pos = scrollable.position;
            if (pos.axis == axis) {
              if (delta != null) {
                final canScrollDown = pos.pixels < pos.maxScrollExtent;
                final canScrollUp = pos.pixels > pos.minScrollExtent;
                if ((delta > 0 && canScrollDown) || (delta < 0 && canScrollUp)) {
                  return pos;
                }
                candidate ??= pos;
              } else {
                return pos;
              }
            }
            Element? outsideScrollable;
            scrollable.context.visitAncestorElements((ancestor) {
              outsideScrollable = ancestor;
              return false;
            });
            currentElement = outsideScrollable;
          } else {
            break;
          }
        }
        if (candidate != null) return candidate;
      }
    } catch (_) {}
    return null;
  }

  ScrollPosition? _findAnyScrollPosition({Axis axis = Axis.vertical}) {
    ScrollPosition? found;
    final root = _hostAppKey.currentContext as Element?;
    if (root != null) {
      void search(Element el) {
        if (found != null) return;
        final w = el.widget;
        if (w is Scrollable) {
          final state = (el as StatefulElement).state;
          if (state is ScrollableState) {
            if (state.position.axis == axis) {
              found = state.position;
              return;
            }
          }
        }
        el.visitChildren(search);
      }
      search(root);
    }
    return found;
  }

  final ValueNotifier<int> _scrollVersion = ValueNotifier<int>(0);
  bool _hasScheduledScrollPostFrameCallback = false;

  void _schedulePostFrameScrollUpdate() {
    if (_hasScheduledScrollPostFrameCallback) return;
    _hasScheduledScrollPostFrameCallback = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hasScheduledScrollPostFrameCallback = false;
      if (mounted) {
        _scrollVersion.value++;
      }
    });
  }

  Rect? _findViewportForRenderBox(RenderBox renderBox) {
    try {
      final element = widget.controller.engine.elementInspector.findElementForRenderObject(
        renderBox,
        rootElement: _hostAppKey.currentContext as Element?,
      );
      if (element != null) {
        final scrollable = Scrollable.maybeOf(element);
        if (scrollable != null) {
          final sBox = scrollable.context.findRenderObject();
          if (sBox is RenderBox && sBox.attached && sBox.hasSize) {
            return sBox.localToGlobal(Offset.zero) & sBox.size;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  Rect? _findViewportForPosition(ScrollPosition position) {
    try {
      final context = position.context;
      if (context is ScrollableState) {
        final ro = context.context.findRenderObject();
        if (ro is RenderBox && ro.attached && ro.hasSize) {
          return ro.localToGlobal(Offset.zero) & ro.size;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Dynamically computes the pixel-accurate current on-screen coordinates for [annotation],
  /// taking into account live RenderBox position, scroll offsets, and viewport bounds.
  /// Returns null if the annotated element is scrolled completely out of its visible viewport.
  WidgetBounds? _resolveCurrentBounds(Annotation annotation) {
    // 1. Fixed element (e.g. AppBar, bottom navigation bar, floating action button)
    if (annotation.isFixed) {
      return annotation.bounds;
    }

    RenderBox? targetBox;
    ScrollableState? scrollable;
    try {
      targetBox = widget.controller.engine.getRenderBox(annotation.targetWidget.id);
      if (targetBox != null && targetBox.attached) {
        final element = widget.controller.engine.elementInspector.findElementForRenderObject(
          targetBox,
          rootElement: _hostAppKey.currentContext as Element?,
        );
        if (element != null) {
          scrollable = Scrollable.maybeOf(element);
        }
      }
    } catch (_) {}

    final scrollPos = scrollable?.position ??
        _findScrollPositionAt(Offset(annotation.bounds.x, annotation.bounds.y)) ??
        _findAnyScrollPosition();

    double currentX = annotation.bounds.x;
    double currentY = annotation.bounds.y;
    double currentWidth = annotation.bounds.width;
    double currentHeight = annotation.bounds.height;

    bool hasLiveBox = false;
    if (targetBox != null && targetBox.attached && targetBox.hasSize) {
      try {
        final globalPos = targetBox.localToGlobal(Offset.zero);
        currentX = globalPos.dx;
        currentY = globalPos.dy;
        currentWidth = targetBox.size.width;
        currentHeight = targetBox.size.height;
        hasLiveBox = true;
      } catch (_) {}
    }

    if (scrollPos != null) {
      final deltaY = scrollPos.axis == Axis.vertical
          ? scrollPos.pixels - annotation.scrollY
          : 0.0;
      final deltaX = scrollPos.axis == Axis.horizontal
          ? scrollPos.pixels - annotation.scrollX
          : 0.0;

      // If the target RenderBox is not available or hasn't completed its layout pass
      // for this frame yet, reproject immediately from initial bounds using the scroll delta.
      if (!hasLiveBox ||
          (deltaY != 0.0 && (currentY - annotation.bounds.y).abs() < 0.01)) {
        currentY = annotation.bounds.y - deltaY;
      }
      if (!hasLiveBox ||
          (deltaX != 0.0 && (currentX - annotation.bounds.x).abs() < 0.01)) {
        currentX = annotation.bounds.x - deltaX;
      }

      final viewport = (targetBox != null && targetBox.attached)
          ? _findViewportForRenderBox(targetBox)
          : _findViewportForPosition(scrollPos);
      if (viewport != null) {
        if (currentY + currentHeight < viewport.top ||
            currentY > viewport.bottom ||
            currentX + currentWidth < viewport.left ||
            currentX > viewport.right) {
          return null; // Scrolled out of visible viewport
        }
      }
    }

    return WidgetBounds(
      x: currentX,
      y: currentY,
      width: currentWidth,
      height: currentHeight,
    );
  }

  WidgetInspectionResult? _resolveLiveResult(WidgetInspectionResult? result) {
    if (result == null || !result.isAvailable) return result;
    if (result.context.isFixed) return result;

    RenderBox? targetBox;
    ScrollableState? scrollable;
    try {
      targetBox = widget.controller.engine.getRenderBox(result.identity.id);
      if (targetBox != null && targetBox.attached) {
        final element = widget.controller.engine.elementInspector.findElementForRenderObject(
          targetBox,
          rootElement: _hostAppKey.currentContext as Element?,
        );
        if (element != null) {
          scrollable = Scrollable.maybeOf(element);
        }
      }
    } catch (_) {}

    final scrollPos = scrollable?.position ??
        _findScrollPositionAt(Offset(result.bounds.x, result.bounds.y)) ??
        _findAnyScrollPosition();

    double currentX = result.bounds.x;
    double currentY = result.bounds.y;
    double currentWidth = result.bounds.width;
    double currentHeight = result.bounds.height;

    bool hasLiveBox = false;
    if (targetBox != null && targetBox.attached && targetBox.hasSize) {
      try {
        final globalPos = targetBox.localToGlobal(Offset.zero);
        currentX = globalPos.dx;
        currentY = globalPos.dy;
        currentWidth = targetBox.size.width;
        currentHeight = targetBox.size.height;
        hasLiveBox = true;
      } catch (_) {}
    }

    if (scrollPos != null) {
      final initialScroll = result.context.scrollOffset ?? 0.0;
      final deltaY = scrollPos.axis == Axis.vertical
          ? scrollPos.pixels - initialScroll
          : 0.0;
      final deltaX = scrollPos.axis == Axis.horizontal
          ? scrollPos.pixels - initialScroll
          : 0.0;

      if (!hasLiveBox ||
          (deltaY != 0.0 && (currentY - result.bounds.y).abs() < 0.01)) {
        currentY = result.bounds.y - deltaY;
      }
      if (!hasLiveBox ||
          (deltaX != 0.0 && (currentX - result.bounds.x).abs() < 0.01)) {
        currentX = result.bounds.x - deltaX;
      }

      final viewport = (targetBox != null && targetBox.attached)
          ? _findViewportForRenderBox(targetBox)
          : _findViewportForPosition(scrollPos);
      if (viewport != null) {
        if (currentY + currentHeight < viewport.top ||
            currentY > viewport.bottom ||
            currentX + currentWidth < viewport.left ||
            currentX > viewport.right) {
          return null; // Scrolled out of visible viewport
        }
      }
    }

    return WidgetInspectionResult(
      identity: result.identity,
      bounds: WidgetBounds(
        x: currentX,
        y: currentY,
        width: currentWidth,
        height: currentHeight,
      ),
      context: result.context,
      route: result.route,
      text: result.text,
      ancestors: result.ancestors,
      sourceLocation: result.sourceLocation,
      metadata: result.metadata,
      isAvailable: true,
    );
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (!widget.controller.isInspecting || widget.controller.isToolbarMinimized) return;
    if (_isEventOnToolbar(event.position)) return;
    if (event is PointerScrollEvent) {
      final axis = event.scrollDelta.dx.abs() > event.scrollDelta.dy.abs()
          ? Axis.horizontal
          : Axis.vertical;
      final delta = axis == Axis.vertical ? event.scrollDelta.dy : event.scrollDelta.dx;
      final scrollPos = _findScrollPositionAt(event.position, axis: axis, delta: delta) ??
          _findAnyScrollPosition(axis: axis);
      if (scrollPos != null && delta != 0) {
        try {
          scrollPos.pointerScroll(delta);
        } catch (e) {
          scrollPos.jumpTo(
            (scrollPos.pixels + delta).clamp(
              scrollPos.minScrollExtent,
              scrollPos.maxScrollExtent,
            ),
          );
        }
        _schedulePostFrameScrollUpdate();
      }
    }
  }

  void _handlePointerPanZoomUpdate(PointerPanZoomUpdateEvent event) {
    if (!widget.controller.isInspecting || widget.controller.isToolbarMinimized) return;
    if (_isEventOnToolbar(event.position)) return;
    final axis = event.pan.dx.abs() > event.pan.dy.abs()
        ? Axis.horizontal
        : Axis.vertical;
    final delta = axis == Axis.vertical ? -event.pan.dy : -event.pan.dx;
    final scrollPos = _findScrollPositionAt(event.position, axis: axis, delta: delta) ??
        _findAnyScrollPosition(axis: axis);
    if (scrollPos != null && delta != 0) {
      try {
        scrollPos.pointerScroll(delta);
      } catch (_) {
        scrollPos.jumpTo(
          (scrollPos.pixels + delta).clamp(
            scrollPos.minScrollExtent,
            scrollPos.maxScrollExtent,
          ),
        );
      }
      _schedulePostFrameScrollUpdate();
    }
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    _isDraggingToScroll = false;
    _pointerDownPosition = null;
    _lastDragPosition = null;
    _dragScrollPosition = null;
  }

  @override
  void dispose() {
    _hoverThrottleTimer?.cancel();
    _drawingNotifier.dispose();
    _activeMarqueeBoundsNotifier.dispose();
    _showComponentPaletteNotifier.dispose();
    _selectedTemplateNotifier.dispose();
    _activeRearrangeTargetNotifier.dispose();
    _activeRearrangeBoundsNotifier.dispose();
    _scrollVersion.dispose();
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

  bool _isEventOnToolbar(Offset position) {
    final bounds = widget.controller.toolbarBounds;
    if (bounds == null) return false;
    return bounds.inflate(4.0).contains(position);
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!widget.controller.isInspecting || widget.controller.isToolbarMinimized) return;
    if (_isEventOnToolbar(event.position)) return;

    final toolMode = widget.controller.toolMode;

    if (toolMode == AnnotationToolMode.design) {
      final selectedTemplate = _selectedTemplateNotifier.value;
      if (selectedTemplate != null) {
        final scrollPos = _findScrollPositionAt(event.position) ?? _findAnyScrollPosition();
        widget.controller.createPlacementAnnotation(
          placement: selectedTemplate.toPlacementData(),
          position: event.position,
          comment: 'Add ${selectedTemplate.label} here',
          isFixed: scrollPos == null,
          scrollY: scrollPos?.pixels,
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

    // Pointer & MultiSelect modes: prepare for potential drag-to-scroll or tap-selection
    _pointerDownPosition = event.position;
    _lastDragPosition = event.position;
    _isDraggingToScroll = false;
    _dragScrollPosition = _findScrollPositionAt(event.position) ?? _findAnyScrollPosition();
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

    // Drag-to-scroll for pointer and multiSelect modes
    if (_pointerDownPosition != null && _dragScrollPosition != null) {
      final totalDelta = (event.position - _pointerDownPosition!).distance;
      if (!_isDraggingToScroll && totalDelta > 8.0) {
        _isDraggingToScroll = true;
      }

      if (_isDraggingToScroll && _lastDragPosition != null) {
        final delta = _dragScrollPosition!.axis == Axis.horizontal
            ? event.position.dx - _lastDragPosition!.dx
            : event.position.dy - _lastDragPosition!.dy;
        _lastDragPosition = event.position;
        if (delta != 0) {
          final canScroll = delta > 0
              ? _dragScrollPosition!.pixels > _dragScrollPosition!.minScrollExtent
              : _dragScrollPosition!.pixels < _dragScrollPosition!.maxScrollExtent;
          if (!canScroll) {
            final enclosing = _findScrollPositionAt(
              event.position,
              axis: _dragScrollPosition!.axis,
              delta: -delta,
            );
            if (enclosing != null) {
              _dragScrollPosition = enclosing;
            }
          }
          final target = (_dragScrollPosition!.pixels - delta).clamp(
            _dragScrollPosition!.minScrollExtent,
            _dragScrollPosition!.maxScrollExtent,
          );
          _dragScrollPosition!.jumpTo(target);
          _schedulePostFrameScrollUpdate();
        }
        return;
      }
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
          isFixed: target.context.isFixed,
          scrollY: target.context.scrollOffset,
        );
      }
      return;
    }

    if (toolMode == AnnotationToolMode.area && _areaHandler.isDragging) {
      final completed = _areaHandler.onPanEnd();
      _activeMarqueeBoundsNotifier.value = null;

      if (completed != null) {
        final scrollPos = _findScrollPositionAt(Offset(completed.x, completed.y)) ?? _findAnyScrollPosition();
        final areaResult = WidgetInspectionResult(
          identity: WidgetIdentity(
            id: 'area_${DateTime.now().millisecondsSinceEpoch}',
            widgetType: 'AreaSelection',
          ),
          bounds: completed,
          context: WidgetContext(
            isFixed: scrollPos == null,
            scrollOffset: scrollPos?.pixels,
            scrollAxis: scrollPos?.axis.name,
          ),
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

      final scrollPos = _findScrollPositionAt(Offset(minX, minY)) ?? _findAnyScrollPosition();
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
        context: WidgetContext(
          isFixed: scrollPos == null,
          scrollOffset: scrollPos?.pixels,
          scrollAxis: scrollPos?.axis.name,
        ),
        ancestors: const [],
      );
      widget.controller.selectResult(drawResult);
      return;
    }

    // Pointer and MultiSelect modes:
    // If this was a scroll drag, finish scrolling without selecting
    if (_isDraggingToScroll) {
      _isDraggingToScroll = false;
      _pointerDownPosition = null;
      _lastDragPosition = null;
      _dragScrollPosition = null;
      return;
    }

    _pointerDownPosition = null;
    _lastDragPosition = null;
    _dragScrollPosition = null;

    if (_isEventOnToolbar(event.position)) return;

    // Direct tap selection
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

  void _handlePointerHover(PointerHoverEvent event) {
    if (!widget.controller.isInspecting || widget.controller.isToolbarMinimized) return;
    if (_isEventOnToolbar(event.position)) {
      _hoverThrottleTimer?.cancel();
      _lastHoverPosition = null;
      if (widget.controller.hoveredResult != null) {
        widget.controller.setHoveredResult(null);
      }
      return;
    }
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
                    badgeBackgroundColor: const Color(0xFF000000),
                    badgeTextColor: const Color(0xFFFFFFFF),
                  )
                : widget.highlightStyle;

        final content = Stack(
            fit: StackFit.expand,
            children: [
            // Underlying application with dynamic animation freezing and paint boundary isolation
            RepaintBoundary(
              child: KeyedSubtree(
                key: _hostAppKey,
                child: FreezeOverlay(
                  controller: widget.controller,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollUpdateNotification ||
                          notification is OverscrollNotification ||
                          notification is ScrollEndNotification ||
                          notification is UserScrollNotification) {
                        _schedulePostFrameScrollUpdate();
                        if (notification is ScrollUpdateNotification &&
                            _lastHoverPosition != null &&
                            widget.controller.isInspecting) {
                          _executeHoverInspection(_lastHoverPosition!);
                        }
                      }
                      return false;
                    },
                    child: widget.child,
                  ),
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
                    onPointerCancel: _handlePointerCancel,
                    onPointerSignal: _handlePointerSignal,
                    onPointerPanZoomUpdate: _handlePointerPanZoomUpdate,
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
                key: const ValueKey('agentation_hover_highlight'),
                child: WidgetHighlight(
                  result: widget.controller.hoveredResult,
                  style: effectiveHighlightStyle,
                  isHover: true,
                ),
              ),

            // Dynamic scroll-aware layers: selection highlight, popup, markers, detail card
            ValueListenableBuilder<int>(
              valueListenable: _scrollVersion,
              builder: (context, version, _) {
                final liveSelected = _resolveLiveResult(widget.controller.selectedResult);

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Active selected widget highlight
                    if (!widget.controller.isInactive && liveSelected != null)
                      RepaintBoundary(
                        key: const ValueKey('agentation_selected_highlight'),
                        child: WidgetHighlight(
                          result: liveSelected,
                          style: effectiveHighlightStyle,
                          isHover: false,
                          showBadge: false,
                        ),
                      ),

                    // Multi-selected items highlights
                    if (isInspecting && toolMode == AnnotationToolMode.multiSelect)
                      for (final selected in widget.controller.multiSelection) ...[
                        () {
                          final liveMulti = _resolveLiveResult(selected);
                          if (liveMulti == null) return const SizedBox.shrink();
                          return RepaintBoundary(
                            key: ValueKey('agentation_multiselect_${liveMulti.identity.id}'),
                            child: WidgetHighlight(
                              result: liveMulti,
                              style: effectiveHighlightStyle,
                              isHover: false,
                            ),
                          );
                        }(),
                      ],

                    // Annotation creation popup when an element is actively selected
                    if (isInspecting && liveSelected != null)
                      Positioned.fill(
                        key: const ValueKey('agentation_annotation_popup_layer'),
                        child: RepaintBoundary(
                          child: AnnotationPopup(
                            key: ValueKey(liveSelected.identity.id),
                            result: liveSelected,
                            onClose: widget.controller.clearSelection,
                          ),
                        ),
                      ),

                    // Numbered spatial annotation markers
                    if (widget.controller.areCommentsVisible)
                      for (int i = 0; i < widget.controller.annotations.length; i++) ...[
                        () {
                          final ann = widget.controller.annotations[i];
                          final currentBounds = _resolveCurrentBounds(ann);
                          if (currentBounds == null) return const SizedBox.shrink();
                          return AnnotationMarker(
                            key: ValueKey('agentation_marker_${ann.id}'),
                            index: i + 1,
                            annotation: ann,
                            boundsOverride: currentBounds,
                            accentColor: markerColor,
                            isSelected: widget.controller.activeAnnotation?.id == ann.id,
                            onTap: () => widget.controller.viewAnnotation(ann),
                          );
                        }(),
                      ],

                    // Annotation detail card when a marker is clicked
                    if (widget.controller.areCommentsVisible &&
                        widget.controller.activeAnnotation != null) ...[
                      () {
                        final active = widget.controller.activeAnnotation!;
                        final currentBounds = _resolveCurrentBounds(active);
                        if (currentBounds == null) return const SizedBox.shrink();
                        return AnnotationDetailCard(
                          key: ValueKey('agentation_card_${active.id}'),
                          index: widget.controller.annotations.indexOf(active) + 1,
                          annotation: active,
                          boundsOverride: currentBounds,
                          accentColor: markerColor,
                          isDark: settings.isDarkMode,
                          onClose: () => widget.controller.viewAnnotation(null),
                          onDelete: () => widget.controller.deleteAnnotation(active.id),
                        );
                      }(),
                    ],
                  ],
                );
              },
            ),

            // Spatial guide crosshairs when dragging to rearrange in Design Mode
            if (isInspecting && toolMode == AnnotationToolMode.design)
              ValueListenableBuilder<WidgetBounds?>(
                key: const ValueKey('agentation_spatial_guides'),
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
                key: const ValueKey('agentation_skeleton_drop_target'),
                child: DragTarget<SkeletonTemplate>(
                  onAcceptWithDetails: (details) {
                    final scrollPos = _findScrollPositionAt(details.offset) ?? _findAnyScrollPosition();
                    widget.controller.createPlacementAnnotation(
                      placement: details.data.toPlacementData(),
                      position: details.offset,
                      comment: 'Add ${details.data.label} here',
                      isFixed: scrollPos == null,
                      scrollY: scrollPos?.pixels,
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
                key: const ValueKey('agentation_wireframe_palette'),
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
              widget.overlayChild!,
          ],
        );

        final effectiveContent = Listener(
          behavior: HitTestBehavior.translucent,
          onPointerSignal: _handlePointerSignal,
          onPointerPanZoomUpdate: _handlePointerPanZoomUpdate,
          child: content,
        );

        if (!widget.controller.enableKeyboardShortcuts ||
            context.findAncestorWidgetOfExactType<AgentationShortcuts>() != null) {
          return effectiveContent;
        }
        return AgentationShortcuts(
          controller: widget.controller,
          child: effectiveContent,
        );
      },
    );
  }
}
