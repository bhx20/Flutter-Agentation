import 'package:flutter/material.dart';
import 'agentation_colors.dart';

/// Semantic theme tokens for Agentation UI elements (toolbar, cards, dialogs, badges).
@immutable
class AgentationThemeData {
  /// Whether this theme data is configured for dark mode.
  final bool isDark;

  /// Background color for toolbar pill.
  final Color toolbarBackground;

  /// Background color for popup cards and dialogs.
  final Color cardBackground;

  /// Elevated background color for inputs and code snippets.
  final Color inputBackground;

  /// Border color for toolbar and panels.
  final Color borderColor;

  /// Translucent border color for floating cards.
  final Color borderTranslucentColor;

  /// Divider line color.
  final Color dividerColor;

  /// Primary body text color.
  final Color textPrimary;

  /// Secondary muted text color.
  final Color textSecondary;

  /// Highly muted caption and shortcut text color.
  final Color textMuted;

  /// Color for icons in standard resting state.
  final Color iconColor;

  /// Color for inactive or disabled icons.
  final Color iconInactiveColor;

  /// Primary accent color.
  final Color primaryColor;

  /// Badge accent color.
  final Color accentColor;

  /// Success state color.
  final Color successColor;

  /// Warning / freeze state color.
  final Color warningColor;

  /// Destructive action color.
  final Color destructiveColor;

  /// Background color for floating settings panel and dialog sheets.
  final Color panelBackground;

  /// Border color for settings panel.
  final Color panelBorderColor;

  /// Background for raw code / monospace blocks.
  final Color codeBackground;

  /// Hover surface color for buttons and list items.
  final Color hoverBackground;

  /// Syntax highlighting colors for Dart snippet viewers.
  final AgentationSyntaxColors syntaxColors;

  /// Ambient and key drop shadows for floating elevation.
  final List<BoxShadow> cardShadows;

  /// Shadows for settings panel.
  final List<BoxShadow> panelShadows;

  /// Shadows for toolbar container.
  final List<BoxShadow> toolbarShadows;

  const AgentationThemeData({
    required this.isDark,
    required this.toolbarBackground,
    required this.cardBackground,
    required this.panelBackground,
    required this.panelBorderColor,
    required this.inputBackground,
    required this.codeBackground,
    required this.hoverBackground,
    required this.syntaxColors,
    required this.borderColor,
    required this.borderTranslucentColor,
    required this.dividerColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.iconColor,
    required this.iconInactiveColor,
    required this.primaryColor,
    required this.accentColor,
    required this.successColor,
    required this.warningColor,
    required this.destructiveColor,
    required this.cardShadows,
    required this.panelShadows,
    required this.toolbarShadows,
  });

