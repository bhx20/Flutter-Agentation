import 'package:flutter/material.dart';

/// Visual styling configuration for inspected widget bounding boxes and badges.
@immutable
class HighlightStyle {
  const HighlightStyle({
    this.strokeColor = const Color(0xFF6366F1), // Indigo 500
    this.fillColor = const Color(0x266366F1), // 15% opacity Indigo
    this.strokeWidth = 2.0,
    this.borderRadius = 4.0,
    this.badgeBackgroundColor = const Color(0xFF1E1B4B), // Deep Indigo 950
    this.badgeTextColor = const Color(0xFFFFFFFF),
    this.hoverStrokeColor = const Color(0x996366F1), // Translucent Indigo
    this.hoverFillColor = const Color(0x146366F1), // 8% opacity Indigo
  });

  /// Border stroke color for selected widgets.
  final Color strokeColor;

  /// Semi-transparent fill color for the bounding box.
  final Color fillColor;

  /// Border stroke width in logical pixels.
  final double strokeWidth;

  /// Corner radius for the highlight rectangle.
  final double borderRadius;

  /// Background color of the attached widget identity badge.
  final Color badgeBackgroundColor;

  /// Text color of the attached widget identity badge.
  final Color badgeTextColor;

  /// Border stroke color for hovered candidate widgets.
  final Color hoverStrokeColor;

  /// Fill color for hovered candidate widgets.
  final Color hoverFillColor;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HighlightStyle &&
        other.strokeColor == strokeColor &&
        other.fillColor == fillColor &&
        other.strokeWidth == strokeWidth &&
        other.borderRadius == borderRadius &&
        other.badgeBackgroundColor == badgeBackgroundColor &&
        other.badgeTextColor == badgeTextColor &&
        other.hoverStrokeColor == hoverStrokeColor &&
        other.hoverFillColor == hoverFillColor;
  }

  @override
  int get hashCode => Object.hash(
        strokeColor,
        fillColor,
        strokeWidth,
        borderRadius,
        badgeBackgroundColor,
        badgeTextColor,
        hoverStrokeColor,
        hoverFillColor,
      );
}
