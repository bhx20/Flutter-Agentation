import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_radii.dart';

/// A custom desktop-grade scrollbar widget matching the classic Windows / Browser
/// stepper UI with top/bottom directional arrows, clean rail track, and a draggable
/// thumb with horizontal grip ridges.
///
/// Uses isolated [RepaintBoundary] and [AnimatedBuilder] layers so the main content
/// never rebuilds during scrolling, completely eliminating scroll flicker.
class DesktopScrollbar extends StatelessWidget {
  const DesktopScrollbar({
    super.key,
    required this.controller,
    required this.child,
    this.width = 14.0,
    this.buttonHeight = 16.0,
  });

  /// The scroll controller linked to the scrollable child.
  final ScrollController controller;

  /// The primary scrollable child content (e.g. [SingleChildScrollView]).
  final Widget child;

  /// Width of the vertical scrollbar rail. Defaults to 14.0px.
  final double width;

  /// Height of the top and bottom stepper buttons. Defaults to 16.0px.
  final double buttonHeight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: child,
          ),
        ),
        Positioned(
          top: AppDimensions.d0,
          bottom: AppDimensions.d0,
          right: AppDimensions.d0,
          width: width,
          child: RepaintBoundary(
            child: _ScrollbarRail(
              controller: controller,
              width: width,
              buttonHeight: buttonHeight,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScrollbarRail extends StatefulWidget {
  const _ScrollbarRail({
    required this.controller,
    required this.width,
    required this.buttonHeight,
  });

  final ScrollController controller;
  final double width;
  final double buttonHeight;

  @override
  State<_ScrollbarRail> createState() => _ScrollbarRailState();
}

class _ScrollbarRailState extends State<_ScrollbarRail> {
  final ValueNotifier<bool> _isTopHovered = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isBottomHovered = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isTopPressed = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isBottomPressed = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isThumbHovered = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isThumbDragging = ValueNotifier<bool>(false);

  Timer? _stepperTimer;

  void _startContinuousScroll({required bool isUp}) {
    _scrollStep(isUp: isUp);
    _stepperTimer?.cancel();
    _stepperTimer = Timer(const Duration(milliseconds: 250), () {
      _stepperTimer = Timer.periodic(const Duration(milliseconds: 40), (_) {
        _scrollStep(isUp: isUp, step: 24.0);
      });
    });
  }

  void _stopContinuousScroll() {
    _stepperTimer?.cancel();
    _stepperTimer = null;
  }

  void _scrollStep({required bool isUp, double step = 48.0}) {
    if (!widget.controller.hasClients || !widget.controller.position.hasContentDimensions) return;
    final position = widget.controller.position;
    final target = isUp
        ? (widget.controller.offset - step).clamp(0.0, position.maxScrollExtent)
        : (widget.controller.offset + step).clamp(0.0, position.maxScrollExtent);

    widget.controller.animateTo(
      target,
      duration: const Duration(milliseconds: 70),
      curve: Curves.easeOut,
    );
  }

  void _pageScroll(double clickY, double thumbTop, double thumbBottom) {
    if (!widget.controller.hasClients || !widget.controller.position.hasContentDimensions) return;
    final position = widget.controller.position;
    final pageSize = position.viewportDimension * 0.8;

    if (clickY < thumbTop) {
      widget.controller.animateTo(
        (widget.controller.offset - pageSize).clamp(0.0, position.maxScrollExtent),
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
      );
    } else if (clickY > thumbBottom) {
      widget.controller.animateTo(
        (widget.controller.offset + pageSize).clamp(0.0, position.maxScrollExtent),
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _stepperTimer?.cancel();
    _isTopHovered.dispose();
    _isBottomHovered.dispose();
    _isTopPressed.dispose();
    _isBottomPressed.dispose();
    _isThumbHovered.dispose();
    _isThumbDragging.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final hasDimensions = widget.controller.hasClients &&
            widget.controller.position.hasContentDimensions;
        final maxScroll = hasDimensions
            ? widget.controller.position.maxScrollExtent
            : 0.0;
        final viewport = hasDimensions
            ? widget.controller.position.viewportDimension
            : 1.0;
        final offset = hasDimensions
            ? widget.controller.offset.clamp(0.0, maxScroll)
            : 0.0;

        return Listener(
          onPointerSignal: (pointerSignal) {
            if (pointerSignal is PointerScrollEvent && hasDimensions && maxScroll > 0) {
              final newOffset = (widget.controller.offset + pointerSignal.scrollDelta.dy)
                  .clamp(0.0, maxScroll);
              widget.controller.jumpTo(newOffset);
            }
          },
          child: Container(
            width: widget.width,
            decoration: const BoxDecoration(
              color: AppColors.scrollbarTrackBg,
              border: Border(
                left: BorderSide(color: AppColors.scrollbarBorderRail, width: AppDimensions.d1),
              ),
            ),
            child: Column(
              children: [
                // Top Stepper Button (Arrow Up)
                _buildStepperButton(
                  isUp: true,
                  hoverNotifier: _isTopHovered,
                  pressedNotifier: _isTopPressed,
                  onEnter: () => _isTopHovered.value = true,
                  onExit: () => _isTopHovered.value = false,
                  onPointerDown: () {
                    _isTopPressed.value = true;
                    _startContinuousScroll(isUp: true);
                  },
                  onPointerUp: () {
                    _isTopPressed.value = false;
                    _stopContinuousScroll();
                  },
                ),

                // Middle Track Area with Draggable Thumb
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final trackHeight = constraints.maxHeight;
                      if (trackHeight <= 0) return const SizedBox.shrink();

                      final bool canScroll = hasDimensions && maxScroll > 0.0;
                      final double minThumbHeight = math.min(trackHeight, 28.0);

                      final double calculatedThumbHeight = canScroll
                          ? (viewport / (maxScroll + viewport)) * trackHeight
                          : trackHeight;
                      final double thumbHeight = math.max(
                        minThumbHeight,
                        math.min(trackHeight, calculatedThumbHeight),
                      );

                      final double effectiveTrack = trackHeight - thumbHeight;
                      final double thumbTop = (canScroll && effectiveTrack > 0)
                          ? (offset / maxScroll) * effectiveTrack
                          : 0.0;
                      final double thumbBottom = thumbTop + thumbHeight;

                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (details) {
                          _pageScroll(
                            details.localPosition.dy,
                            thumbTop,
                            thumbBottom,
                          );
                        },
                        child: Stack(
                          children: [
                            if (canScroll)
                              Positioned(
                                top: thumbTop,
                                left: AppDimensions.d1_5,
                                right: AppDimensions.d1_5,
                                height: thumbHeight,
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.basic,
                                  onEnter: (_) => _isThumbHovered.value = true,
                                  onExit: (_) => _isThumbHovered.value = false,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onVerticalDragStart: (_) {
                                      _isThumbDragging.value = true;
                                    },
                                    onVerticalDragUpdate: (details) {
                                      if (effectiveTrack > 0 && maxScroll > 0) {
                                        final deltaScroll =
                                            (details.delta.dy / effectiveTrack) *
                                                maxScroll;
                                        widget.controller.jumpTo(
                                          (widget.controller.offset + deltaScroll)
                                              .clamp(0.0, maxScroll),
                                        );
                                      }
                                    },
                                    onVerticalDragEnd: (_) {
                                      _isThumbDragging.value = false;
                                    },
                                    onVerticalDragCancel: () {
                                      _isThumbDragging.value = false;
                                    },
                                    child: ValueListenableBuilder<bool>(
                                      valueListenable: _isThumbDragging,
                                      builder: (context, isDragging, _) {
                                        return ValueListenableBuilder<bool>(
                                          valueListenable: _isThumbHovered,
                                          builder: (context, isHovered, _) {
                                            final Color currentThumbColor = isDragging
                                                ? AppColors.scrollbarThumbDrag
                                                : (isHovered
                                                    ? AppColors.scrollbarThumbHover
                                                    : AppColors.scrollbarThumbIdle);
                                            final Color currentGripColor =
                                                (isDragging || isHovered)
                                                    ? AppColors.scrollbarGripActive
                                                    : AppColors.scrollbarGripIdle;

                                            return Container(
                                              decoration: BoxDecoration(
                                                color: currentThumbColor,
                                                borderRadius: AppRadii.rounded2,
                                              ),
                                              child: Center(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: AppDimensions.d6,
                                                      height: AppDimensions.d1,
                                                      color: currentGripColor,
                                                    ),
                                                    const SizedBox(
                                                      height: AppDimensions.d1_5,
                                                    ),
                                                    Container(
                                                      width: AppDimensions.d6,
                                                      height: AppDimensions.d1,
                                                      color: currentGripColor,
                                                    ),
                                                    const SizedBox(
                                                      height: AppDimensions.d1_5,
                                                    ),
                                                    Container(
                                                      width: AppDimensions.d6,
                                                      height: AppDimensions.d1,
                                                      color: currentGripColor,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Stepper Button (Arrow Down)
                _buildStepperButton(
                  isUp: false,
                  hoverNotifier: _isBottomHovered,
                  pressedNotifier: _isBottomPressed,
                  onEnter: () => _isBottomHovered.value = true,
                  onExit: () => _isBottomHovered.value = false,
                  onPointerDown: () {
                    _isBottomPressed.value = true;
                    _startContinuousScroll(isUp: false);
                  },
                  onPointerUp: () {
                    _isBottomPressed.value = false;
                    _stopContinuousScroll();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepperButton({
    required bool isUp,
    required ValueNotifier<bool> hoverNotifier,
    required ValueNotifier<bool> pressedNotifier,
    required VoidCallback onEnter,
    required VoidCallback onExit,
    required VoidCallback onPointerDown,
    required VoidCallback onPointerUp,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => onEnter(),
      onExit: (_) => onExit(),
      child: Listener(
        onPointerDown: (_) => onPointerDown(),
        onPointerUp: (_) => onPointerUp(),
        onPointerCancel: (_) => onPointerUp(),
        child: ValueListenableBuilder<bool>(
          valueListenable: pressedNotifier,
          builder: (context, isPressed, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: hoverNotifier,
              builder: (context, isHovered, _) {
                final Color bgColor = isPressed
                    ? AppColors.scrollbarBtnPressed
                    : (isHovered
                        ? AppColors.scrollbarBtnHover
                        : AppColors.scrollbarBtnIdle);

                return Container(
                  width: widget.width,
                  height: widget.buttonHeight,
                  decoration: BoxDecoration(
                    color: bgColor,
                    border: Border(
                      top: isUp
                          ? BorderSide.none
                          : const BorderSide(
                              color: AppColors.scrollbarBorderButton,
                              width: AppDimensions.d1,
                            ),
                      bottom: isUp
                          ? const BorderSide(
                              color: AppColors.scrollbarBorderButton,
                              width: AppDimensions.d1,
                            )
                          : BorderSide.none,
                    ),
                  ),
                  child: Center(
                    child: CustomPaint(
                      size: const Size(AppDimensions.d6, AppDimensions.d5),
                      painter: _StepperTrianglePainter(
                        isUp: isUp,
                        color: AppColors.scrollbarArrow,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _StepperTrianglePainter extends CustomPainter {
  const _StepperTrianglePainter({
    required this.isUp,
    required this.color,
  });

  final bool isUp;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    if (isUp) {
      path.moveTo(size.width / 2.0, 0.0);
      path.lineTo(size.width, size.height);
      path.lineTo(0.0, size.height);
    } else {
      path.moveTo(0.0, 0.0);
      path.lineTo(size.width, 0.0);
      path.lineTo(size.width / 2.0, size.height);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_StepperTrianglePainter oldDelegate) =>
      oldDelegate.isUp != isUp || oldDelegate.color != color;
}
