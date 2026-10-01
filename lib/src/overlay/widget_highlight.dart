import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/widget_inspection_result.dart';
import 'highlight_style.dart';

/// Visual bounding box and identity badge rendered over an inspected widget.
class WidgetHighlight extends StatelessWidget {
  const WidgetHighlight({
    super.key,
    required this.result,
    this.style = const HighlightStyle(),
    this.isHover = false,
    this.showBadge = true,
  });

  /// The inspection result providing coordinates and identity.
  final WidgetInspectionResult? result;

  /// Visual styling configuration.
  final HighlightStyle style;

  /// Whether this highlight represents a transient pointer hover candidate.
  final bool isHover;

  /// Whether to render the widget identity badge pill.
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final res = result;
    if (res == null || !res.isAvailable) {
      return const SizedBox.shrink();
    }

    final bounds = res.bounds;
    final strokeColor = isHover ? style.hoverStrokeColor : style.strokeColor;
    final fillColor = isHover ? style.hoverFillColor : style.fillColor;

    // Calculate badge position: place above if space permits, else below.
    final placeAbove = bounds.y >= 26.0;
    final badgeTop = placeAbove ? math.max(4.0, bounds.y - 22.0) : bounds.y + bounds.height + 4.0;
    final screenWidth = MediaQuery.maybeOf(context)?.size.width ?? 1200.0;
    final alignRight = bounds.width >= 60.0 && (screenWidth - (bounds.x + bounds.width)) >= 0;
    final badgeRight = alignRight ? math.max(8.0, screenWidth - (bounds.x + bounds.width)) : null;
    final badgeLeft = !alignRight ? math.max(8.0, bounds.x) : null;

    final keyString = res.identity.keyString;

    return RepaintBoundary(
      child: IgnorePointer(
        child: Stack(
          children: [
            // Bounding box highlight outline and fill
            Positioned(
              left: bounds.x,
              top: bounds.y,
              width: bounds.width,
              height: bounds.height,
              child: CustomPaint(
                painter: HighlightPainter(
                  strokeColor: strokeColor,
                  fillColor: fillColor,
                  strokeWidth: style.strokeWidth,
                  borderRadius: style.borderRadius,
                ),
              ),
            ),

            // Identification badge (only for selected results or hovered when desired)
            if (showBadge)
              Positioned(
                left: badgeLeft,
                right: badgeRight,
                top: badgeTop,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: style.badgeBackgroundColor.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(style.borderRadius + 2.0),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                      width: 0.8,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x40000000),
                        blurRadius: 6.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        res.identity.widgetType,
                        style: TextStyle(
                          color: style.badgeTextColor,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      if (!isHover && keyString != null && keyString.isNotEmpty) ...[
                        const SizedBox(width: 4.0),
                        Text(
                          keyString,
                          style: TextStyle(
                            color: style.badgeTextColor.withValues(alpha: 0.75),
                            fontSize: 10.0,
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter responsible for rendering the bounding outline and semi-transparent fill.
class HighlightPainter extends CustomPainter {
  const HighlightPainter({
    required this.strokeColor,
    required this.fillColor,
    required this.strokeWidth,
    required this.borderRadius,
  });

  final Color strokeColor;
  final Color fillColor;
  final double strokeWidth;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Paint semi-transparent fill if specified
    if (fillColor != Colors.transparent && fillColor.alpha > 0) {
      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rrect, fillPaint);
    }

    // Paint crisp border stroke
    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawRRect(rrect, strokePaint);
  }

  @override
  bool shouldRepaint(covariant HighlightPainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.borderRadius != borderRadius;
  }
}
