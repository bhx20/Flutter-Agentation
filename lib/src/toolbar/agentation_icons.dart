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

  /// Eye-off icon (eye with diagonal slash) for hidden comments.
  static Widget eyeOff({double size = 20.0, Color color = Colors.white}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _EyeOffIconPainter(color: color),
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

  /// Send arrow icon matching upstream Agentation IconSendArrow.
  static Widget send({double size = 20.0, Color color = Colors.white}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SendIconPainter(color: color),
    );
  }

  /// List with Sparkle icon (launcher and minimized toolbar toggle) matching upstream Agentation.
  static Widget listSparkle({double size = 20.0, Color color = Colors.white}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ListSparkleIconPainter(color: color),
    );
  }

  /// Crescent Moon icon matching upstream Agentation IconMoon.
  static Widget moon({double size = 16.0, Color color = Colors.white}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _MoonIconPainter(color: color),
    );
  }

  /// Sun icon matching upstream Agentation IconSun.
  static Widget sun({double size = 16.0, Color color = Colors.white}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SunIconPainter(color: color),
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

    // Outer rect: x="3" y="3" width="18" height="18" rx="2"
    final rect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(3.0, 3.0, 18.0, 18.0),
      const Radius.circular(2.0),
    );
    canvas.drawRRect(rect, strokePaint);

    // Horizontal split line: x1="3" y1="9" x2="21" y2="9"
    canvas.drawLine(const Offset(3.0, 9.0), const Offset(21.0, 9.0), strokePaint);

    // Vertical split line: x1="9" y1="9" x2="9" y2="21"
    canvas.drawLine(const Offset(9.0, 9.0), const Offset(9.0, 21.0), strokePaint);

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
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale);

    canvas.drawLine(const Offset(7.5, 4.5), const Offset(7.5, 19.5), strokePaint);
    canvas.drawLine(const Offset(16.5, 4.5), const Offset(16.5, 19.5), strokePaint);

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
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale);

    final path = Path()
      ..moveTo(17.75, 10.701)
      ..cubicTo(18.75, 11.2783, 18.75, 12.7217, 17.75, 13.299)
      ..lineTo(8.75, 18.4952)
      ..cubicTo(7.75, 19.0725, 6.5, 18.3509, 6.5, 17.1962)
      ..lineTo(6.5, 6.80384)
      ..cubicTo(6.5, 5.64914, 7.75, 4.92746, 8.75, 5.50481)
      ..close();

    canvas.drawPath(path, strokePaint);
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

    final path = Path()
      ..moveTo(3.91752, 12.7539)
      ..cubicTo(3.65127, 12.2996, 3.65037, 11.7515, 3.9149, 11.2962)
      ..cubicTo(4.9042, 9.59346, 7.72688, 5.49994, 12.0, 5.49994)
      ..cubicTo(16.2731, 5.49994, 19.0958, 9.59346, 20.0851, 11.2962)
      ..cubicTo(20.3496, 11.7515, 20.3487, 12.2996, 20.0825, 12.7539)
      ..cubicTo(19.0908, 14.4459, 16.2694, 18.4999, 12.0, 18.4999)
      ..cubicTo(7.73064, 18.4999, 4.90918, 14.4459, 3.91752, 12.7539)
      ..close();
    canvas.drawPath(path, strokePaint);

    // Center pupil
    canvas.drawCircle(const Offset(12.0, 12.0), 2.8261, strokePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_EyeIconPainter oldDelegate) => oldDelegate.color != color;
}

class _EyeOffIconPainter extends CustomPainter {
  const _EyeOffIconPainter({required this.color});
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

    final path = Path()
      ..moveTo(3.91752, 12.7539)
      ..cubicTo(3.65127, 12.2996, 3.65037, 11.7515, 3.9149, 11.2962)
      ..cubicTo(4.9042, 9.59346, 7.72688, 5.49994, 12.0, 5.49994)
      ..cubicTo(16.2731, 5.49994, 19.0958, 9.59346, 20.0851, 11.2962)
      ..cubicTo(20.3496, 11.7515, 20.3487, 12.2996, 20.0825, 12.7539)
      ..cubicTo(19.0908, 14.4459, 16.2694, 18.4999, 12.0, 18.4999)
      ..cubicTo(7.73064, 18.4999, 4.90918, 14.4459, 3.91752, 12.7539)
      ..close();
    canvas.drawPath(path, strokePaint);

    // Center pupil
    canvas.drawCircle(const Offset(12.0, 12.0), 2.8261, strokePaint);

    // Diagonal slash: M5 19L19 5
    canvas.drawLine(const Offset(5.0, 19.0), const Offset(19.0, 5.0), strokePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_EyeOffIconPainter oldDelegate) => oldDelegate.color != color;
}

