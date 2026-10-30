import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/annotation.dart';
import '../../domain/placement_data.dart';
import '../../theme/agentation_theme.dart';
import '../design/realistic_skeleton_preview.dart';

/// Interactive visual preview widget that renders the exact look of a placed wireframe component
/// (Avatar, Button, Image, Input, Text, Switch, Slider, Card, ListTile, etc.) based on the user-configured details.
class PlacedComponentPreview extends StatefulWidget {
  const PlacedComponentPreview({
    super.key,
    required this.annotation,
    required this.index,
    required this.isDark,
    required this.accentColor,
    this.isSelected = false,
    this.isHovered = false,
    this.onTap,
    this.onHoverChanged,
  });

  /// The placement annotation containing PlacementData and properties.
  final Annotation annotation;

  /// 1-based sequential index number.
  final int index;

  /// Dark mode flag.
  final bool isDark;

  /// Theme accent color.
  final Color accentColor;

  /// Selection state.
  final bool isSelected;

  /// Hover state.
  final bool isHovered;

  /// Tap callback.
  final VoidCallback? onTap;

  /// Hover changed callback.
  final ValueChanged<bool>? onHoverChanged;

  @override
  State<PlacedComponentPreview> createState() => _PlacedComponentPreviewState();
}

class _PlacedComponentPreviewState extends State<PlacedComponentPreview> {
  final ValueNotifier<bool> _localHover = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _localHover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final placement = widget.annotation.placement;
    if (placement == null) return const SizedBox.shrink();

    final theme = AgentationThemeData.resolve(isDark: widget.isDark);
    final accent = widget.accentColor;

    return MouseRegion(
      onEnter: (_) {
        _localHover.value = true;
        widget.onHoverChanged?.call(true);
      },
      onExit: (_) {
        _localHover.value = false;
        widget.onHoverChanged?.call(false);
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: ValueListenableBuilder<bool>(
          valueListenable: _localHover,
          builder: (context, localHover, _) {
            final isEffectiveHover = widget.isHovered || localHover;
            return Opacity(
              opacity: 0.80,
              child: Material(
                type: MaterialType.transparency,
                child: DefaultTextStyle.merge(
                  style: const TextStyle(decoration: TextDecoration.none),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? accent.withValues(alpha: 0.08)
                          : (isEffectiveHover ? accent.withValues(alpha: 0.04) : Colors.transparent),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: widget.isSelected
                            ? accent
                            : (isEffectiveHover ? accent.withValues(alpha: 0.7) : Colors.transparent),
                        width: widget.isSelected ? 1.6 : 1.0,
                      ),
                      boxShadow: widget.isSelected
                          ? [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.25),
                                blurRadius: 8.0,
                                spreadRadius: 1.0,
                              ),
                            ]
                          : (isEffectiveHover
                              ? [
                                  BoxShadow(
                                    color: accent.withValues(alpha: 0.15),
                                    blurRadius: 5.0,
                                  ),
                                ]
                              : null),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      clipBehavior: Clip.none,
                      children: [
                    // Exact rendered component look based on user configuration
                    _buildComponentVisual(placement, theme, accent),

                    // Small component type label tag on top edge when hovered or selected
                    if (isEffectiveHover || widget.isSelected)
                      Positioned(
                        right: 4.0,
                        top: -9.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(4.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 3.0,
                              ),
                            ],
                          ),
                          child: Text(
                            placement.label ?? placement.componentType,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.0,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.none,
                            ),
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
    ),
  ),
);
  }

  Widget _buildComponentVisual(PlacementData placement, AgentationThemeData theme, Color accent) {
    switch (placement.componentType) {
      case 'Avatar':
      case 'UserAvatar':
        return _buildAvatar(placement, theme, accent);

      case 'Button':
      case 'ElevatedButton':
      case 'FilledButton':
      case 'OutlinedButton':
      case 'TextButton':
      case 'FAB':
        return _buildButton(placement, theme, accent);

      case 'Image':
      case 'ImagePreview':
        return _buildImage(placement, theme, accent);

      case 'Input':
      case 'TextField':
      case 'SearchBar':
      case 'PasswordField':
        return _buildInput(placement, theme, accent);

      case 'Text':
      case 'Heading':
      case 'Title':
        return _buildText(placement, theme, accent);

      case 'Switch':
      case 'SwitchListTile':
      case 'Checkbox':
      case 'CheckboxListTile':
      case 'Radio':
      case 'RadioListTile':
        return _buildSwitch(placement, theme, accent);

      case 'Slider':
        return _buildSlider(placement, theme, accent);

      case 'Card':
      case 'Container':
        return _buildCard(placement, theme, accent);

      case 'ListTile':
        return _buildListTile(placement, theme, accent);

      case 'Chip':
      case 'Badge':
        return _buildChip(placement, theme, accent);

      case 'Icon':
      case 'IconButton':
        return _buildIconButton(placement, theme, accent);

      case 'Divider':
        return _buildDivider(placement, theme, accent);

      case 'ErrorState':
      case 'EmptyState':
      case 'Pricing':
      case 'Product Card':
      case 'ProductCard':
      case 'Testimonial':
      case 'Form':
      case 'Profile':
      case 'FileUploader':
      case 'Breadcrumbs':
      case 'Pagination':
      case 'AlertDialog':
      case 'ModalDialog':
      case 'TimelineFeed':
      case 'Timeline':
        return RealisticSkeletonPreview(
          placement: placement,
          accentColor: accent,
          isDark: widget.isDark,
        );

      default:
        return _buildGeneric(placement, theme, accent);
    }
  }

