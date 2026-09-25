import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/agentation_controller.dart';
import '../core/agentation_scope.dart';
import '../core/agentation_state.dart';
import '../models/marker_color.dart';
import '../models/toolbar_settings.dart';
import 'output_detail_button.dart';
import 'toolbar_action_button.dart';

/// Draggable floating pill toolbar providing on-screen inspection controls,
/// interaction mode selectors, detail level cycling, undo/redo, and export.
class AgentationToolbar extends StatefulWidget {
  const AgentationToolbar({
    super.key,
    this.controller,
    this.initialAlignment = Alignment.bottomRight,
    this.onOpenSettings,
  });

  /// Optional controller; defaults to closest [AgentationScope].
  final AgentationController? controller;

  /// Initial screen quadrant alignment.
  final Alignment initialAlignment;

  /// Optional callback to open the settings panel.
  final VoidCallback? onOpenSettings;

  @override
  State<AgentationToolbar> createState() => _AgentationToolbarState();
}

class _AgentationToolbarState extends State<AgentationToolbar> {
  Offset? _currentOffset;
  String? _toastMessage;
  Timer? _toastTimer;

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  void _showFeedback(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      setState(() {
        _toastMessage = message;
      });
      _toastTimer?.cancel();
      _toastTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _toastMessage = null;
          });
        }
      });
    }
  }

  AgentationController get _controller =>
      widget.controller ?? AgentationScope.of(context);

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

    final double x;
    if (widget.initialAlignment.x < 0) {
      x = safePadding.left + 16.0;
    } else if (widget.initialAlignment.x > 0) {
      x = screenSize.width - safePadding.right - width - 16.0;
    } else {
      x = (screenSize.width - width) / 2.0;
    }

    final double y;
    if (widget.initialAlignment.y < 0) {
      y = safePadding.top + 16.0;
    } else if (widget.initialAlignment.y > 0) {
      y = screenSize.height - safePadding.bottom - height - 16.0;
    } else {
      y = (screenSize.height - height) / 2.0;
    }

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

        final maxAllowedWidth = math.max(44.0, screenSize.width - safePadding.horizontal - 16.0);
        final toolbarWidth = isMinimized ? 44.0 : math.min(640.0, maxAllowedWidth);
        const toolbarHeight = 44.0;

        final offset = _currentOffset ?? _getDefaultOffset(screenSize, safePadding, toolbarWidth, toolbarHeight);

        return Positioned(
          left: offset.dx,
          top: offset.dy,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_toastMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 6.0),
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xE60F172A) : const Color(0xE61E293B),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: const Color(0x33FFFFFF)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x40000000),
                        blurRadius: 8.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _toastMessage!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              GestureDetector(
                onPanUpdate: (details) => _onPanUpdate(details, screenSize, safePadding, toolbarWidth, toolbarHeight),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  constraints: BoxConstraints(maxWidth: toolbarWidth),
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xE61E1E2E) : const Color(0xF2FFFFFF),
                    borderRadius: BorderRadius.circular(22.0),
                    border: Border.all(
                      color: controller.isInspecting
                          ? markerColor.withValues(alpha: 0.6)
                          : (isDark ? const Color(0x33FFFFFF) : const Color(0x1F000000)),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? const Color(0x66000000) : const Color(0x26000000),
                        blurRadius: 16.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: isMinimized
                        ? _buildMinimizedContent(controller, markerColor)
                        : _buildExpandedContent(controller, markerColor, isDark),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMinimizedContent(AgentationController controller, Color markerColor) {
    return ToolbarActionButton(
      icon: Icons.open_in_full,
      tooltip: 'Expand Toolbar',
      isActive: controller.isInspecting,
      activeColor: markerColor,
      onPressed: controller.toggleToolbarMinimized,
    );
  }

  Widget _buildExpandedContent(
    AgentationController controller,
    Color markerColor,
    bool isDark,
  ) {
    final dividerColor = isDark ? const Color(0x33FFFFFF) : const Color(0x1F000000);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle grip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Icon(
              Icons.drag_indicator,
              size: 16.0,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
          ),

          // Inspect Toggle
          ToolbarActionButton(
            icon: controller.isInspecting ? Icons.explore : Icons.ads_click,
            tooltip: controller.isInspecting ? 'Stop Inspecting' : 'Inspect Widgets',
            isActive: controller.isInspecting,
            activeColor: markerColor,
            onPressed: controller.toggleInspect,
          ),

          // Pause / Resume
          ToolbarActionButton(
            icon: controller.isPaused ? Icons.play_arrow : Icons.pause,
            tooltip: controller.isPaused ? 'Resume Inspection' : 'Pause Inspection',
            isActive: controller.isPaused,
            activeColor: const Color(0xFFF59E0B),
            onPressed: controller.isInspecting || controller.isPaused
                ? () {
                    if (controller.isPaused) {
                      controller.resume();
                    } else {
                      controller.pause();
                    }
                  }
                : null,
          ),

          // Freeze / Resume Animations
          ToolbarActionButton(
            icon: controller.isFrozen ? Icons.ac_unit : Icons.ac_unit_outlined,
            tooltip: controller.isFrozen ? 'Resume Animations' : 'Freeze Animations',
            isActive: controller.isFrozen,
            activeColor: const Color(0xFF38BDF8),
            onPressed: controller.toggleFreeze,
          ),

          _buildVerticalDivider(dividerColor),

          // Segmented Tool Modes
          ToolbarActionButton(
            icon: Icons.near_me_outlined,
            tooltip: 'Pointer',
            isActive: controller.toolMode == AnnotationToolMode.pointer,
            activeColor: markerColor,
            onPressed: () => controller.setToolMode(AnnotationToolMode.pointer),
          ),
          ToolbarActionButton(
            icon: Icons.crop_free,
            tooltip: 'Area Marquee',
            isActive: controller.toolMode == AnnotationToolMode.area,
            activeColor: markerColor,
            onPressed: () => controller.setToolMode(AnnotationToolMode.area),
          ),
          ToolbarActionButton(
            icon: Icons.select_all,
            tooltip: 'Multi-Select',
            isActive: controller.toolMode == AnnotationToolMode.multiSelect,
            activeColor: markerColor,
            badgeText: controller.multiSelection.isNotEmpty
                ? '${controller.multiSelection.length}'
                : null,
            onPressed: () => controller.setToolMode(AnnotationToolMode.multiSelect),
          ),
          ToolbarActionButton(
            icon: Icons.gesture,
            tooltip: 'Draw Canvas',
            isActive: controller.toolMode == AnnotationToolMode.draw,
            activeColor: markerColor,
            onPressed: () => controller.setToolMode(AnnotationToolMode.draw),
          ),
          ToolbarActionButton(
            icon: Icons.dashboard_customize_outlined,
            tooltip: 'Design Mode',
            isActive: controller.toolMode == AnnotationToolMode.design,
            activeColor: markerColor,
            onPressed: () => controller.setToolMode(AnnotationToolMode.design),
          ),

          _buildVerticalDivider(dividerColor),

          // Output Detail Level Button
          OutputDetailButton(
            detailLevel: controller.settings.outputDetail,
            onChanged: controller.setDetailLevel,
          ),

          _buildVerticalDivider(dividerColor),

          // Undo / Redo
          ToolbarActionButton(
            icon: Icons.undo,
            tooltip: 'Undo',
            isActive: false,
            onPressed: controller.canUndo ? () => controller.undo() : null,
          ),
          ToolbarActionButton(
            icon: Icons.redo,
            tooltip: 'Redo',
            isActive: false,
            onPressed: controller.canRedo ? () => controller.redo() : null,
          ),

          _buildVerticalDivider(dividerColor),

          // Export / Copy Format Popup Menu
          PopupMenuButton<CopyFormat>(
            tooltip: 'Copy Format (${controller.settings.copyFormat.name})',
            initialValue: controller.settings.copyFormat,
            onSelected: (format) {
              controller.setCopyFormat(format);
              _handleCopy(controller);
            },
            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            itemBuilder: (context) => [
              _buildMenuItem(CopyFormat.markdown, 'Markdown (.md)', isDark),
              _buildMenuItem(CopyFormat.json, 'Standard JSON', isDark),
              _buildMenuItem(CopyFormat.agentationJson, 'Agentation Protocol JSON', isDark),
              _buildMenuItem(CopyFormat.source, 'Source References', isDark),
              _buildMenuItem(CopyFormat.attributes, 'Element Attributes', isDark),
            ],
            child: ToolbarActionButton(
              icon: Icons.copy,
              tooltip: 'Copy Annotations',
              isActive: false,
              badgeText: controller.annotations.isNotEmpty
                  ? '${controller.annotations.length}'
                  : null,
              onPressed: () => _handleCopy(controller),
            ),
          ),

          // Clear Selection
          if (controller.selectedResult != null || controller.multiSelection.isNotEmpty)
            ToolbarActionButton(
              icon: Icons.clear_all,
              tooltip: 'Clear Selection',
              isActive: false,
              onPressed: controller.clearSelection,
            ),

          // Settings Button (if callback provided)
          if (widget.onOpenSettings != null)
            ToolbarActionButton(
              icon: Icons.settings_outlined,
              tooltip: 'Settings',
              isActive: false,
              onPressed: widget.onOpenSettings,
            ),

          // Minimize Toolbar
          ToolbarActionButton(
            icon: Icons.close_fullscreen,
            tooltip: 'Minimize Toolbar',
            isActive: false,
            onPressed: controller.toggleToolbarMinimized,
          ),
        ],
      ),
    );
  }

  PopupMenuItem<CopyFormat> _buildMenuItem(CopyFormat value, String label, bool isDark) {
    return PopupMenuItem<CopyFormat>(
      value: value,
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 13.0,
        ),
      ),
    );
  }

  Widget _buildVerticalDivider(Color color) {
    return Container(
      width: 1.0,
      height: 20.0,
      margin: const EdgeInsets.symmetric(horizontal: 3.0),
      color: color,
    );
  }

  Future<void> _handleCopy(AgentationController controller) async {
    final count = controller.annotations.length;
    if (count == 0) {
      _showFeedback('No annotations to export');
      return;
    }
    final copied = await controller.exportAnnotations();
    if (!mounted) return;
    if (copied != null) {
      _showFeedback('Copied $count annotation${count > 1 ? 's' : ''} to clipboard!');
    } else {
      _showFeedback('Failed to copy to clipboard');
    }
  }
}

