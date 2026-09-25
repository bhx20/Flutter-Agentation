import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/agentation_controller.dart';
import '../core/agentation_scope.dart';
import 'toolbar_action_button.dart';

/// Draggable floating pill toolbar providing on-screen inspection controls.
class AgentationToolbar extends StatefulWidget {
  const AgentationToolbar({
    super.key,
    this.controller,
    this.initialAlignment = Alignment.bottomRight,
  });

  /// Optional controller; defaults to closest [AgentationScope].
  final AgentationController? controller;

  /// Initial screen quadrant alignment.
  final Alignment initialAlignment;

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

  void _onPanUpdate(DragUpdateDetails details, Size screenSize, EdgeInsets safePadding, double toolbarWidth, double toolbarHeight) {
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
        final toolbarWidth = isMinimized ? 44.0 : 240.0;
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
                    color: const Color(0xE60F172A),
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
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: const Color(0xE61E1E2E), // Glassmorphism dark slate
                    borderRadius: BorderRadius.circular(22.0),
                    border: Border.all(
                      color: controller.isInspecting
                          ? const Color(0x666366F1) // Indigo glow
                          : const Color(0x33FFFFFF), // Subtle translucent white
                      width: 1.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 16.0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: isMinimized
                      ? _buildMinimizedContent(controller)
                      : _buildExpandedContent(controller),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMinimizedContent(AgentationController controller) {
    return ToolbarActionButton(
      icon: Icons.open_in_full,
      tooltip: 'Expand Toolbar',
      isActive: controller.isInspecting,
      onPressed: controller.toggleToolbarMinimized,
    );
  }

  Widget _buildExpandedContent(AgentationController controller) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle grip
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Icon(
            Icons.drag_indicator,
            size: 16.0,
            color: Color(0xFF64748B), // Slate 500
          ),
        ),

        // Action 1: Toggle Inspect
        ToolbarActionButton(
          icon: controller.isInspecting ? Icons.explore : Icons.ads_click,
          tooltip: controller.isInspecting ? 'Stop Inspecting' : 'Inspect Widgets',
          isActive: controller.isInspecting,
          activeColor: const Color(0xFF6366F1), // Indigo
          onPressed: controller.toggleInspect,
        ),

        // Action 2: Pause / Resume (visible during inspection or pause)
        ToolbarActionButton(
          icon: controller.isPaused ? Icons.play_arrow : Icons.pause,
          tooltip: controller.isPaused ? 'Resume Inspection' : 'Pause Inspection',
          isActive: controller.isPaused,
          activeColor: const Color(0xFFF59E0B), // Amber
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

        // Action 3: Clear Selection
        ToolbarActionButton(
          icon: Icons.clear_all,
          tooltip: 'Clear Selection',
          isActive: false,
          onPressed: controller.selectedResult != null
              ? controller.clearSelection
              : null,
        ),

        // Action 4: Export Annotations
        ToolbarActionButton(
          icon: Icons.copy,
          tooltip: 'Copy Annotations',
          isActive: false,
          onPressed: () async {
            final count = controller.annotations.length;
            if (count == 0) {
              _showFeedback('No annotations to export');
              return;
            }
            final copied = await controller.exportAnnotations();
            if (!mounted) return;
            if (copied != null) {
              _showFeedback(
                'Copied $count annotation${count > 1 ? 's' : ''} to clipboard!',
              );
            } else {
              _showFeedback('Failed to copy to clipboard');
            }
          },
        ),

        // Action 5: Minimize Toolbar
        ToolbarActionButton(
          icon: Icons.close_fullscreen,
          tooltip: 'Minimize Toolbar',
          isActive: false,
          onPressed: controller.toggleToolbarMinimized,
        ),
      ],
    );
  }
}
