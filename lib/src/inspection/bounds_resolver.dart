import 'dart:math' as math;
import 'package:flutter/rendering.dart';

import '../core/agentation_logger.dart';
import '../models/widget_bounds.dart';

/// Specialized resolver responsible for calculating accurate global coordinates
/// and bounding boxes for RenderBoxes, including transformed and rotated geometry.
class BoundsResolver {
  /// Computes the global coordinates and rectangular boundaries of [renderBox].
  ///
  /// Correctly calculates enclosing bounding boxes for rotated, scaled, or
  /// matrix-transformed widgets.
  WidgetBounds resolveBounds(RenderBox renderBox) {
    if (!renderBox.hasSize || !renderBox.attached) {
      return const WidgetBounds.zero();
    }

    try {
      final size = renderBox.size;

      // Transform all 4 corner points to global coordinates to accurately
      // compute bounding box across rotations and transformations.
      final p1 = renderBox.localToGlobal(Offset.zero);
      final p2 = renderBox.localToGlobal(Offset(size.width, 0.0));
      final p3 = renderBox.localToGlobal(Offset(0.0, size.height));
      final p4 = renderBox.localToGlobal(Offset(size.width, size.height));

      final minX = math.min(math.min(p1.dx, p2.dx), math.min(p3.dx, p4.dx));
      final maxX = math.max(math.max(p1.dx, p2.dx), math.max(p3.dx, p4.dx));
      final minY = math.min(math.min(p1.dy, p2.dy), math.min(p3.dy, p4.dy));
      final maxY = math.max(math.max(p1.dy, p2.dy), math.max(p3.dy, p4.dy));

      return WidgetBounds(
        x: minX,
        y: minY,
        width: maxX - minX,
        height: maxY - minY,
      );
    } catch (e, st) {
      AgentationLogger.warning('Failed to resolve bounds for $renderBox: $e');
      AgentationLogger.verbose(st.toString());
      return const WidgetBounds.zero();
    }
  }
}
