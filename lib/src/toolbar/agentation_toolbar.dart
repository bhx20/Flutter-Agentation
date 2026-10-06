import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/agentation_controller.dart';
import '../core/agentation_scope.dart';
import '../core/agentation_state.dart';
import '../design/component_palette.dart';
import '../models/marker_color.dart';
import 'agentation_icons.dart';
import 'settings_panel.dart';

/// Pixel-perfect floating pill toolbar matching Screenshot 1, 2, 3, 4 of Agentation.
class AgentationToolbar extends StatefulWidget {
  const AgentationToolbar({
    super.key,
    this.controller,
    this.initialAlignment = Alignment.bottomCenter,
    this.onOpenSettings,
  });

  /// Optional controller; defaults to closest [AgentationScope].
  final AgentationController? controller;

  /// Initial screen quadrant alignment (defaults to bottom-center).
  final Alignment initialAlignment;

  /// Optional callback to open settings.
  final VoidCallback? onOpenSettings;

  @override
  State<AgentationToolbar> createState() => _AgentationToolbarState();
}

enum ToolbarAnchor { left, right, center }

class _ToolbarPositionState {
  final ToolbarAnchor anchor;
  final double? leftInset;
  final double? rightInset;
  final double? bottomInset;
  final bool isDragging;

  const _ToolbarPositionState({
    this.anchor = ToolbarAnchor.center,
    this.leftInset,
    this.rightInset,
    this.bottomInset,
    this.isDragging = false,
  });

  _ToolbarPositionState copyWith({
    ToolbarAnchor? anchor,
    double? leftInset,
    double? rightInset,
    double? bottomInset,
    bool? isDragging,
    bool clearLeft = false,
    bool clearRight = false,
  }) {
    return _ToolbarPositionState(
      anchor: anchor ?? this.anchor,
      leftInset: clearLeft ? null : (leftInset ?? this.leftInset),
      rightInset: clearRight ? null : (rightInset ?? this.rightInset),
      bottomInset: bottomInset ?? this.bottomInset,
      isDragging: isDragging ?? this.isDragging,
    );
  }
}

