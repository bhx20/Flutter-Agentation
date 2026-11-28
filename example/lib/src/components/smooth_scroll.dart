import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// A drop-in [ScrollController] that provides ultra-smooth, JS-grade mouse wheel
/// momentum and exponential decay physics (matching Lenis / Locomotive scroll)
/// directly at the engine's [ScrollPosition] layer.
class SmoothScrollController extends ScrollController {
  SmoothScrollController({
    super.initialScrollOffset,
    super.keepScrollOffset,
    super.debugLabel,
    this.damping = 4.2,
    this.speedMultiplier = 1.35,
  });

  /// Exponential decay damping factor.
  /// Lower values (e.g. 3.8 - 4.5) yield a luxurious, floaty, cinematic glide.
  final double damping;

  /// Multiplier applied to mouse wheel delta for effortless page travel.
  final double speedMultiplier;

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return _SmoothScrollPosition(
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
      damping: damping,
      speedMultiplier: speedMultiplier,
    );
  }
}

class _SmoothScrollPosition extends ScrollPositionWithSingleContext {
  _SmoothScrollPosition({
    required super.physics,
    required super.context,
    super.initialPixels = 0.0,
    super.keepScrollOffset,
    super.oldPosition,
    super.debugLabel,
    required this.damping,
    required this.speedMultiplier,
  });

  final double damping;
  final double speedMultiplier;

  Ticker? _smoothTicker;
  double _smoothTarget = 0.0;
  Duration? _lastTime;

  @override
  void pointerScroll(double delta) {
    if (delta == 0.0) {
      goBallistic(0.0);
      return;
    }

    // Check bounds
    if (!hasContentDimensions || maxScrollExtent <= 0.0) {
      super.pointerScroll(delta);
      return;
    }

    final effectiveDelta = delta * speedMultiplier;

    if (_smoothTicker == null || !_smoothTicker!.isActive) {
      _smoothTarget = pixels;
      _lastTime = null;
      _smoothTicker ??= context.vsync.createTicker(_onSmoothTick);
    }

    _smoothTarget = (_smoothTarget + effectiveDelta).clamp(minScrollExtent, maxScrollExtent);

    if (!_smoothTicker!.isActive) {
      goIdle();
      updateUserScrollDirection(
        -delta > 0.0 ? ScrollDirection.forward : ScrollDirection.reverse,
      );
      _smoothTicker!.start();
    }
  }

  void _onSmoothTick(Duration elapsed) {
    if (!hasContentDimensions) {
      _smoothTicker?.stop();
      _lastTime = null;
      return;
    }

    final dt = _lastTime == null
        ? 0.016
        : (elapsed - _lastTime!).inMicroseconds / 1000000.0;
    _lastTime = elapsed;

    final clampedDt = dt.clamp(0.001, 0.05);
    final t = 1.0 - math.exp(-damping * clampedDt);
    final next = pixels + (_smoothTarget - pixels) * t;

    if ((_smoothTarget - pixels).abs() <= 0.2) {
      final double delta = _smoothTarget - pixels;
      if (delta != 0.0) {
        forcePixels(_smoothTarget);
        didUpdateScrollPositionBy(delta);
      }
      _smoothTicker?.stop();
      _lastTime = null;
      goIdle();
    } else {
      final double delta = next - pixels;
      if (delta != 0.0) {
        forcePixels(next);
        didUpdateScrollPositionBy(delta);
      }
    }
  }

  @override
  void jumpTo(double value) {
    _smoothTicker?.stop();
    _lastTime = null;
    super.jumpTo(value);
  }

  @override
  Future<void> animateTo(
    double to, {
    required Duration duration,
    required Curve curve,
  }) {
    _smoothTicker?.stop();
    _lastTime = null;
    return super.animateTo(to, duration: duration, curve: curve);
  }

  @override
  Drag drag(DragStartDetails details, VoidCallback dragCancelCallback) {
    _smoothTicker?.stop();
    _lastTime = null;
    return super.drag(details, dragCancelCallback);
  }

  @override
  void dispose() {
    _smoothTicker?.dispose();
    super.dispose();
  }
}

/// A high-performance smooth scrolling wrapper widget providing modern,
/// silky-smooth JS-grade momentum and exponential decay physics (similar to
/// Lenis / Locomotive scroll) for mouse wheel and trackpad interactions.
class SmoothScroll extends StatefulWidget {
  const SmoothScroll({
    super.key,
    required this.controller,
    required this.child,
    this.speedMultiplier = 1.35,
    this.damping = 4.2,
  });

  /// The scroll controller linked to the scrollable view.
  final ScrollController controller;

  /// The child scrollable content.
  final Widget child;

  /// Multiplier applied to mouse wheel delta. Defaults to 1.35.
  final double speedMultiplier;

  /// Exponential decay damping factor. Defaults to 4.2.
  final double damping;

  @override
  State<SmoothScroll> createState() => SmoothScrollState();
}

class SmoothScrollState extends State<SmoothScroll>
    with SingleTickerProviderStateMixin {
  Ticker? _ticker;
  double _targetOffset = 0.0;
  Duration? _lastFrameTime;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!widget.controller.hasClients ||
        !widget.controller.position.hasContentDimensions) {
      _ticker?.stop();
      _lastFrameTime = null;
      return;
    }

    final maxScroll = widget.controller.position.maxScrollExtent;
    _targetOffset = _targetOffset.clamp(0.0, maxScroll);
    final currentOffset = widget.controller.offset;

    final dt = _lastFrameTime == null
        ? 0.016
        : (elapsed - _lastFrameTime!).inMicroseconds / 1000000.0;
    _lastFrameTime = elapsed;

    final clampedDt = dt.clamp(0.001, 0.05);
    final t = 1.0 - math.exp(-widget.damping * clampedDt);
    final nextOffset = currentOffset + (_targetOffset - currentOffset) * t;

    if ((_targetOffset - currentOffset).abs() <= 0.2) {
      widget.controller.jumpTo(_targetOffset);
      _ticker?.stop();
      _lastFrameTime = null;
    } else {
      widget.controller.jumpTo(nextOffset);
    }
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (event.scrollDelta.dy == 0.0) return;

    if (!widget.controller.hasClients ||
        !widget.controller.position.hasContentDimensions) {
      return;
    }

    final maxScroll = widget.controller.position.maxScrollExtent;
    if (maxScroll <= 0.0) return;

    GestureBinding.instance.pointerSignalResolver.register(event, (resolvedEvent) {
      final scrollEvent = resolvedEvent as PointerScrollEvent;
      final delta = scrollEvent.scrollDelta.dy * widget.speedMultiplier;

      // Synchronize target with current offset if not already active
      if (!(_ticker?.isActive ?? false)) {
        _targetOffset = widget.controller.offset;
      }

      _targetOffset = (_targetOffset + delta).clamp(0.0, maxScroll);

      if (!(_ticker?.isActive ?? false)) {
        _lastFrameTime = null;
        _ticker?.start();
      }
    });
  }

  /// Smoothly scrolls to the given target offset with the same Lenis-style decay curve.
  void smoothScrollTo(double target) {
    if (!widget.controller.hasClients ||
        !widget.controller.position.hasContentDimensions) {
      return;
    }

    final maxScroll = widget.controller.position.maxScrollExtent;
    _targetOffset = target.clamp(0.0, maxScroll);

    if (!(_ticker?.isActive ?? false)) {
      _lastFrameTime = null;
      _ticker?.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _handlePointerSignal,
      child: widget.child,
    );
  }
}
