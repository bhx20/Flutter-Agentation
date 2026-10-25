import 'package:flutter/material.dart';

/// Centralized standard typography and text styles for Agentation UI elements.
abstract final class AgentationTypography {
  static const String fontFamily = 'Inter';
  static const String monospaceFamily = 'monospace';

  // ── Headings & Titles ──
  /// Standard title and heading style (14.0, normal weight).
  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.1,
  );

  /// Semi-bold title for cards and major section headings (14.0, w600).
  static const TextStyle titleSemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
  );

  /// Bold title for top-level headers and sheet titles (15.0, w700).
  static const TextStyle header = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15.0,
    fontWeight: FontWeight.w700,
  );

  // ── Body Text ──
  /// Standard body text style (13.0, w400).
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
  );

  /// Medium body text style for emphasized content (13.0, w500).
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.0,
    fontWeight: FontWeight.w500,
  );

  /// Bold body text style for labels and emphasis (13.0, w700).
  static const TextStyle bodyBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.0,
    fontWeight: FontWeight.w700,
  );

  // ── Subtext & Secondary Labels ──
  /// Secondary label and version text (12.0, normal weight).
  static const TextStyle subtext = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
  );

  /// Italic element hierarchy label (12.5, normal weight, italic).
  static const TextStyle italicLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.5,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.normal,
    decoration: TextDecoration.none,
  );

  /// Element preview label in card header (12.5, w600).
  static const TextStyle elementLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
  );

  // ── Captions & Footnotes ──
  /// Small caption style (11.0, normal weight).
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.normal,
  );

  /// Semi-bold caption style (11.0, w600).
  static const TextStyle captionSemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w600,
  );

  /// Bold caption style for pins and count markers (11.0, bold).
  static const TextStyle captionBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.none,
  );

  /// Footnote style for timestamps and metadata (10.0, normal weight).
  static const TextStyle footnote = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10.0,
    fontWeight: FontWeight.normal,
  );

  /// Bold footnote style for author names and chips (10.0, bold).
  static const TextStyle footnoteBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10.0,
    fontWeight: FontWeight.bold,
  );

  // ── Code & Monospace ──
  /// Standard code font style for Dart snippet inspection (11.5, monospace, height 1.4).
  static const TextStyle code = TextStyle(
    fontFamily: monospaceFamily,
    fontSize: 11.5,
    height: 1.4,
  );

  /// Compact code font style for popup review boxes (11.0, monospace, height 1.4).
  static const TextStyle codeCompact = TextStyle(
    fontFamily: monospaceFamily,
    fontSize: 11.0,
    height: 1.4,
  );

  /// Small monospace style for source file:line location badges (10.0, monospace).
  static const TextStyle codeLocation = TextStyle(
    fontFamily: monospaceFamily,
    fontSize: 10.0,
  );

  /// Code block header uppercase label style (9.5, w700, letterSpacing 0.6).
  static const TextStyle codeHeader = TextStyle(
    fontFamily: fontFamily,
    fontSize: 9.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
  );

  // ── Tooltips & Badges ──
  /// Toolbar hover beak tooltip label (11.5, normal weight).
  static const TextStyle tooltipTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.5,
    fontWeight: FontWeight.normal,
    decoration: TextDecoration.none,
  );

  /// Toolbar hover beak tooltip shortcut pill (11.5, w500).
  static const TextStyle tooltipShortcut = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.none,
  );

  /// Floating tooltip action message (12.0, normal weight).
  static const TextStyle tooltipMessage = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    decoration: TextDecoration.none,
  );

  /// Keyboard shortcut badge style (10.0, w500).
  static const TextStyle shortcut = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10.0,
    fontWeight: FontWeight.w500,
  );

  /// Floating count badge for minimized toolbar (8.0, bold).
  static const TextStyle badge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 8.0,
    fontWeight: FontWeight.bold,
  );

  /// Larger badge text for multi-digit counters (9.0, bold).
  static const TextStyle badgeMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 9.0,
    fontWeight: FontWeight.bold,
  );

  /// Help tooltip text style with line height (11.0, w400, height 1.35).
  static const TextStyle helpTooltip = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  // ── Controls & Actions ──
  /// Button action text style (13.0, w500).
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.0,
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.none,
  );

  /// Textfield input style (13.0, w400).
  static const TextStyle input = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
  );

  /// Textfield placeholder / hint style (13.0, normal weight).
  static const TextStyle inputHint = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.0,
    fontWeight: FontWeight.normal,
  );

  /// ActionChip label style (10.0, normal weight).
  static const TextStyle chip = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10.0,
  );

  // ── Panel & Toolbar Dedicated Styles ──
  /// Navigation & page header style (13.5, w500).
  static const TextStyle panelHeader = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.5,
    fontWeight: FontWeight.w500,
  );

  /// Section title in settings and automation panels (13.0, w500).
  static const TextStyle sectionHeader = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.0,
    fontWeight: FontWeight.w500,
  );

  /// Panel description and explainer text (11.5, normal weight, height 1.35).
  static const TextStyle panelDescription = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.5,
    fontWeight: FontWeight.normal,
    height: 1.35,
  );

  /// Link text style inside panels (11.5, normal weight, underline, height 1.35).
  static const TextStyle panelLink = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.5,
    fontWeight: FontWeight.normal,
    height: 1.35,
    decoration: TextDecoration.underline,
    decorationStyle: TextDecorationStyle.dotted,
  );

  /// Auto-send toggle label (11.5, w500).
  static const TextStyle autoSendLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
  );

  /// Input text style for webhook and settings fields (12.0, normal weight).
  static const TextStyle panelInput = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
  );

  /// Input hint / placeholder text (12.0, normal weight).
  static const TextStyle panelInputHint = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
  );

  /// Small chip and action tag label (10.5, w500).
  static const TextStyle panelActionTag = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10.5,
    fontWeight: FontWeight.w500,
  );

  /// Monospace code / URL snippet in panels (10.5, monospace).
  static const TextStyle panelCodeSnippet = TextStyle(
    fontFamily: monospaceFamily,
    fontSize: 10.5,
  );

  /// Standard panel tooltip message (10.5, normal weight).
  static const TextStyle panelTooltipText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10.5,
    fontWeight: FontWeight.normal,
  );

  /// Send button badge counter (9.5, w600, height 1.0).
  static const TextStyle toolbarBadge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 9.5,
    fontWeight: FontWeight.w600,
    height: 1.0,
    decoration: TextDecoration.none,
  );
}