class _CopyIconPainter extends CustomPainter {
  const _CopyIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale);

    // Front box: x: 3.75, y: 8.75, w: 10.5, h: 10.5, r: 1.75
    final frontRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(3.75, 8.75, 10.5, 10.5),
      const Radius.circular(1.75),
    );
    canvas.drawRRect(frontRect, strokePaint);

    // Back box path matching IconCopyAlt enlarged
    final backPath = Path()
      ..moveTo(8.75, 5.75)
      ..lineTo(8.75, 5.25)
      ..cubicTo(8.75, 4.42, 9.42, 3.75, 10.25, 3.75)
      ..lineTo(18.25, 3.75)
      ..cubicTo(19.08, 3.75, 19.75, 4.42, 19.75, 5.25)
      ..lineTo(19.75, 13.25)
      ..cubicTo(19.75, 14.08, 19.08, 14.75, 18.25, 14.75)
      ..lineTo(17.75, 14.75);
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
      ..strokeWidth = 1.5
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
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale);

    // Exact compound path from upstream IconTrashAlt
    final path = Path()
      ..moveTo(13.5, 4.0)
      ..cubicTo(14.7426, 4.0, 15.75, 5.00736, 15.75, 6.25)
      ..lineTo(15.75, 7.0)
      ..lineTo(18.5, 7.0)
      ..cubicTo(18.9142, 7.0, 19.25, 7.33579, 19.25, 7.75)
      ..cubicTo(19.25, 8.16421, 18.9142, 8.5, 18.5, 8.5)
      ..lineTo(17.9678, 8.5)
      ..lineTo(17.6328, 16.2217)
      ..cubicTo(17.61, 16.7475, 17.5912, 17.1861, 17.5469, 17.543)
      ..cubicTo(17.5015, 17.9087, 17.4225, 18.2506, 17.2461, 18.5723)
      ..cubicTo(16.9747, 19.0671, 16.5579, 19.4671, 16.0518, 19.7168)
      ..cubicTo(15.7227, 19.8791, 15.3772, 19.9422, 15.0098, 19.9717)
      ..cubicTo(14.6514, 20.0004, 14.2126, 20.0, 13.6865, 20.0)
      ..lineTo(10.3135, 20.0)
      ..cubicTo(9.78735, 20.0, 9.34856, 20.0004, 8.99023, 19.9717)
      ..cubicTo(8.62278, 19.9422, 8.27729, 19.8791, 7.94824, 19.7168)
      ..cubicTo(7.44205, 19.4671, 7.02532, 19.0671, 6.75391, 18.5723)
      ..cubicTo(6.57751, 18.2506, 6.49853, 17.9087, 6.45312, 17.543)
      ..cubicTo(6.40883, 17.1861, 6.39005, 16.7475, 6.36719, 16.2217)
      ..lineTo(6.03223, 8.5)
      ..lineTo(5.5, 8.5)
      ..cubicTo(5.08579, 8.5, 4.75, 8.16421, 4.75, 7.75)
      ..cubicTo(4.75, 7.33579, 5.08579, 7.0, 5.5, 7.0)
      ..lineTo(8.25, 7.0)
      ..lineTo(8.25, 6.25)
      ..cubicTo(8.25, 5.00736, 9.25736, 4.0, 10.5, 4.0)
      ..lineTo(13.5, 4.0)
      ..close()
      ..moveTo(7.86621, 16.1562)
      ..cubicTo(7.89013, 16.7063, 7.90624, 17.0751, 7.94141, 17.3584)
      ..cubicTo(7.97545, 17.6326, 8.02151, 17.7644, 8.06934, 17.8516)
      ..cubicTo(8.19271, 18.0763, 8.38239, 18.2577, 8.6123, 18.3711)
      ..cubicTo(8.70153, 18.4151, 8.83504, 18.4545, 9.11035, 18.4766)
      ..cubicTo(9.39482, 18.4994, 9.76335, 18.5, 10.3135, 18.5)
      ..lineTo(13.6865, 18.5)
      ..cubicTo(14.2367, 18.5, 14.6052, 18.4994, 14.8896, 18.4766)
      ..cubicTo(15.165, 18.4545, 15.2985, 18.4151, 15.3877, 18.3711)
      ..cubicTo(15.6176, 18.2577, 15.8073, 18.0763, 15.9307, 17.8516)
      ..cubicTo(15.9785, 17.7644, 16.0245, 17.6326, 16.0586, 17.3584)
      ..cubicTo(16.0938, 17.0751, 16.1099, 16.7063, 16.1338, 16.1562)
      ..lineTo(16.4668, 8.5)
      ..lineTo(7.5332, 8.5)
      ..lineTo(7.86621, 16.1562)
      ..close()
      ..moveTo(9.97656, 10.75)
      ..cubicTo(10.3906, 10.7371, 10.7371, 11.0626, 10.75, 11.4766)
      ..lineTo(10.875, 15.4766)
      ..cubicTo(10.8879, 15.8906, 10.5624, 16.2371, 10.1484, 16.25)
      ..cubicTo(9.73443, 16.2629, 9.38794, 15.9374, 9.375, 15.5234)
      ..lineTo(9.25, 11.5234)
      ..cubicTo(9.23706, 11.1094, 9.56255, 10.7629, 9.97656, 10.75)
      ..close()
      ..moveTo(14.0244, 10.75)
      ..cubicTo(14.4384, 10.7635, 14.7635, 11.1105, 14.75, 11.5244)
      ..lineTo(14.6201, 15.5244)
      ..cubicTo(14.6066, 15.9384, 14.2596, 16.2634, 13.8457, 16.25)
      ..cubicTo(13.4317, 16.2365, 13.1067, 15.8896, 13.1201, 15.4756)
      ..lineTo(13.251, 11.4756)
      ..cubicTo(13.2645, 11.0617, 13.6105, 10.7366, 14.0244, 10.75)
      ..close()
      ..moveTo(10.5, 5.5)
      ..cubicTo(10.0858, 5.5, 9.75, 5.83579, 9.75, 6.25)
      ..lineTo(9.75, 7.0)
      ..lineTo(14.25, 7.0)
      ..lineTo(14.25, 6.25)
      ..cubicTo(14.25, 5.83579, 13.9142, 5.5, 13.5, 5.5)
      ..lineTo(10.5, 5.5)
      ..close();

    canvas.drawPath(path, fillPaint);
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

    // Exact path from upstream IconGear
    final path = Path()
      ..moveTo(10.6504, 5.81117)
      ..cubicTo(10.9939, 4.39628, 13.0061, 4.39628, 13.3496, 5.81117)
      ..cubicTo(13.5715, 6.72517, 14.6187, 7.15891, 15.4219, 6.66952)
      ..cubicTo(16.6652, 5.91193, 18.0881, 7.33479, 17.3305, 8.57815)
      ..cubicTo(16.8411, 9.38134, 17.2748, 10.4285, 18.1888, 10.6504)
      ..cubicTo(19.6037, 10.9939, 19.6037, 13.0061, 18.1888, 13.3496)
      ..cubicTo(17.2748, 13.5715, 16.8411, 14.6187, 17.3305, 15.4219)
      ..cubicTo(18.0881, 16.6652, 16.6652, 18.0881, 15.4219, 17.3305)
      ..cubicTo(14.6187, 16.8411, 13.5715, 17.2748, 13.3496, 18.1888)
      ..cubicTo(13.0061, 19.6037, 10.9939, 19.6037, 10.6504, 18.1888)
      ..cubicTo(10.4285, 17.2748, 9.38135, 16.8411, 8.57815, 17.3305)
      ..cubicTo(7.33479, 18.0881, 5.91193, 16.6652, 6.66952, 15.4219)
      ..cubicTo(7.15891, 14.6187, 6.72517, 13.5715, 5.81117, 13.3496)
      ..cubicTo(4.39628, 13.0061, 4.39628, 10.9939, 5.81117, 10.6504)
      ..cubicTo(6.72517, 10.4285, 7.15891, 9.38134, 6.66952, 8.57815)
      ..cubicTo(5.91193, 7.33479, 7.33479, 5.91192, 8.57815, 6.66952)
      ..cubicTo(9.38135, 7.15891, 10.4285, 6.72517, 10.6504, 5.81117)
      ..close();

    canvas.drawPath(path, strokePaint);
    canvas.drawCircle(const Offset(12.0, 12.0), 2.5, strokePaint);

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
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

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

