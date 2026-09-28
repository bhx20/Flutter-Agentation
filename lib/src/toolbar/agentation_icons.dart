import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Pixel-perfect vector icons matching the official Agentation design system.
class AgentationIcons {
  const AgentationIcons._();

  /// Layout Mode icon (split window / grid).
  static Widget layout({double size = 20.0, Color color = Colors.white}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _LayoutIconPainter(color: color),
    );
  }

  /// Pause icon (two vertical bars).
  static Widget pause({double size = 20.0, Color color = Colors.white}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PauseIconPainter(color: color),
    );
  }

  /// Play icon (triangle pointing right).
  static Widget play({double size = 20.0, Color color = Colors.white}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PlayIconPainter(color: color),
    );
  }

  /// Inspect / Eye icon (outline with pupil).
  static Widget eye({double size = 20.0, Color color = Colors.white}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _EyeIconPainter(color: color),
    );
  }

  /// Copy icon (two overlapping rounded rectangles).
  static Widget copy({double size = 20.0, Color color = Colors.white}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CopyIconPainter(color: color),
    );
  }

  /// Checkmark icon (for successful copy).
  static Widget check({double size = 20.0, Color color = const Color(0xFF34C759)}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CheckIconPainter(color: color),
    );
  }

  /// Trash can icon (with lid).
  static Widget trash({double size = 20.0, Color color = Colors.white}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TrashIconPainter(color: color),
    );
  }

  /// Settings gear icon (cogwheel).
  static Widget gear({double size = 20.0, Color color = Colors.white}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GearIconPainter(color: color),
    );
  }

  /// Close '✕' icon.
  static Widget close({double size = 18.0, Color color = Colors.white}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CloseIconPainter(color: color),
    );
  }

  /// Help question mark icon '?' in a circle.
  static Widget help({double size = 14.0, Color color = const Color(0xFF8E8E93)}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _HelpIconPainter(color: color),
    );
  }

  /// Wireframe 9-dot grid icon inside rounded rectangle.
  static Widget wireframe({double size = 16.0, Color color = Colors.white}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _WireframeIconPainter(color: color),
    );
  }
}

class _LayoutIconPainter extends CustomPainter {
  const _LayoutIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale);

    // Outer rect
    final rect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(3, 3, 18, 18),
      const Radius.circular(3),
    );
    canvas.drawRRect(rect, strokePaint);

    // Horizontal split line
    canvas.drawLine(const Offset(3, 9), const Offset(21, 9), strokePaint);

    // Vertical split line
    canvas.drawLine(const Offset(9, 9), const Offset(9, 21), strokePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_LayoutIconPainter oldDelegate) => oldDelegate.color != color;
}

class _PauseIconPainter extends CustomPainter {
  const _PauseIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.75
      ..strokeCap = StrokeCap.round;

    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale);

    canvas.drawLine(const Offset(9.0, 6.5), const Offset(9.0, 17.5), paint);
    canvas.drawLine(const Offset(15.0, 6.5), const Offset(15.0, 17.5), paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_PauseIconPainter oldDelegate) => oldDelegate.color != color;
}

class _PlayIconPainter extends CustomPainter {
  const _PlayIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale);

    final path = Path()
      ..moveTo(8.5, 6.5)
      ..lineTo(17.5, 12.0)
      ..lineTo(8.5, 17.5)
      ..close();
    canvas.drawPath(path, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_PlayIconPainter oldDelegate) => oldDelegate.color != color;
}

class _EyeIconPainter extends CustomPainter {
  const _EyeIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale);

    // Eye outline path
    final path = Path()
      ..moveTo(4.0, 12.0)
      ..cubicTo(6.0, 7.0, 18.0, 7.0, 20.0, 12.0)
      ..cubicTo(18.0, 17.0, 6.0, 17.0, 4.0, 12.0);
    canvas.drawPath(path, strokePaint);

    // Center pupil
    canvas.drawCircle(const Offset(12.0, 12.0), 2.5, strokePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_EyeIconPainter oldDelegate) => oldDelegate.color != color;
}

class _CopyIconPainter extends CustomPainter {
  const _CopyIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale);

    // Front box
    final frontRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(5.0, 9.0, 10.0, 10.0),
      const Radius.circular(2.5),
    );
    canvas.drawRRect(frontRect, strokePaint);

    // Back box
    final backPath = Path()
      ..moveTo(9.0, 6.5)
      ..lineTo(16.5, 6.5)
      ..arcToPoint(const Offset(19.0, 9.0), radius: const Radius.circular(2.5))
      ..lineTo(19.0, 15.0)
      ..arcToPoint(const Offset(17.5, 16.5), radius: const Radius.circular(1.5));
    canvas.drawPath(backPath, strokePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_CopyIconPainter oldDelegate) => oldDelegate.color != color;
}

class _CheckIconPainter extends CustomPainter {
  const _CheckIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.75
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale);

    // Outer circle
    canvas.drawCircle(const Offset(12, 12), 8, strokePaint);

    // Checkmark
    final checkPath = Path()
      ..moveTo(8.5, 12.0)
      ..lineTo(11.0, 14.5)
      ..lineTo(15.5, 9.5);
    canvas.drawPath(checkPath, strokePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_CheckIconPainter oldDelegate) => oldDelegate.color != color;
}

