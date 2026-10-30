import 'package:flutter/material.dart';

import '../../theme/agentation_colors.dart';
import '../../theme/agentation_radii.dart';
import '../../theme/agentation_typography.dart';
import 'agentation_icons.dart';

/// Centralized tooltip component for Flutter Agentation.
///
/// Supports both floating careted action tooltips (e.g. for toolbar buttons with shortcuts)
/// and dark rounded help bubbles (e.g. for settings and panel options).
class AgentationTooltip extends StatefulWidget {
  const AgentationTooltip({
    super.key,
    required this.message,
    this.shortcut,
    required this.child,
    this.targetAnchor = Alignment.topCenter,
    this.followerAnchor = Alignment.bottomCenter,
    this.offset = const Offset(0, -6),
    this.width,
    this.showCaret = true,
    this.tapToToggle = false,
  });

  /// Help popup tooltip matching upstream Agentation style with dark rounded bubble anchored to the side.
  const AgentationTooltip.help({
    Key? key,
    required String content,
    Widget? child,
  }) : this(
         key: key,
         message: content,
         child: child ?? const _DefaultHelpIcon(),
         targetAnchor: Alignment.centerLeft,
         followerAnchor: Alignment.centerRight,
         offset: const Offset(-8.0, 0.0),
         width: 175.0,
         showCaret: false,
         tapToToggle: true,
       );

  /// Action label or help message.
  final String message;

  /// Optional keyboard shortcut key (e.g. "P", "L", "I", "C").
  final String? shortcut;

  /// Target widget that triggers the tooltip.
  final Widget child;

  /// Target anchor on the child.
  final Alignment targetAnchor;

  /// Follower anchor on the tooltip overlay.
  final Alignment followerAnchor;

  /// Relative offset for the overlay.
  final Offset offset;

  /// Optional fixed width for the tooltip container.
  final double? width;

  /// Whether to render a pointing caret triangle.
  final bool showCaret;

  /// Whether clicking / tapping toggles the tooltip display.
  final bool tapToToggle;

  @override
  State<AgentationTooltip> createState() => _AgentationTooltipState();
}

class _AgentationTooltipState extends State<AgentationTooltip> {
  final OverlayPortalController _portalController = OverlayPortalController();
  final LayerLink _layerLink = LayerLink();

  void _showTooltip() {
    if (!_portalController.isShowing) {
      _portalController.show();
    }
  }

  void _hideTooltip() {
    if (_portalController.isShowing) {
      _portalController.hide();
    }
  }

  void _toggleTooltip() {
    if (_portalController.isShowing) {
      _portalController.hide();
    } else {
      _portalController.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: OverlayPortal(
        controller: _portalController,
        overlayChildBuilder: (context) {
          return CompositedTransformFollower(
            link: _layerLink,
            targetAnchor: widget.targetAnchor,
            followerAnchor: widget.followerAnchor,
            offset: widget.offset,
            child: Align(
              alignment: widget.followerAnchor,
              child: widget.showCaret ? _buildCaretTooltip() : _buildBubbleTooltip(),
            ),
          );
        },
        child: MouseRegion(
          cursor: widget.tapToToggle ? SystemMouseCursors.click : SystemMouseCursors.basic,
          onEnter: (_) => _showTooltip(),
          onExit: (_) => _hideTooltip(),
          child: GestureDetector(
            onTap: widget.tapToToggle ? _toggleTooltip : null,
            behavior: HitTestBehavior.opaque,
            child: widget.child,
          ),
        ),
      ),
    );
  }

  Widget _buildBubbleTooltip() {
    return Container(
      width: widget.width ?? 175.0,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
      decoration: BoxDecoration(
        color: AgentationColors.darkHelpTooltipBg,
        borderRadius: AgentationRadii.br10,
        boxShadow: const [
          BoxShadow(
            color: AgentationColors.shadowHelp,
            blurRadius: 8.0,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Text(
          widget.message,
          style: AgentationTypography.helpTooltip.copyWith(
            color: AgentationColors.darkTextTranslucent,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Widget _buildCaretTooltip() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 6.0,
          ),
          decoration: BoxDecoration(
            color: AgentationColors.darkTooltipBg,
            borderRadius: AgentationRadii.br8,
            boxShadow: const [
              BoxShadow(
                color: AgentationColors.shadowDark,
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
                style: AgentationTypography.tooltipMessage.copyWith(
                  color: Colors.white,
                ),
              ),
              if (widget.shortcut != null) ...[
                const SizedBox(width: 6.0),
                Text(
                  widget.shortcut!,
                  style: AgentationTypography.tooltipShortcut.copyWith(
                    color: AgentationColors.lightTextGray,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ],
          ),
        ),
        CustomPaint(
          size: const Size(10, 5),
          painter: _CaretPainter(color: AgentationColors.darkTooltipBg),
        ),
      ],
    );
  }
}

class _DefaultHelpIcon extends StatelessWidget {
  const _DefaultHelpIcon();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: AgentationIcons.help(
        size: 13.0,
        color: AgentationColors.darkTextMuted,
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
