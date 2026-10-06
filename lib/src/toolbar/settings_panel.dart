import 'package:flutter/material.dart';
import '../core/agentation_controller.dart';
import '../core/agentation_scope.dart';
import '../core/package_version.dart';
import '../models/marker_color.dart';
import '../models/toolbar_settings.dart';
import 'agentation_icons.dart';

/// Settings panel matching the official Agentation design system without MCP.
class SettingsPanel extends StatefulWidget {
  const SettingsPanel({
    super.key,
    required this.onClose,
    this.controller,
  });

  final VoidCallback onClose;
  final AgentationController? controller;

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  AgentationController get _ctrl =>
      widget.controller ?? AgentationScope.of(context);

  @override
  void initState() {
    super.initState();
    PackageVersion.loadFromYaml().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = _ctrl;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final settings = controller.settings;
        final isDark = settings.isDarkMode;

        final cardBg = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);
        final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
        final subtextColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93);
        final borderColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);
        final dividerColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFEFEFF4);

        return Material(
          color: Colors.transparent,
          child: Container(
            width: 253.0,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: borderColor, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: isDark ? const Color(0x66000000) : const Color(0x14000000),
                  blurRadius: 20.0,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: isDark ? const Color(0x33000000) : const Color(0x0A000000),
                  blurRadius: 6.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header: Agentation v0.0.1 + Moon/Sun Theme Toggle ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  'Agentation',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 5.0),
                                Text(
                                  'v${PackageVersion.current}',
                                  style: TextStyle(
                                    color: subtextColor,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          key: const ValueKey('theme_toggle_button'),
                          onTap: controller.toggleTheme,
                          borderRadius: BorderRadius.circular(14.0),
                          child: SizedBox(
                            width: 28.0,
                            height: 28.0,
                            child: Center(
                              child: isDark
                                  ? AgentationIcons.sun(size: 16.0, color: subtextColor)
                                  : AgentationIcons.moon(size: 16.0, color: subtextColor),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10.0),
                    Divider(height: 1.0, thickness: 1.0, color: dividerColor),
                    const SizedBox(height: 12.0),

                    // ── Row 1: Output Detail ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  'Output Detail',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4.0),
                              const _HelpTooltip(
                                content: 'Controls how much detail is included in the copied output',
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: controller.cycleDetailLevel,
                          borderRadius: BorderRadius.circular(4.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getDetailLabel(settings.outputDetail),
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 2.0),
                                Icon(
                                  Icons.more_vert,
                                  size: 14.0,
                                  color: subtextColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10.0),

                    // ── Row 2: Hide Until Restart ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  'Hide Until Restart',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4.0),
                              const _HelpTooltip(
                                content: 'Hides the toolbar until restart',
                              ),
                            ],
                          ),
                        ),
                        _AgentationSwitch(
                          value: settings.hideUntilRestart,
                          isDark: isDark,
                          onChanged: (val) {
                            controller.updateSettings(
                              settings.copyWith(hideUntilRestart: val),
                            );
                            if (val) {
                              controller.toggleToolbarMinimized();
                              widget.onClose();
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 12.0),
                    Divider(height: 1.0, thickness: 1.0, color: dividerColor),
                    const SizedBox(height: 10.0),

                    // ── Marker Color ──
                    Text(
                      'Marker Color',
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8.0),

                    // ── 7 Swatches with Concentric Ring Selection ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: MarkerColor.values.map((swatch) {
                        final isSelected = settings.markerColorId == swatch.id;
                        return Tooltip(
                          message: swatch.label,
                          child: GestureDetector(
                            key: ValueKey('swatch_${swatch.id}'),
                            onTap: () => controller.setMarkerColorId(swatch.id),
                            behavior: HitTestBehavior.opaque,
                            child: SizedBox(
                              width: 24.0,
                              height: 24.0,
                              child: Center(
                                child: isSelected
                                    ? Container(
                                        width: 24.0,
                                        height: 24.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: swatch.color, width: 2.0),
                                        ),
                                        child: Center(
                                          child: Container(
                                            width: 14.0,
                                            height: 14.0,
                                            decoration: BoxDecoration(
                                              color: swatch.color,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: 20.0,
                                        height: 20.0,
                                        decoration: BoxDecoration(
                                          color: swatch.color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 12.0),
                    Divider(height: 1.0, thickness: 1.0, color: dividerColor),
                    const SizedBox(height: 10.0),

                    // ── Checkbox 1: Clear on copy/send ──
                    InkWell(
                      key: const ValueKey('toggle_auto_clear'),
                      onTap: () {
                        controller.updateSettings(
                          settings.copyWith(
                            autoClearAfterCopy: !settings.autoClearAfterCopy,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(4.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            _buildCustomCheckbox(
                              checked: settings.autoClearAfterCopy,
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Clear on copy/send',
                                      style: TextStyle(color: textColor, fontSize: 13.0),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4.0),
                                  const _HelpTooltip(
                                    content: 'Automatically clear annotations after copying',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 4.0),

                    // ── Checkbox 2: Block page interactions ──
                    InkWell(
                      key: const ValueKey('toggle_block_interactions'),
                      onTap: () {
                        controller.updateSettings(
                          settings.copyWith(
                            blockInteractions: !settings.blockInteractions,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(4.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            _buildCustomCheckbox(
                              checked: settings.blockInteractions,
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                'Block page interactions',
                                style: TextStyle(color: textColor, fontSize: 13.0),
                                overflow: TextOverflow.ellipsis,
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
          ),
        );
      },
    );
  }

  Widget _buildCustomCheckbox({required bool checked, required bool isDark}) {
    return Container(
      width: 16.0,
      height: 16.0,
      decoration: BoxDecoration(
        color: checked
            ? (isDark ? Colors.white : const Color(0xFF1C1C1E))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(4.5),
        border: Border.all(
          color: checked
              ? (isDark ? Colors.white : const Color(0xFF1C1C1E))
              : (isDark ? const Color(0xFF48484A) : const Color(0xFFD1D1D6)),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: checked
          ? Icon(
              Icons.check,
              size: 11.0,
              color: isDark ? Colors.black : Colors.white,
            )
          : null,
    );
  }

  String _getDetailLabel(OutputDetailLevel level) {
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
}

/// Help tooltip matching upstream Agentation style with dark rounded bubble anchored to the left.
class _HelpTooltip extends StatefulWidget {
  const _HelpTooltip({
    required this.content,
  });

  final String content;

  @override
  State<_HelpTooltip> createState() => _HelpTooltipState();
}

class _HelpTooltipState extends State<_HelpTooltip> {
  final _portalController = OverlayPortalController();
  final _layerLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    const iconColor = Color(0xFF8E8E93);

    return CompositedTransformTarget(
      link: _layerLink,
      child: OverlayPortal(
        controller: _portalController,
        overlayChildBuilder: (context) {
          return CompositedTransformFollower(
            link: _layerLink,
            targetAnchor: Alignment.centerLeft,
            followerAnchor: Alignment.centerRight,
            offset: const Offset(-8.0, 0.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 175.0,
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF383838),
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x47000000),
                      blurRadius: 8.0,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(
                    widget.content,
                    style: const TextStyle(
                      color: Color(0xD9FFFFFF),
                      fontSize: 11.0,
                      fontWeight: FontWeight.w400,
                      height: 1.35,
                      fontFamily: 'Inter',
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),
          );
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => _portalController.show(),
          onExit: (_) => _portalController.hide(),
          child: GestureDetector(
            onTap: () {
              if (_portalController.isShowing) {
                _portalController.hide();
              } else {
                _portalController.show();
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: AgentationIcons.help(size: 13.0, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact miniature toggle switch matching upstream Agentation (24px x 16px).
class _AgentationSwitch extends StatelessWidget {
  const _AgentationSwitch({
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    const trackWidth = 24.0;
    const trackHeight = 16.0;
    const thumbSize = 12.0;

    final trackColor = value
        ? const Color(0xFF007AFF)
        : (isDark ? const Color(0xFF484848) : const Color(0xFFCDCDCD));

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          width: trackWidth,
          height: trackHeight,
          padding: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Align(
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: thumbSize,
              height: thumbSize,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 2.0,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