class _TrashIconPainter extends CustomPainter {
  const _TrashIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale);

    // Lid line
    canvas.drawLine(const Offset(5.0, 7.5), const Offset(19.0, 7.5), strokePaint);

    // Handle
    final handle = Path()
      ..moveTo(9.5, 7.5)
      ..lineTo(9.5, 5.5)
      ..arcToPoint(const Offset(11.0, 4.5), radius: const Radius.circular(1.0))
      ..lineTo(13.0, 4.5)
      ..arcToPoint(const Offset(14.5, 5.5), radius: const Radius.circular(1.0))
      ..lineTo(14.5, 7.5);
    canvas.drawPath(handle, strokePaint);

    // Can body
    final body = Path()
      ..moveTo(6.5, 7.5)
      ..lineTo(7.5, 18.0)
      ..arcToPoint(const Offset(9.5, 19.5), radius: const Radius.circular(2.0))
      ..lineTo(14.5, 19.5)
      ..arcToPoint(const Offset(16.5, 18.0), radius: const Radius.circular(2.0))
      ..lineTo(17.5, 7.5);
    canvas.drawPath(body, strokePaint);

    // Vertical slats inside can
    canvas.drawLine(const Offset(10.0, 10.5), const Offset(10.0, 16.5), strokePaint);
    canvas.drawLine(const Offset(14.0, 10.5), const Offset(14.0, 16.5), strokePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_TrashIconPainter oldDelegate) => oldDelegate.color != color;
}

class _GearIconPainter extends CustomPainter {
  const _GearIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale);

    final center = const Offset(12.0, 12.0);
    const numTeeth = 8;
    const rOuter = 8.5;
    const rInner = 6.8;

    final path = Path();
    for (int i = 0; i < numTeeth; i++) {
      final angle1 = (i * 2 * math.pi / numTeeth) - 0.2;
      final angle2 = angle1 + 0.2;
      final angle3 = angle2 + 0.2;
      final angle4 = angle3 + 0.2;

      final p1 = Offset(center.dx + rInner * math.cos(angle1), center.dy + rInner * math.sin(angle1));
      final p2 = Offset(center.dx + rOuter * math.cos(angle2), center.dy + rOuter * math.sin(angle2));
      final p3 = Offset(center.dx + rOuter * math.cos(angle3), center.dy + rOuter * math.sin(angle3));
      final p4 = Offset(center.dx + rInner * math.cos(angle4), center.dy + rInner * math.sin(angle4));

      if (i == 0) {
        path.moveTo(p1.dx, p1.dy);
      } else {
        path.lineTo(p1.dx, p1.dy);
      }
      path.lineTo(p2.dx, p2.dy);
      path.lineTo(p3.dx, p3.dy);
      path.lineTo(p4.dx, p4.dy);
    }
    path.close();
    canvas.drawPath(path, strokePaint);

    // Center hole
    canvas.drawCircle(center, 2.5, strokePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_GearIconPainter oldDelegate) => oldDelegate.color != color;
}

class _CloseIconPainter extends CustomPainter {
  const _CloseIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale);

    canvas.drawLine(const Offset(6.5, 6.5), const Offset(17.5, 17.5), strokePaint);
    canvas.drawLine(const Offset(17.5, 6.5), const Offset(6.5, 17.5), strokePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_CloseIconPainter oldDelegate) => oldDelegate.color != color;
}

class _HelpIconPainter extends CustomPainter {
  const _HelpIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final scale = size.width / 16.0;
    canvas.save();
    canvas.scale(scale);

    // Circle
    canvas.drawCircle(const Offset(8.0, 8.0), 6.5, strokePaint);

    // Question mark curve
    final path = Path()
      ..moveTo(6.2, 6.2)
      ..cubicTo(6.5, 4.8, 9.5, 4.8, 9.5, 6.5)
      ..cubicTo(9.5, 8.2, 8.0, 8.5, 8.0, 10.0);
    canvas.drawPath(path, strokePaint);

    // Dot
    canvas.drawCircle(const Offset(8.0, 11.8), 0.75, fillPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_HelpIconPainter oldDelegate) => oldDelegate.color != color;
}

class _WireframeIconPainter extends CustomPainter {
  const _WireframeIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final dotPaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final scale = size.width / 16.0;
    canvas.save();
    canvas.scale(scale);

    // Outer rect
    final rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(1.5, 1.5, 13.0, 13.0),
      const Radius.circular(2.5),
    );
    canvas.drawRRect(rrect, strokePaint);

    // 9 dots (3x3 grid)
    final xs = [5.0, 8.0, 11.0];
    final ys = [5.0, 8.0, 11.0];
    for (final x in xs) {
      for (final y in ys) {
        canvas.drawCircle(Offset(x, y), 0.9, dotPaint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_WireframeIconPainter oldDelegate) => oldDelegate.color != color;
}
