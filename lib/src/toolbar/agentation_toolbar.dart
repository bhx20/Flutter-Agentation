import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/agentation_controller.dart';
import '../core/agentation_scope.dart';
import '../core/agentation_state.dart';
import '../design/component_palette.dart';
import '../models/marker_color.dart';
import 'agentation_icons.dart';
import 'agentation_tooltip.dart';
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

class _AgentationToolbarState extends State<AgentationToolbar> {
  Offset? _currentOffset;
  bool _isCopied = false;
  Timer? _copyTimer;
  bool _isSettingsOpen = false;
  bool _isLayoutModeOpen = false;

  @override
  void dispose() {
    _copyTimer?.cancel();
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
    setState(() => _isCopied = true);
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
      if (mounted) setState(() => _isCopied = false);
    });
  }

  void _onPanUpdate(
    DragUpdateDetails details,
    Size screenSize,
    EdgeInsets safePadding,
    double toolbarWidth,
    double toolbarHeight,
  ) {
    final minX = safePadding.left + 8.0;
    final maxX = math.max(minX, screenSize.width - safePadding.right - toolbarWidth - 8.0);
    final minY = safePadding.top + 8.0;
    final maxY = math.max(minY, screenSize.height - safePadding.bottom - toolbarHeight - 8.0);

    final current = _currentOffset ?? _getDefaultOffset(screenSize, safePadding, toolbarWidth, toolbarHeight);
    final updatedX = (current.dx + details.delta.dx).clamp(minX, maxX);
    final updatedY = (current.dy + details.delta.dy).clamp(minY, maxY);

    final newOffset = Offset(updatedX, updatedY);
    setState(() {
      _currentOffset = newOffset;
    });
    _controller.updateToolbarOffset(newOffset);
  }

  Offset _getDefaultOffset(Size screenSize, EdgeInsets safePadding, double width, double height) {
    if (_controller.toolbarOffset != Offset.zero) {
      return _controller.toolbarOffset;
    }

    final double x = (screenSize.width - width) / 2.0;
    final double y = screenSize.height - safePadding.bottom - height - 20.0;
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final screenSize = MediaQuery.of(context).size;
    final safePadding = MediaQuery.paddingOf(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final isMinimized = controller.isToolbarMinimized;
        final isDark = controller.settings.isDarkMode;
        final markerColor = MarkerColor.findById(controller.settings.markerColorId).color;

        const double expandedWidth = 296.0;
        final toolbarWidth = isMinimized ? 44.0 : expandedWidth;
        const double toolbarHeight = 44.0;

        final offset = _currentOffset ?? _getDefaultOffset(screenSize, safePadding, toolbarWidth, toolbarHeight);
        final double bottomInset = screenSize.height - offset.dy - toolbarHeight;

        return Positioned(
          left: offset.dx,
          bottom: bottomInset,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Floating Panel: Settings or Layout Mode (Screenshots 3 & 4) ──
              if (!isMinimized && _isSettingsOpen)
                Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: SettingsPanel(
                    onClose: () => setState(() => _isSettingsOpen = false),
                    controller: controller,
                  ),
                )
              else if (!isMinimized && _isLayoutModeOpen)
                Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ComponentPalette(
                    controller: controller,
                    onClose: () => setState(() => _isLayoutModeOpen = false),
                    onSelectTemplate: (template) {
                      controller.createPlacementAnnotation(
                        placement: template.toPlacementData(),
                        position: Offset(screenSize.width / 2, screenSize.height / 2),
                        comment: 'Add ${template.label} here',
                      );
                      setState(() => _isLayoutModeOpen = false);
                    },
                  ),
                ),

              // ── Pill Toolbar Container (Screenshot 1) ──
              GestureDetector(
                onPanUpdate: (details) => _onPanUpdate(details, screenSize, safePadding, toolbarWidth, toolbarHeight),
                child: Material(
                  color: Colors.transparent,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: toolbarWidth,
                    height: toolbarHeight,
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
                        : _buildExpandedPill(controller, markerColor, isDark),
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
    return Tooltip(
      message: 'Expand Toolbar',
      triggerMode: TooltipTriggerMode.manual,
      child: InkWell(
        key: const ValueKey('toolbar_expand'),
        onTap: controller.toggleToolbarMinimized,
        borderRadius: BorderRadius.circular(22.0),
        child: Center(
          child: AgentationIcons.eye(
            size: 20.0,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedPill(
    AgentationController controller,
    Color markerColor,
    bool isDark,
  ) {
    final iconColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final dividerColor = isDark ? const Color(0x33FFFFFF) : const Color(0x1F000000);

    final isPaused = controller.isFrozen || controller.isPaused;
    final isLayoutActive = _isLayoutModeOpen || controller.toolMode == AnnotationToolMode.design;
    final isInspectActive = controller.isInspecting;

    return ClipRect(
      child: OverflowBox(
        minWidth: 286.0,
        maxWidth: 286.0,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
        // 1. Pause animations (|| / ▶) - Screenshot 1 & 2
        AgentationTooltip(
          message: isPaused ? 'Resume animations' : 'Pause animations',
          shortcut: 'P',
          child: _buildToolbarButton(
            key: const ValueKey('toolbar_pause'),
            icon: isPaused
                ? AgentationIcons.play(size: 18.0, color: const Color(0xFFFF9500))
                : AgentationIcons.pause(size: 18.0, color: iconColor),
            isActive: isPaused,
            activeColor: const Color(0x33FF9500),
            onPressed: () {
              controller.toggleFreeze();
            },
          ),
        ),

        // 2. Layout Mode (split grid/window) - Screenshot 1 & 4
        AgentationTooltip(
          message: 'Layout mode',
          shortcut: 'L',
          child: _buildToolbarButton(
            key: const ValueKey('toolbar_layout'),
            icon: AgentationIcons.layout(
              size: 19.0,
              color: isLayoutActive ? Colors.white : iconColor,
            ),
            isActive: isLayoutActive,
            activeColor: const Color(0xFF0070F3), // Original vibrant blue active circle
            onPressed: () {
              setState(() {
                _isLayoutModeOpen = !_isLayoutModeOpen;
                _isSettingsOpen = false;
              });
              if (_isLayoutModeOpen) {
                controller.setToolMode(AnnotationToolMode.design);
                if (!controller.isInspecting) controller.toggleInspect();
              } else {
                controller.setToolMode(AnnotationToolMode.pointer);
              }
            },
          ),
        ),

        // 3. Inspect Mode (Eye icon) - Screenshot 1 & 5
        AgentationTooltip(
          message: 'Inspect',
          shortcut: 'I',
          child: _buildToolbarButton(
            key: const ValueKey('toolbar_inspect'),
            icon: AgentationIcons.eye(
              size: 20.0,
              color: isInspectActive && !isLayoutActive ? markerColor : iconColor,
            ),
            isActive: isInspectActive && !isLayoutActive,
            activeColor: markerColor.withValues(alpha: 0.2),
            onPressed: () {
              controller.toggleInspect();
              if (controller.isInspecting) {
                controller.setToolMode(AnnotationToolMode.pointer);
                setState(() {
                  _isLayoutModeOpen = false;
                });
              }
            },
          ),
        ),

        // 4. Copy (Overlapping rectangles) - Screenshot 1
        AgentationTooltip(
          message: 'Copy annotations',
          shortcut: 'C',
          child: _buildToolbarButton(
            key: const ValueKey('toolbar_copy'),
            icon: _isCopied
                ? AgentationIcons.check(size: 19.0, color: const Color(0xFF34C759))
                : AgentationIcons.copy(size: 19.0, color: iconColor),
            isActive: _isCopied,
            activeColor: const Color(0x2634C759),
            onPressed: () => _onCopy(controller),
          ),
        ),

        // 5. Delete / Trash (Trash can) - Screenshot 1
        AgentationTooltip(
          message: 'Clear annotations',
          shortcut: 'D',
          child: _buildToolbarButton(
            key: const ValueKey('toolbar_clear'),
            icon: AgentationIcons.trash(size: 18.0, color: iconColor),
            isActive: false,
            activeColor: Colors.transparent,
            onPressed: () {
              controller.clearAnnotations();
            },
          ),
        ),

        // 6. Settings (Cog wheel) - Screenshot 1 & 3
        AgentationTooltip(
          message: 'Settings',
          shortcut: 'S',
          child: _buildToolbarButton(
            key: const ValueKey('toolbar_settings'),
            icon: AgentationIcons.gear(
              size: 19.0,
              color: _isSettingsOpen ? Colors.white : iconColor,
            ),
            isActive: _isSettingsOpen,
            activeColor: const Color(0xFF333333),
            onPressed: () {
              setState(() {
                _isSettingsOpen = !_isSettingsOpen;
                _isLayoutModeOpen = false;
              });
            },
          ),
        ),

        // Vertical divider line (Screenshot 1)
        Container(
          width: 1.0,
          height: 16.0,
          color: dividerColor,
          margin: const EdgeInsets.symmetric(horizontal: 2.0),
        ),

        // 7. Close / Minimize (X) - Screenshot 1
        AgentationTooltip(
          message: 'Close',
          shortcut: 'Esc',
          child: _buildToolbarButton(
            key: const ValueKey('toolbar_close'),
            icon: AgentationIcons.close(size: 16.0, color: iconColor),
            isActive: false,
            activeColor: Colors.transparent,
            onPressed: controller.toggleToolbarMinimized,
          ),
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
