import 'package:flutter/material.dart';
import 'package:example/src/theme/app_dimensions.dart';

import 'app_colors.dart';
import 'app_insets.dart';
import 'app_radii.dart';
import 'app_typography.dart';

/// Central app theme configurations matching the Flutter Agentation showcase design.
/// Manages all colors, typography, button shapes, borders, and scrollbars centrally.
abstract final class AppTheme {
  // ── Central Button Style Tokens ──

  /// Standard Primary Filled Button style matching filledButtonTheme.
  static ButtonStyle get primaryButton => FilledButton.styleFrom(
        backgroundColor: AppColors.primaryButton,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadii.button,
        ),
        textStyle: AppTypography.buttonWhite,
        padding: AppInsets.button,
      );

  /// Standard Outlined Button style matching outlinedButtonTheme.
  static ButtonStyle get outlinedButton => OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        backgroundColor: AppColors.cardBackground,
        side: const BorderSide(color: AppColors.borderMedium),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadii.button,
        ),
        textStyle: AppTypography.button,
        padding: AppInsets.button,
      );

  /// Standard Elevated Button style matching elevatedButtonTheme.
  static ButtonStyle get elevatedButton => ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryButton,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadii.button,
        ),
        textStyle: AppTypography.button,
        padding: AppInsets.button,
      );

  /// Large Primary Action Button (used in ActionButton).
  static ButtonStyle get actionButtonPrimary => FilledButton.styleFrom(
        backgroundColor: AppColors.primaryButton,
        foregroundColor: AppColors.textWhite,
        padding: AppInsets.h20v14,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.rounded8),
        elevation: 0,
        textStyle: AppTypography.button,
      );

  /// Large Secondary Action Button (used in ActionButton).
  static ButtonStyle get actionButtonSecondary => FilledButton.styleFrom(
        backgroundColor: AppColors.cardBackgroundAlt,
        foregroundColor: AppColors.textPrimary,
        padding: AppInsets.h18v14,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.rounded8),
        elevation: 0,
        textStyle: AppTypography.button,
      );

  /// Large Outline Action Button (used in ActionButton).
  static ButtonStyle get actionButtonOutline => OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        backgroundColor: AppColors.cardBackground,
        side: const BorderSide(color: AppColors.borderMedium),
        padding: AppInsets.h18v14,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.rounded8),
        textStyle: AppTypography.button,
      );

  /// Compact Primary Button (used in Navbar / Toolbar tags).
  static ButtonStyle get compactPrimaryButton => FilledButton.styleFrom(
        backgroundColor: AppColors.primaryButton,
        foregroundColor: AppColors.textWhite,
        padding: AppInsets.h10v8,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadii.rounded4,
        ),
        textStyle: AppTypography.buttonSmall,
      );

  /// Compact Outlined Button (used in Changelog / Section actions).
  static ButtonStyle get compactOutlinedButton => OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.borderMedium),
        backgroundColor: AppColors.cardBackground,
        padding: AppInsets.h12v8,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadii.rounded4,
        ),
        textStyle: AppTypography.buttonSmall,
      );

  /// Dispatch/Action Primary Button with rounded6 (used in Toolbar spec dialog).
  static ButtonStyle get actionPrimaryButton => FilledButton.styleFrom(
        backgroundColor: AppColors.primaryButton,
        foregroundColor: AppColors.textWhite,
        padding: AppInsets.h14v10,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.rounded6),
        textStyle: AppTypography.captionBold,
      );

  /// Drawer Full-Width Primary Button.
  static ButtonStyle get drawerPrimaryButton => FilledButton.styleFrom(
        backgroundColor: AppColors.primaryButton,
        foregroundColor: AppColors.textWhite,
        padding: AppInsets.v12,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.rounded6),
        textStyle: AppTypography.buttonBold,
      );

  /// Drawer Full-Width Outlined Button.
  static ButtonStyle get drawerOutlinedButton => OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        backgroundColor: AppColors.cardBackground,
        side: const BorderSide(color: AppColors.borderMedium),
        padding: AppInsets.v12,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.rounded6),
        textStyle: AppTypography.button,
      );

  // ── Central Container & Card Decorations ──

  /// Standard Card decoration.
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.borderSubtle),
      );

  /// Card decoration with alt background.
  static BoxDecoration get cardDecorationAlt => BoxDecoration(
        color: AppColors.cardBackgroundAlt,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.borderSubtle),
      );

  /// Code block container decoration.
  static BoxDecoration get codeBlockDecoration => BoxDecoration(
        color: AppColors.codeBackground,
        borderRadius: AppRadii.codeBlock,
        border: Border.all(color: AppColors.codeSnippetBorder),
      );

  /// Browser preview window container decoration.
  static BoxDecoration get windowDecoration => BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadii.browserWindow,
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSubtle,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      );

  // ── Main ThemeData Configuration ──

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.pageBackground,
      textSelectionTheme: const TextSelectionThemeData(
        selectionColor: AppColors.textSelection,
        cursorColor: AppColors.textPrimary,
        selectionHandleColor: AppColors.textPrimary,
      ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryButton,
        onPrimary: AppColors.textWhite,
        surface: AppColors.cardBackground,
        onSurface: AppColors.textPrimary,
        outline: AppColors.borderSubtle,
      ),
      textTheme: const TextTheme(
        displayLarge: AppTypography.display,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displayMobile,
        headlineLarge: AppTypography.h1,
        headlineMedium: AppTypography.h2,
        headlineSmall: AppTypography.h3,
        titleLarge: AppTypography.cardTitle,
        titleMedium: AppTypography.cardTitleMedium,
        titleSmall: AppTypography.cardTitleSmall,
        bodyLarge: AppTypography.lead,
        bodyMedium: AppTypography.body,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.button,
        labelMedium: AppTypography.badge,
        labelSmall: AppTypography.caption,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: const WidgetStatePropertyAll(true),
        trackVisibility: const WidgetStatePropertyAll(true),
        interactive: true,
        thickness: const WidgetStatePropertyAll(12.0),
        radius: AppRadii.r5,
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered) || states.contains(WidgetState.dragged)) {
            return AppColors.scrollbarThumbHover;
          }
          return AppColors.scrollbarThumb;
        }),
        trackColor: const WidgetStatePropertyAll(AppColors.scrollbarTrack),
        trackBorderColor: const WidgetStatePropertyAll(AppColors.borderSubtle),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: AppDimensions.d1,
        space: 1,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.card,
          side: BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: elevatedButton,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: primaryButton,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: outlinedButton,
      ),
    );
  }
}