class _AgentationToolbarState extends State<AgentationToolbar> {
  final ValueNotifier<_ToolbarPositionState> _positionNotifier =
      ValueNotifier<_ToolbarPositionState>(const _ToolbarPositionState());
  final ValueNotifier<String> _sendStateNotifier = ValueNotifier<String>('idle');
  Timer? _sendTimer;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final ctrl = _controller;
        if (!ctrl.isToolbarMinimized && !ctrl.isInspecting) {
          ctrl.activate();
        }
      }
    });
  }

  @override
  void dispose() {
    _sendTimer?.cancel();
    _positionNotifier.dispose();
    _sendStateNotifier.dispose();
    super.dispose();
  }

  AgentationController get _controller =>
      widget.controller ?? AgentationScope.of(context);

  Future<void> _onCopy(AgentationController controller) async {
    final count = controller.annotations.length;
    if (count == 0) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(
            content: Text('No annotations to export'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    await controller.copyFeedback();
    if (mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text('Copied $count annotation${count == 1 ? "" : "s"} to clipboard!'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _initInsetsIfNeeded(
    Size screenSize,
    EdgeInsets safePadding,
    double effectiveWidth,
    double toolbarHeight,
  ) {
    if (_initialized) return;
    _initialized = true;

    final defaultBottom = safePadding.bottom + 20.0;

    if (_controller.toolbarOffset != Offset.zero) {
      final ox = _controller.toolbarOffset.dx;
      final oy = _controller.toolbarOffset.dy;
      final bottomInset = screenSize.height - oy - toolbarHeight;
      final centerX = ox + effectiveWidth / 2.0;
      if (centerX >= screenSize.width / 2.0) {
        _positionNotifier.value = _ToolbarPositionState(
          anchor: ToolbarAnchor.right,
          rightInset: screenSize.width - (ox + effectiveWidth),
          bottomInset: bottomInset,
        );
      } else {
        _positionNotifier.value = _ToolbarPositionState(
          anchor: ToolbarAnchor.left,
          leftInset: ox,
          bottomInset: bottomInset,
        );
      }
      return;
    }

    if (widget.initialAlignment.x > 0.1) {
      _positionNotifier.value = _ToolbarPositionState(
        anchor: ToolbarAnchor.right,
        rightInset: safePadding.right + 20.0,
        bottomInset: widget.initialAlignment.y > 0.1
            ? defaultBottom
            : (widget.initialAlignment.y < -0.1
                ? screenSize.height - safePadding.top - toolbarHeight - 20.0
                : (screenSize.height - toolbarHeight) / 2.0),
      );
    } else if (widget.initialAlignment.x < -0.1) {
      _positionNotifier.value = _ToolbarPositionState(
        anchor: ToolbarAnchor.left,
        leftInset: safePadding.left + 20.0,
        bottomInset: widget.initialAlignment.y > 0.1
            ? defaultBottom
            : (widget.initialAlignment.y < -0.1
                ? screenSize.height - safePadding.top - toolbarHeight - 20.0
                : (screenSize.height - toolbarHeight) / 2.0),
      );
    } else {
      _positionNotifier.value = _ToolbarPositionState(
        anchor: ToolbarAnchor.center,
        bottomInset: widget.initialAlignment.y > 0.1
            ? defaultBottom
            : (widget.initialAlignment.y < -0.1
                ? screenSize.height - safePadding.top - toolbarHeight - 20.0
                : (screenSize.height - toolbarHeight) / 2.0),
      );
    }
  }

  void _onPanStart(DragStartDetails details) {
    _positionNotifier.value = _positionNotifier.value.copyWith(isDragging: true);
  }

  void _onPanUpdate(
    DragUpdateDetails details,
    Size screenSize,
    EdgeInsets safePadding,
    double currentPillWidth,
    double toolbarHeight,
  ) {
    final pos = _positionNotifier.value;
    final currentBottom = pos.bottomInset ?? (safePadding.bottom + 20.0);
    final newBottom = currentBottom - details.delta.dy;

    if (pos.anchor == ToolbarAnchor.right) {
      final currentRight = pos.rightInset ?? (safePadding.right + 20.0);
      final newRight = currentRight - details.delta.dx;
      final centerX = (screenSize.width - newRight) - currentPillWidth / 2.0;
      if (centerX < screenSize.width / 2.0) {
        _positionNotifier.value = pos.copyWith(
          anchor: ToolbarAnchor.left,
          leftInset: screenSize.width - newRight - currentPillWidth,
          clearRight: true,
          bottomInset: newBottom,
        );
      } else {
        _positionNotifier.value = pos.copyWith(
          rightInset: newRight,
          bottomInset: newBottom,
        );
      }
    } else if (pos.anchor == ToolbarAnchor.left) {
      final currentLeft = pos.leftInset ?? (safePadding.left + 20.0);
      final newLeft = currentLeft + details.delta.dx;
      final centerX = newLeft + currentPillWidth / 2.0;
      if (centerX >= screenSize.width / 2.0) {
        _positionNotifier.value = pos.copyWith(
          anchor: ToolbarAnchor.right,
          rightInset: screenSize.width - (newLeft + currentPillWidth),
          clearLeft: true,
          bottomInset: newBottom,
        );
      } else {
        _positionNotifier.value = pos.copyWith(
          leftInset: newLeft,
          bottomInset: newBottom,
        );
      }
    } else {
      final currentLeft = (screenSize.width - currentPillWidth) / 2.0;
      final newLeft = currentLeft + details.delta.dx;
      final centerX = newLeft + currentPillWidth / 2.0;
      if (centerX >= screenSize.width / 2.0) {
        _positionNotifier.value = pos.copyWith(
          anchor: ToolbarAnchor.right,
          rightInset: screenSize.width - (newLeft + currentPillWidth),
          clearLeft: true,
          bottomInset: newBottom,
        );
      } else {
        _positionNotifier.value = pos.copyWith(
          anchor: ToolbarAnchor.left,
          leftInset: newLeft,
          clearRight: true,
          bottomInset: newBottom,
        );
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    _positionNotifier.value = _positionNotifier.value.copyWith(isDragging: false);
  }

  void _onPanCancel() {
    _positionNotifier.value = _positionNotifier.value.copyWith(isDragging: false);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final screenSize = MediaQuery.of(context).size;
    final safePadding = MediaQuery.paddingOf(context);

    return ListenableBuilder(
      listenable: Listenable.merge([
        controller,
        _positionNotifier,
        controller.isCopiedNotifier,
        _sendStateNotifier,
      ]),
      builder: (context, _) {
        final isSettingsOpen = controller.isSettingsOpen;
        final isLayoutModeOpen = controller.isLayoutModeOpen;

        final isMinimized = controller.isToolbarMinimized;
        final isDark = controller.settings.isDarkMode;
        final markerColor = MarkerColor.findById(controller.settings.markerColorId).color;

        final double expandedWidth = controller.canSend ? 336.0 : 296.0;
        final toolbarWidth = isMinimized ? 44.0 : expandedWidth;
        const double toolbarHeight = 44.0;

        final effectiveWidth = math.max(
          toolbarWidth,
          isSettingsOpen ? 253.0 : (isLayoutModeOpen ? 290.0 : 0.0),
        );

        _initInsetsIfNeeded(screenSize, safePadding, effectiveWidth, toolbarHeight);

        final pos = _positionNotifier.value;
        final isDragging = pos.isDragging;

        final minX = safePadding.left + 8.0;
        final maxX = screenSize.width - safePadding.right - 8.0;
        final maxY = screenSize.height - safePadding.bottom - 8.0;

        final minRightInset = safePadding.right + 8.0;
        final maxRightInset = math.max(minRightInset, screenSize.width - minX - effectiveWidth);
        final clampedRightInset = (pos.rightInset ?? minRightInset).clamp(minRightInset, maxRightInset);

        final minLeftInset = safePadding.left + 8.0;
        final maxLeftInset = math.max(minLeftInset, maxX - effectiveWidth);
        final clampedLeftInset = (pos.leftInset ?? minLeftInset).clamp(minLeftInset, maxLeftInset);

        final minBottomInset = safePadding.bottom + 8.0;
        final maxBottomInset = math.max(minBottomInset, maxY - toolbarHeight);
        final clampedBottomInset = (pos.bottomInset ?? minBottomInset).clamp(minBottomInset, maxBottomInset);

        final double? posLeft;
        final double? posRight;
        final CrossAxisAlignment colAlignment;
        final Alignment pillAlignment;

        if (pos.anchor == ToolbarAnchor.right) {
          posLeft = null;
          posRight = clampedRightInset;
          colAlignment = CrossAxisAlignment.end;
          pillAlignment = Alignment.centerRight;
        } else if (pos.anchor == ToolbarAnchor.left) {
          posLeft = clampedLeftInset;
          posRight = null;
          colAlignment = CrossAxisAlignment.start;
          pillAlignment = Alignment.centerLeft;
        } else {
          posLeft = (screenSize.width - effectiveWidth) / 2.0;
          posRight = null;
          colAlignment = CrossAxisAlignment.center;
          pillAlignment = Alignment.center;
        }

        final computedX = (posRight != null)
            ? (screenSize.width - posRight - effectiveWidth)
            : (posLeft ?? (screenSize.width - effectiveWidth) / 2.0);
        final computedY = screenSize.height - clampedBottomInset - toolbarHeight;
        final currentOffset = Offset(computedX, computedY);
        if (_controller.toolbarOffset != currentOffset && isDragging) {
          _controller.updateToolbarOffset(currentOffset);
        }

        final currentBounds = Rect.fromLTWH(
          computedX,
          computedY,
          isMinimized ? 44.0 : effectiveWidth,
          toolbarHeight,
        );
        if (_controller.toolbarBounds != currentBounds) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _controller.updateToolbarBounds(currentBounds);
            }
          });
        }

        return AnimatedPositioned(
          duration: isDragging ? Duration.zero : const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          left: posLeft,
          right: posRight,
          bottom: clampedBottomInset,
          child: Column(
            crossAxisAlignment: colAlignment,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Floating Panel: Settings or Layout Mode (Screenshots 3 & 4) ──
              if (!isMinimized && isSettingsOpen)
                Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: SettingsPanel(
                    onClose: () {
                      controller.closeSettings();
                    },
                    controller: controller,
                  ),
                )
              else if (!isMinimized && isLayoutModeOpen)
                Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ComponentPalette(
                    controller: controller,
                    onClose: () {
                      controller.closeLayoutMode();
                    },
                    onSelectTemplate: (template) {
                      controller.createPlacementAnnotation(
                        placement: template.toPlacementData(),
                        position: Offset(screenSize.width / 2, screenSize.height / 2),
                        comment: 'Add ${template.label} here',
                      );
                      controller.closeLayoutMode();
                    },
                  ),
                ),

              // ── Pill Toolbar Container (Screenshot 1) ──
              GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: (details) => _onPanUpdate(details, screenSize, safePadding, toolbarWidth, toolbarHeight),
                onPanEnd: _onPanEnd,
                onPanCancel: _onPanCancel,
                child: Material(
                  color: Colors.transparent,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: toolbarWidth,
                    height: toolbarHeight,
                    clipBehavior: Clip.none,
                    alignment: isMinimized ? Alignment.center : pillAlignment,
                    padding: isMinimized
                        ? EdgeInsets.zero
                        : const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF141416)
                          : const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(22.0),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2C2C2E)
                            : const Color(0xFFE5E5EA),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.12),
                          blurRadius: 16.0,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
                          blurRadius: 4.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isMinimized
                        ? _buildMinimizedPill(controller, markerColor, isDark)
                        : _buildExpandedPill(controller, markerColor, isDark, pillAlignment),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMinimizedPill(AgentationController controller, Color markerColor, bool isDark) {
    final count = controller.annotations.length;
    final iconColor = isDark ? Colors.white : const Color(0xFF1C1C1E);

    final button = _ToolbarIconButton(
      buttonKey: const ValueKey('toolbar_expand'),
      icon: AgentationIcons.listSparkle(
        size: 20.0,
        color: iconColor,
      ),
      tooltipLabel: 'Open Agentation',
      tooltipShortcut: null,
      buttonSize: 44.0,
      isActive: false,
      isEnabled: true,
      isDark: isDark,
      onPressed: () => controller.setToolbarMinimized(false),
    );

    if (count == 0) {
      return button;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        button,
        Positioned(
          top: -4.0,
          right: -4.0,
          child: IgnorePointer(
            child: Container(
              constraints: const BoxConstraints(minWidth: 19.0, minHeight: 19.0),
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                color: const Color(0xFF0088FF),
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 3.5,
                    offset: Offset(0, 1.5),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedPill(
    AgentationController controller,
    Color markerColor,
    bool isDark,
    Alignment pillAlignment,
  ) {
    final iconColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final dividerColor = isDark ? const Color(0x33FFFFFF) : const Color(0x1F000000);

    final isPaused = controller.isFrozen;
    final isLayoutOpen = controller.isLayoutModeOpen;
    final isSettingsOpen = controller.isSettingsOpen;
    final isCopied = controller.isCopiedNotifier.value;
    final isLayoutActive = isLayoutOpen || controller.toolMode == AnnotationToolMode.design;
    final hasAnnotations = controller.annotations.isNotEmpty;

    final canSend = controller.canSend;
    final pillWidth = canSend ? 326.0 : 286.0;

    return ClipRect(
      child: OverflowBox(
        minWidth: pillWidth,
        maxWidth: pillWidth,
        alignment: pillAlignment,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Play / Pause Animations (|| / ▶) - Screenshot 1 & 2
            _ToolbarIconButton(
              buttonKey: const ValueKey('toolbar_pause'),
              icon: isPaused
                  ? AgentationIcons.play(size: 22.0, color: const Color(0xFFFF9500))
                  : AgentationIcons.pause(size: 22.0, color: iconColor),
              tooltipLabel: isPaused ? 'Resume animations' : 'Pause animations',
              tooltipShortcut: 'P',
              isActive: isPaused,
              activeColor: const Color(0x33FF9500),
              isEnabled: true,
              isDark: isDark,
              onPressed: () {
                controller.toggleFreeze();
              },
            ),

            // 2. Layout Mode (split grid/window) - Screenshot 1 & 4
            _ToolbarIconButton(
              buttonKey: const ValueKey('toolbar_layout'),
              icon: AgentationIcons.layout(
                size: 22.0,
                color: isLayoutActive ? Colors.white : iconColor,
              ),
              tooltipLabel: isLayoutActive ? 'Exit layout mode' : 'Layout mode',
              tooltipShortcut: 'L',
              isActive: isLayoutActive,
              activeColor: const Color(0xFF0070F3), // Original vibrant blue active circle
              isEnabled: true,
              isDark: isDark,
              onPressed: () {
                controller.toggleLayoutMode();
              },
            ),

            // 3. Comments Visibility Mode (Eye icon) - Toggle show/hide comments on the page
            _ToolbarIconButton(
              buttonKey: const ValueKey('toolbar_inspect'),
              icon: controller.areCommentsVisible
                  ? AgentationIcons.eye(
                      size: 22.0,
                      color: iconColor,
                    )
                  : AgentationIcons.eyeOff(
                      size: 22.0,
                      color: isDark ? const Color(0xFF6E6E73) : const Color(0xFF8E8E93),
                    ),
              tooltipLabel: controller.areCommentsVisible ? 'Hide markers' : 'Show markers',
              tooltipShortcut: 'H',
              isActive: false,
              activeColor: Colors.transparent,
              isEnabled: hasAnnotations && controller.toolMode != AnnotationToolMode.design,
              isDark: isDark,
              onPressed: () {
                controller.toggleCommentsVisibility();
              },
            ),

            // 4. Copy (Overlapping rectangles) - Screenshot 1
            _ToolbarIconButton(
              buttonKey: const ValueKey('toolbar_copy'),
              icon: isCopied
                  ? AgentationIcons.check(size: 22.0, color: const Color(0xFF34C759))
                  : AgentationIcons.copy(size: 22.0, color: iconColor),
              tooltipLabel: isCopied ? 'Copied!' : 'Copy feedback',
              tooltipShortcut: 'C',
              isActive: isCopied,
              activeColor: const Color(0x2634C759),
              isEnabled: hasAnnotations,
              isDark: isDark,
              onPressed: () => _onCopy(controller),
            ),

            // Send button (visible when canSend is true) - matches upstream Agentation
            if (canSend)
              _buildSendButton(controller, iconColor, isDark),

            // 5. Delete / Trash (Trash can) - Screenshot 1
            _ToolbarIconButton(
              buttonKey: const ValueKey('toolbar_clear'),
              icon: AgentationIcons.trash(size: 22.0, color: iconColor),
              tooltipLabel: 'Clear all',
              tooltipShortcut: 'X',
              isActive: false,
              activeColor: Colors.transparent,
              isEnabled: hasAnnotations,
              isDanger: true,
              isDark: isDark,
              onPressed: () {
                controller.clearAnnotations();
              },
            ),

            // 6. Settings (Cog wheel) - Screenshot 1 & 3
            _ToolbarIconButton(
              buttonKey: const ValueKey('toolbar_settings'),
              icon: AgentationIcons.gear(
                size: 22.0,
                color: isSettingsOpen ? Colors.white : iconColor,
              ),
              tooltipLabel: 'Settings',
              tooltipShortcut: null,
              isActive: isSettingsOpen,
              activeColor: const Color(0xFF333333),
              isEnabled: true,
              isDark: isDark,
              onPressed: () {
                widget.onOpenSettings?.call();
                controller.toggleSettings();
              },
            ),

            // Vertical divider line (Screenshot 1)
            Container(
              width: 1.0,
              height: 16.0,
              color: dividerColor,
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
            ),

            // 7. Close / Minimize (X) - Screenshot 1
            _ToolbarIconButton(
              buttonKey: const ValueKey('toolbar_close'),
              icon: AgentationIcons.close(size: 20.0, color: iconColor),
              tooltipLabel: 'Exit',
              tooltipShortcut: 'Esc',
              isActive: false,
              activeColor: Colors.transparent,
              isEnabled: true,
              isDark: isDark,
              onPressed: () {
                controller.closeSettings();
                controller.closeLayoutMode();
                controller.setToolbarMinimized(true);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton(AgentationController controller, Color iconColor, bool isDark) {
    return ValueListenableBuilder<String>(
      valueListenable: _sendStateNotifier,
      builder: (context, sendState, _) {
        final count = controller.annotations.length;
        final isSending = sendState == 'sending';
        final isSent = sendState == 'sent';
        final isFailed = sendState == 'failed';
        final isEnabled = count > 0 && !isSending;

        final Widget iconWidget;
        if (isSending) {
          iconWidget = SizedBox(
            width: 16.0,
            height: 16.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(iconColor),
            ),
          );
        } else if (isSent) {
          iconWidget = AgentationIcons.check(size: 22.0, color: const Color(0xFF34C759));
        } else if (isFailed) {
          iconWidget = const Icon(Icons.error_outline_rounded, size: 22.0, color: Colors.redAccent);
        } else {
          iconWidget = AgentationIcons.send(size: 22.0, color: iconColor);
        }

        final stackIcon = Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            iconWidget,
            if (!isSending && !isSent && !isFailed && count > 0)
              Positioned(
                top: -4.0,
                right: -6.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0088FF),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  constraints: const BoxConstraints(minWidth: 14.0, minHeight: 14.0),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );

        return _ToolbarIconButton(
          buttonKey: const ValueKey('toolbar_send'),
          icon: stackIcon,
          tooltipLabel: 'Send Annotations',
          tooltipShortcut: 'S',
          isActive: isSent,
          activeColor: const Color(0x2634C759),
          isEnabled: isEnabled,
          isDark: isDark,
          onPressed: () async {
            final messenger = ScaffoldMessenger.maybeOf(context);
            _sendStateNotifier.value = 'sending';
            final success = await controller.submitAnnotations();
            _sendStateNotifier.value = success ? 'sent' : 'failed';
            messenger?.showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? 'Sent annotations to agent'
                      : 'Failed to send annotations',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
            _sendTimer?.cancel();
            _sendTimer = Timer(const Duration(milliseconds: 2000), () {
              if (mounted) {
                _sendStateNotifier.value = 'idle';
              }
            });
          },
        );
      },
    );
  }
}

/// Interactive toolbar action button with circular hover highlight, enabled/disabled states,
/// and pixel-perfect tooltip matching Screenshot 1 of Agentation.
class _ToolbarIconButton extends StatefulWidget {
  final Key? buttonKey;
  final Widget icon;
  final String tooltipLabel;
  final String? tooltipShortcut;
  final bool isActive;
  final Color activeColor;
  final bool isEnabled;
  final bool isDanger;
  final bool isDark;
  final double buttonSize;
  final VoidCallback? onPressed;

  const _ToolbarIconButton({
    this.buttonKey,
    required this.icon,
    required this.tooltipLabel,
    this.tooltipShortcut,
    this.isActive = false,
    this.activeColor = Colors.transparent,
    this.isEnabled = true,
    this.isDanger = false,
    this.isDark = true,
    this.buttonSize = 34.0,
    this.onPressed,
  });

  @override
  State<_ToolbarIconButton> createState() => _ToolbarIconButtonState();
}

class _ToolbarIconButtonState extends State<_ToolbarIconButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.isEnabled;
    final isActive = widget.isActive;
    final isDark = widget.isDark;

    final Color bgColor;
    if (isActive) {
      bgColor = widget.activeColor;
    } else if (isEnabled && _isHovered) {
      if (widget.isDanger) {
        bgColor = const Color(0x33FF3B30);
      } else {
        bgColor = isDark ? const Color(0x29FFFFFF) : const Color(0x14000000);
      }
    } else {
      bgColor = Colors.transparent;
    }

    final double opacity = isEnabled ? 1.0 : 0.35;

    Widget buttonContent = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      width: widget.buttonSize,
      height: widget.buttonSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Opacity(
        opacity: opacity,
        child: widget.icon,
      ),
    );

    if (_isPressed && isEnabled) {
      buttonContent = Transform.scale(
        scale: 0.92,
        child: buttonContent,
      );
    }

    Widget result = MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (mounted && isEnabled) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (mounted) setState(() => _isHovered = false);
      },
      child: GestureDetector(
        key: widget.buttonKey,
        behavior: HitTestBehavior.opaque,
        onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
        onTap: isEnabled ? widget.onPressed : null,
        child: buttonContent,
      ),
    );

    if (!isEnabled) {
      return result;
    }

    final tooltipBgColor = isDark ? const Color(0xFF18181B) : Colors.white;
    final tooltipTextColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final tooltipShortcutColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : const Color(0x73000000);

    return Tooltip(
      preferBelow: false,
      verticalOffset: 22.0,
      waitDuration: const Duration(milliseconds: 150),
      showDuration: Duration.zero,
      padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 8.5),
      richMessage: TextSpan(
        children: [
          TextSpan(
            text: widget.tooltipLabel,
            style: TextStyle(
              color: tooltipTextColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
          if (widget.tooltipShortcut != null) ...[
            const TextSpan(text: ' '),
            TextSpan(
              text: widget.tooltipShortcut!,
              style: TextStyle(
                color: tooltipShortcutColor,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ],
      ),
      decoration: ShapeDecoration(
        color: tooltipBgColor,
        shape: _TooltipBeakBorder(
          borderRadius: 8.0,
          beakWidth: 9.0,
          beakHeight: 5.0,
          borderColor: isDark ? null : const Color(0x14000000),
          borderWidth: isDark ? 0.0 : 0.75,
        ),
        shadows: isDark
            ? const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 8.0,
                  offset: Offset(0, 3),
                ),
              ]
            : const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 8.0,
                  offset: Offset(0, 2),
                ),
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 16.0,
                  offset: Offset(0, 4),
                ),
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 1.0,
                  spreadRadius: 0.5,
                ),
              ],
      ),
      child: result,
    );
  }
}

/// Downward pointing triangular beak shape border for tooltip bubbles.
class _TooltipBeakBorder extends ShapeBorder {
  final double borderRadius;
  final double beakWidth;
  final double beakHeight;
  final Color? borderColor;
  final double borderWidth;

  const _TooltipBeakBorder({
    this.borderRadius = 8.0,
    this.beakWidth = 9.0,
    this.beakHeight = 5.0,
    this.borderColor,
    this.borderWidth = 0.0,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only(bottom: beakHeight);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final w = rect.width;
    final h = rect.height - beakHeight;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(rect.left, rect.top, w, h),
          Radius.circular(borderRadius),
        ),
      );

    final centerX = rect.center.dx;
    final beakTop = rect.top + h - 0.5;
    final beakPath = Path()
      ..moveTo(centerX - beakWidth / 2, beakTop)
      ..lineTo(centerX, beakTop + beakHeight + 0.5)
      ..lineTo(centerX + beakWidth / 2, beakTop)
      ..close();

    return Path.combine(PathOperation.union, path, beakPath);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (borderColor != null && borderWidth > 0) {
      final paint = Paint()
        ..color = borderColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawPath(getOuterPath(rect, textDirection: textDirection), paint);
    }
  }

  @override
  ShapeBorder scale(double t) => this;
}
