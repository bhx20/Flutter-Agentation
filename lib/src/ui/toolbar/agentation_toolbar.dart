import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/agentation_controller.dart';
import '../../core/agentation_scope.dart';
import '../../core/agentation_state.dart';
import '../design/component_palette.dart';
import '../../domain/marker_color.dart';
import '../../theme/agentation_theme.dart';
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
  final bool justChangedAnchor;

  const _ToolbarPositionState({
    this.anchor = ToolbarAnchor.center,
    this.leftInset,
    this.rightInset,
    this.bottomInset,
    this.isDragging = false,
    this.justChangedAnchor = false,
  });

  _ToolbarPositionState copyWith({
    ToolbarAnchor? anchor,
    double? leftInset,
    double? rightInset,
    double? bottomInset,
    bool? isDragging,
    bool? justChangedAnchor,
    bool clearLeft = false,
    bool clearRight = false,
  }) {
    return _ToolbarPositionState(
      anchor: anchor ?? this.anchor,
      leftInset: clearLeft ? null : (leftInset ?? this.leftInset),
      rightInset: clearRight ? null : (rightInset ?? this.rightInset),
      bottomInset: bottomInset ?? this.bottomInset,
      isDragging: isDragging ?? this.isDragging,
      justChangedAnchor: justChangedAnchor ?? this.justChangedAnchor,
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
      final anchor = centerX >= screenSize.width / 2.0 ? ToolbarAnchor.right : ToolbarAnchor.left;
      _positionNotifier.value = _ToolbarPositionState(
        anchor: anchor,
        leftInset: ox,
        bottomInset: bottomInset,
      );
      return;
    }

    final double computedBottom = widget.initialAlignment.y > 0.1
        ? defaultBottom
        : (widget.initialAlignment.y < -0.1
            ? screenSize.height - safePadding.top - toolbarHeight - 20.0
            : (screenSize.height - toolbarHeight) / 2.0);

    final isMobile = screenSize.width < 600.0;

    if (isMobile) {
      _positionNotifier.value = _ToolbarPositionState(
        anchor: ToolbarAnchor.center,
        leftInset: (screenSize.width - effectiveWidth) / 2.0,
        rightInset: (screenSize.width - effectiveWidth) / 2.0,
        bottomInset: computedBottom,
      );
    } else if (widget.initialAlignment.x > 0.1) {
      _positionNotifier.value = _ToolbarPositionState(
        anchor: ToolbarAnchor.right,
        rightInset: safePadding.right + 20.0,
        leftInset: screenSize.width - safePadding.right - 20.0 - effectiveWidth,
        bottomInset: computedBottom,
      );
    } else if (widget.initialAlignment.x < -0.1) {
      _positionNotifier.value = _ToolbarPositionState(
        anchor: ToolbarAnchor.left,
        leftInset: safePadding.left + 20.0,
        rightInset: screenSize.width - safePadding.left - 20.0 - effectiveWidth,
        bottomInset: computedBottom,
      );
    } else {
      _positionNotifier.value = _ToolbarPositionState(
        anchor: ToolbarAnchor.center,
        leftInset: (screenSize.width - effectiveWidth) / 2.0,
        rightInset: (screenSize.width - effectiveWidth) / 2.0,
        bottomInset: computedBottom,
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
    final minBottom = safePadding.bottom + 8.0;
    final maxBottom = math.max(minBottom, screenSize.height - safePadding.top - 8.0 - toolbarHeight);
    final newBottom = (currentBottom - details.delta.dy).clamp(minBottom, maxBottom).toDouble();

    final minLeft = safePadding.left + 8.0;
    final maxLeft = math.max(minLeft, screenSize.width - safePadding.right - 8.0 - currentPillWidth);

    final double currentLeft;
    if (pos.leftInset != null) {
      currentLeft = pos.leftInset!;
    } else if (pos.rightInset != null) {
      currentLeft = screenSize.width - pos.rightInset! - currentPillWidth;
    } else {
      currentLeft = (screenSize.width - currentPillWidth) / 2.0;
    }

    final newLeft = (currentLeft + details.delta.dx).clamp(minLeft, maxLeft).toDouble();
    final newRight = (screenSize.width - newLeft - currentPillWidth).clamp(
      safePadding.right + 8.0,
      math.max(safePadding.right + 8.0, screenSize.width - minLeft - currentPillWidth),
    ).toDouble();

    // Keep consistent anchor during drag to maintain smooth 1:1 motion
    _positionNotifier.value = pos.copyWith(
      leftInset: newLeft,
      rightInset: newRight,
      bottomInset: newBottom,
      isDragging: true,
    );
  }

  void _onPanEnd(DragEndDetails details) {
    final pos = _positionNotifier.value;
    final screenSize = MediaQuery.sizeOf(context);
    final double currentLeft;
    if (pos.leftInset != null) {
      currentLeft = pos.leftInset!;
    } else if (pos.rightInset != null) {
      currentLeft = screenSize.width - pos.rightInset! - 296.0;
    } else {
      currentLeft = (screenSize.width - 296.0) / 2.0;
    }
    final centerX = currentLeft + 148.0;
    final newAnchor = centerX >= screenSize.width / 2.0 ? ToolbarAnchor.right : ToolbarAnchor.left;
    final anchorChanged = newAnchor != pos.anchor;

    _positionNotifier.value = pos.copyWith(
      anchor: newAnchor,
      isDragging: false,
      justChangedAnchor: anchorChanged,
    );

    if (anchorChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _positionNotifier.value = _positionNotifier.value.copyWith(
            justChangedAnchor: false,
          );
        }
      });
    }

    if (pos.bottomInset != null && mounted) {
      final oy = screenSize.height - pos.bottomInset! - 44.0;
      _controller.updateToolbarOffset(Offset(currentLeft, oy));
    }
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

        final theme = AgentationThemeData.resolve(isDark: isDark);

        final double expandedWidth = controller.canSend ? 336.0 : 296.0;
        final toolbarWidth = isMinimized ? 44.0 : expandedWidth;
        const double toolbarHeight = 44.0;

        final isMobile = screenSize.width < 600.0;
        final double panelWidth = isSettingsOpen
            ? (isMobile ? math.min(253.0, screenSize.width - 24.0) : 253.0)
            : (isLayoutModeOpen ? (isMobile ? math.min(268.0, screenSize.width - 24.0) : 290.0) : 0.0);

        final effectiveWidth = math.max(
          toolbarWidth,
          panelWidth,
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
        final clampedLeftInset = (pos.leftInset ?? ((screenSize.width - effectiveWidth) / 2.0)).clamp(minLeftInset, maxLeftInset);

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
          posLeft = clampedLeftInset;
          posRight = null;
          colAlignment = CrossAxisAlignment.center;
          pillAlignment = Alignment.center;
        }

        final computedX = (posRight != null)
            ? (screenSize.width - posRight - effectiveWidth)
            : (posLeft ?? (screenSize.width - effectiveWidth) / 2.0);
        final computedY = screenSize.height - clampedBottomInset - toolbarHeight;

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
          duration: (isDragging || pos.justChangedAnchor) ? Duration.zero : const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
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
                behavior: HitTestBehavior.opaque,
                onPanStart: _onPanStart,
                onPanUpdate: (details) => _onPanUpdate(details, screenSize, safePadding, toolbarWidth, toolbarHeight),
                onPanEnd: _onPanEnd,
                onPanCancel: _onPanCancel,
                child: Material(
                  color: Colors.transparent,
                  child: AnimatedContainer(
                    duration: isDragging ? Duration.zero : const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: toolbarWidth,
                    height: toolbarHeight,
                    clipBehavior: Clip.none,
                    alignment: isMinimized ? Alignment.center : pillAlignment,
                    padding: isMinimized
                        ? EdgeInsets.zero
                        : const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                    decoration: BoxDecoration(
                      color: theme.toolbarBackground,
                      borderRadius: BorderRadius.circular(22.0),
                      border: Border.all(
                        color: theme.borderColor,
                        width: 1.0,
                      ),
                      boxShadow: theme.toolbarShadows,
                    ),
                    child: isMinimized
                        ? _buildMinimizedPill(controller, markerColor, theme)
                        : _buildExpandedPill(controller, markerColor, theme, pillAlignment),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMinimizedPill(AgentationController controller, Color markerColor, AgentationThemeData theme) {
    final count = controller.annotations.length;
    final iconColor = theme.iconColor;

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
      isDark: theme.isDark,
      theme: theme,
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
                color: theme.accentColor,
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
    AgentationThemeData theme,
    Alignment pillAlignment,
  ) {
    final iconColor = theme.iconColor;
    final dividerColor = theme.dividerColor;

    final isPaused = controller.isFrozen;
    final isLayoutOpen = controller.isLayoutModeOpen;
    final isSettingsOpen = controller.isSettingsOpen;
    final isCopied = controller.isCopiedNotifier.value;
    final isLayoutActive = isLayoutOpen;
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
                  ? AgentationIcons.play(size: 22.0, color: theme.warningColor)
                  : AgentationIcons.pause(size: 22.0, color: iconColor),
              tooltipLabel: isPaused ? 'Resume animations' : 'Pause animations',
              tooltipShortcut: 'P',
              isActive: isPaused,
              activeColor: theme.warningColor.withValues(alpha: 0.2),
              isEnabled: true,
              isDark: theme.isDark,
              theme: theme,
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
              activeColor: theme.primaryColor,
              isEnabled: true,
              isDark: theme.isDark,
              theme: theme,
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
                      color: theme.iconInactiveColor,
                    ),
              tooltipLabel: controller.areCommentsVisible ? 'Hide markers' : 'Show markers',
              tooltipShortcut: 'H',
              isActive: false,
              activeColor: Colors.transparent,
              isEnabled: hasAnnotations && controller.toolMode != AnnotationToolMode.design,
              isDark: theme.isDark,
              theme: theme,
              onPressed: () {
                controller.toggleCommentsVisibility();
              },
            ),

            // 4. Copy (Overlapping rectangles) - Screenshot 1
            _ToolbarIconButton(
              buttonKey: const ValueKey('toolbar_copy'),
              icon: isCopied
                  ? AgentationIcons.check(size: 22.0, color: theme.successColor)
                  : AgentationIcons.copy(size: 22.0, color: iconColor),
              tooltipLabel: isCopied ? 'Copied!' : 'Copy feedback',
              tooltipShortcut: 'C',
              isActive: isCopied,
              activeColor: theme.successColor.withValues(alpha: 0.15),
              isEnabled: hasAnnotations,
              isDark: theme.isDark,
              theme: theme,
              onPressed: () => _onCopy(controller),
            ),

            // Send button (visible when canSend is true) - matches upstream Agentation
            if (canSend)
              _buildSendButton(controller, iconColor, theme),

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
              isDark: theme.isDark,
              theme: theme,
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
              activeColor: theme.isDark ? const Color(0xFF333333) : const Color(0xFFE2E2E2),
              isEnabled: true,
              isDark: theme.isDark,
              theme: theme,
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
              isDark: theme.isDark,
              theme: theme,
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

  Widget _buildSendButton(AgentationController controller, Color iconColor, AgentationThemeData theme) {
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
          iconWidget = AgentationIcons.check(size: 22.0, color: theme.successColor);
        } else if (isFailed) {
          iconWidget = Icon(Icons.error_outline_rounded, size: 22.0, color: theme.destructiveColor);
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
                    color: theme.accentColor,
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
          activeColor: theme.successColor.withValues(alpha: 0.15),
          isEnabled: isEnabled,
          isDark: theme.isDark,
          theme: theme,
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

  final AgentationThemeData? theme;

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
    this.theme,
    this.buttonSize = 34.0,
    this.onPressed,
  });

  @override
  State<_ToolbarIconButton> createState() => _ToolbarIconButtonState();
}

