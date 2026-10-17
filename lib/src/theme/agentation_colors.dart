import 'package:flutter/material.dart';

/// Centralized color palette and design tokens for the Agentation visual inspection engine.
abstract final class AgentationColors {
  // ── Brand Accents ──
  /// Primary vibrant blue accent used for active highlights, layout mode, and focus states.
  static const Color primary = Color(0xFF0070F3);

  /// Secondary electric blue used for marker dots, notification badges, and active pins.
  static const Color accent = Color(0xFF0088FF);

  /// Platform iOS blue used for toggles, links, and standard platform controls.
  static const Color platformBlue = Color(0xFF007AFF);

  // ── Intent & Status Accents ──
  /// Vibrant green used for code tags, checkmarks, and area selection highlights.
  static const Color success = Color(0xFF34C759);

  /// Amber / orange used for animation freeze states and warnings.
  static const Color warning = Color(0xFFFF9500);

  /// Warm amber accent used for warning badges and banners.
  static const Color warningAmber = Color(0xFFFF8D28);

  /// Red used for delete actions, bug reports, and destructive operations.
  static const Color destructive = Color(0xFFFF383C);

  /// Tailwind red-500 used for critical diagnostic badges.
  static const Color red500 = Color(0xFFEF4444);

  /// Purple used for queries and hierarchical annotations.
  static const Color purple = Color(0xFFAF52DE);

  /// Vibrant violet used for deep nesting and selector chips.
  static const Color violet = Color(0xFF7C3AED);

  /// Soft purple accent for chip tags.
  static const Color purpleSoft = Color(0xFFA78BFA);

  /// Cyan accent used for placement annotations.
  static const Color cyan = Color(0xFF00C3D0);

  /// Amber / gold accent used for warning intents.
  static const Color amber = Color(0xFFFFCC00);

  /// Amber-400 / yellow-500 accents for intent chips.
  static const Color yellowAmber = Color(0xFFFBBF24);
  static const Color yellow500 = Color(0xFFEAB308);

  /// Orange accent used for mode switch badges.
  static const Color orange = Color(0xFFF97316);
  static const Color orangeDark = Color(0xFFD97706);

  /// Indigo accent used for spatial guide painters and layout measurements.
  static const Color indigo = Color(0xFF6366F1);
  static const Color indigoSoft = Color(0xFF818CF8);

  /// Emerald green used for copied status indicators and success tags.
  static const Color emerald = Color(0xFF34D399);
  static const Color emeraldDark = Color(0xFF059669);

