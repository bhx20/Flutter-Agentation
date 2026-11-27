import 'package:flutter/material.dart';

/// Pixel-perfect vector icons specific to the Agentation example showcase and mockups.
class AppIcons {
  const AppIcons._();

  /// Lock icon matching upstream Agentation URL bar security badge.
  static Widget lock({double size = 14.0, Color color = Colors.white}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _LockIconPainter(color: color),
    );
  }
}

class _LockIconPainter extends CustomPainter {
  const _LockIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scale = size.width / 16.0;
    canvas.save();
    canvas.scale(scale);

    // Shackle arch
    final shackle = Path()
      ..moveTo(5.5, 7.5)
      ..lineTo(5.5, 5.0)
      ..arcToPoint(const Offset(10.5, 5.0), radius: const Radius.circular(2.5))
      ..lineTo(10.5, 7.5);
    canvas.drawPath(shackle, strokePaint);

    // Lock body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(3.5, 7.5, 9.0, 6.5),
        const Radius.circular(1.5),
      ),
      strokePaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_LockIconPainter oldDelegate) => oldDelegate.color != color;
}
