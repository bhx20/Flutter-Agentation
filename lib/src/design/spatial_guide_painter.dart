import 'package:flutter/material.dart';
import '../models/widget_bounds.dart';

/// Custom painter for rendering alignment crosshairs, coordinate lines,
/// and live dimension callouts during skeleton dragging and rearrangement.
class SpatialGuidePainter extends CustomPainter {
  const SpatialGuidePainter({
    WidgetBounds? targetBounds,
    WidgetBounds? activeBounds,
    this.screenSize = Size.zero,
    Color? accentColor,
    Color? guideColor,
  })  : targetBounds = activeBounds ?? targetBounds ?? const WidgetBounds.zero(),
        accentColor = guideColor ?? accentColor ?? const Color(0xFF6366F1);

  /// The active bounding box being placed or dragged.
  final WidgetBounds targetBounds;

  /// The viewport screen dimensions.
  final Size screenSize;

  /// Visual theme accent color.
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final guidePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.4)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final boxPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(
      targetBounds.x,
      targetBounds.y,
      targetBounds.width,
      targetBounds.height,
    );

    // Draw alignment crosshair lines extending to viewport boundaries
    // Top & Bottom vertical guide lines
    canvas.drawLine(Offset(rect.left, 0), Offset(rect.left, size.height), guidePaint);
    canvas.drawLine(Offset(rect.right, 0), Offset(rect.right, size.height), guidePaint);

    // Left & Right horizontal guide lines
    canvas.drawLine(Offset(0, rect.top), Offset(size.width, rect.top), guidePaint);
    canvas.drawLine(Offset(0, rect.bottom), Offset(size.width, rect.bottom), guidePaint);

    // Draw bounding box fill and outline
    canvas.drawRect(rect, fillPaint);
    canvas.drawRect(rect, boxPaint);

    // Draw dimension badge: "W×H"
    final dimensionText = '${rect.width.round()}×${rect.height.round()}px';
    _paintCalloutBadge(
      canvas,
      text: dimensionText,
      center: Offset(rect.center.dx, rect.top - 14.0),
    );

    // Draw coordinate position badge: "x, y"
    final coordText = 'x:${rect.left.round()} y:${rect.top.round()}';
    _paintCalloutBadge(
      canvas,
      text: coordText,
      center: Offset(rect.center.dx, rect.bottom + 14.0),
    );
  }

  void _paintCalloutBadge(
    Canvas canvas, {
    required String text,
    required Offset center,
  }) {
    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10.0,
        fontWeight: FontWeight.w600,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeRect = Rect.fromCenter(
      center: center,
      width: textPainter.width + 10.0,
      height: textPainter.height + 6.0,
    );

    final bgPaint = Paint()
      ..color = const Color(0xE61E1E2E)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.6)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(4.0)), bgPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(4.0)), borderPaint);

    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant SpatialGuidePainter oldDelegate) {
    return oldDelegate.targetBounds != targetBounds ||
        oldDelegate.screenSize != screenSize ||
        oldDelegate.accentColor != accentColor;
  }
}