  /// Sky & light blue accents.
  static const Color sky = Color(0xFF0284C7);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);

  /// Fuchsia / Magenta accents.
  static const Color fuchsia = Color(0xFFC026D3);
  static const Color pink = Color(0xFFF472B6);

  // ── Dark Mode Theme Palette ──
  /// Deep dark background for floating toolbar pill container.
  static const Color darkToolbarBg = Color(0xFF141416);

  /// Rich dark surface for cards, popups, and dropdown menus.
  static const Color darkCardBg = Color(0xFF181825);

  /// Dark surface for settings panel and dialog sheets.
  static const Color darkPanelBg = Color(0xFF1C1C1E);

  /// Elevated dark surface used for input fields and textareas.
  static const Color darkInputBg = Color(0xFF232336);

  /// Deep code container background.
  static const Color darkCodeBg = Color(0xFF141418);

  /// Dark code block header background.
  static const Color darkCodeHeaderBg = Color(0xFF1C1C24);

  /// Dark code badge tag background.
  static const Color darkCodeTagBg = Color(0xFF282834);

  /// Dark tooltip container background.
  static const Color darkTooltipBg = Color(0xFF18181B);

  /// Dark help tooltip bubble background.
  static const Color darkHelpTooltipBg = Color(0xFF383838);

  /// Deep slate surface for active cards.
  static const Color darkSlateBg = Color(0xFF1E1E2E);
  static const Color darkSlatePanel = Color(0xFF1E293B);

  /// Subtle dark border line.
  static const Color darkBorder = Color(0xFF2C2C2E);

  /// Dark code border line.
  static const Color darkCodeBorder = Color(0xFF2E2E38);

  /// Dark checkbox unselected border line.
  static const Color darkCheckboxBorder = Color(0xFF48484A);

  /// Subtle gray border for settings items.
  static const Color darkBorderMuted = Color(0xFF484848);

  /// Translucent white border for elevated popups.
  static const Color darkBorderTranslucent = Color(0x33FFFFFF);

  /// Divider line for dark mode.
  static const Color darkDivider = Color(0xFF2C2C2E);

  /// Primary white text color in dark mode.
  static const Color darkTextPrimary = Colors.white;

  /// Secondary muted text (Slate 400) in dark mode.
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  /// Subtext and caption color in dark mode.
  static const Color darkTextMuted = Color(0xFF8E8E93);

  /// Slate-300 text color for subtle buttons in dark mode.
  static const Color darkTextSubtle = Color(0xFFCBD5E1);

  /// Inactive icon color in dark mode.
  static const Color darkIconInactive = Color(0xFF6E6E73);

  /// Translucent white hover highlights.
  static const Color darkHoverBg = Color(0x1AFFFFFF);
  static const Color darkPressedBg = Color(0x29FFFFFF);

  /// Translucent white text for help popups.
  static const Color darkTextTranslucent = Color(0xD9FFFFFF);

  // ── Light Mode Theme Palette ──
  /// Pure white background for floating toolbar pill container.
  static const Color lightToolbarBg = Colors.white;

  /// Pure white surface for cards, popups, and dialogs.
  static const Color lightCardBg = Colors.white;

  /// Pure white surface for settings panel.
  static const Color lightPanelBg = Colors.white;

  /// Light grayish surface used for input fields and textareas.
  static const Color lightInputBg = Color(0xFFF2F2F7);

  /// Light code container background.
  static const Color lightCodeBg = Color(0xFFF6F8FA);

  /// Light code block header background.
  static const Color lightCodeHeaderBg = Color(0xFFEEF2F6);

  /// Light code badge tag background.
  static const Color lightCodeTagBg = Color(0xFFE2E8F0);

  /// Subtle light border line.
  static const Color lightBorder = Color(0xFFE5E5EA);

  /// Light slate border line.
  static const Color lightBorderSlate = Color(0xFFE2E8F0);

  /// Light gray border line for inputs.
  static const Color lightBorderGray = Color(0xFFD1D1D6);

  /// Subtle gray border line.
  static const Color lightBorderSubtle = Color(0xFFCDCDCD);
  static const Color lightBorderLight = Color(0xFFE2E2E2);

  /// Translucent black border for elevated popups.
  static const Color lightBorderTranslucent = Color(0x1F000000);

  /// Divider line for light mode.
  static const Color lightDivider = Color(0xFFEFEFF4);

  /// Primary slate text color in light mode.
  static const Color lightTextPrimary = Color(0xFF0F172A);

  /// Near-black text color used on toolbar icons.
  static const Color lightTextHeading = Color(0xFF1C1C1E);

  /// Secondary text color in light mode (Slate 600).
  static const Color lightTextSecondary = Color(0xFF475569);

  /// Slate 500 text color.
  static const Color lightTextSlate = Color(0xFF64748B);

  /// Muted caption text in light mode.
  static const Color lightTextMuted = Color(0xFF8E8E93);

  /// Gray 500 text color for shortcuts.
  static const Color lightTextGray = Color(0xFF888888);

  /// Zinc 400 subtext color.
  static const Color lightTextZinc = Color(0xFFA1A1AA);

  /// Near-black dark neutral text.
  static const Color darkNeutral = Color(0xFF333333);

  /// Inactive icon color in light mode.
  static const Color lightIconInactive = Color(0xFF8E8E93);

  /// Translucent hover color in light mode.
  static const Color lightHoverBg = Color(0x0A000000);
  static const Color lightPressedBg = Color(0x14000000);

  // ── Shadow & Overlay Tokens ──
  static const Color shadowSubtle = Color(0x0A000000);
  static const Color shadowCardLight = Color(0x0D000000);
  static const Color shadowToolbarLight = Color(0x0F000000);
  static const Color shadowPanel = Color(0x1F000000);
  static const Color shadowMedium = Color(0x22000000);
  static const Color shadowDeep = Color(0x26000000);
  static const Color shadowHeavy = Color(0x33000000);
  static const Color shadowHelp = Color(0x47000000);
  static const Color shadowDark = Color(0x66000000);
  static const Color shadowScrim = Color(0x7F000000);
  static const Color shadowIntense = Color(0xE6000000);

  // ── Syntax Highlighting Tokens ──
  static const Color syntaxDarkDefault = lightBorderSlate;
  static const Color syntaxDarkKeyword = pink;
  static const Color syntaxDarkType = blue400;
  static const Color syntaxDarkString = emerald;
  static const Color syntaxDarkProperty = purpleSoft;
  static const Color syntaxDarkNumber = yellowAmber;
  static const Color syntaxDarkComment = lightTextSlate;
  static const Color syntaxDarkPunctuation = darkTextSecondary;

  static const Color syntaxLightDefault = darkSlatePanel;
  static const Color syntaxLightKeyword = fuchsia;
  static const Color syntaxLightType = sky;
  static const Color syntaxLightString = emeraldDark;
  static const Color syntaxLightProperty = violet;
  static const Color syntaxLightNumber = orangeDark;
  static const Color syntaxLightComment = darkTextSecondary;
  static const Color syntaxLightPunctuation = lightTextSlate;
}
