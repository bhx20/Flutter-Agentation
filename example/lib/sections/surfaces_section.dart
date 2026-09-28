import 'package:flutter/material.dart';
import '../models/widget_category.dart';
import '../widgets/category_header.dart';
import '../widgets/widget_card.dart';

/// Comprehensive showcase of Material 3 Cards, Containers, and Surface styles.
class SurfacesSection extends StatelessWidget {
  const SurfacesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CategoryHeader(
          category: WidgetCategory.surfaces,
          itemCount: 6,
        ),

        // 1. Standard Elevated Card (Required by widget_test with key 'info_card_layout')
        Card(
          key: const ValueKey('info_card_layout'),
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.dashboard_outlined, color: Color(0xFF6366F1)),
                    SizedBox(width: 8.0),
                    Text(
                      'Hierarchical Component',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'The inspection engine accurately maps ancestry breadcrumbs and bounding dimensions across complex layouts.',
                  style: TextStyle(color: Colors.black54, fontSize: 13.0, height: 1.4),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12.0),

        // 2. Material 3 Card Variants: Filled & Outlined
        Row(
          children: [
            Expanded(
              child: Card.filled(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.layers, size: 18.0, color: Color(0xFF0284C7)),
                          SizedBox(width: 6.0),
                          Text(
                            'Card.filled',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.0),
                      Text(
                        'Soft tinted background fill for subtle grouping.',
                        style: TextStyle(fontSize: 12.0, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Card.outlined(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.crop_square, size: 18.0, color: Color(0xFF10B981)),
                          SizedBox(width: 6.0),
                          Text(
                            'Card.outlined',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.0),
                      Text(
                        'Border outline without shadow elevation.',
                        style: TextStyle(fontSize: 12.0, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),

        // 3. Container with Multi-stop Gradient & Shadows
        WidgetCard(
          title: 'DecoratedBox & Gradient Container',
          subtitle: 'LinearGradient, BoxShadows, and rounded border decorations',
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x336366F1),
                  blurRadius: 16.0,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28.0),
                ),
                const SizedBox(width: 16.0),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gradient Hero Surface',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        'Inspect gradient stops, radius metrics, and render tree depth seamlessly.',
                        style: TextStyle(color: Colors.white70, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 4. Interactive Material & InkWell Ripple Surface
        WidgetCard(
          title: 'Material & InkWell Surface',
          subtitle: 'Clickable surface displaying touch splash ripples on tap',
          child: Material(
            color: const Color(0xFFF8FAFC),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12.0),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                child: Row(
                  children: const [
                    Badge(
                      label: Text('NEW'),
                      backgroundColor: Color(0xFFEF4444),
                      child: Icon(Icons.touch_app_outlined, color: Color(0xFF6366F1)),
                    ),
                    SizedBox(width: 14.0),
                    Expanded(
                      child: Text(
                        'Tap here to trigger Material Ink splash feedback',
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.5),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
