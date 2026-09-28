import 'package:flutter/material.dart';
import 'package:flutter_agentation/flutter_agentation.dart';
import '../models/widget_category.dart';
import '../widgets/category_header.dart';
import '../widgets/widget_card.dart';

/// Comprehensive showcase of Wrap, Stack, Table, Transform, and AgentationTarget.
class LayoutsTransformsSection extends StatelessWidget {
  const LayoutsTransformsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CategoryHeader(
          category: WidgetCategory.layouts,
          itemCount: 6,
        ),

        // 1. Explicit AgentationTarget Identifier (Required by demo)
        WidgetCard(
          title: 'AgentationTarget Explicit Identifier',
          subtitle: 'Explicit target ID prioritized during AI inspection and annotation',
          child: AgentationTarget(
            id: 'custom_annotated_target',
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.label_important_outline, color: Color(0xFF4F46E5)),
                  SizedBox(width: 8.0),
                  Text(
                    'Tagged: custom_annotated_target',
                    style: TextStyle(
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 2. Transformed & Rotated Element (Required by demo with key 'rotated_demo_box')
        WidgetCard(
          title: 'Transform.rotate & Transform.scale',
          subtitle: 'Affine transform matrices with accurate bounding box calculation',
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Transform.rotate(
                angle: 0.15, // ~8.5 degrees
                child: Container(
                  key: const ValueKey('rotated_demo_box'),
                  width: 240,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                    ),
                    borderRadius: BorderRadius.circular(14.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26000000),
                        blurRadius: 10.0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Rotated Card (8.5°)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // 3. Stack with Overlapping Positioned Elements
        WidgetCard(
          title: 'Stack & Positioned Layout',
          subtitle: 'Overlapping layers, absolute coordinate positioning, and z-index',
          child: SizedBox(
            height: 120.0,
            child: Stack(
              children: [
                Positioned(
                  left: 10.0,
                  top: 10.0,
                  right: 40.0,
                  bottom: 10.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    padding: const EdgeInsets.all(14.0),
                    child: const Text(
                      'Base Layer in Stack (Background Card)',
                      style: TextStyle(color: Colors.black54, fontSize: 13.0),
                    ),
                  ),
                ),
                Positioned(
                  right: 20.0,
                  top: 20.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 8.0,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.layers, size: 16.0, color: Colors.white),
                        SizedBox(width: 6.0),
                        Text(
                          'Floating Layer',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 4. Wrap Layout
        WidgetCard(
          title: 'Wrap Layout',
          subtitle: 'Flowing multi-line layouts adapting flexibly to available width',
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              'Flutter', 'Widgets', 'Inspection', 'Dart', 'DevTools',
              'LayoutBuilder', 'Constraints', 'Visual Overlay', 'Cross-Platform',
            ].map((text) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7FF),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF3730A3),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
