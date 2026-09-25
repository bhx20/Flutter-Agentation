import 'package:flutter/material.dart';
import '../models/toolbar_settings.dart';

/// Interactive button cycling between the 4 output detail levels with animated dot indicators.
class OutputDetailButton extends StatelessWidget {
  const OutputDetailButton({
    super.key,
    required this.detailLevel,
    required this.onChanged,
  });

  /// The currently active output detail level.
  final OutputDetailLevel detailLevel;

  /// Callback invoked when the user clicks to cycle to the next detail level.
  final ValueChanged<OutputDetailLevel> onChanged;

  static const List<OutputDetailLevel> _levels = [
    OutputDetailLevel.compact,
    OutputDetailLevel.standard,
    OutputDetailLevel.detailed,
    OutputDetailLevel.forensic,
  ];

  String _labelFor(OutputDetailLevel level) {
    switch (level) {
      case OutputDetailLevel.compact:
        return 'Compact';
      case OutputDetailLevel.standard:
        return 'Standard';
      case OutputDetailLevel.detailed:
        return 'Detailed';
      case OutputDetailLevel.forensic:
        return 'Forensic';
    }
  }

  void _handleCycle() {
    final currentIndex = _levels.indexOf(detailLevel);
    final nextIndex = (currentIndex + 1) % _levels.length;
    onChanged(_levels[nextIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleCycle,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _labelFor(detailLevel),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6.0),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: _levels.map((level) {
                  final isActive = level == detailLevel;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    width: isActive ? 6.0 : 4.0,
                    height: isActive ? 6.0 : 4.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? const Color(0xFF818CF8)
                          : Colors.white.withValues(alpha: 0.25),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
