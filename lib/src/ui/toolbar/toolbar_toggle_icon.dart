import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Morphing animated toggle icon matching upstream Agentation ToolbarToggleIcon.
///
/// The same strokes form both the launcher icon (list with sparkle) and the close '✕' icon:
/// - When active=false (collapsed): displays the 3 horizontal lines and sparkle star.
/// - When active=true (expanded): top & middle lines rotate and translate to form the '✕',
///   while the bottom line and sparkle smoothly scale down to 0 and fade out.
/// - Uses exact cubic-bezier(0.22, 1, 0.36, 1) timing over 300ms, with 160ms opacity fade.
class ToolbarToggleIcon extends StatefulWidget {
  const ToolbarToggleIcon({
    super.key,
    required this.active,
    this.size = 20.0,
    this.color = Colors.white,
  });

  /// Whether the toolbar is active/expanded (true = close '✕', false = launcher list-sparkle).
  final bool active;

  /// Width and height of the icon (defaults to 20.0).
  final double size;

  /// Stroke color of the icon glyph.
  final Color color;

  // Preserves animation progress across widget rebuilds and key switches
  static double _lastProgress = 0.0;
  static bool _hasInitialized = false;

  @override
  State<ToolbarToggleIcon> createState() => _ToolbarToggleIconState();
}

class _ToolbarToggleIconState extends State<ToolbarToggleIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curvedAnimation;

  @override
  void initState() {
    super.initState();
    final target = widget.active ? 1.0 : 0.0;
    final initial = ToolbarToggleIcon._hasInitialized
        ? ToolbarToggleIcon._lastProgress
        : target;
    ToolbarToggleIcon._hasInitialized = true;
    ToolbarToggleIcon._lastProgress = initial;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: initial,
    );

    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Cubic(0.22, 1.0, 0.36, 1.0),
      reverseCurve: const Cubic(0.22, 1.0, 0.36, 1.0).flipped,
    );

    _controller.addListener(() {
      ToolbarToggleIcon._lastProgress = _controller.value;
    });

    if (initial != target) {
      _controller.animateTo(target);
    }
  }

  @override
  void didUpdateWidget(covariant ToolbarToggleIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) {
      final target = widget.active ? 1.0 : 0.0;
      _controller.animateTo(target);
    }
  }

  @override
  void dispose() {
    ToolbarToggleIcon._lastProgress = _controller.value;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curvedAnimation,
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _ToolbarTogglePainter(
            progress: _curvedAnimation.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _ToolbarTogglePainter extends CustomPainter {
  final double progress; // 0.0 = listSparkle (collapsed), 1.0 = close X (expanded)
  final Color color;

  const _ToolbarTogglePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale);

    // Upstream: .toggleIcon translateY(-0.5px) when collapsed, 0 when expanded
    final translateY = -0.5 * (1.0 - progress);
    canvas.translate(0.0, translateY);

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // ── 1. Top Line -> First stroke of '✕' ──
    // Inactive: (5.5, 6.75) to (18.5, 6.75)
    // Active: translateY(5.25px) rotate(45deg) scaleX(1.1422494)
    final topCenterY = 6.75 + 5.25 * progress;
    final topAngle = (math.pi / 4.0) * progress;
    final topHalfLen = 6.5 * (1.0 + 0.1422494 * progress);
    final topVec = Offset(
      math.cos(topAngle) * topHalfLen,
      math.sin(topAngle) * topHalfLen,
    );
    final topCenter = Offset(12.0, topCenterY);
    canvas.drawLine(topCenter - topVec, topCenter + topVec, strokePaint);

    // ── 2. Middle Line -> Second stroke of '✕' ──
    // Inactive: (5.5, 12.0) to (11.5, 12.0)
    // Active: translateX(3.5px) rotate(-45deg) scaleX(2.4748737)
    final midCenterX = 8.5 + 3.5 * progress;
    final midAngle = (-math.pi / 4.0) * progress;
    final midHalfLen = 3.0 * (1.0 + 1.4748737 * progress);
    final midVec = Offset(
      math.cos(midAngle) * midHalfLen,
      math.sin(midAngle) * midHalfLen,
    );
    final midCenter = Offset(midCenterX, 12.0);
    canvas.drawLine(midCenter - midVec, midCenter + midVec, strokePaint);

    // ── Opacity for disappearing elements (160ms out of 300ms => 160/300 = 0.5333) ──
    final opacityRatio = (1.0 - progress).clamp(0.0, 1.0);
    final fadeProgress = (opacityRatio / 0.5333).clamp(0.0, 1.0);
    final double elementOpacity = Curves.ease.transform(fadeProgress);

    if (elementOpacity > 0.005) {
      final fadePaint = Paint()
        ..color = color.withValues(alpha: color.a * elementOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      // ── 3. Bottom Line: scales X to 0 from left (5.5, 17.25) ──
      final bottomLen = 3.75 * opacityRatio;
      if (bottomLen > 0.01) {
        canvas.drawLine(
          const Offset(5.5, 17.25),
          Offset(5.5 + bottomLen, 17.25),
          fadePaint,
        );
      }

      // ── 4. Sparkle Star: scales to 0 from center (16.0, 16.0) ──
      if (opacityRatio > 0.01) {
        canvas.save();
        canvas.translate(16.0, 16.0);
        canvas.scale(opacityRatio);
        canvas.translate(-16.0, -16.0);

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

        canvas.drawPath(sparklePath, fadePaint);
        canvas.restore();
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_ToolbarTogglePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