  /// Standard dark theme matching Agentation's sleek aesthetic.
  factory AgentationThemeData.dark() {
    return const AgentationThemeData(
      isDark: true,
      toolbarBackground: AgentationColors.darkToolbarBg,
      cardBackground: AgentationColors.darkCardBg,
      panelBackground: AgentationColors.darkPanelBg,
      panelBorderColor: AgentationColors.darkBorder,
      inputBackground: AgentationColors.darkInputBg,
      codeBackground: AgentationColors.darkCodeBg,
      hoverBackground: AgentationColors.darkHoverBg,
      syntaxColors: AgentationSyntaxColors.dark(),
      borderColor: AgentationColors.darkBorder,
      borderTranslucentColor: AgentationColors.darkBorderTranslucent,
      dividerColor: AgentationColors.darkDivider,
      textPrimary: AgentationColors.darkTextPrimary,
      textSecondary: AgentationColors.darkTextSecondary,
      textMuted: AgentationColors.darkTextMuted,
      iconColor: AgentationColors.darkTextPrimary,
      iconInactiveColor: AgentationColors.darkIconInactive,
      primaryColor: AgentationColors.primary,
      accentColor: AgentationColors.accent,
      successColor: AgentationColors.success,
      warningColor: AgentationColors.warning,
      destructiveColor: AgentationColors.destructive,
      cardShadows: [
        BoxShadow(
          color: AgentationColors.shadowScrim,
          blurRadius: 20.0,
          offset: Offset(0, 6),
        ),
      ],
      panelShadows: [
        BoxShadow(
          color: AgentationColors.shadowDark,
          blurRadius: 20.0,
          offset: Offset(0, 6),
        ),
        BoxShadow(
          color: AgentationColors.shadowHeavy,
          blurRadius: 6.0,
          offset: Offset(0, 2),
        ),
      ],
      toolbarShadows: [
        BoxShadow(
          color: AgentationColors.shadowDark,
          blurRadius: 16.0,
          offset: Offset(0, 6),
        ),
        BoxShadow(
          color: AgentationColors.shadowHeavy,
          blurRadius: 4.0,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  /// Clean light theme matching macOS / iOS native design.
  factory AgentationThemeData.light() {
    return const AgentationThemeData(
      isDark: false,
      toolbarBackground: AgentationColors.lightToolbarBg,
      cardBackground: AgentationColors.lightCardBg,
      panelBackground: AgentationColors.lightPanelBg,
      panelBorderColor: AgentationColors.lightBorder,
      inputBackground: AgentationColors.lightInputBg,
      codeBackground: AgentationColors.lightCodeBg,
      hoverBackground: AgentationColors.lightHoverBg,
      syntaxColors: AgentationSyntaxColors.light(),
      borderColor: AgentationColors.lightBorder,
      borderTranslucentColor: AgentationColors.lightBorderTranslucent,
      dividerColor: AgentationColors.lightDivider,
      textPrimary: AgentationColors.lightTextPrimary,
      textSecondary: AgentationColors.lightTextSecondary,
      textMuted: AgentationColors.lightTextMuted,
      iconColor: AgentationColors.lightTextHeading,
      iconInactiveColor: AgentationColors.lightIconInactive,
      primaryColor: AgentationColors.primary,
      accentColor: AgentationColors.accent,
      successColor: AgentationColors.success,
      warningColor: AgentationColors.warning,
      destructiveColor: AgentationColors.destructive,
      cardShadows: [
        BoxShadow(
          color: AgentationColors.shadowDeep,
          blurRadius: 20.0,
          offset: Offset(0, 6),
        ),
      ],
      panelShadows: [
        BoxShadow(
          color: AgentationColors.lightPressedBg,
          blurRadius: 20.0,
          offset: Offset(0, 6),
        ),
        BoxShadow(
          color: AgentationColors.shadowSubtle,
          blurRadius: 6.0,
          offset: Offset(0, 2),
        ),
      ],
      toolbarShadows: [
        BoxShadow(
          color: AgentationColors.shadowPanel,
          blurRadius: 16.0,
          offset: Offset(0, 6),
        ),
        BoxShadow(
          color: AgentationColors.shadowCardLight,
          blurRadius: 4.0,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  /// Connection status: connected (Tailwind green-500).
  Color get statusConnected => AgentationColors.statusConnected;

  /// Connection status: connecting (Tailwind amber-500).
  Color get statusConnecting => AgentationColors.statusConnecting;

  /// Connection status: disconnected (Tailwind red-500).
  Color get statusDisconnected => AgentationColors.statusDisconnected;

  /// Panel input background.
  Color get panelInputBackground => isDark
      ? Colors.white.withValues(alpha: 0.04)
      : AgentationColors.gray50;

  /// Panel input border.
  Color get panelInputBorder => isDark
      ? Colors.white.withValues(alpha: 0.12)
      : AgentationColors.gray200;

  /// Panel input placeholder / hint color.
  Color get panelInputHint => isDark
      ? Colors.white.withValues(alpha: 0.3)
      : AgentationColors.gray400;

  /// Auto-send active toggle text color.
  Color get autoSendActiveColor => isDark
      ? AgentationColors.blue300
      : AgentationColors.blue400;

  /// Sub-panel divider color.
  Color get panelDividerColor => isDark
      ? Colors.white.withValues(alpha: 0.08)
      : AgentationColors.lightDividerLight;

  /// Link text color.
  Color get linkColor => isDark
      ? AgentationColors.blue300
      : AgentationColors.blue600;

  /// Tooltip bubble background.
  Color get tooltipBubbleBg => isDark
      ? AgentationColors.zinc900
      : AgentationColors.zinc100;

  /// Convenience resolver: returns dark or light theme based on [isDark].
  factory AgentationThemeData.resolve({required bool isDark}) {
    return isDark ? AgentationThemeData.dark() : AgentationThemeData.light();
  }
}

/// Syntax highlighting color scheme for inspected Dart snippets.
@immutable
class AgentationSyntaxColors {
  final Color defaultColor;
  final Color keywordColor;
  final Color typeColor;
  final Color stringColor;
  final Color propertyColor;
  final Color numberColor;
  final Color commentColor;
  final Color punctuationColor;

  const AgentationSyntaxColors({
    required this.defaultColor,
    required this.keywordColor,
    required this.typeColor,
    required this.stringColor,
    required this.propertyColor,
    required this.numberColor,
    required this.commentColor,
    required this.punctuationColor,
  });

  /// Dark syntax highlighting tokens.
  const AgentationSyntaxColors.dark()
      : defaultColor = AgentationColors.syntaxDarkDefault,
        keywordColor = AgentationColors.syntaxDarkKeyword,
        typeColor = AgentationColors.syntaxDarkType,
        stringColor = AgentationColors.syntaxDarkString,
        propertyColor = AgentationColors.syntaxDarkProperty,
        numberColor = AgentationColors.syntaxDarkNumber,
        commentColor = AgentationColors.syntaxDarkComment,
        punctuationColor = AgentationColors.syntaxDarkPunctuation;

  /// Light syntax highlighting tokens.
  const AgentationSyntaxColors.light()
      : defaultColor = AgentationColors.syntaxLightDefault,
        keywordColor = AgentationColors.syntaxLightKeyword,
        typeColor = AgentationColors.syntaxLightType,
        stringColor = AgentationColors.syntaxLightString,
        propertyColor = AgentationColors.syntaxLightProperty,
        numberColor = AgentationColors.syntaxLightNumber,
        commentColor = AgentationColors.syntaxLightComment,
        punctuationColor = AgentationColors.syntaxLightPunctuation;
}