class _ToolbarIconButtonState extends State<_ToolbarIconButton> {
  final ValueNotifier<bool> _isHovered = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isPressed = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isHovered.dispose();
    _isPressed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.isEnabled;
    final isActive = widget.isActive;
    final theme = widget.theme ?? AgentationThemeData.resolve(isDark: widget.isDark);
    final isDark = theme.isDark;
    final double opacity = isEnabled ? 1.0 : 0.35;

    Widget result = MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (isEnabled) _isHovered.value = true;
      },
      onExit: (_) {
        _isHovered.value = false;
      },
      child: GestureDetector(
        key: widget.buttonKey,
        behavior: HitTestBehavior.opaque,
        onTapDown: isEnabled ? (_) => _isPressed.value = true : null,
        onTapUp: isEnabled ? (_) => _isPressed.value = false : null,
        onTapCancel: isEnabled ? () => _isPressed.value = false : null,
        onTap: isEnabled ? widget.onPressed : null,
        child: ListenableBuilder(
          listenable: Listenable.merge([_isHovered, _isPressed]),
          builder: (context, _) {
            final hovered = _isHovered.value;
            final pressed = _isPressed.value;

            final Color bgColor;
            if (isActive) {
              bgColor = widget.activeColor;
            } else if (isEnabled && hovered) {
              if (widget.isDanger) {
                bgColor = theme.destructiveColor.withValues(alpha: 0.2);
              } else {
                bgColor = isDark ? const Color(0x29FFFFFF) : const Color(0x14000000);
              }
            } else {
              bgColor = Colors.transparent;
            }

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

            if (pressed && isEnabled) {
              buttonContent = Transform.scale(
                scale: 0.92,
                child: buttonContent,
              );
            }

            return buttonContent;
          },
        ),
      ),
    );

    if (!isEnabled) {
      return result;
    }

    final tooltipBgColor = isDark ? const Color(0xFF18181B) : Colors.white;
    final tooltipTextColor = isDark ? Colors.white : theme.textPrimary;
    final tooltipShortcutColor = theme.textMuted;

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
              fontWeight: FontWeight.normal,
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
          borderColor: isDark ? null : theme.borderTranslucentColor,
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

