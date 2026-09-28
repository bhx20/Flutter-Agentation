import 'package:flutter/material.dart';
import '../models/widget_category.dart';
import '../widgets/category_header.dart';
import '../widgets/widget_card.dart';

/// Showcases all 12 Flutter "Layout" widgets:
/// Row, Column, Flex, Stack, Positioned, PositionedDirectional, Wrap,
/// Expanded, Flexible, Spacer, Baseline, OverflowBar.
class LayoutSection extends StatelessWidget {
  const LayoutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CategoryHeader(
          category: WidgetCategory.layout,
          itemCount: 12,
        ),

        // 1. Row, Expanded, Flexible, Spacer
        const WidgetCard(
          title: 'Row, Expanded, Flexible & Spacer',
          subtitle: 'Horizontal linear layout distribution',
          badgeColor: Color(0xFF3B82F6),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: ColoredBox(
                  color: Color(0xFF3B82F6),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: Text('Expanded (flex 2)', style: TextStyle(color: Colors.white, fontSize: 11))),
                  ),
                ),
              ),
              SizedBox(width: 6.0),
              Spacer(flex: 1),
              SizedBox(width: 6.0),
              Flexible(
                flex: 1,
                child: ColoredBox(
                  color: Color(0xFF10B981),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: Text('Flexible (flex 1)', style: TextStyle(color: Colors.white, fontSize: 11))),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. Column & Flex
        const WidgetCard(
          title: 'Column & Flex Layouts',
          subtitle: 'Vertical and arbitrary axis arrangement',
          badgeColor: Color(0xFF6366F1),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Column Item 1', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Column Item 2 with descriptive body', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              Expanded(
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Chip(label: Text('Flex A', style: TextStyle(fontSize: 10))),
                    Chip(label: Text('Flex B', style: TextStyle(fontSize: 10))),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 3. Stack, Positioned, PositionedDirectional
        WidgetCard(
          title: 'Stack & Positioned Layers',
          subtitle: 'Stack, Positioned, PositionedDirectional',
          badgeColor: const Color(0xFFEC4899),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              height: 100,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0x22EC4899),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0x44EC4899)),
                    ),
                    alignment: Alignment.center,
                    child: const Text('Stack Background Surface', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEC4899),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Positioned Top-Left', style: TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  ),
                  PositionedDirectional(
                    bottom: 8,
                    end: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('PositionedDirectional End-Bottom', style: TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 4. Wrap & Baseline & OverflowBar
        const WidgetCard(
          title: 'Wrap, Baseline & OverflowBar',
          subtitle: 'Flow wrapping, text baseline alignment, and responsive overflow',
          badgeColor: Color(0xFFF59E0B),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 6.0,
                runSpacing: 6.0,
                children: [
                  Chip(label: Text('Wrap Tag 1', style: TextStyle(fontSize: 10))),
                  Chip(label: Text('Wrap Tag 2', style: TextStyle(fontSize: 10))),
                  Chip(label: Text('Wrap Tag 3', style: TextStyle(fontSize: 10))),
                  Chip(label: Text('Wrap Tag 4', style: TextStyle(fontSize: 10))),
                ],
              ),
              SizedBox(height: 12.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Baseline(
                    baseline: 24.0,
                    baselineType: TextBaseline.alphabetic,
                    child: Text('Large', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                  ),
                  SizedBox(width: 8),
                  Baseline(
                    baseline: 24.0,
                    baselineType: TextBaseline.alphabetic,
                    child: Text('Baseline aligned small text', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
              SizedBox(height: 12.0),
              OverflowBar(
                spacing: 8.0,
                overflowSpacing: 6.0,
                alignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(onPressed: null, child: Text('OverflowBar 1', style: TextStyle(fontSize: 11))),
                  FilledButton(onPressed: null, child: Text('OverflowBar 2', style: TextStyle(fontSize: 11))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
