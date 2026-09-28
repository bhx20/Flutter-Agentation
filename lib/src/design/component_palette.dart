import 'package:flutter/material.dart';
import '../core/agentation_controller.dart';
import '../core/agentation_scope.dart';
import '../models/marker_color.dart';
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

        final cardBg = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);
        final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
        final subtextColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6E6E73);
        final borderColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);

        final elements = SkeletonTemplate.defaultTemplates
            .where((t) => t.category == 'Elements')
            .toList();
        final blocks = SkeletonTemplate.defaultTemplates
            .where((t) => t.category == 'Blocks')
            .toList();

        return Material(
          color: Colors.transparent,
          child: Container(
            width: 290.0,
            constraints: const BoxConstraints(maxHeight: 460.0),
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: borderColor, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: isDark ? const Color(0x66000000) : const Color(0x1F000000),
                  blurRadius: 20.0,
                  offset: const Offset(0, 6),
                ),
              ],
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
                            fontSize: 15.0,
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
                      icon: Icon(Icons.close, size: 16.0, color: subtextColor),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),

                // ── Subtitle Description ──
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: subtextColor,
                      fontSize: 11.5,
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
                          color: Color(0xFF007AFF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12.0),

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
                              ? const Color(0xFFFF9500)
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
                                    color: isWireframeActive ? const Color(0xFFFF9500) : subtextColor,
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    'Wireframe New Page',
                                    style: TextStyle(
                                      color: isWireframeActive
                                          ? const Color(0xFFFF9500)
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: isHovered ? const Color(0x1AFFFFFF) : Colors.transparent,
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Row(
        children: [
          Icon(
            item.icon,
            size: 16.0,
            color: isHovered ? Colors.white : subtextColor,
          ),
          const SizedBox(width: 10.0),
          Text(
            item.label,
            style: TextStyle(
              color: isHovered ? Colors.white : textColor,
              fontSize: 12.5,
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
