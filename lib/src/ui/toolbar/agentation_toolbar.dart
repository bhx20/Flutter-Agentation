import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/agentation_controller.dart';
import '../../core/agentation_scope.dart';
import '../../core/agentation_state.dart';
import '../design/component_palette.dart';
import '../../domain/marker_color.dart';
import '../../theme/agentation_colors.dart';
import '../../theme/agentation_radii.dart';
import '../../theme/agentation_theme.dart';
import '../../theme/agentation_typography.dart';
import 'agentation_icons.dart';
import 'settings_panel.dart';
import 'toolbar_toggle_icon.dart';

/// Pixel-perfect floating pill toolbar matching Screenshot 1, 2, 3, 4 of Agentation.
/// Standard icon sizes for toolbar buttons.
const double _toolbarActionIconSize = 23.5;
const double _toolbarToggleIconSize = 21.5;

class AgentationToolbar extends StatefulWidget {
  const AgentationToolbar({
    super.key,
    this.controller,
    this.initialAlignment = Alignment.bottomCenter,
    this.initialMinimized = false,
    this.onOpenSettings,
  });

  /// Optional controller; defaults to closest [AgentationScope].
  final AgentationController? controller;

  /// Initial screen quadrant alignment (defaults to bottom-center).
  final Alignment initialAlignment;

