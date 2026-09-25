import 'package:flutter/material.dart';

/// An interactive action button within the Agentation floating toolbar.
class ToolbarActionButton extends StatelessWidget {
  const ToolbarActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isActive = false,
    this.activeColor = const Color(0xFF6366F1), // Indigo 500
    this.inactiveColor = const Color(0xFF94A3B8), // Slate 400
    this.badgeText,
  });

  /// The icon to display.
  final IconData icon;

  /// Tooltip text.
  final String tooltip;

  /// Callback when pressed.
  final VoidCallback? onPressed;

  /// Whether this action is in an active/highlighted state.
  final bool isActive;

  /// Color used when [isActive] is true.
  final Color activeColor;

  /// Color used when [isActive] is false.
  final Color inactiveColor;

  /// Optional counter badge string.
  final String? badgeText;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.0),
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isActive ? activeColor.withValues(alpha: 0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(20.0),
              border: isActive
                  ? Border.all(color: activeColor.withValues(alpha: 0.6), width: 1.0)
                  : null,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 18.0,
                  color: isActive ? activeColor : inactiveColor,
                ),
                if (badgeText != null)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
                      decoration: BoxDecoration(
                        color: activeColor,
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Text(
                        badgeText!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
