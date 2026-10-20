import 'package:flutter/material.dart';
import '../../theme/agentation_colors.dart';

/// Visual styling configuration for inspected widget bounding boxes and badges.
@immutable
class HighlightStyle {
  const HighlightStyle({
    this.strokeColor = AgentationColors.platformBlue, // Blue
    this.fillColor = Colors.transparent,
    this.strokeWidth = 1.5,
    this.borderRadius = 4.0,
    this.badgeBackgroundColor = AgentationColors.pureBlack,
    this.badgeTextColor = AgentationColors.pureWhite,
    this.hoverStrokeColor = AgentationColors.highlightHoverStroke, // Translucent Blue
    this.hoverFillColor = AgentationColors.highlightHoverFill, // ~6% opacity Blue
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

