import 'dart:ui' show BoxHeightStyle, BoxWidthStyle;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A universal, selectable text widget for the Flutter Agentation design system.
///
/// Designed as a direct, enhanced alternative to [Text] and [SelectableText],
/// providing native text selection, clipboard copying, accessibility, and
/// clean selection cursor/highlight colors.
///
/// Supports both plain strings and rich inline spans via [AppText.rich].
class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.textDirection,
    this.textScaler,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.onTap,
    this.mouseCursor,
    this.semanticsLabel,
  }) : textSpan = null;

  const AppText.rich(
    TextSpan this.textSpan, {
    super.key,
    this.style,
    this.textAlign,
    this.textDirection,
    this.textScaler,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.onTap,
    this.mouseCursor,
    this.semanticsLabel,
  }) : text = null;

  /// The plain text string to display.
  final String? text;

  /// The rich text span to display when using [AppText.rich].
  final TextSpan? textSpan;

  /// The typography style.
  final TextStyle? style;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// The directionality of the text.
  final TextDirection? textDirection;

  /// Scaling factor for font size.
  final TextScaler? textScaler;

  /// Maximum lines to render.
  final int? maxLines;

  /// How visual overflow should be handled.
  final TextOverflow? overflow;

  /// Whether the text should break at soft line breaks.
  final bool? softWrap;

  /// Optional tap callback.
  final VoidCallback? onTap;

  /// Optional custom mouse cursor when hovering over this text.
  final MouseCursor? mouseCursor;

  /// Alternative semantics label for accessibility.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final effectiveCursor = mouseCursor ?? (onTap != null ? SystemMouseCursors.click : null);

    if (textSpan != null) {
      if (overflow != null) {
        Widget result = Text.rich(
          textSpan!,
          style: style,
          textAlign: textAlign,
          textDirection: textDirection,
          textScaler: textScaler,
          maxLines: maxLines,
          overflow: overflow,
          softWrap: softWrap,
          semanticsLabel: semanticsLabel,
        );
        if (effectiveCursor != null) {
          result = MouseRegion(cursor: effectiveCursor, child: result);
        }
        return result;
      }

      Widget result = SelectableText.rich(
        textSpan!,
        style: style,
        textAlign: textAlign,
        textDirection: textDirection,
        textScaler: textScaler,
        maxLines: maxLines,
        onTap: onTap,
        semanticsLabel: semanticsLabel,
        cursorColor: AppColors.textPrimary,
        selectionHeightStyle: BoxHeightStyle.max,
        selectionWidthStyle: BoxWidthStyle.tight,
        showCursor: false,
        enableInteractiveSelection: true,
      );
      if (effectiveCursor != null) {
        result = MouseRegion(cursor: effectiveCursor, child: result);
      }
      return result;
    }

    if (overflow != null) {
      Widget result = Text(
        text ?? '',
        style: style,
        textAlign: textAlign,
        textDirection: textDirection,
        textScaler: textScaler,
        maxLines: maxLines,
        overflow: overflow,
        softWrap: softWrap,
        semanticsLabel: semanticsLabel,
      );
      if (effectiveCursor != null) {
        result = MouseRegion(cursor: effectiveCursor, child: result);
      }
      return result;
    }

    Widget result = SelectableText(
      text ?? '',
      style: style,
      textAlign: textAlign,
      textDirection: textDirection,
      textScaler: textScaler,
      maxLines: maxLines,
      onTap: onTap,
      semanticsLabel: semanticsLabel,
      cursorColor: AppColors.textPrimary,
      selectionHeightStyle: BoxHeightStyle.max,
      selectionWidthStyle: BoxWidthStyle.tight,
      showCursor: false,
      enableInteractiveSelection: true,
    );
    if (effectiveCursor != null) {
      result = MouseRegion(cursor: effectiveCursor, child: result);
    }
    return result;
  }
}

/// Alias for [AppText] to explicitly express selectable text intent.
typedef AppSelectableText = AppText;