class _SendIconPainter extends CustomPainter {
  const _SendIconPainter({required this.color});
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

    final path = Path()
      ..moveTo(9.875, 14.125)
      ..lineTo(12.3506, 19.6951)
      ..cubicTo(12.7184, 20.5227, 13.9091, 20.4741, 14.2083, 19.6193)
      ..lineTo(18.8139, 6.46032)
      ..cubicTo(19.0907, 5.6695, 18.3305, 4.90933, 17.5397, 5.18611)
      ..lineTo(4.38072, 9.79174)
      ..cubicTo(3.52589, 10.0909, 3.47731, 11.2816, 4.30494, 11.6494)
      ..lineTo(9.875, 14.125)
      ..close()
      ..moveTo(9.875, 14.125)
      ..lineTo(13.375, 10.625);

    canvas.drawPath(path, strokePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SendIconPainter oldDelegate) => oldDelegate.color != color;
}

class _ListSparkleIconPainter extends CustomPainter {
  const _ListSparkleIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale);

    // Top horizontal line
    canvas.drawLine(const Offset(5.5, 6.75), const Offset(18.5, 6.75), strokePaint);

    // Middle horizontal line
    canvas.drawLine(const Offset(5.5, 12.0), const Offset(11.5, 12.0), strokePaint);

    // Bottom horizontal line
    canvas.drawLine(const Offset(5.5, 17.25), const Offset(9.25, 17.25), strokePaint);

    // Sparkle star on bottom-right
    final sparklePath = Path()
      ..moveTo(16.0, 12.75)
      ..lineTo(16.5179, 13.9677)
      ..cubicTo(16.8078, 14.6494, 17.3506, 15.1922, 18.0323, 15.4821)
      ..lineTo(19.25, 16.0)
      ..lineTo(18.0323, 16.5179)
      ..cubicTo(17.3506, 16.8078, 16.8078, 17.3506, 16.5179, 18.0323)
      ..lineTo(16.0, 19.25)
      ..lineTo(15.4821, 18.0323)
      ..cubicTo(15.1922, 17.3506, 14.6494, 16.8078, 13.9677, 16.5179)
      ..lineTo(12.75, 16.0)
      ..lineTo(13.9677, 15.4821)
      ..cubicTo(14.6494, 15.1922, 15.1922, 14.6494, 15.4821, 13.9677)
      ..close();

    canvas.drawPath(sparklePath, strokePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ListSparkleIconPainter oldDelegate) => oldDelegate.color != color;
}