  /// Whether the toolbar starts in the collapsed/minimized pill state.
  final bool initialMinimized;

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
  final GlobalKey _toggleIconKey = GlobalKey();
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
        if (widget.initialMinimized && !ctrl.isToolbarMinimized) {
          ctrl.setToolbarMinimized(true);
        } else if (!ctrl.isToolbarMinimized && !ctrl.isInspecting) {
          ctrl.activate();
        }
      }
    });
  }

  @override
  void dispose() {
    _sendTimer?.cancel();
    _sendStateNotifier.dispose();
    _positionNotifier.dispose();
    super.dispose();
  }

  AgentationController get _controller =>
      widget.controller ?? AgentationScope.of(context);

  Future<void> _onCopy(AgentationController controller) async {
    final count = controller.annotations.length;
    if (count == 0) {
      return;
    }

    await controller.copyFeedback();
  }

  Future<void> _onSend(AgentationController controller) async {
    final count = controller.annotations.length;
    if (count == 0 || !controller.canSend || _sendStateNotifier.value == 'sending') {
      return;
    }

    _sendStateNotifier.value = 'sending';
    final success = await controller.submitAnnotations();
    if (mounted) {
      _sendStateNotifier.value = success ? 'sent' : 'failed';
    }

    _sendTimer?.cancel();
    _sendTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _sendStateNotifier.value = 'idle';
      }
    });
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
    final ctrl = _controller;
    final pillWidth = ctrl.isToolbarMinimized ? 44.0 : (ctrl.canSend ? 336.0 : 296.0);
    final double currentLeft;
    if (pos.leftInset != null) {
      currentLeft = pos.leftInset!;
    } else if (pos.rightInset != null) {
      currentLeft = screenSize.width - pos.rightInset! - pillWidth;
    } else {
      currentLeft = (screenSize.width - pillWidth) / 2.0;
    }
    final centerX = currentLeft + pillWidth / 2.0;
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
    controller.updateScreenSize(screenSize);

    return ListenableBuilder(
      listenable: Listenable.merge([
        controller,
        _positionNotifier,
        controller.isCopiedNotifier,
        _sendStateNotifier,
      ]),
      builder: (context, _) {
        if (controller.settings.hideUntilRestart) {
          if (_controller.toolbarBounds != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _controller.updateToolbarBounds(null);
              }
            });
          }
          return const SizedBox.shrink();
        }

        final isSettingsOpen = controller.isSettingsOpen;
        final isLayoutModeOpen = controller.isLayoutModeOpen;

        final isMinimized = controller.isToolbarMinimized;
        final isDark = controller.settings.isDarkMode;
        final markerColor = MarkerColor.findById(controller.settings.markerColorId).color;

        final theme = AgentationThemeData.resolve(isDark: isDark);

        final canSend = controller.canSend;
        final double expandedWidth = canSend ? 336.0 : 296.0;
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

        if (pos.anchor == ToolbarAnchor.right) {
          posLeft = null;
          posRight = clampedRightInset;
          colAlignment = CrossAxisAlignment.end;
        } else if (pos.anchor == ToolbarAnchor.left) {
          posLeft = clampedLeftInset;
          posRight = null;
          colAlignment = CrossAxisAlignment.start;
        } else {
          posLeft = clampedLeftInset;
          posRight = null;
          colAlignment = CrossAxisAlignment.center;
        }

        final computedX = (posRight != null)
            ? (screenSize.width - posRight - effectiveWidth)
            : (posLeft ?? (screenSize.width - effectiveWidth) / 2.0);
        final computedY = screenSize.height - clampedBottomInset - toolbarHeight;
        final bool isNearTop = computedY < (safePadding.top + 70.0);
        final double spaceAbove = computedY - safePadding.top;
        final double spaceBelow = screenSize.height - (computedY + toolbarHeight) - safePadding.bottom;
        final bool openBelow = spaceAbove < 380.0 && spaceBelow > spaceAbove;

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

        Widget? floatingPanel;
        if (!isMinimized && isSettingsOpen) {
          floatingPanel = Container(
            margin: EdgeInsets.only(
              bottom: openBelow ? 0.0 : 8.0,
              top: openBelow ? 8.0 : 0.0,
            ),
            child: SettingsPanel(
              onClose: () {
                controller.closeSettings();
              },
              controller: controller,
            ),
          );
        } else if (!isMinimized && isLayoutModeOpen) {
          floatingPanel = Container(
            margin: EdgeInsets.only(
              bottom: openBelow ? 0.0 : 8.0,
              top: openBelow ? 8.0 : 0.0,
            ),
            child: ComponentPalette(
              controller: controller,
              onClose: () {
                controller.closeLayoutMode();
              },
              onSelectTemplate: (template) {
                final dropPos = Offset(screenSize.width / 2, screenSize.height / 2);
                final treePlacement = controller.engine.resolveTreePlacement(dropPos);
                controller.promptPlacement(
                  template: template,
                  position: dropPos,
                  treePlacement: treePlacement,
                );
                controller.closeLayoutMode();
              },
            ),
          );
        }

        final pillContainer = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: _onPanStart,
          onPanUpdate: (details) => _onPanUpdate(details, screenSize, safePadding, toolbarWidth, toolbarHeight),
          onPanEnd: _onPanEnd,
          onPanCancel: _onPanCancel,
          child: Material(
            color: Colors.transparent,
            child: AnimatedContainer(
              duration: isDragging ? Duration.zero : const Duration(milliseconds: 360),
              curve: const Cubic(0.19, 1.0, 0.22, 1.0),
              width: toolbarWidth,
              height: toolbarHeight,
              clipBehavior: Clip.none,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: theme.toolbarBackground,
                borderRadius: AgentationRadii.br22,
                border: Border.all(
                  color: theme.borderColor,
                  width: 1.0,
                ),
                boxShadow: theme.toolbarShadows,
              ),
              child: _buildToolbarPill(controller, markerColor, theme, isMinimized, expandedWidth, isNearTop),
            ),
          ),
        );

        return AnimatedPositioned(
          key: ValueKey(openBelow ? 'toolbar_pos_top' : 'toolbar_pos_bottom'),
          duration: (isDragging || pos.justChangedAnchor) ? Duration.zero : const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          left: posLeft,
          right: posRight,
          top: openBelow ? computedY : null,
          bottom: openBelow ? null : clampedBottomInset,
          child: Column(
            crossAxisAlignment: colAlignment,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!openBelow && floatingPanel != null) floatingPanel,
              pillContainer,
              if (openBelow && floatingPanel != null) floatingPanel,
            ],
          ),
        );
      },
    );
  }

  Widget _buildToolbarPill(
    AgentationController controller,
    Color markerColor,
    AgentationThemeData theme,
    bool isMinimized,
    double expandedWidth,
    bool isNearTop,
  ) {
    final iconColor = theme.iconColor;
    final dividerColor = theme.dividerColor;
    final count = controller.annotations.length;

    final isPaused = controller.isFrozen;
    final isLayoutOpen = controller.isLayoutModeOpen;
    final isSettingsOpen = controller.isSettingsOpen;
    final isCopied = controller.isCopiedNotifier.value;
    final hasAnnotations = controller.annotations.isNotEmpty;
    final sendState = _sendStateNotifier.value;
    final canSend = controller.canSend;
    final isMcpRunning = controller.mcpServer.isRunning;
    final isMcpConnecting = controller.settings.mcpEnabled && !isMcpRunning;

    return SizedBox(
      height: 44.0,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerRight,
        children: [
          // ── Clipped Toolbar Interior (Controls & Toggle Button) ──
          ClipRRect(
            borderRadius: AgentationRadii.br22,
            child: SizedBox(
              height: 44.0,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerRight,
                children: [
                  // ── 1. Controls Content (Visible when expanded, smoothly scales/fades) ──
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 360),
                    curve: const Cubic(0.19, 1.0, 0.22, 1.0),
                    right: 44.0,
                    top: 0,
                    bottom: 0,
                    width: expandedWidth - 44.0,
                    child: AnimatedScale(
                scale: isMinimized ? 0.4 : 1.0,
                duration: isMinimized
                    ? const Duration(milliseconds: 360)
                    : const Duration(milliseconds: 420),
                curve: const Cubic(0.19, 1.0, 0.22, 1.0),
                alignment: Alignment.centerRight,
                child: AnimatedOpacity(
                  opacity: isMinimized ? 0.0 : 1.0,
                  duration: isMinimized
                      ? const Duration(milliseconds: 140)
                      : const Duration(milliseconds: 240),
                  curve: Curves.easeOut,
                  child: IgnorePointer(
                    ignoring: isMinimized,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 1. Play / Pause Animations (|| / ▶) - Screenshot 1 & 2
                          _ToolbarIconButton(
                            buttonKey: const ValueKey('toolbar_pause'),
                            icon: isPaused
                                ? AgentationIcons.play(size: _toolbarActionIconSize, color: theme.warningColor)
                                : AgentationIcons.pause(size: _toolbarActionIconSize, color: iconColor),
                            tooltipLabel: isPaused ? 'Resume animations' : 'Pause animations',
                            tooltipShortcut: 'P',
                            isActive: isPaused,
                            activeColor: theme.warningColor.withValues(alpha: 0.2),
                            isEnabled: true,
                            preferBelow: isNearTop,
                            isDark: theme.isDark,
                            theme: theme,
                            onPressed: () => controller.toggleFreeze(),
                          ),

                          // 2. Component Mode
                          _ToolbarIconButton(
                            buttonKey: const ValueKey('toolbar_layout'),
                            icon: AgentationIcons.component(
                              size: _toolbarActionIconSize,
                              color: isLayoutOpen ? Colors.white : iconColor,
                            ),
                            tooltipLabel: isLayoutOpen ? 'Exit component' : 'Component',
                            tooltipShortcut: 'L',
                            showTooltip: !isLayoutOpen,
                            isActive: isLayoutOpen,
                            activeColor: theme.primaryColor,
                            isEnabled: true,
                            preferBelow: isNearTop,
                            isDark: theme.isDark,
                            theme: theme,
                            onPressed: () => controller.toggleLayoutMode(),
                          ),

                          // 3. Comments Visibility Mode (Eye icon)
                          _ToolbarIconButton(
                            buttonKey: const ValueKey('toolbar_inspect'),
                            icon: controller.areCommentsVisible
                                ? AgentationIcons.eye(size: _toolbarActionIconSize, color: iconColor)
                                : AgentationIcons.eyeOff(size: _toolbarActionIconSize, color: theme.iconInactiveColor),
                            tooltipLabel: controller.areCommentsVisible ? 'Hide markers' : 'Show markers',
                            tooltipShortcut: 'H',
                            isActive: false,
                            activeColor: Colors.transparent,
                            isEnabled: hasAnnotations && controller.toolMode != AnnotationToolMode.design,
                            preferBelow: isNearTop,
                            isDark: theme.isDark,
                            theme: theme,
                            onPressed: () => controller.toggleCommentsVisibility(),
                          ),

                          // 4. Copy (Overlapping rectangles) - Screenshot 1
                          _ToolbarIconButton(
                            buttonKey: const ValueKey('toolbar_copy'),
                            icon: isCopied
                                ? AgentationIcons.check(size: _toolbarActionIconSize, color: theme.successColor)
                                : AgentationIcons.copy(size: _toolbarActionIconSize, color: iconColor),
                            tooltipLabel: 'Copy feedback',
                            tooltipShortcut: 'C',
                            isActive: isCopied,
                            activeColor: theme.successColor.withValues(alpha: 0.15),
                            isEnabled: hasAnnotations,
                            preferBelow: isNearTop,
                            isDark: theme.isDark,
                            theme: theme,
                            onPressed: () => _onCopy(controller),
                          ),

                          // 5. Send Annotations (Paper plane) - Upstream IconSendArrow with fluid show/hide animation
                          AnimatedSize(
                            duration: const Duration(milliseconds: 320),
                            curve: const Cubic(0.19, 1.0, 0.22, 1.0),
                            child: canSend
                                ? AnimatedOpacity(
                                    duration: const Duration(milliseconds: 240),
                                    curve: Curves.easeInOut,
                                    opacity: canSend ? 1.0 : 0.0,
                                    child: AnimatedScale(
                                      duration: const Duration(milliseconds: 280),
                                      curve: const Cubic(0.19, 1.0, 0.22, 1.0),
                                      scale: canSend ? 1.0 : 0.6,
                                      child: _ToolbarIconButton(
                                        buttonKey: const ValueKey('toolbar_send'),
                                        icon: AgentationIcons.send(
                                          size: _toolbarActionIconSize,
                                          color: (sendState == 'sent' || sendState == 'failed')
                                              ? (sendState == 'sent' ? theme.successColor : theme.destructiveColor)
                                              : (hasAnnotations ? iconColor : theme.iconInactiveColor),
                                          state: sendState,
                                        ),
                                        badgeCount: (hasAnnotations && sendState == 'idle') ? count : null,
                                        tooltipLabel: 'Send Annotations',
                                        tooltipShortcut: controller.enableKeyboardShortcuts ? 'S' : null,
                                        isActive: sendState == 'sent' || sendState == 'failed',
                                        activeColor: sendState == 'sent'
                                            ? theme.successColor.withValues(alpha: 0.15)
                                            : theme.destructiveColor.withValues(alpha: 0.15),
                                        isEnabled: hasAnnotations && canSend && sendState != 'sending',
                                        preferBelow: isNearTop,
                                        isDark: theme.isDark,
                                        theme: theme,
                                        onPressed: () => _onSend(controller),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),

                          // 6. Delete / Trash (Trash can) - Screenshot 1
                          _ToolbarIconButton(
                            buttonKey: const ValueKey('toolbar_clear'),
                            icon: AgentationIcons.trash(size: _toolbarActionIconSize, color: iconColor),
                            hoverIcon: AgentationIcons.trash(size: _toolbarActionIconSize, color: theme.destructiveColor),
                            tooltipLabel: 'Clear all',
                            tooltipShortcut: 'X',
                            isActive: false,
                            activeColor: Colors.transparent,
                            isEnabled: hasAnnotations,
                            isDanger: true,
                            preferBelow: isNearTop,
                            isDark: theme.isDark,
                            theme: theme,
                            onPressed: () => controller.clearAnnotations(),
                          ),

                          // 7. Settings (Cog wheel) - Screenshot 1 & 3
                          _ToolbarIconButton(
                            buttonKey: const ValueKey('toolbar_settings'),
                            icon: AgentationIcons.gear(
                              size: _toolbarActionIconSize,
                              color: isSettingsOpen
                                  ? (theme.isDark ? Colors.white : theme.textPrimary)
                                  : iconColor,
                            ),
                            indicatorDot: (!isSettingsOpen && (isMcpRunning || controller.syncClient?.endpoint.isNotEmpty == true))
                                ? Container(
                                    width: 6.0,
                                    height: 6.0,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AgentationColors.statusConnected,
                                    ),
                                  )
                                : (!isSettingsOpen && isMcpConnecting
                                    ? Container(
                                        width: 6.0,
                                        height: 6.0,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AgentationColors.statusConnecting,
                                        ),
                                      )
                                    : null),
                            tooltipLabel: 'Settings',
                            tooltipShortcut: null,
                            showTooltip: !isSettingsOpen,
                            isActive: isSettingsOpen,
                            activeColor: theme.isDark ? AgentationColors.darkNeutral : AgentationColors.lightBorderLight,
                            isEnabled: true,
                            preferBelow: isNearTop,
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── 2. Persistent Right End-Cap Toggle Button ──
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 44.0,
              child: _ToolbarIconButton(
                buttonKey: ValueKey(isMinimized ? 'toolbar_expand' : 'toolbar_close'),
                icon: ToolbarToggleIcon(
                  key: _toggleIconKey,
                  active: !isMinimized,
                  size: _toolbarToggleIconSize,
                  color: iconColor,
                ),
                tooltipLabel: isMinimized ? 'Start Feedback Mode' : 'Exit',
                tooltipShortcut: isMinimized ? null : 'Esc',
                tooltipOnLeft: isMinimized,
                preferBelow: isNearTop,
                buttonSize: 34.0,
                showHoverBg: !isMinimized,
                isActive: false,
                isEnabled: true,
                isDark: theme.isDark,
                theme: theme,
                onPressed: () {
                  if (isMinimized) {
                    controller.setToolbarMinimized(false);
                  } else {
                    controller.closeSettings();
                    controller.closeLayoutMode();
                    controller.setToolbarMinimized(true);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    ),

          // ── 3. Notification Badge (Anchored to Minimized Toggle Button - OUTSIDE ClipRRect!) ──
          if (count > 0 && isMinimized)
            Positioned(
              top: -4.0,
              right: -4.0,
              child: IgnorePointer(
                child: Container(
                  constraints: const BoxConstraints(minWidth: 18.0, minHeight: 18.0),
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    color: markerColor,
                    borderRadius: AgentationRadii.br9,
                    boxShadow: const [
                      BoxShadow(
                        color: AgentationColors.shadowHeavy,
                        blurRadius: 3.0,
                        offset: Offset(0, 1.0),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$count',
                    style: AgentationTypography.captionBold.copyWith(
                      color: Colors.white,
                      fontSize: 10.0,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Interactive toolbar action button with circular hover highlight, enabled/disabled states,
/// and pixel-perfect tooltip matching Screenshot 1 of Agentation.
class _ToolbarIconButton extends StatefulWidget {
  final Key? buttonKey;
  final Widget icon;
  final Widget? hoverIcon;
  final String tooltipLabel;
  final String? tooltipShortcut;
  final bool isActive;
  final Color activeColor;
  final bool isEnabled;
  final bool isDanger;
  final bool isDark;
  final double buttonSize;
  final bool tooltipOnLeft;
  final bool showHoverBg;
  final bool showTooltip;
  final bool preferBelow;
  final VoidCallback? onPressed;

  final AgentationThemeData? theme;
  final int? badgeCount;
  final Widget? indicatorDot;

  const _ToolbarIconButton({
    this.buttonKey,
    required this.icon,
    this.hoverIcon,
    required this.tooltipLabel,
    this.tooltipShortcut,
    this.isActive = false,
    this.activeColor = Colors.transparent,
    this.isEnabled = true,
    this.isDanger = false,
    this.isDark = true,
    this.theme,
    this.buttonSize = 34.0,
    this.showHoverBg = true,
    this.tooltipOnLeft = false,
    this.showTooltip = true,
    this.preferBelow = false,
    this.badgeCount,
    this.indicatorDot,
    this.onPressed,
  });

  @override
  State<_ToolbarIconButton> createState() => _ToolbarIconButtonState();
}

enum _TooltipPlacement { left, right, top, bottom }

class _ToolbarIconButtonState extends State<_ToolbarIconButton>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> _isHovered = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isPressed = ValueNotifier<bool>(false);
  OverlayEntry? _overlayEntry;
  AnimationController? _tooltipFadeController;
  bool _suppressTooltipUntilMouseLeave = false;

  void _hideTooltip({bool immediate = false}) {
    if (_overlayEntry == null) return;
    if (immediate || !mounted || _tooltipFadeController == null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _tooltipFadeController?.value = 0.0;
      return;
    }

    _tooltipFadeController!.reverse().then((_) {
      if (mounted && (_tooltipFadeController?.status == AnimationStatus.dismissed)) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    });
  }

  void _showTooltip() {
    if (!mounted || !widget.isEnabled || !widget.showTooltip || _suppressTooltipUntilMouseLeave) return;
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;
    final buttonRect = renderBox.localToGlobal(Offset.zero) & renderBox.size;

    final screenSize = MediaQuery.sizeOf(context);
    final safePadding = MediaQuery.paddingOf(context);

    final safeLeft = safePadding.left + 8.0;
    final safeRight = screenSize.width - safePadding.right - 8.0;
    final safeTop = safePadding.top + 8.0;
    final safeBottom = screenSize.height - safePadding.bottom - 8.0;

    final theme = widget.theme ?? AgentationThemeData.resolve(isDark: widget.isDark);
    final isDark = theme.isDark;
    final tooltipBgColor = isDark ? AgentationColors.darkTooltipBg : Colors.white;
    final tooltipTextColor = isDark ? Colors.white : theme.textPrimary;
    final tooltipShortcutColor = theme.textMuted;

    final textSpan = TextSpan(
      children: [
        TextSpan(
          text: widget.tooltipLabel,
          style: AgentationTypography.tooltipTitle.copyWith(
            color: tooltipTextColor,
          ),
        ),
        if (widget.tooltipShortcut != null) ...[
          const TextSpan(text: ' '),
          TextSpan(
            text: widget.tooltipShortcut!,
            style: AgentationTypography.tooltipShortcut.copyWith(
              color: tooltipShortcutColor,
            ),
          ),
        ],
      ],
    );

    final tp = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    final contentWidth = tp.width + 20.0;
    final contentHeight = math.max(tp.height + 14.0, 28.0);
    const beakHeight = 5.0;
    const beakWidth = 9.0;
    const borderRadius = 8.0;
    const gap = 8.0;

    final spaceLeft = buttonRect.left - safeLeft;
    final spaceRight = safeRight - buttonRect.right;
    final spaceTop = buttonRect.top - safeTop;
    final spaceBottom = safeBottom - buttonRect.bottom;

    final reqHorizontal = contentWidth + beakHeight + gap;
    final reqVertical = contentHeight + beakHeight + gap;

    final canGoLeft = spaceLeft >= reqHorizontal;
    final canGoRight = spaceRight >= reqHorizontal;
    final canGoBottom = spaceBottom >= reqVertical;
    final canGoTop = spaceTop >= reqVertical;

    // Preferred side is left (when tooltipOnLeft is true).
    // If satisfied pixels are not available on the left, adaptively flip to right, bottom, or top.
    final _TooltipPlacement placement;
    if (canGoLeft) {
      placement = _TooltipPlacement.left;
    } else if (canGoRight) {
      placement = _TooltipPlacement.right;
    } else if (canGoBottom) {
      placement = _TooltipPlacement.bottom;
    } else if (canGoTop) {
      placement = _TooltipPlacement.top;
    } else {
      placement = spaceRight >= spaceLeft ? _TooltipPlacement.right : _TooltipPlacement.left;
    }

    final double tooltipLeft;
    final double tooltipTop;
    final TooltipBeakDirection beakDirection;
    final double beakOffset;

    switch (placement) {
      case _TooltipPlacement.left:
        beakDirection = TooltipBeakDirection.right;
        final totalW = contentWidth + beakHeight;
        final totalH = contentHeight;
        final idealLeft = buttonRect.left - gap - totalW;
        tooltipLeft = idealLeft.clamp(safeLeft, math.max(safeLeft, safeRight - totalW));
        final idealTop = buttonRect.center.dy - totalH / 2.0;
        tooltipTop = idealTop.clamp(safeTop, math.max(safeTop, safeBottom - totalH));
        final minBeakY = borderRadius + beakWidth / 2.0;
        final maxBeakY = math.max(minBeakY, totalH - borderRadius - beakWidth / 2.0);
        beakOffset = (buttonRect.center.dy - tooltipTop).clamp(minBeakY, maxBeakY);
        break;

      case _TooltipPlacement.right:
        beakDirection = TooltipBeakDirection.left;
        final totalW = contentWidth + beakHeight;
        final totalH = contentHeight;
        final idealLeft = buttonRect.right + gap;
        tooltipLeft = idealLeft.clamp(safeLeft, math.max(safeLeft, safeRight - totalW));
        final idealTop = buttonRect.center.dy - totalH / 2.0;
        tooltipTop = idealTop.clamp(safeTop, math.max(safeTop, safeBottom - totalH));
        final minBeakY = borderRadius + beakWidth / 2.0;
        final maxBeakY = math.max(minBeakY, totalH - borderRadius - beakWidth / 2.0);
        beakOffset = (buttonRect.center.dy - tooltipTop).clamp(minBeakY, maxBeakY);
        break;

      case _TooltipPlacement.top:
        beakDirection = TooltipBeakDirection.down;
        final totalW = contentWidth;
        final totalH = contentHeight + beakHeight;
        final idealTop = buttonRect.top - gap - totalH;
        tooltipTop = idealTop.clamp(safeTop, math.max(safeTop, safeBottom - totalH));
        final idealLeft = buttonRect.center.dx - totalW / 2.0;
        tooltipLeft = idealLeft.clamp(safeLeft, math.max(safeLeft, safeRight - totalW));
        final minBeakX = borderRadius + beakWidth / 2.0;
        final maxBeakX = math.max(minBeakX, totalW - borderRadius - beakWidth / 2.0);
        beakOffset = (buttonRect.center.dx - tooltipLeft).clamp(minBeakX, maxBeakX);
        break;

      case _TooltipPlacement.bottom:
        beakDirection = TooltipBeakDirection.up;
        final totalW = contentWidth;
        final totalH = contentHeight + beakHeight;
        final idealTop = buttonRect.bottom + gap;
        tooltipTop = idealTop.clamp(safeTop, math.max(safeTop, safeBottom - totalH));
        final idealLeft = buttonRect.center.dx - totalW / 2.0;
        tooltipLeft = idealLeft.clamp(safeLeft, math.max(safeLeft, safeRight - totalW));
        final minBeakX = borderRadius + beakWidth / 2.0;
        final maxBeakX = math.max(minBeakX, totalW - borderRadius - beakWidth / 2.0);
        beakOffset = (buttonRect.center.dx - tooltipLeft).clamp(minBeakX, maxBeakX);
        break;
    }

    if (_tooltipFadeController == null) {
      _tooltipFadeController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 180),
      );
    } else {
      _tooltipFadeController!.value = 0.0;
    }

    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: tooltipLeft,
          top: tooltipTop,
          child: IgnorePointer(
            child: Material(
              color: Colors.transparent,
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _tooltipFadeController!,
                  curve: Curves.easeOut,
                  reverseCurve: Curves.easeIn,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
                  decoration: ShapeDecoration(
                    color: tooltipBgColor,
                    shape: _TooltipBeakBorder(
                      borderRadius: borderRadius,
                      beakWidth: beakWidth,
                      beakHeight: beakHeight,
                      beakDirection: beakDirection,
                      beakOffset: beakOffset,
                      borderColor: isDark ? null : theme.borderTranslucentColor,
                      borderWidth: isDark ? 0.0 : 0.75,
                    ),
                    shadows: isDark
                        ? const [
                            BoxShadow(
                              color: AgentationColors.shadowDark,
                              blurRadius: 8.0,
                              offset: Offset(0, 3),
                            ),
                          ]
                        : const [
                            BoxShadow(
                              color: AgentationColors.shadowToolbarMedium,
                              blurRadius: 8.0,
                              offset: Offset(0, 2),
                            ),
                            BoxShadow(
                              color: AgentationColors.shadowToolbarLight,
                              blurRadius: 16.0,
                              offset: Offset(0, 4),
                            ),
                            BoxShadow(
                              color: AgentationColors.shadowSubtle,
                              blurRadius: 1.0,
                              spreadRadius: 0.5,
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.tooltipLabel,
                        style: AgentationTypography.tooltipTitle.copyWith(
                          color: tooltipTextColor,
                        ),
                      ),
                      if (widget.tooltipShortcut != null) ...[
                        const SizedBox(width: 4.0),
                        Text(
                          widget.tooltipShortcut!,
                          style: AgentationTypography.tooltipShortcut.copyWith(
                            color: tooltipShortcutColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(_overlayEntry!);
    _tooltipFadeController?.forward();
  }

  @override
  void didUpdateWidget(_ToolbarIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isEnabled || !widget.tooltipOnLeft || !widget.showTooltip) {
      _hideTooltip(immediate: true);
    }
  }

  @override
  void dispose() {
    _hideTooltip(immediate: true);
    _tooltipFadeController?.dispose();
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
        if (isEnabled) {
          _isHovered.value = true;
          if (widget.tooltipOnLeft && widget.showTooltip && !_suppressTooltipUntilMouseLeave) _showTooltip();
        }
      },
      onExit: (_) {
        _isHovered.value = false;
        if (_suppressTooltipUntilMouseLeave) {
          _suppressTooltipUntilMouseLeave = false;
        }
        if (widget.tooltipOnLeft) _hideTooltip();
      },
      child: GestureDetector(
        key: widget.buttonKey,
        behavior: HitTestBehavior.opaque,
        onTapDown: isEnabled
            ? (_) {
                if (widget.tooltipOnLeft) _hideTooltip(immediate: true);
                _isPressed.value = true;
              }
            : null,
        onTapUp: isEnabled ? (_) => _isPressed.value = false : null,
        onTapCancel: isEnabled ? () => _isPressed.value = false : null,
        onTap: isEnabled
            ? () {
                if (widget.tooltipOnLeft) _hideTooltip(immediate: true);
                _suppressTooltipUntilMouseLeave = true;
                widget.onPressed?.call();
              }
            : null,
        child: ListenableBuilder(
          listenable: Listenable.merge([_isHovered, _isPressed]),
          builder: (context, _) {
            final hovered = _isHovered.value;
            final pressed = _isPressed.value;

            final Color bgColor;
            if (isActive) {
              bgColor = widget.activeColor;
            } else if (isEnabled && hovered && widget.showHoverBg) {
              if (widget.isDanger) {
                bgColor = theme.destructiveColor.withValues(alpha: 0.2);
              } else {
                bgColor = isDark ? AgentationColors.darkPressedBg : AgentationColors.lightPressedBg;
              }
            } else {
              bgColor = Colors.transparent;
            }

            final Widget currentIcon;
            if (isEnabled && hovered) {
              if (widget.hoverIcon != null) {
                currentIcon = widget.hoverIcon!;
              } else if (widget.isDanger) {
                currentIcon = AgentationIcons.trash(size: _toolbarActionIconSize, color: theme.destructiveColor);
              } else {
                currentIcon = widget.icon;
              }
            } else {
              currentIcon = widget.icon;
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
                child: currentIcon,
              ),
            );

            if (pressed && isEnabled) {
              buttonContent = Transform.scale(
                scale: 0.92,
                child: buttonContent,
              );
            }

            if (widget.badgeCount != null && widget.badgeCount! > 0) {
              buttonContent = Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  buttonContent,
                  Positioned(
                    top: -1.0,
                    right: -1.0,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 16.0, minHeight: 16.0),
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        color: theme.accentColor,
                        borderRadius: AgentationRadii.br8,
                        border: Border.all(
                          color: isDark ? AgentationColors.darkRing : Colors.white,
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: AgentationColors.shadowSubtle,
                            blurRadius: 3.0,
                            offset: Offset(0, 1.0),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${widget.badgeCount}',
                        style: AgentationTypography.toolbarBadge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            if (widget.indicatorDot != null) {
              buttonContent = Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  buttonContent,
                  Positioned(
                    top: 2.0,
                    right: 2.0,
                    child: widget.indicatorDot!,
                  ),
                ],
              );
            }

            return Center(child: buttonContent);
          },
        ),
      ),
    );

    if (!isEnabled || !widget.showTooltip || _suppressTooltipUntilMouseLeave) {
      return result;
    }

    if (widget.tooltipOnLeft) {
      return Semantics(
        label: widget.tooltipLabel,
        child: result,
      );
    }

    final tooltipBgColor = isDark ? AgentationColors.darkTooltipBg : Colors.white;
    final tooltipTextColor = isDark ? Colors.white : theme.textPrimary;
    final tooltipShortcutColor = theme.textMuted;

    final preferBelow = widget.preferBelow;

    return Tooltip(
      triggerMode: TooltipTriggerMode.manual,
      preferBelow: preferBelow,
      verticalOffset: 30.0,
      waitDuration: const Duration(milliseconds: 150),
      showDuration: Duration.zero,
      padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 8.5),
      richMessage: TextSpan(
        children: [
          TextSpan(
            text: widget.tooltipLabel,
            style: AgentationTypography.tooltipTitle.copyWith(
              color: tooltipTextColor,
            ),
          ),
          if (widget.tooltipShortcut != null) ...[
            const TextSpan(text: ' '),
            TextSpan(
              text: widget.tooltipShortcut!,
              style: AgentationTypography.tooltipShortcut.copyWith(
                color: tooltipShortcutColor,
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
          beakDirection: preferBelow ? TooltipBeakDirection.up : TooltipBeakDirection.down,
          borderColor: isDark ? null : theme.borderTranslucentColor,
          borderWidth: isDark ? 0.0 : 0.75,
        ),
        shadows: isDark
            ? const [
                BoxShadow(
                  color: AgentationColors.shadowDark,
                  blurRadius: 8.0,
                  offset: Offset(0, 3),
                ),
              ]
            : const [
                BoxShadow(
                  color: AgentationColors.shadowToolbarMedium,
                  blurRadius: 8.0,
                  offset: Offset(0, 2),
                ),
                BoxShadow(
                  color: AgentationColors.shadowToolbarLight,
                  blurRadius: 16.0,
                  offset: Offset(0, 4),
                ),
                BoxShadow(
                  color: AgentationColors.shadowSubtle,
                  blurRadius: 1.0,
                  spreadRadius: 0.5,
                ),
              ],
      ),
      child: result,
    );
  }
}

enum TooltipBeakDirection { down, up, left, right }

/// Triangular beak shape border for tooltip bubbles.
class _TooltipBeakBorder extends ShapeBorder {
  final double borderRadius;
  final double beakWidth;
  final double beakHeight;
  final Color? borderColor;
  final double borderWidth;
  final TooltipBeakDirection beakDirection;
  final double? beakOffset;

  const _TooltipBeakBorder({
    this.borderRadius = 8.0,
    this.beakWidth = 9.0,
    this.beakHeight = 5.0,
    this.borderColor,
    this.borderWidth = 0.0,
    this.beakDirection = TooltipBeakDirection.down,
    this.beakOffset,
  });

  @override
  EdgeInsetsGeometry get dimensions {
    switch (beakDirection) {
      case TooltipBeakDirection.down:
        return EdgeInsets.only(bottom: beakHeight);
      case TooltipBeakDirection.up:
        return EdgeInsets.only(top: beakHeight);
      case TooltipBeakDirection.right:
        return EdgeInsets.only(right: beakHeight);
      case TooltipBeakDirection.left:
        return EdgeInsets.only(left: beakHeight);
    }
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    switch (beakDirection) {
      case TooltipBeakDirection.right: {
        final w = rect.width - beakHeight;
        final h = rect.height;
        final path = Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(rect.left, rect.top, w, h),
              Radius.circular(borderRadius),
            ),
          );

        final double centerY = (beakOffset != null)
            ? (rect.top + beakOffset!).clamp(
                rect.top + borderRadius + beakWidth / 2.0,
                math.max(rect.top + borderRadius + beakWidth / 2.0, rect.top + h - borderRadius - beakWidth / 2.0),
              ).toDouble()
            : rect.center.dy;
        final beakLeft = rect.left + w - 0.5;
        final beakPath = Path()
          ..moveTo(beakLeft, centerY - beakWidth / 2.0)
          ..lineTo(beakLeft + beakHeight + 0.5, centerY)
          ..lineTo(beakLeft, centerY + beakWidth / 2.0)
          ..close();

        return Path.combine(PathOperation.union, path, beakPath);
      }

      case TooltipBeakDirection.left: {
        final w = rect.width - beakHeight;
        final h = rect.height;
        final path = Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(rect.left + beakHeight, rect.top, w, h),
              Radius.circular(borderRadius),
            ),
          );

        final double centerY = (beakOffset != null)
            ? (rect.top + beakOffset!).clamp(
                rect.top + borderRadius + beakWidth / 2.0,
                math.max(rect.top + borderRadius + beakWidth / 2.0, rect.top + h - borderRadius - beakWidth / 2.0),
              ).toDouble()
            : rect.center.dy;
        final beakRight = rect.left + beakHeight + 0.5;
        final beakPath = Path()
          ..moveTo(beakRight, centerY - beakWidth / 2.0)
          ..lineTo(rect.left, centerY)
          ..lineTo(beakRight, centerY + beakWidth / 2.0)
          ..close();

        return Path.combine(PathOperation.union, path, beakPath);
      }

      case TooltipBeakDirection.up: {
        final w = rect.width;
        final h = rect.height - beakHeight;
        final path = Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(rect.left, rect.top + beakHeight, w, h),
              Radius.circular(borderRadius),
            ),
          );

        final double centerX = (beakOffset != null)
            ? (rect.left + beakOffset!).clamp(
                rect.left + borderRadius + beakWidth / 2.0,
                math.max(rect.left + borderRadius + beakWidth / 2.0, rect.left + w - borderRadius - beakWidth / 2.0),
              ).toDouble()
            : rect.center.dx;
        final beakBottom = rect.top + beakHeight + 0.5;
        final beakPath = Path()
          ..moveTo(centerX - beakWidth / 2.0, beakBottom)
          ..lineTo(centerX, rect.top)
          ..lineTo(centerX + beakWidth / 2.0, beakBottom)
          ..close();

        return Path.combine(PathOperation.union, path, beakPath);
      }

      case TooltipBeakDirection.down: {
        final w = rect.width;
        final h = rect.height - beakHeight;
        final path = Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(rect.left, rect.top, w, h),
              Radius.circular(borderRadius),
            ),
          );

        final double centerX = (beakOffset != null)
            ? (rect.left + beakOffset!).clamp(
                rect.left + borderRadius + beakWidth / 2.0,
                math.max(rect.left + borderRadius + beakWidth / 2.0, rect.left + w - borderRadius - beakWidth / 2.0),
              ).toDouble()
            : rect.center.dx;
        final beakTop = rect.top + h - 0.5;
        final beakPath = Path()
          ..moveTo(centerX - beakWidth / 2.0, beakTop)
          ..lineTo(centerX, beakTop + beakHeight + 0.5)
          ..lineTo(centerX + beakWidth / 2.0, beakTop)
          ..close();

        return Path.combine(PathOperation.union, path, beakPath);
      }
    }
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