  Widget _buildAvatar(PlacementData placement, AgentationThemeData theme, Color accent) {
    final props = placement.properties;
    final isCircular = props['circular'] != false;
    final hasOnlineDot = props['onlineDot'] == true;
    final source = (placement.source ?? placement.text ?? '').trim();

    double size = 48.0;
    final sizeOpt = props['Size']?.toString() ?? props['size']?.toString();
    if (sizeOpt != null) {
      if (sizeOpt.contains('32')) size = 32.0;
      if (sizeOpt.contains('64')) size = 64.0;
    } else if (placement.height > 0) {
      size = math.min(placement.height, placement.width > 0 ? placement.width : placement.height);
    }

    Widget content;
    if (source.startsWith('http://') || source.startsWith('https://')) {
      content = Image.network(
        source,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildFallbackAvatarIcon(size, theme, accent),
      );
    } else if (source.startsWith('assets/')) {
      content = Image.asset(
        source,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildFallbackAvatarIcon(size, theme, accent),
      );
    } else if (source.isNotEmpty && source.length <= 4 && !source.contains('/')) {
      content = Center(
        child: Text(
          source,
          style: TextStyle(
            color: accent,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.38,
          ),
        ),
      );
    } else {
      content = _buildFallbackAvatarIcon(size, theme, accent);
    }

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: isCircular ? null : BorderRadius.circular(10.0),
                color: widget.isDark ? const Color(0xFF232530) : const Color(0xFFE2E8F0),
                border: Border.all(
                  color: widget.isSelected ? accent : (widget.isDark ? Colors.white24 : Colors.black12),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: content,
            ),
            if (hasOnlineDot)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: size * 0.28,
                  height: size * 0.28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.isDark ? const Color(0xFF1E1F2B) : Colors.white,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackAvatarIcon(double size, AgentationThemeData theme, Color accent) {
    return Center(
      child: Icon(
        Icons.person,
        size: size * 0.55,
        color: accent.withValues(alpha: 0.8),
      ),
    );
  }

  Widget _buildButton(PlacementData placement, AgentationThemeData theme, Color accent) {
    final props = placement.properties;
    final label = (placement.text ?? placement.label ?? 'Button').trim();
    final variant = (placement.variant ?? props['Variant']?.toString() ?? '').toLowerCase();
    final hasIcon = props['hasIcon'] == true || variant.contains('icon');
    final isLoading = props['isLoading'] == true;
    final isOutlined = variant.contains('outlined');
    final isTextBtn = variant.contains('text') && !variant.contains('icon');

    final isFab = placement.componentType == 'FAB';
    if (isFab) {
      return Center(
        child: Container(
          width: 48.0,
          height: 48.0,
          decoration: BoxDecoration(
            color: accent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.35),
                blurRadius: 8.0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 24.0),
        ),
      );
    }

    Color bg;
    Color fg;
    Border? border;

    if (isOutlined) {
      bg = widget.isDark ? accent.withValues(alpha: 0.1) : accent.withValues(alpha: 0.06);
      fg = accent;
      border = Border.all(color: accent, width: 1.2);
    } else if (isTextBtn) {
      bg = Colors.transparent;
      fg = accent;
    } else {
      bg = accent;
      fg = Colors.white;
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8.0),
          border: border,
          boxShadow: (!isOutlined && !isTextBtn)
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.25),
                    blurRadius: 6.0,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              SizedBox(
                width: 13.0,
                height: 13.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation(fg),
                ),
              ),
              const SizedBox(width: 6.0),
            ] else if (hasIcon) ...[
              Icon(Icons.arrow_forward_rounded, size: 14.0, color: fg),
              const SizedBox(width: 6.0),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(PlacementData placement, AgentationThemeData theme, Color accent) {
    final props = placement.properties;
    final isRounded = props['rounded'] != false;
    final source = (placement.source ?? placement.text ?? '').trim();
    final borderRadius = isRounded ? BorderRadius.circular(10.0) : BorderRadius.zero;

    Widget content;
    if (source.startsWith('http://') || source.startsWith('https://')) {
      content = Image.network(
        source,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildFallbackImageBox(source, theme, accent),
      );
    } else if (source.startsWith('assets/')) {
      content = Image.asset(
        source,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildFallbackImageBox(source, theme, accent),
      );
    } else {
      content = _buildFallbackImageBox(source, theme, accent);
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: content,
    );
  }

  Widget _buildFallbackImageBox(String source, AgentationThemeData theme, Color accent) {
    return Container(
      color: widget.isDark ? const Color(0xFF1E202B) : const Color(0xFFE2E8F0),
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_outlined, size: 28.0, color: accent.withValues(alpha: 0.8)),
            const SizedBox(height: 4.0),
            Text(
              source.isNotEmpty ? source : 'Image Preview',
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 10.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(PlacementData placement, AgentationThemeData theme, Color accent) {
    final props = placement.properties;
    final hint = (placement.text ?? 'Enter text...').trim();
    final isSearch = props['leadingSearch'] == true || placement.componentType.toLowerCase().contains('search');
    final isPassword = props['obscureEye'] == true || placement.componentType.toLowerCase().contains('password');
    final isClearable = props['clearable'] == true;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: theme.inputBackground,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: widget.isSelected ? accent : theme.borderTranslucentColor,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            if (isSearch) ...[
              Icon(Icons.search, size: 16.0, color: theme.textSecondary),
              const SizedBox(width: 6.0),
            ],
            Expanded(
              child: Text(
                hint,
                style: TextStyle(
                  color: theme.textMuted,
                  fontSize: 12.0,
                  fontWeight: FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isPassword)
              Icon(Icons.visibility_off_outlined, size: 15.0, color: theme.textMuted)
            else if (isClearable)
              Icon(Icons.clear, size: 14.0, color: theme.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildText(PlacementData placement, AgentationThemeData theme, Color accent) {
    final props = placement.properties;
    final content = (placement.text ?? 'Text Block').trim();
    final variant = (placement.variant ?? props['Typography Hierarchy']?.toString() ?? '').toLowerCase();
    final alignmentStr = (props['Alignment']?.toString() ?? '').toLowerCase();

    TextAlign align = TextAlign.left;
    if (alignmentStr.contains('center')) align = TextAlign.center;
    if (alignmentStr.contains('right')) align = TextAlign.right;

    double fontSize = 13.0;
    FontWeight fontWeight = FontWeight.normal;
    Color textColor = theme.textPrimary;

    if (variant.contains('h1') || variant.contains('headline')) {
      fontSize = 20.0;
      fontWeight = FontWeight.bold;
    } else if (variant.contains('h2') || variant.contains('title')) {
      fontSize = 16.0;
      fontWeight = FontWeight.w600;
    } else if (variant.contains('caption') || variant.contains('muted')) {
      fontSize = 11.0;
      textColor = theme.textSecondary;
    }

    return Container(
      alignment: align == TextAlign.center
          ? Alignment.center
          : (align == TextAlign.right ? Alignment.centerRight : Alignment.centerLeft),
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      child: Text(
        content,
        textAlign: align,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSwitch(PlacementData placement, AgentationThemeData theme, Color accent) {
    final props = placement.properties;
    final isChecked = props['checked'] != false;
    final isCheckbox = placement.componentType.toLowerCase().contains('checkbox');
    final isRadio = placement.componentType.toLowerCase().contains('radio');
    final isListTile = placement.componentType.toLowerCase().contains('listtile') ||
        placement.width >= 120.0;

    if (!isListTile && !isCheckbox && !isRadio) {
      // Standalone Switch (52×32) - clean realistic Flutter Switch toggle, NO outer dark box, NO overflow!
      return Center(
        child: Container(
          width: 48.0,
          height: 28.0,
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            color: isChecked ? accent : (widget.isDark ? Colors.white24 : Colors.black26),
            borderRadius: BorderRadius.circular(14.0),
            boxShadow: [
              BoxShadow(
                color: (isChecked ? accent : Colors.black).withValues(alpha: 0.25),
                blurRadius: 4.0,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Align(
            alignment: isChecked ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 23.0,
              height: 23.0,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 3.0,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (isCheckbox && !isListTile) {
      return Center(
        child: Container(
          width: 22.0,
          height: 22.0,
          decoration: BoxDecoration(
            color: isChecked ? accent : Colors.transparent,
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(
              color: isChecked ? accent : (widget.isDark ? Colors.white54 : Colors.black54),
              width: 2.0,
            ),
          ),
          child: isChecked
              ? const Icon(Icons.check, size: 16.0, color: Colors.white)
              : null,
        ),
      );
    }

    if (isRadio && !isListTile) {
      return Center(
        child: Container(
          width: 22.0,
          height: 22.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isChecked ? accent : (widget.isDark ? Colors.white54 : Colors.black54),
              width: 2.0,
            ),
          ),
          child: isChecked
              ? Center(
                  child: Container(
                    width: 12.0,
                    height: 12.0,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              : null,
        ),
      );
    }

    final label = (placement.text ?? 'Setting Option').trim();

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: theme.cardBackground,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: widget.isSelected ? accent : theme.borderTranslucentColor,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 12.0,
                  fontWeight: FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8.0),
            if (isCheckbox)
              Icon(
                isChecked ? Icons.check_box : Icons.check_box_outline_blank,
                size: 20.0,
                color: isChecked ? accent : theme.textSecondary,
              )
            else if (isRadio)
              Icon(
                isChecked ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 20.0,
                color: isChecked ? accent : theme.textSecondary,
              )
            else
              Container(
                width: 38.0,
                height: 22.0,
                padding: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  color: isChecked ? accent : (widget.isDark ? Colors.white24 : Colors.black26),
                  borderRadius: BorderRadius.circular(11.0),
                ),
                child: Align(
                  alignment: isChecked ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 18.0,
                    height: 18.0,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(PlacementData placement, AgentationThemeData theme, Color accent) {
    final props = placement.properties;
    final val = (props['sliderValue'] as num?)?.toDouble() ?? 50.0;
    final label = (placement.text ?? 'Slider').trim();

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: theme.inputBackground,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: widget.isSelected ? accent : theme.borderTranslucentColor,
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${val.round()}%',
                  style: TextStyle(
                    color: accent,
                    fontSize: 11.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            ClipRRect(
              borderRadius: BorderRadius.circular(2.0),
              child: LinearProgressIndicator(
                value: (val / 100.0).clamp(0.0, 1.0),
                backgroundColor: widget.isDark ? Colors.white12 : Colors.black12,
                valueColor: AlwaysStoppedAnimation(accent),
                minHeight: 4.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(PlacementData placement, AgentationThemeData theme, Color accent) {
    final title = (placement.text ?? 'Card Container').trim();

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: widget.isSelected ? accent : theme.borderTranslucentColor,
          width: 1.0,
        ),
        boxShadow: theme.cardShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.dashboard_customize_outlined, size: 14.0, color: accent),
              const SizedBox(width: 6.0),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            height: 6.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(3.0),
            ),
          ),
          const SizedBox(height: 5.0),
          Container(
            height: 6.0,
            width: 80.0,
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(3.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(PlacementData placement, AgentationThemeData theme, Color accent) {
    final title = (placement.text ?? 'List Item Title').trim();

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: theme.cardBackground,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: widget.isSelected ? accent : theme.borderTranslucentColor,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28.0,
              height: 28.0,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Icon(Icons.list_alt, size: 16.0, color: accent),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right, size: 16.0, color: theme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(PlacementData placement, AgentationThemeData theme, Color accent) {
    final label = (placement.text ?? 'Badge').trim();

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: accent.withValues(alpha: 0.5), width: 1.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: accent,
            fontSize: 11.0,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildIconButton(PlacementData placement, AgentationThemeData theme, Color accent) {
    return Center(
      child: Container(
        width: 36.0,
        height: 36.0,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.0),
        ),
        child: Icon(Icons.touch_app, size: 18.0, color: accent),
      ),
    );
  }

  Widget _buildDivider(PlacementData placement, AgentationThemeData theme, Color accent) {
    return Center(
      child: Container(
        height: 1.5,
        color: accent.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _buildGeneric(PlacementData placement, AgentationThemeData theme, Color accent) {
    final label = (placement.text ?? placement.label ?? placement.componentType).trim();

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: widget.isSelected ? accent : theme.borderTranslucentColor,
          width: 1.0,
        ),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.widgets_outlined, size: 14.0, color: accent),
            const SizedBox(width: 6.0),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
