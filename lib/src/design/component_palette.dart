import 'package:flutter/material.dart';
import '../core/agentation_controller.dart';
import '../core/agentation_scope.dart';
import '../models/marker_color.dart';
import 'skeleton_templates.dart';

/// Floating panel displaying wireframe skeleton templates for drag-and-drop placement.
class ComponentPalette extends StatelessWidget {
  const ComponentPalette({
    super.key,
    required this.onSelectTemplate,
    required this.onClose,
    this.controller,
  });

  /// Callback when a template is selected or dropped.
  final ValueChanged<SkeletonTemplate> onSelectTemplate;

  /// Callback to dismiss the palette.
  final VoidCallback onClose;

  /// Optional controller; defaults to closest [AgentationScope].
  final AgentationController? controller;

  @override
  Widget build(BuildContext context) {
    final effectiveController =
        controller ?? AgentationScope.of(context);

    return ListenableBuilder(
      listenable: effectiveController,
      builder: (context, _) {
        final settings = effectiveController.settings;
        final isDark = settings.isDarkMode;
        final activeColor = MarkerColor.findById(settings.markerColorId).color;

        final bg = isDark ? const Color(0xF2181825) : const Color(0xF7FFFFFF);
        final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
        final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        final borderColor = isDark ? const Color(0x33FFFFFF) : const Color(0x1F000000);

        return Material(
          color: Colors.transparent,
          child: Container(
            width: 320.0,
            constraints: const BoxConstraints(maxHeight: 480.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: borderColor, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: isDark ? const Color(0x7F000000) : const Color(0x26000000),
                  blurRadius: 24.0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.dashboard_customize_outlined, size: 18.0, color: activeColor),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              'Component Palette',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 18.0, color: subtextColor),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: onClose,
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),

                // Template items list
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: SkeletonTemplate.defaultTemplates.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8.0),
                    itemBuilder: (context, index) {
                      final template = SkeletonTemplate.defaultTemplates[index];
                      return _buildTemplateTile(
                        context,
                        template: template,
                        isDark: isDark,
                        activeColor: activeColor,
                        textColor: textColor,
                        subtextColor: subtextColor,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTemplateTile(
    BuildContext context, {
    required SkeletonTemplate template,
    required bool isDark,
    required Color activeColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    return Draggable<SkeletonTemplate>(
      data: template,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: template.defaultWidth,
          height: template.defaultHeight,
          decoration: BoxDecoration(
            color: activeColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: activeColor, width: 2.0),
          ),
          child: Center(
            child: Text(
              template.label,
              style: TextStyle(
                color: activeColor,
                fontWeight: FontWeight.bold,
                fontSize: 12.0,
              ),
            ),
          ),
        ),
      ),
      child: InkWell(
        onTap: () => onSelectTemplate(template),
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0x1AFFFFFF) : const Color(0x0A000000),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: isDark ? const Color(0x1FFFFFFF) : const Color(0x0F000000),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32.0,
                height: 32.0,
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(template.icon, size: 16.0, color: activeColor),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.label,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      template.description,
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 10.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x26000000) : const Color(0x14000000),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  '${template.defaultWidth.round()}×${template.defaultHeight.round()}',
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: 9.5,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
