import 'package:flutter/material.dart';
import '../models/widget_category.dart';
import '../widgets/category_header.dart';
import '../widgets/widget_card.dart';

/// Comprehensive showcase of Progress Indicators and Live Animation widgets.
class IndicatorsAnimationsSection extends StatefulWidget {
  const IndicatorsAnimationsSection({
    super.key,
    required this.animController,
  });

  final AnimationController animController;

  @override
  State<IndicatorsAnimationsSection> createState() => _IndicatorsAnimationsSectionState();
}

class _IndicatorsAnimationsSectionState extends State<IndicatorsAnimationsSection> {
  bool _expandedContainer = false;
  double _opacityLevel = 1.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CategoryHeader(
          category: WidgetCategory.indicators,
          itemCount: 6,
        ),

        // 1. Live Continuous Animation (for testing Animation Freeze button)
        Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.only(bottom: 14.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            children: [
              RotationTransition(
                turns: widget.animController,
                child: Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.refresh, color: Colors.white, size: 24.0),
                ),
              ),
              const SizedBox(width: 14.0),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Continuous Animation (Freeze Test)',
                      style: TextStyle(
                        color: Color(0xFF065F46),
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      'Tap the snowflake (❄) button on the toolbar to freeze this animation mid-flight and inspect it.',
                      style: TextStyle(color: Color(0xFF047857), fontSize: 12.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 2. Circular & Linear Progress Indicators
        WidgetCard(
          title: 'Circular & Linear Progress Indicators',
          subtitle: 'Determinate and indeterminate progress visualization',
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Column(
                    children: [
                      CircularProgressIndicator(strokeWidth: 3.5),
                      SizedBox(height: 8.0),
                      Text('Indeterminate', style: TextStyle(fontSize: 11.5, color: Colors.grey)),
                    ],
                  ),
                  Column(
                    children: [
                      CircularProgressIndicator(
                        value: 0.72,
                        strokeWidth: 4.0,
                        color: Color(0xFF10B981),
                        backgroundColor: Color(0xFFE2E8F0),
                      ),
                      SizedBox(height: 8.0),
                      Text('72% Complete', style: TextStyle(fontSize: 11.5, color: Colors.grey)),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: 32.0,
                        height: 32.0,
                        child: CircularProgressIndicator(
                          value: 0.45,
                          strokeWidth: 3.0,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text('45% Warning', style: TextStyle(fontSize: 11.5, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('LinearProgressIndicator (Determinate 68%):', style: TextStyle(fontSize: 12.0)),
                  SizedBox(height: 6.0),
                  LinearProgressIndicator(
                    value: 0.68,
                    minHeight: 6.0,
                    borderRadius: BorderRadius.all(Radius.circular(3.0)),
                    color: Color(0xFF6366F1),
                    backgroundColor: Color(0xFFE2E8F0),
                  ),
                  SizedBox(height: 12.0),
                  Text('LinearProgressIndicator (Indeterminate):', style: TextStyle(fontSize: 12.0)),
                  SizedBox(height: 6.0),
                  LinearProgressIndicator(
                    minHeight: 4.0,
                    color: Color(0xFF8B5CF6),
                    backgroundColor: Color(0xFFF1F5F9),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 3. Interactive AnimatedContainer
        WidgetCard(
          title: 'AnimatedContainer & AnimatedOpacity',
          subtitle: 'Implicit animations transitioning dimensions, colors, and opacity on tap',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // AnimatedContainer demo
              GestureDetector(
                onTap: () => setState(() => _expandedContainer = !_expandedContainer),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  width: _expandedContainer ? 120.0 : 80.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    color: _expandedContainer ? const Color(0xFF8B5CF6) : const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(_expandedContainer ? 24.0 : 8.0),
                    boxShadow: [
                      BoxShadow(
                        color: (_expandedContainer ? const Color(0xFF8B5CF6) : const Color(0xFF6366F1))
                            .withValues(alpha: 0.4),
                        blurRadius: _expandedContainer ? 12.0 : 4.0,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _expandedContainer ? 'Toggled!' : 'Tap me',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.0),
                    ),
                  ),
                ),
              ),

              // AnimatedOpacity demo
              GestureDetector(
                onTap: () => setState(() => _opacityLevel = _opacityLevel == 0.2 ? 1.0 : 0.2),
                child: AnimatedOpacity(
                  opacity: _opacityLevel,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility, color: Colors.white, size: 16.0),
                        SizedBox(width: 6.0),
                        Text(
                          'Fade Tap',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
