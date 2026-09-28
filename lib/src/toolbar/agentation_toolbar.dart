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
  final ValueNotifier<bool> _isCopiedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isSettingsOpenNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isLayoutModeOpenNotifier = ValueNotifier<bool>(false);
  Timer? _copyTimer;

  @override
  void dispose() {
    _copyTimer?.cancel();
    _positionNotifier.dispose();
    _isCopiedNotifier.dispose();
    _isSettingsOpenNotifier.dispose();
    _isLayoutModeOpenNotifier.dispose();
    super.dispose();
  }

  AgentationController get _controller =>
      widget.controller ?? AgentationScope.of(context);

  void _onCopy(AgentationController controller) async {
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

    await controller.copyToClipboard(
      format: controller.settings.copyFormat,
    );
    _isCopiedNotifier.value = true;
    if (mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text('Copied $count annotation${count == 1 ? "" : "s"} to clipboard!'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    _copyTimer?.cancel();
    _copyTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) _isCopiedNotifier.value = false;
    });
  }

  void _initInsetsIfNeeded(
    Size screenSize,
    EdgeInsets safePadding,
    double effectiveWidth,
    double toolbarHeight,
  ) {
    final current = _positionNotifier.value;
    if (current.leftInset != null || current.rightInset != null) return;

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
        _isSettingsOpenNotifier,
        _isLayoutModeOpenNotifier,
        _isCopiedNotifier,
      ]),
      builder: (context, _) {
        final pos = _positionNotifier.value;
        final isSettingsOpen = _isSettingsOpenNotifier.value;
        final isLayoutModeOpen = _isLayoutModeOpenNotifier.value;
        final isDragging = pos.isDragging;

        final isMinimized = controller.isToolbarMinimized;
        final isDark = controller.settings.isDarkMode;
        final markerColor = MarkerColor.findById(controller.settings.markerColorId).color;

        const double expandedWidth = 296.0;
        final toolbarWidth = isMinimized ? 44.0 : expandedWidth;
        const double toolbarHeight = 44.0;

        final effectiveWidth = math.max(
          toolbarWidth,
          isSettingsOpen ? 300.0 : (isLayoutModeOpen ? 290.0 : 0.0),
        );

        _initInsetsIfNeeded(screenSize, safePadding, effectiveWidth, toolbarHeight);

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
                    onClose: () => _isSettingsOpenNotifier.value = false,
                    controller: controller,
                  ),
                )
              else if (!isMinimized && isLayoutModeOpen)
                Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ComponentPalette(
                    controller: controller,
                    onClose: () {
                      _isLayoutModeOpenNotifier.value = false;
                      controller.setToolMode(AnnotationToolMode.pointer);
                    },
                    onSelectTemplate: (template) {
                      controller.createPlacementAnnotation(
                        placement: template.toPlacementData(),
                        position: Offset(screenSize.width / 2, screenSize.height / 2),
                        comment: 'Add ${template.label} here',
                      );
                      _isLayoutModeOpenNotifier.value = false;
                      controller.setToolMode(AnnotationToolMode.pointer);
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
                    alignment: pillAlignment,
                    padding: isMinimized
                        ? EdgeInsets.zero
                        : const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(22.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 8.0,
                          offset: Offset(0, 2),
                        ),
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 16.0,
                          offset: Offset(0, 4),
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
    return InkWell(
      key: const ValueKey('toolbar_expand'),
      onTap: controller.toggleToolbarMinimized,
      borderRadius: BorderRadius.circular(22.0),
      child: Center(
        child: AgentationIcons.eye(
          size: 20.0,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
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
    final isLayoutOpen = _isLayoutModeOpenNotifier.value;
    final isSettingsOpen = _isSettingsOpenNotifier.value;
    final isCopied = _isCopiedNotifier.value;
    final isLayoutActive = isLayoutOpen || controller.toolMode == AnnotationToolMode.design;

    return ClipRect(
      child: OverflowBox(
        minWidth: 286.0,
        maxWidth: 286.0,
        alignment: pillAlignment,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Play / Pause & Inspect (|| / ▶) - Screenshot 1 & 2
            _buildToolbarButton(
              key: const ValueKey('toolbar_pause'),
              icon: isPaused
                  ? AgentationIcons.play(size: 18.0, color: const Color(0xFFFF9500))
                  : AgentationIcons.pause(size: 18.0, color: iconColor),
              isActive: isPaused,
              activeColor: const Color(0x33FF9500),
              onPressed: () {
                if (controller.isFrozen) {
                  controller.deactivate(unfreeze: true);
                } else {
                  controller.activate(freeze: true);
                  _isLayoutModeOpenNotifier.value = false;
                }
              },
            ),

            // 2. Layout Mode (split grid/window) - Screenshot 1 & 4
            _buildToolbarButton(
              key: const ValueKey('toolbar_layout'),
              icon: AgentationIcons.layout(
                size: 19.0,
                color: isLayoutActive ? Colors.white : iconColor,
              ),
              isActive: isLayoutActive,
              activeColor: const Color(0xFF0070F3), // Original vibrant blue active circle
              onPressed: () {
                final nextVal = !_isLayoutModeOpenNotifier.value;
                _isLayoutModeOpenNotifier.value = nextVal;
                _isSettingsOpenNotifier.value = false;
                if (nextVal) {
                  controller.setToolMode(AnnotationToolMode.design);
                  if (!controller.isInspecting) controller.activate();
                } else {
                  controller.setToolMode(AnnotationToolMode.pointer);
                }
              },
            ),

            // 3. Comments Visibility Mode (Eye icon) - Toggle show/hide comments on the page
            _buildToolbarButton(
              key: const ValueKey('toolbar_inspect'),
              icon: controller.areCommentsVisible
                  ? AgentationIcons.eye(
                      size: 20.0,
                      color: markerColor,
                    )
                  : AgentationIcons.eyeOff(
                      size: 20.0,
                      color: isDark ? const Color(0xFF6E6E73) : const Color(0xFF8E8E93),
                    ),
              isActive: controller.areCommentsVisible,
              activeColor: markerColor.withValues(alpha: 0.2),
              onPressed: () {
                controller.toggleCommentsVisibility();
              },
            ),

            // 4. Copy (Overlapping rectangles) - Screenshot 1
            _buildToolbarButton(
              key: const ValueKey('toolbar_copy'),
              icon: isCopied
                  ? AgentationIcons.check(size: 19.0, color: const Color(0xFF34C759))
                  : AgentationIcons.copy(size: 19.0, color: iconColor),
              isActive: isCopied,
              activeColor: const Color(0x2634C759),
              onPressed: () => _onCopy(controller),
            ),

            // 5. Delete / Trash (Trash can) - Screenshot 1
            _buildToolbarButton(
              key: const ValueKey('toolbar_clear'),
              icon: AgentationIcons.trash(size: 18.0, color: iconColor),
              isActive: false,
              activeColor: Colors.transparent,
              onPressed: () {
                controller.clearAnnotations();
              },
            ),

            // 6. Settings (Cog wheel) - Screenshot 1 & 3
            _buildToolbarButton(
              key: const ValueKey('toolbar_settings'),
              icon: AgentationIcons.gear(
                size: 19.0,
                color: isSettingsOpen ? Colors.white : iconColor,
              ),
              isActive: isSettingsOpen,
              activeColor: const Color(0xFF333333),
              onPressed: () {
                _isSettingsOpenNotifier.value = !_isSettingsOpenNotifier.value;
                _isLayoutModeOpenNotifier.value = false;
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
            _buildToolbarButton(
              key: const ValueKey('toolbar_close'),
              icon: AgentationIcons.close(size: 16.0, color: iconColor),
              isActive: false,
              activeColor: Colors.transparent,
              onPressed: () {
                _isLayoutModeOpenNotifier.value = false;
                _isSettingsOpenNotifier.value = false;
                controller.toggleToolbarMinimized();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton({
    Key? key,
    required Widget icon,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      key: key,
      onTap: onPressed,
      borderRadius: BorderRadius.circular(17.0),
      child: Container(
        width: 34.0,
        height: 34.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: icon,
      ),
    );
  }
}
