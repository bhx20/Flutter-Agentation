import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import '../models/widget_bounds.dart';

/// State and geometry helper for dragging marquee bounding boxes in Area Selection mode.
class AreaSelectionHandler {
  Offset? _startPoint;
  Offset? _currentPoint;
  bool _isDragging = false;

  /// Whether a drag gesture is currently in progress.
  bool get isDragging => _isDragging;

  /// The current bounding box rectangle derived from start and current drag points.
  WidgetBounds get currentBounds {
    if (_startPoint == null || _currentPoint == null) {
      return const WidgetBounds.zero();
    }

    final minX = math.min(_startPoint!.dx, _currentPoint!.dx);
    final maxX = math.max(_startPoint!.dx, _currentPoint!.dx);
    final minY = math.min(_startPoint!.dy, _currentPoint!.dy);
    final maxY = math.max(_startPoint!.dy, _currentPoint!.dy);

    return WidgetBounds(
      x: minX,
      y: minY,
      width: maxX - minX,
      height: maxY - minY,
    );
  }

  /// Begins a new area marquee drag at [globalPosition].
  void onPanStart(Offset globalPosition) {
    _startPoint = globalPosition;
    _currentPoint = globalPosition;
    _isDragging = true;
  }

  /// Updates the marquee boundary with new [globalPosition].
  void onPanUpdate(Offset globalPosition) {
    if (!_isDragging) return;
    _currentPoint = globalPosition;
  }

  /// Concludes the marquee drag and returns the finalized [WidgetBounds], or null if tap without drag.
  WidgetBounds? onPanEnd({double minDimension = 4.0}) {
    if (!_isDragging) return null;
    final bounds = currentBounds;
    _isDragging = false;
    _startPoint = null;
    _currentPoint = null;

    if (bounds.width < minDimension && bounds.height < minDimension) {
      return null;
    }
    return bounds;
  }

  /// Resets active drag state.
  void reset() {
    _isDragging = false;
    _startPoint = null;
    _currentPoint = null;
  }
}
