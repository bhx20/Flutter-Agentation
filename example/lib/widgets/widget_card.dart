import 'package:flutter/material.dart';

/// A card that showcases one or more related Flutter widgets with a clear badge.
class WidgetCard extends StatelessWidget {
  const WidgetCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.badgeColor,
    this.padding = const EdgeInsets.all(16.0),
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Color? badgeColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.0),
        side: BorderSide(
          color: isDark ? const Color(0xFF2E2E3E) : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
      ),
      color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
      margin: const EdgeInsets.only(bottom: 14.0),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? const Color(0xFF6366F1)).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(
                      color: (badgeColor ?? const Color(0xFF6366F1)).withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: badgeColor ?? const Color(0xFF6366F1),
                    ),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white54 : Colors.black45,
                        fontSize: 11.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12.0),
            child,
          ],
        ),
      ),
    );
  }
}
