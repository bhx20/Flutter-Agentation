import 'package:flutter/material.dart';

/// Sleek floating tooltip with a downward pointing caret and shortcut badge,
/// matching Screenshot 2 of the Agentation design system.
class AgentationTooltip extends StatefulWidget {
  const AgentationTooltip({
    super.key,
    required this.message,
    this.shortcut,
    required this.child,
  });

  /// Action label (e.g. "Pause animations").
  final String message;

  /// Optional keyboard shortcut key (e.g. "P", "L", "I", "C").
  final String? shortcut;

  /// Target button widget.
  final Widget child;

  @override
  State<AgentationTooltip> createState() => _AgentationTooltipState();
}

class _AgentationTooltipState extends State<AgentationTooltip> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _showTooltip() {
    _hideTooltip();
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 0,
        height: 0,
        child: CompositedTransformFollower(
          link: _layerLink,
          targetAnchor: Alignment.topCenter,
          followerAnchor: Alignment.bottomCenter,
          offset: const Offset(0, -6),
          child: IgnorePointer(
            child: OverflowBox(
              maxWidth: 240,
              maxHeight: 60,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF18181B),
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x66000000),
                          blurRadius: 8.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        if (widget.shortcut != null) ...[
                          const SizedBox(width: 6.0),
                          Text(
                            widget.shortcut!,
                            style: const TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  CustomPaint(
                    size: const Size(10, 5),
                    painter: _CaretPainter(color: const Color(0xFF18181B)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hideTooltip();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.message,
      triggerMode: TooltipTriggerMode.manual,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: MouseRegion(
          onEnter: (_) => _showTooltip(),
          onExit: (_) => _hideTooltip(),
          child: widget.child,
        ),
      ),
    );
  }
}

class _CaretPainter extends CustomPainter {
  const _CaretPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CaretPainter oldDelegate) => oldDelegate.color != color;
}
