import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_radii.dart';

/// A universal, reusable hover & selection state wrapper widget.
///
/// Wraps any widget (e.g. sidebar navigation links, list items, cards, badges)
/// with smooth, theme-aligned color transitions and cursor feedback.
///
/// By default, [showBox] is `false`, ensuring pure color transitions (text and icons)
/// with zero background box or border. Set [showBox] to `true` if a full background
/// pill and border outline box is desired.
class HoverTile extends StatefulWidget {
  const HoverTile({
    super.key,
    required this.child,
    this.onTap,
    this.isSelected = false,
    this.showBox = false,
    this.padding = EdgeInsets.zero,
    this.margin,
    this.borderRadius = AppRadii.rounded6,
    this.defaultTextColor,
    this.hoverTextColor,
    this.selectedTextColor,
    this.hoverColor,
    this.selectedColor,
    this.hoverBorderColor,
    this.selectedBorderColor,
    this.showLeftIndicator = false,
    this.builder,
  });

  /// The child content widget to display inside the tile.
  final Widget child;

  /// Optional tap handler. When provided, shows a click cursor on hover.
  final VoidCallback? onTap;

  /// Whether this tile is in active / selected state.
  final bool isSelected;

  /// Whether to render a background box and border outline.
  /// Defaults to `false` for pure text/icon color change without any box.
  final bool showBox;

  /// Inner padding for the hoverable surface. Defaults to [EdgeInsets.zero].
  final EdgeInsetsGeometry padding;

  /// Optional outer margin.
  final EdgeInsetsGeometry? margin;

  /// Rounded corner radius when [showBox] is `true`.
  final BorderRadius borderRadius;

  /// Default text color when unhovered and unselected.
  /// Defaults to [AppColors.textTertiary].
  final Color? defaultTextColor;

  /// Text color on mouse hover.
  /// Defaults to [AppColors.textPrimary].
  final Color? hoverTextColor;

  /// Text color when [isSelected] is `true`.
  /// Defaults to [AppColors.accentBlue].
  final Color? selectedTextColor;

  /// Custom background color on hover when [showBox] is `true`.
  /// Defaults to [AppColors.surfaceMuted].
  final Color? hoverColor;

  /// Custom background color when selected and [showBox] is `true`.
  /// Defaults to [AppColors.accentBlueSubtle].
  final Color? selectedColor;

  /// Custom border color on hover when [showBox] is `true`.
  /// Defaults to [AppColors.borderSubtle].
  final Color? hoverBorderColor;

  /// Custom border color when selected and [showBox] is `true`.
  /// Defaults to [AppColors.accentBlueBorder].
  final Color? selectedBorderColor;

  /// Whether to render a vertical indicator bar on the left edge.
  final bool showLeftIndicator;

  /// Optional builder that gives access to the live [isHovered] and [isSelected] states
  /// to conditionally style text or icons inside the child.
  final Widget Function(BuildContext context, bool isHovered, bool isSelected)? builder;

  @override
  State<HoverTile> createState() => _HoverTileState();
}

class _HoverTileState extends State<HoverTile> {
  bool _isHovered = false;

  void _setHovered(bool value) {
    if (_isHovered != value) {
      setState(() => _isHovered = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveDefaultTextColor = widget.defaultTextColor ?? AppColors.textTertiary;
    final effectiveHoverTextColor = widget.hoverTextColor ?? AppColors.textPrimary;
    final effectiveSelectedTextColor = widget.selectedTextColor ?? AppColors.accentBlue;

    final Color currentColor;
    final FontWeight currentWeight;

    if (widget.isSelected) {
      currentColor = effectiveSelectedTextColor;
      currentWeight = FontWeight.w500;
    } else if (_isHovered) {
      currentColor = effectiveHoverTextColor;
      currentWeight = FontWeight.w500;
    } else {
      currentColor = effectiveDefaultTextColor;
      currentWeight = FontWeight.w400;
    }

    final Widget content;
    if (widget.builder != null) {
      content = widget.builder!(context, _isHovered, widget.isSelected);
    } else {
      content = AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 140),
        style: TextStyle(
          color: currentColor,
          fontWeight: currentWeight,
        ),
        child: IconTheme.merge(
          data: IconThemeData(color: currentColor),
          child: widget.child,
        ),
      );
    }

    Widget body = content;
    if (widget.showLeftIndicator) {
      body = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: AppDimensions.d3,
            height: AppDimensions.d14,
            decoration: BoxDecoration(
              color: (widget.isSelected || _isHovered)
                  ? AppColors.primaryButton
                  : Colors.transparent,
              borderRadius: AppRadii.rounded2,
            ),
          ),
          AppDimensions.w6,
          Flexible(child: content),
        ],
      );
    }

    BoxDecoration? decoration;
    if (widget.showBox) {
      final effectiveHoverColor = widget.hoverColor ?? AppColors.surfaceMuted;
      final effectiveSelectedColor = widget.selectedColor ?? AppColors.accentBlueSubtle;
      final effectiveHoverBorder = widget.hoverBorderColor ?? AppColors.borderSubtle;
      final effectiveSelectedBorder = widget.selectedBorderColor ?? AppColors.accentBlueBorder;

      final Color bgColor;
      final Color borderColor;

      if (widget.isSelected) {
        bgColor = effectiveSelectedColor;
        borderColor = effectiveSelectedBorder;
      } else if (_isHovered) {
        bgColor = effectiveHoverColor;
        borderColor = effectiveHoverBorder;
      } else {
        bgColor = Colors.transparent;
        borderColor = Colors.transparent;
      }

      decoration = BoxDecoration(
        color: bgColor,
        borderRadius: widget.borderRadius,
        border: Border.all(color: borderColor, width: AppDimensions.d1),
      );
    }

    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          margin: widget.margin,
          padding: widget.padding,
          decoration: decoration,
          child: body,
        ),
      ),
    );
  }
}
