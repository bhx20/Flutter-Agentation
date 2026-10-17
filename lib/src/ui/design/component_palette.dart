import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/agentation_controller.dart';
import '../../core/agentation_scope.dart';
import '../../domain/marker_color.dart';
import '../../theme/agentation_colors.dart';
import '../../theme/agentation_theme.dart';
import '../toolbar/agentation_icons.dart';
import 'skeleton_templates.dart';

/// Layout Mode component palette matching Screenshot 4 of the Agentation design system.
class ComponentPalette extends StatefulWidget {
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
  State<ComponentPalette> createState() => _ComponentPaletteState();
}

class _ComponentPaletteState extends State<ComponentPalette> {
  final ValueNotifier<String?> _hoveredTypeNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<bool> _isWireframeActiveNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _hoveredTypeNotifier.dispose();
    _isWireframeActiveNotifier.dispose();
    super.dispose();
  }

  AgentationController get _ctrl =>
      widget.controller ?? AgentationScope.of(context);

  @override
  Widget build(BuildContext context) {
    final controller = _ctrl;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final settings = controller.settings;
        final isDark = settings.isDarkMode;
        final activeColor = MarkerColor.findById(settings.markerColorId).color;
        final theme = AgentationThemeData.resolve(isDark: isDark);

        final cardBg = theme.panelBackground;
        final textColor = theme.textPrimary;
        final subtextColor = theme.textSecondary;
        final borderColor = theme.panelBorderColor;

        final screenSize = MediaQuery.sizeOf(context);
        final isMobile = screenSize.width < 600.0;

        final cardWidth = isMobile ? math.min(268.0, screenSize.width - 24.0) : 290.0;
        final cardMaxHeight = isMobile ? math.min(340.0, screenSize.height - 140.0) : 460.0;

        final elements = SkeletonTemplate.defaultTemplates
            .where((t) => t.category == 'Elements')
            .toList();
        final blocks = SkeletonTemplate.defaultTemplates
            .where((t) => t.category == 'Blocks')
            .toList();

        return Material(
          color: Colors.transparent,
          child: Container(
            width: cardWidth,
            constraints: BoxConstraints(maxHeight: cardMaxHeight),
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12.0 : 14.0, vertical: isMobile ? 10.0 : 14.0),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: borderColor, width: 1.0),
              boxShadow: theme.panelShadows,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header: Layout Mode (Screenshot 4) ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Layout Mode',
                          style: TextStyle(
                            color: textColor,
                            fontSize: isMobile ? 14.0 : 15.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Opacity(
                          opacity: 0.0,
                          child: SizedBox(
                            width: 0,
                            height: 0,
                            child: Text('Component Palette', style: TextStyle(fontSize: 1, color: textColor)),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: isMobile ? 15.0 : 16.0, color: subtextColor),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 2.0 : 4.0),

                // ── Subtitle Description ──
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: subtextColor,
                      fontSize: isMobile ? 10.5 : 11.5,
                      height: 1.35,
                    ),
                    children: const [
                      TextSpan(
                        text:
                            'Rearrange and resize existing elements, add new components, and explore layout ideas. Agent results may vary. ',
                      ),
                      TextSpan(
                        text: 'Learn more.',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          decorationStyle: TextDecorationStyle.solid,
                          color: AgentationColors.platformBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 8.0 : 12.0),

                // ── Wireframe New Page Button (Dashed) ──
                ValueListenableBuilder<bool>(
                  valueListenable: _isWireframeActiveNotifier,
                  builder: (context, isWireframeActive, _) {
                    return InkWell(
                      onTap: () {
                        _isWireframeActiveNotifier.value = !_isWireframeActiveNotifier.value;
                      },
                      borderRadius: BorderRadius.circular(8.0),
                      child: CustomPaint(
                        painter: _DashedBorderPainter(
                          color: isWireframeActive
                              ? AgentationColors.warning
                              : (isDark ? const Color(0x33FFFFFF) : const Color(0x33000000)),
                          radius: 8.0,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                          child: Center(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AgentationIcons.wireframe(
                                    size: 15.0,
                                    color: isWireframeActive ? AgentationColors.warning : subtextColor,
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    'Wireframe New Page',
                                    style: TextStyle(
                                      color: isWireframeActive
                                          ? AgentationColors.warning
                                          : (isDark ? Colors.white70 : Colors.black87),
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10.0),

                // ── Scrollable Items (Elements & Blocks) ──
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Elements list
                        for (final item in elements)
                          _buildDraggableItem(item, isDark, textColor, subtextColor, activeColor),

                        const SizedBox(height: 10.0),

                        // Section header: Blocks
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                          child: Text(
                            'Blocks',
                            style: TextStyle(
                              color: subtextColor,
                              fontSize: 11.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2.0),

                        // Blocks list
                        for (final item in blocks)
                          _buildDraggableItem(item, isDark, textColor, subtextColor, activeColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDraggableItem(
    SkeletonTemplate item,
    bool isDark,
    Color textColor,
    Color subtextColor,
    Color activeColor,
  ) {
    return ValueListenableBuilder<String?>(
      valueListenable: _hoveredTypeNotifier,
      builder: (context, hoveredType, _) {
        final isHovered = hoveredType == item.componentType;

        return MouseRegion(
          onEnter: (_) => _hoveredTypeNotifier.value = item.componentType,
          onExit: (_) => _hoveredTypeNotifier.value = null,
          child: Draggable<SkeletonTemplate>(
        data: item,
        feedback: Material(
          color: Colors.transparent,
          child: Container(
            width: item.defaultWidth,
            height: item.defaultHeight,
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: activeColor, width: 2.0),
            ),
            child: Center(
              child: Text(
                item.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.4,
          child: _buildItemRow(item, textColor, subtextColor, false),
        ),
        child: InkWell(
          onTap: () {
            widget.onSelectTemplate(item);
          },
          borderRadius: BorderRadius.circular(8.0),
          child: _buildItemRow(item, textColor, subtextColor, isHovered),
        ),
      ),
    );
      },
    );
  }

  Widget _buildItemRow(
    SkeletonTemplate item,
    Color textColor,
    Color subtextColor,
    bool isHovered,
  ) {
    final isMobile = MediaQuery.sizeOf(context).width < 600.0;
    return Container(
      margin: EdgeInsets.symmetric(vertical: isMobile ? 0.5 : 1.5),
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: isMobile ? 4.0 : 6.0),
      decoration: BoxDecoration(
        color: isHovered ? AgentationColors.darkHoverBg : Colors.transparent,
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Row(
        children: [
          Icon(
            item.icon,
            size: isMobile ? 14.5 : 16.0,
            color: isHovered ? Colors.white : subtextColor,
          ),
          const SizedBox(width: 8.0),
          Text(
            item.label,
            style: TextStyle(
              color: isHovered ? Colors.white : textColor,
              fontSize: isMobile ? 11.5 : 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    // Approximate dashed path
    final dashLength = 4.0;
    final dashGap = 3.0;
    final pathMetrics = path.computeMetrics();

    for (final metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final end = distance + dashLength;
        final extract = metric.extractPath(distance, end < metric.length ? end : metric.length);
        canvas.drawPath(extract, paint);
        distance += dashLength + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

