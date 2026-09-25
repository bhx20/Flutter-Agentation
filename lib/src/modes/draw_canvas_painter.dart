import 'package:flutter/material.dart';
import '../models/drawing_stroke.dart';

/// Canvas painter rendering both completed freehand strokes and active in-flight sketch paths.
class DrawCanvasPainter extends CustomPainter {
  const DrawCanvasPainter({
    required this.strokes,
    this.currentStrokePoints = const [],
    this.activeColor = const Color(0xFF6366F1),
    this.activeStrokeWidth = 3.0,
  });

  /// All completed strokes already finalized.
  final List<DrawingStroke> strokes;

  /// In-flight points currently being drawn by pointer drag.
  final List<Offset> currentStrokePoints;

  /// Active line color for the in-flight stroke.
  final Color activeColor;

  /// Active stroke thickness for the in-flight stroke.
  final double activeStrokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Paint all completed strokes
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (stroke.points.length == 1) {
        canvas.drawCircle(
            stroke.points.first, stroke.strokeWidth / 2.0, paint..style = PaintingStyle.fill);
      } else {
        final path = Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy);
        for (int i = 1; i < stroke.points.length; i++) {
          path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }

    // 2. Paint in-flight active stroke
    if (currentStrokePoints.isNotEmpty) {
      final activePaint = Paint()
        ..color = activeColor
        ..strokeWidth = activeStrokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (currentStrokePoints.length == 1) {
        canvas.drawCircle(
          currentStrokePoints.first,
          activeStrokeWidth / 2.0,
          activePaint..style = PaintingStyle.fill,
        );
      } else {
        final activePath = Path()
          ..moveTo(currentStrokePoints.first.dx, currentStrokePoints.first.dy);
        for (int i = 1; i < currentStrokePoints.length; i++) {
          activePath.lineTo(currentStrokePoints[i].dx, currentStrokePoints[i].dy);
        }
        canvas.drawPath(activePath, activePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DrawCanvasPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.currentStrokePoints != currentStrokePoints ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.activeStrokeWidth != activeStrokeWidth;
  }
}