class _MoonIconPainter extends CustomPainter {
  const _MoonIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scale = size.width / 20.0;
    canvas.save();
    canvas.scale(scale);

    final path = Path()
      ..moveTo(15.5, 10.4955)
      ..cubicTo(15.4037, 11.5379, 15.0124, 12.5314, 14.3721, 13.3596)
      ..cubicTo(13.7317, 14.1878, 12.8688, 14.8165, 11.8841, 15.1722)
      ..cubicTo(10.8995, 15.5278, 9.83397, 15.5957, 8.81217, 15.3679)
      ..cubicTo(7.79038, 15.1401, 6.8546, 14.6259, 6.11434, 13.8857)
      ..cubicTo(5.37408, 13.1454, 4.85995, 12.2096, 4.63211, 11.1878)
      ..cubicTo(4.40427, 10.166, 4.47215, 9.10048, 4.82781, 8.11585)
      ..cubicTo(5.18346, 7.13123, 5.81218, 6.26825, 6.64039, 5.62791)
      ..cubicTo(7.4686, 4.98756, 8.46206, 4.59634, 9.5045, 4.5)
      ..cubicTo(8.89418, 5.32569, 8.60049, 6.34302, 8.67685, 7.36695)
      ..cubicTo(8.75321, 8.39087, 9.19454, 9.35339, 9.92058, 10.0794)
      ..cubicTo(10.6466, 10.8055, 11.6091, 11.2468, 12.6331, 11.3231)
      ..cubicTo(13.657, 11.3995, 14.6743, 11.1058, 15.5, 10.4955)
      ..close();

    canvas.drawPath(path, strokePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MoonIconPainter oldDelegate) => oldDelegate.color != color;
}

class _SunIconPainter extends CustomPainter {
  const _SunIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scale = size.width / 20.0;
    canvas.save();
    canvas.scale(scale);

    // Center circular sun
    canvas.drawCircle(const Offset(10.0, 10.0), 2.7083, strokePaint);

    // 8 rays
    canvas.drawLine(const Offset(10.0, 3.9585), const Offset(10.0, 5.057), strokePaint);
    canvas.drawLine(const Offset(10.0, 14.943), const Offset(10.0, 16.0414), strokePaint);
    canvas.drawLine(const Offset(3.9583, 10.0), const Offset(5.0568, 10.0), strokePaint);
    canvas.drawLine(const Offset(14.9432, 10.0), const Offset(16.0417, 10.0), strokePaint);
    canvas.drawLine(const Offset(5.7269, 5.7266), const Offset(6.5068, 6.5065), strokePaint);
    canvas.drawLine(const Offset(13.4932, 13.4932), const Offset(14.2731, 14.2731), strokePaint);
    canvas.drawLine(const Offset(5.7269, 14.2731), const Offset(6.5068, 13.4932), strokePaint);
    canvas.drawLine(const Offset(13.4932, 6.5065), const Offset(14.2731, 5.7266), strokePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_SunIconPainter oldDelegate) => oldDelegate.color != color;
}

