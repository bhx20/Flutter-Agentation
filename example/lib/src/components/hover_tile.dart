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
    this.cursor,
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
    this.hoverNotifier,
  });

  /// The child content widget to display inside the tile.
  final Widget child;

  /// Optional tap handler. When provided, shows a click cursor on hover.
  final VoidCallback? onTap;

  /// Custom mouse cursor when hovering over this tile.
  /// Defaults to [SystemMouseCursors.click] if [onTap] is provided, or [SystemMouseCursors.defer].
  final MouseCursor? cursor;

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

  /// Optional external notifier for hover state (e.g. from NativeLinkWrapper).
  final ValueNotifier<bool>? hoverNotifier;

  @override
  State<HoverTile> createState() => _HoverTileState();
}

class _HoverTileState extends State<HoverTile> {
  late final ValueNotifier<bool> _internalHoverNotifier;
  ValueNotifier<bool> get _effectiveHoverNotifier =>
      widget.hoverNotifier ?? _internalHoverNotifier;

  @override
  void initState() {
    super.initState();
    _internalHoverNotifier = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _internalHoverNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveDefaultTextColor = widget.defaultTextColor ?? AppColors.textTertiary;
    final effectiveHoverTextColor = widget.hoverTextColor ?? AppColors.textPrimary;
    final effectiveSelectedTextColor = widget.selectedTextColor ?? AppColors.accentBlue;
    final effectiveCursor = widget.cursor ??
        (widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer);

    Widget result = MouseRegion(
      onEnter: (_) => _effectiveHoverNotifier.value = true,
      onExit: (_) => _effectiveHoverNotifier.value = false,
      cursor: effectiveCursor,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: ValueListenableBuilder<bool>(
          valueListenable: _effectiveHoverNotifier,
          builder: (context, isHovered, _) {
            final Color currentColor;
            final FontWeight currentWeight;

            if (widget.isSelected) {
              currentColor = effectiveSelectedTextColor;
              currentWeight = FontWeight.w500;
            } else if (isHovered) {
              currentColor = effectiveHoverTextColor;
              currentWeight = FontWeight.w500;
            } else {
              currentColor = effectiveDefaultTextColor;
              currentWeight = FontWeight.w400;
            }

            final Widget content;
            if (widget.builder != null) {
              content = widget.builder!(context, isHovered, widget.isSelected);
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
                      color: (widget.isSelected || isHovered)
                          ? AppColors.primaryButton
                          : AppColors.transparent,
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
              } else if (isHovered) {
                bgColor = effectiveHoverColor;
                borderColor = effectiveHoverBorder;
              } else {
                bgColor = AppColors.transparent;
                borderColor = AppColors.transparent;
              }

              decoration = BoxDecoration(
                color: bgColor,
                borderRadius: widget.borderRadius,
                border: Border.all(color: borderColor, width: AppDimensions.d1),
              );
            }

            return AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              margin: widget.margin,
              padding: widget.padding,
              decoration: decoration,
              child: body,
            );
          },
        ),
      ),
    );

    if (effectiveCursor == SystemMouseCursors.click || widget.onTap != null) {
      result = SelectionContainer.disabled(child: result);
    }

    return result;
  }
}
