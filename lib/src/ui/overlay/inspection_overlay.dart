import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../core/agentation_controller.dart';
import '../../core/agentation_keymap.dart';
import '../../core/agentation_logger.dart';
import '../../core/agentation_state.dart';
import '../../domain/annotation.dart';
import '../../domain/drawing_stroke.dart';
import '../../domain/marker_color.dart';
import '../../domain/placement_data.dart';
import '../../domain/widget_bounds.dart';
import '../../domain/widget_context.dart';
import '../../domain/widget_identity.dart';
import '../../domain/widget_inspection_result.dart';
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
  final ValueNotifier<Offset?> _hoverPositionNotifier = ValueNotifier<Offset?>(null);
  final ValueNotifier<String?> _hoveredAnnotationIdNotifier = ValueNotifier<String?>(null);
  Offset? _pointerDownPosition;
  Offset? _lastDragPosition;
  bool _isDraggingToScroll = false;
  bool _isMarqueeDragging = false;
  ScrollPosition? _dragScrollPosition;

  bool _isTextWidget(WidgetInspectionResult? res) {
    if (res == null) return false;
    final type = res.identity.widgetType;
    return type == 'Text' ||
        type == 'RichText' ||
        type == 'SelectableText' ||
        type == 'EditableText' ||
        type == 'TextField' ||
        type == 'TextFormField';
  }

  MouseCursor get _currentInspectionCursor {
    if (!widget.controller.isInspecting || widget.controller.isToolbarMinimized) {
      return MouseCursor.defer;
    }
    if (_isTextWidget(widget.controller.hoveredResult)) {
      return SystemMouseCursors.text;
    }
    return SystemMouseCursors.precise;
  }

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

  ScrollPosition? _cachedPrimaryScrollPosition;
  bool _hasSearchedForScrollPosition = false;

  ScrollPosition? _getPrimaryScrollPosition({Axis axis = Axis.vertical}) {
    if (_cachedPrimaryScrollPosition != null &&
        _cachedPrimaryScrollPosition!.axis == axis) {
      try {
        if (_cachedPrimaryScrollPosition!.hasPixels) {
          return _cachedPrimaryScrollPosition;
        }
      } catch (_) {
        _cachedPrimaryScrollPosition = null;
      }
    }

    if (_hasSearchedForScrollPosition) {
      return _cachedPrimaryScrollPosition;
    }

    _hasSearchedForScrollPosition = true;
    _cachedPrimaryScrollPosition = _findAnyScrollPosition(axis: axis);
    return _cachedPrimaryScrollPosition;
  }

  ScrollPosition? _findAnyScrollPosition({Axis axis = Axis.vertical}) {
    ScrollPosition? found;
    final root = _hostAppKey.currentContext as Element?;
    if (root != null && root.mounted) {
      void search(Element el) {
        if (found != null) return;
        final w = el.widget;
        if (w is Scrollable) {
          try {
            final state = (el as StatefulElement).state;
            if (state is ScrollableState) {
              if (state.position.axis == axis) {
                found = state.position;
                return;
              }
            }
          } catch (_) {}
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
    if (!renderBox.attached) return null;
    try {
      // Direct render tree walk: locate RenderViewportBase in microseconds without heavy element tree lookups
      RenderObject? cur = renderBox.parent;
      while (cur != null) {
        if (cur is RenderViewportBase && cur.attached && cur.hasSize) {
          return cur.localToGlobal(Offset.zero) & cur.size;
        }
        cur = cur.parent;
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
    ScrollPosition? scrollPos;
    try {
      targetBox = widget.controller.engine.getRenderBox(annotation.targetWidget.id);
      if (targetBox != null && targetBox.attached) {
        // Fast-path: locate viewport offset directly in render tree in microseconds
        RenderObject? cur = targetBox.parent;
        while (cur != null) {
          if (cur is RenderViewportBase) {
            final offset = cur.offset;
            if (offset is ScrollPosition) {
              scrollPos = offset;
              break;
            }
          }
          cur = cur.parent;
        }
        if (scrollPos == null) {
          final element = widget.controller.engine.elementInspector.findElementForRenderObject(
            targetBox,
            rootElement: _hostAppKey.currentContext as Element?,
          );
          if (element != null && element.mounted) {
            final scrollable = Scrollable.maybeOf(element);
            scrollPos = scrollable?.position;
          }
        }
      }
    } catch (_) {}

    scrollPos ??= _getPrimaryScrollPosition();

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
    ScrollPosition? scrollPos;
    try {
      targetBox = widget.controller.engine.getRenderBox(result.identity.id);
      if (targetBox != null && targetBox.attached) {
        // Fast-path: locate viewport offset directly in render tree in microseconds
        RenderObject? cur = targetBox.parent;
        while (cur != null) {
          if (cur is RenderViewportBase) {
            final offset = cur.offset;
            if (offset is ScrollPosition) {
              scrollPos = offset;
              break;
            }
          }
          cur = cur.parent;
        }
        if (scrollPos == null) {
          final element = widget.controller.engine.elementInspector.findElementForRenderObject(
            targetBox,
            rootElement: _hostAppKey.currentContext as Element?,
          );
          if (element != null && element.mounted) {
            final scrollable = Scrollable.maybeOf(element);
            scrollPos = scrollable?.position;
          }
        }
      }
    } catch (_) {}

    scrollPos ??= _getPrimaryScrollPosition();

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

    Offset? liveTapPosition;
    if (result.tapPosition != null) {
      if (scrollPos != null) {
        final deltaY = scrollPos.axis == Axis.vertical
            ? scrollPos.pixels - (result.context.scrollOffset ?? 0.0)
            : 0.0;
        final deltaX = scrollPos.axis == Axis.horizontal
            ? scrollPos.pixels - (result.context.scrollOffset ?? 0.0)
            : 0.0;
        liveTapPosition = Offset(
          result.tapPosition!.dx - deltaX,
          result.tapPosition!.dy - deltaY,
        );
      } else {
        liveTapPosition = result.tapPosition;
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
      widgetCode: result.widgetCode,
      isAvailable: true,
      tapPosition: liveTapPosition ?? result.tapPosition,
    );
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (!widget.controller.isInspecting || widget.controller.isToolbarMinimized) return;
    if (_isEventOnInteractiveOverlay(event.position)) return;
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
    if (_isEventOnInteractiveOverlay(event.position)) return;
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
    _isMarqueeDragging = false;
    _activeMarqueeBoundsNotifier.value = null;
    _pointerDownPosition = null;
    _lastDragPosition = null;
    _dragScrollPosition = null;
  }

  @override
  void dispose() {
    _hoverThrottleTimer?.cancel();
    _hoverPositionNotifier.dispose();
    _drawingNotifier.dispose();
    _activeMarqueeBoundsNotifier.dispose();
    _showComponentPaletteNotifier.dispose();
    _selectedTemplateNotifier.dispose();
    _activeRearrangeTargetNotifier.dispose();
    _activeRearrangeBoundsNotifier.dispose();
    _hoveredAnnotationIdNotifier.dispose();
    _scrollVersion.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    _hoverThrottleTimer?.cancel();
    _lastHoverPosition = null;
    _lastHoverTime = null;
    _hoverPositionNotifier.value = null;
    _hoveredAnnotationIdNotifier.value = null;
    _cachedPrimaryScrollPosition = null;
    _hasSearchedForScrollPosition = false;
    _dragScrollPosition = null;
    _isDraggingToScroll = false;
    _isMarqueeDragging = false;
    _activeMarqueeBoundsNotifier.value = null;
    widget.controller.clearCaches();
    if (widget.controller.hoveredResult != null) {
      widget.controller.setHoveredResult(null);
    }
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

  bool _isEventOnInteractiveOverlay(Offset position) {
    if (_isEventOnToolbar(position)) return true;
    final pBounds = widget.controller.popupBounds;
    if (pBounds != null && pBounds.inflate(8.0).contains(position)) return true;
    final fBounds = widget.controller.flyoutBounds;
    if (fBounds != null && fBounds.inflate(8.0).contains(position)) return true;
    return false;
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!widget.controller.isInspecting || widget.controller.isToolbarMinimized) return;
    if (_isEventOnInteractiveOverlay(event.position)) return;

    final toolMode = widget.controller.toolMode;

    if (toolMode == AnnotationToolMode.design) {
      final selectedTemplate = _selectedTemplateNotifier.value;
      if (selectedTemplate != null) {
        final scrollPos = _findScrollPositionAt(event.position) ?? _findAnyScrollPosition();
        final treePlacement = widget.controller.engine.resolveTreePlacement(
          event.position,
          rootRenderObject: _hostRenderObject,
          rootElement: _hostAppKey.currentContext as Element?,
        );

        final comment = widget.controller.engine.treePlacementResolver.formatComment(
          action: 'Place',
          targetLabel: selectedTemplate.label,
          placement: treePlacement,
        );

        final placementData = selectedTemplate.toPlacementData();
        final enrichedPlacement = PlacementData(
          componentType: placementData.componentType,
          width: placementData.width,
          height: placementData.height,
          text: placementData.text,
          prompt: placementData.prompt,
          parentWidget: treePlacement.parentWidget,
          relativeTarget: treePlacement.relativeTarget,
          direction: treePlacement.direction,
          treePlacement: treePlacement.description,
        );

        widget.controller.createPlacementAnnotation(
          placement: enrichedPlacement,
          position: event.position,
          comment: comment,
          isFixed: scrollPos == null,
          scrollY: scrollPos?.pixels,
          metadata: {
            'parentWidget': treePlacement.parentWidget,
            'direction': treePlacement.direction,
            if (treePlacement.relativeTarget != null) 'relativeTarget': treePlacement.relativeTarget,
            if (treePlacement.siblingBefore != null) 'siblingBefore': treePlacement.siblingBefore,
            if (treePlacement.siblingAfter != null) 'siblingAfter': treePlacement.siblingAfter,
            if (treePlacement.childIndex != null) 'childIndex': treePlacement.childIndex,
            if (treePlacement.parentBreadcrumb != null) 'parentBreadcrumb': treePlacement.parentBreadcrumb,
            'treePlacement': treePlacement.description,
          },
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

    // Pointer & MultiSelect modes: prepare for potential drag-to-select, drag-to-scroll, or tap-selection
    _pointerDownPosition = event.position;
    _lastDragPosition = event.position;
    _isDraggingToScroll = false;
    _isMarqueeDragging = false;
    _dragScrollPosition = _findScrollPositionAt(event.position) ?? _findAnyScrollPosition();
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!widget.controller.isInspecting) return;
    if (_isEventOnInteractiveOverlay(event.position)) return;

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

    // Drag handling for pointer and multiSelect modes:
    // Mouse drag initiates area marquee selection (matching agentation-main desktop/web flow).
    // Touch drag initiates natural list scrolling (preserving mobile scroll tests).
    if (_pointerDownPosition != null) {
      final totalDelta = (event.position - _pointerDownPosition!).distance;

      if (event.kind == PointerDeviceKind.mouse) {
        if (!_isMarqueeDragging && totalDelta > 8.0) {
          _isMarqueeDragging = true;
        }
        if (_isMarqueeDragging) {
          final left = math.min(_pointerDownPosition!.dx, event.position.dx);
          final top = math.min(_pointerDownPosition!.dy, event.position.dy);
          final width = (event.position.dx - _pointerDownPosition!.dx).abs();
          final height = (event.position.dy - _pointerDownPosition!.dy).abs();
          _activeMarqueeBoundsNotifier.value = WidgetBounds(x: left, y: top, width: width, height: height);
          return;
        }
      } else if (_dragScrollPosition != null) {
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
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (!widget.controller.isInspecting) return;

    final toolMode = widget.controller.toolMode;

    if (toolMode == AnnotationToolMode.design && _rearrangeController.isDragging) {
      final target = _activeRearrangeTargetNotifier.value;
      _activeRearrangeTargetNotifier.value = null;
      _activeRearrangeBoundsNotifier.value = null;

      if (target != null) {
        final treePlacement = widget.controller.engine.resolveTreePlacement(
          event.position,
          draggedIdentity: target.identity,
          rootRenderObject: _hostRenderObject,
          rootElement: _hostAppKey.currentContext as Element?,
        );

        final rearrangeData = _rearrangeController.endDrag(
          relativeTarget: treePlacement.relativeTarget,
          direction: treePlacement.direction,
          parentWidget: treePlacement.parentWidget,
          siblingBefore: treePlacement.siblingBefore,
          siblingAfter: treePlacement.siblingAfter,
          childIndex: treePlacement.childIndex,
          totalChildren: treePlacement.totalChildren,
          treePlacement: treePlacement.description,
        );

        if (rearrangeData.distanceMoved > 5.0) {
          final targetName = target.text?.isNotEmpty == true
              ? "${target.identity.widgetType} ('${target.text}')"
              : target.identity.widgetType;

          final comment = widget.controller.engine.treePlacementResolver.formatComment(
            action: 'Move',
            targetLabel: targetName,
            placement: treePlacement,
          );

          widget.controller.createRearrangeAnnotation(
            rearrange: rearrangeData,
            targetIdentity: target.identity,
            comment: comment,
            isFixed: target.context.isFixed,
            scrollY: target.context.scrollOffset,
            metadata: {
              'parentWidget': treePlacement.parentWidget,
              'direction': treePlacement.direction,
              if (treePlacement.relativeTarget != null) 'relativeTarget': treePlacement.relativeTarget,
              if (treePlacement.siblingBefore != null) 'siblingBefore': treePlacement.siblingBefore,
              if (treePlacement.siblingAfter != null) 'siblingAfter': treePlacement.siblingAfter,
              if (treePlacement.childIndex != null) 'childIndex': treePlacement.childIndex,
              if (treePlacement.parentBreadcrumb != null) 'parentBreadcrumb': treePlacement.parentBreadcrumb,
              'treePlacement': treePlacement.description,
            },
          );
        }
      } else {
        _rearrangeController.endDrag();
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
    // If this was a marquee drag selection, finalize and select the area
    if (_isMarqueeDragging) {
      final completed = _activeMarqueeBoundsNotifier.value;
      _activeMarqueeBoundsNotifier.value = null;
      _isMarqueeDragging = false;
      _pointerDownPosition = null;
      _lastDragPosition = null;
      _dragScrollPosition = null;

      if (completed != null && completed.width > 20.0 && completed.height > 20.0) {
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
        return;
      }
    }

    // If this was a touch scroll drag, finish scrolling without selecting
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

    if (_isEventOnInteractiveOverlay(event.position)) return;

    // Direct tap selection
    try {
      final hierarchy = widget.controller.engine.inspectHierarchyAt(
        event.position,
        rootRenderObject: _hostRenderObject,
        rootElement: _hostAppKey.currentContext as Element?,
      );
      final rawPrimary = hierarchy.primaryTarget;
      final primary = rawPrimary.isAvailable
          ? rawPrimary.copyWith(tapPosition: event.position)
          : rawPrimary;

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
    _hoverPositionNotifier.value = event.position;
    if (_isEventOnInteractiveOverlay(event.position)) {
      _hoverThrottleTimer?.cancel();
      _lastHoverPosition = null;
      _hoverPositionNotifier.value = null;
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
                      final metrics = notification.metrics;
                      if (metrics is ScrollPosition) {
                        _cachedPrimaryScrollPosition = metrics;
                        _hasSearchedForScrollPosition = true;
                      }
                      if (notification is ScrollUpdateNotification ||
                          notification is OverscrollNotification ||
                          notification is ScrollEndNotification ||
                          notification is UserScrollNotification) {
                        _schedulePostFrameScrollUpdate();
                        if (notification is ScrollUpdateNotification &&
                            _lastHoverPosition != null &&
                            widget.controller.isInspecting) {
                          _hoverThrottleTimer?.cancel();
                          _hoverThrottleTimer = Timer(const Duration(milliseconds: 16), () {
                            if (mounted && widget.controller.isInspecting && _lastHoverPosition != null) {
                              _executeHoverInspection(_lastHoverPosition!);
                            }
                          });
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
                  cursor: _currentInspectionCursor,
                  onExit: (_) {
                    _hoverThrottleTimer?.cancel();
                    _lastHoverPosition = null;
                    _hoverPositionNotifier.value = null;
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

            // In-flight Area marquee drag highlight (green theme matching agentation-main)
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
                          color: const Color(0xFF34C759).withValues(alpha: 0.08),
                          border: Border.all(
                            color: const Color(0xFF34C759).withValues(alpha: 0.6),
                            width: 2.0,
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
                widget.controller.hoveredResult?.identity.id != widget.controller.selectedResult?.identity.id) ...[
              RepaintBoundary(
                key: const ValueKey('agentation_hover_highlight'),
                child: WidgetHighlight(
                  result: widget.controller.hoveredResult,
                  style: effectiveHighlightStyle,
                  isHover: true,
                  showBadge: false, // Replaced by the floating cursor-following badge
                ),
              ),
              // Floating cursor-following badge (matching agentation-main HoverTooltip)
              ValueListenableBuilder<Offset?>(
                valueListenable: _hoverPositionNotifier,
                builder: (context, hoverPos, _) {
                  if (hoverPos == null || _isMarqueeDragging) return const SizedBox.shrink();
                  final screenSize = MediaQuery.of(context).size;
                  final hovered = widget.controller.hoveredResult!;
                  final label = hovered.identity.widgetType;
                  final left = math.max(8.0, math.min(hoverPos.dx, screenSize.width - 160.0));
                  final preferredTop = hoverPos.dy - 28.0 - 8.0;
                  final top = math.max(8.0, math.min(preferredTop, screenSize.height - 36.0));

                  return Positioned(
                    left: left,
                    top: top,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xE6000000), // rgba(0, 0, 0, 0.85)
                          borderRadius: BorderRadius.circular(3.5),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1.0,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 4.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],

            // Dynamic scroll-aware layers: selection highlight, popup, markers, detail card
            ValueListenableBuilder<int>(
              valueListenable: _scrollVersion,
              builder: (context, version, _) {
                final liveSelected = _resolveLiveResult(widget.controller.selectedResult);

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Active selected widget highlight
                    if (!widget.controller.isInactive && liveSelected != null) ...[
                      () {
                        final isAreaSelection = liveSelected.identity.widgetType == 'AreaSelection';
                        final selectionStyle = isAreaSelection
                            ? HighlightStyle(
                                strokeColor: const Color(0xFF34C759),
                                fillColor: const Color(0xFF34C759).withValues(alpha: 0.08),
                                strokeWidth: 2.0,
                                borderRadius: 4.0,
                              )
                            : effectiveHighlightStyle;

                        return RepaintBoundary(
                          key: const ValueKey('agentation_selected_highlight'),
                          child: WidgetHighlight(
                            result: liveSelected,
                            style: selectionStyle,
                            isHover: false,
                            showBadge: false,
                          ),
                        );
                      }(),
                    ],

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
                            accentColor: (liveSelected.identity.widgetType == 'AreaSelection' ||
                                    toolMode == AnnotationToolMode.area ||
                                    widget.controller.multiSelection.length > 1)
                                ? const Color(0xFF34C759)
                                : null,
                            onClose: widget.controller.clearSelection,
                          ),
                        ),
                      ),

                    // Numbered spatial annotation markers, hover preview tooltip, and edit dialog
                    if (widget.controller.areCommentsVisible)
                      ValueListenableBuilder<String?>(
                        valueListenable: _hoveredAnnotationIdNotifier,
                        builder: (context, hoveredId, _) {
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              // 1. Highlight outline around the hovered annotation element (matching Screenshot 1)
                              if (hoveredId != null && widget.controller.activeAnnotation == null)
                                ...(() {
                                  final hoveredAnn = widget.controller.annotations
                                      .where((a) => a.id == hoveredId)
                                      .firstOrNull;
                                  if (hoveredAnn == null) return <Widget>[];
                                  final hoveredBounds = _resolveCurrentBounds(hoveredAnn);
                                  if (hoveredBounds == null) return <Widget>[];
                                  return <Widget>[
                                    Positioned(
                                      left: hoveredBounds.x,
                                      top: hoveredBounds.y,
                                      width: hoveredBounds.width,
                                      height: hoveredBounds.height,
                                      child: IgnorePointer(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0088FF).withValues(alpha: 0.05),
                                            border: Border.all(
                                              color: const Color(0xFF0088FF).withValues(alpha: 0.75),
                                              width: 1.5,
                                            ),
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ];
                                })(),

                              // 2. The markers
                              for (int i = 0; i < widget.controller.annotations.length; i++) ...[
                                () {
                                  final ann = widget.controller.annotations[i];
                                  final currentBounds = _resolveCurrentBounds(ann);
                                  if (currentBounds == null) return const SizedBox.shrink();
                                  final isArea = ann.targetWidget.widgetType == 'AreaSelection' ||
                                      ann.isMultiSelect;
                                  final effectiveMarkerAccent = isArea
                                      ? const Color(0xFF34C759)
                                      : const Color(0xFF0088FF);
                                  final isHovered = hoveredId == ann.id;

                                  return AnnotationMarker(
                                    key: ValueKey('agentation_marker_${ann.id}'),
                                    index: i + 1,
                                    annotation: ann,
                                    boundsOverride: currentBounds,
                                    accentColor: effectiveMarkerAccent,
                                    isSelected: widget.controller.activeAnnotation?.id == ann.id,
                                    isHovered: isHovered,
                                    onHoverChanged: (hovering) {
                                      if (hovering) {
                                        _hoveredAnnotationIdNotifier.value = ann.id;
                                      } else if (_hoveredAnnotationIdNotifier.value == ann.id) {
                                        _hoveredAnnotationIdNotifier.value = null;
                                      }
                                    },
                                    onTap: () {
                                      _hoveredAnnotationIdNotifier.value = null;
                                      widget.controller.viewAnnotation(ann);
                                    },
                                  );
                                }(),
                              ],

                              // 3. Hover Preview Tooltip Card (matching Screenshot 1)
                              if (hoveredId != null && widget.controller.activeAnnotation == null)
                                ...(() {
                                  final hoveredAnn = widget.controller.annotations
                                      .where((a) => a.id == hoveredId)
                                      .firstOrNull;
                                  if (hoveredAnn == null) return <Widget>[];
                                  final hoveredBounds = _resolveCurrentBounds(hoveredAnn);
                                  if (hoveredBounds == null) return <Widget>[];
                                  return <Widget>[
                                    AnnotationHoverPreviewCard(
                                      annotation: hoveredAnn,
                                      bounds: hoveredBounds,
                                      isDark: settings.isDarkMode,
                                      onTap: () {
                                        _hoveredAnnotationIdNotifier.value = null;
                                        widget.controller.viewAnnotation(hoveredAnn);
                                      },
                                    ),
                                  ];
                                })(),
                            ],
                          );
                        },
                      ),

                    // Annotation edit dialog (matching Screenshot 2)
                    if (widget.controller.areCommentsVisible &&
                        widget.controller.activeAnnotation != null) ...[
                      () {
                        final active = widget.controller.activeAnnotation!;
                        final currentBounds = _resolveCurrentBounds(active);
                        if (currentBounds == null) return const SizedBox.shrink();
                        final isActiveArea = active.targetWidget.widgetType == 'AreaSelection' ||
                            active.isMultiSelect;
                        final effectiveCardAccent = isActiveArea
                            ? const Color(0xFF34C759)
                            : const Color(0xFF0088FF);
                        return AnnotationDetailCard(
                          key: ValueKey('agentation_card_${active.id}'),
                          index: widget.controller.annotations.indexOf(active) + 1,
                          annotation: active,
                          boundsOverride: currentBounds,
                          accentColor: effectiveCardAccent,
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
                    final treePlacement = widget.controller.engine.resolveTreePlacement(
                      details.offset,
                      rootRenderObject: _hostRenderObject,
                      rootElement: _hostAppKey.currentContext as Element?,
                    );

                    final comment = widget.controller.engine.treePlacementResolver.formatComment(
                      action: 'Place',
                      targetLabel: details.data.label,
                      placement: treePlacement,
                    );

                    final placementData = details.data.toPlacementData();
                    final enrichedPlacement = PlacementData(
                      componentType: placementData.componentType,
                      width: placementData.width,
                      height: placementData.height,
                      text: placementData.text,
                      prompt: placementData.prompt,
                      parentWidget: treePlacement.parentWidget,
                      relativeTarget: treePlacement.relativeTarget,
                      direction: treePlacement.direction,
                      treePlacement: treePlacement.description,
                    );

                    widget.controller.createPlacementAnnotation(
                      placement: enrichedPlacement,
                      position: details.offset,
                      comment: comment,
                      isFixed: scrollPos == null,
                      scrollY: scrollPos?.pixels,
                      metadata: {
                        'parentWidget': treePlacement.parentWidget,
                        'direction': treePlacement.direction,
                        if (treePlacement.relativeTarget != null) 'relativeTarget': treePlacement.relativeTarget,
                        if (treePlacement.siblingBefore != null) 'siblingBefore': treePlacement.siblingBefore,
                        if (treePlacement.siblingAfter != null) 'siblingAfter': treePlacement.siblingAfter,
                        if (treePlacement.childIndex != null) 'childIndex': treePlacement.childIndex,
                        if (treePlacement.parentBreadcrumb != null) 'parentBreadcrumb': treePlacement.parentBreadcrumb,
                        'treePlacement': treePlacement.description,
                      },
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

