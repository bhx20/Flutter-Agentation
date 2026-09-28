import 'package:flutter/material.dart';
import '../models/widget_category.dart';

/// Clean, visually striking category header for dividing widget groups.
class CategoryHeader extends StatelessWidget {
  const CategoryHeader({
    super.key,
    required this.category,
    this.itemCount,
  });

  final WidgetCategory category;
  final int? itemCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(top: 28.0, bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF27273A) : const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: isDark ? const Color(0xFF3B3B54) : const Color(0xFFC7D2FE),
              ),
            ),
            child: Icon(
              category.icon,
              size: 20.0,
              color: const Color(0xFF6366F1),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      category.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (itemCount != null) ...[
                      const SizedBox(width: 8.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          '$itemCount items',
                          style: TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2.0),
                Text(
                  category.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
