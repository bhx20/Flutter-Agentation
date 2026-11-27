import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography hierarchy and centralized text styles matching the Flutter Agentation design system.
/// All text styles across the application and showcase are centralized here.
abstract final class AppTypography {
  // Headings & Displays
  static const TextStyle display = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
    height: 1.15,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: -0.8,
    height: 1.2,
  );

  static const TextStyle displayMobile = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: -0.6,
    height: 1.2,
  );

  static const TextStyle h1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.25,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
    height: 1.35,
  );

  // Card & Section Titles
  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static const TextStyle cardTitleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardTitleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardTitleSubtle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardTitleSlate = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.slateCard,
  );

  static const TextStyle sectionItemTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const TextStyle sectionItemTitleBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static const TextStyle sectionItemTitlePrimary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle sectionItemTitlePrimaryBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle itemTitleSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle itemTitleSmallDark = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  // Eyebrow, Overline & Labels
  static const TextStyle eyebrow = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.12,
    color: AppColors.textEyebrow,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.8,
    color: AppColors.textTertiary,
  );

  static const TextStyle overlineMini = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.8,
    color: AppColors.textTertiary,
  );

  static const TextStyle overlineMiniMuted = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.8,
    color: AppColors.textMuted,
  );

  static const TextStyle overlineDark = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.8,
    color: AppColors.textDark,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.8,
    color: AppColors.textEyebrow,
  );

  // Body & Paragraphs
  static const TextStyle lead = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: -0.084,
    height: 1.45,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static const TextStyle bodyMediumLoose = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.55,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: -0.065,
    height: 1.4,
  );

  static const TextStyle bodySmallSecondary = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static const TextStyle bodySmallTertiary = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.45,
  );

  static const TextStyle bodySmallMuted = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const TextStyle bodySmallCodeDark = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textCodeDark,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  // Captions & Micro-Text
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    letterSpacing: 0.22,
    height: 1.3,
  );

  static const TextStyle captionWhite = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.22,
    color: AppColors.textWhite,
  );

  static const TextStyle captionSlateBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.slateText,
  );

  static const TextStyle captionTertiaryTight = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.35,
  );

  static const TextStyle badgeBoldSlate = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.slateCard,
  );

  static const TextStyle codeSmallSlateDark = TextStyle(
    fontSize: 12,
    fontFamily: 'monospace',
    fontWeight: FontWeight.w500,
    color: AppColors.slateDark,
  );

  static const TextStyle bodyMediumLooseAccent = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.accentBlue,
    height: 1.55,
  );

  static const TextStyle bodySmallSecondaryTight = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle captionTertiary = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  static const TextStyle captionMuted = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const TextStyle captionSecondary = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle captionSecondaryLoose = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static const TextStyle captionDark = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static const TextStyle captionCodeDark = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textCodeDark,
  );

  static const TextStyle captionBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle microTertiary = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  // Buttons & Navigation
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.065,
    color: AppColors.textPrimary,
  );

  static const TextStyle buttonWhite = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.065,
    color: AppColors.textWhite,
  );

  static const TextStyle buttonSlate = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.065,
    color: AppColors.slateText,
  );

  static const TextStyle buttonBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle buttonSmallBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle buttonMini = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textWhite,
  );

  static const TextStyle navLink = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: -0.084,
  );

  static const TextStyle navLinkActive = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.accentBlue,
    letterSpacing: -0.084,
  );

  static const TextStyle sidebarLink = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    letterSpacing: -0.1,
  );

  static const TextStyle sidebarLinkActive = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.accentBlue,
    letterSpacing: -0.1,
  );

  // Badges, Tags, Pills & Chips
  static const TextStyle badge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.slateText,
  );

  static const TextStyle badgeBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.slateText,
  );

  static const TextStyle badgeSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.accentBlue,
  );

  static const TextStyle badgeSmallSpaced = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.accentBlue,
  );

  static const TextStyle badgeSmallSemiBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.accentBlue,
  );

  static const TextStyle badgeSmallRed = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.accentRedMedium,
  );

  static const TextStyle badgeTag = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle badgeTagBold = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle badgeTagBoldBlue = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.accentBlue,
  );

  static const TextStyle badgeTagMuted = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static const TextStyle badgeMicro = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  // Metrics & Stats
  static const TextStyle metricValue = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle metricSub = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.accentGreen,
  );

  static const TextStyle metricLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.3,
  );

  // Footer & Legal
  static const TextStyle footerTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.27,
    color: AppColors.textHeadingDark,
  );

  static const TextStyle footerDesc = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    color: AppColors.textSecondary,
  );

  static const TextStyle legalLink = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0.22,
  );

  // FAQ
  static const TextStyle faqQuestion = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle faqAnswer = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.55,
  );

  // Monospace & Code Styles
  static const TextStyle code = TextStyle(
    fontSize: 14,
    fontFamily: 'monospace',
    color: AppColors.textPrimary,
    height: 1.45,
  );

  static const TextStyle codeSmall = TextStyle(
    fontSize: 12,
    fontFamily: 'monospace',
    color: AppColors.textPrimary,
  );

  static const TextStyle codeSmallDark = TextStyle(
    fontSize: 12,
    fontFamily: 'monospace',
    color: AppColors.textDark,
    height: 1.45,
  );

  static const TextStyle codeSmallDarkBold = TextStyle(
    fontSize: 12,
    fontFamily: 'monospace',
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static const TextStyle codeSmallSecondary = TextStyle(
    fontSize: 12,
    fontFamily: 'monospace',
    color: AppColors.textSecondary,
  );

  static const TextStyle codeSmallTertiary = TextStyle(
    fontSize: 12,
    fontFamily: 'monospace',
    color: AppColors.textTertiary,
  );

  static const TextStyle codeSmallMuted = TextStyle(
    fontSize: 12,
    fontFamily: 'monospace',
    color: AppColors.textMuted,
  );

  static const TextStyle codeSmallCodeDark = TextStyle(
    fontSize: 12,
    fontFamily: 'monospace',
    color: AppColors.textCodeDark,
  );

  static const TextStyle codeMicro = TextStyle(
    fontSize: 10,
    fontFamily: 'monospace',
    color: AppColors.textSecondary,
  );

  static const TextStyle codeMicroBold = TextStyle(
    fontSize: 10,
    fontFamily: 'monospace',
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static const TextStyle codeMicroCodeDark = TextStyle(
    fontSize: 10,
    fontFamily: 'monospace',
    fontWeight: FontWeight.w500,
    color: AppColors.textCodeDark,
  );

  static const TextStyle codeMicroSecondaryBold = TextStyle(
    fontSize: 10,
    fontFamily: 'monospace',
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle codeNano = TextStyle(
    fontSize: 10,
    fontFamily: 'monospace',
    color: AppColors.slateMuted,
  );

  static const TextStyle codeMedium = TextStyle(
    fontSize: 12,
    fontFamily: 'monospace',
    color: AppColors.textPrimary,
  );

  static const TextStyle codeMediumBold = TextStyle(
    fontSize: 12,
    fontFamily: 'monospace',
    fontWeight: FontWeight.w500,
    color: AppColors.codeKeyword,
  );

  static const TextStyle codeMediumDark = TextStyle(
    fontSize: 12,
    fontFamily: 'monospace',
    color: AppColors.textDark,
    height: 1.45,
  );

  static const TextStyle codeMediumDarkBold = TextStyle(
    fontSize: 12,
    fontFamily: 'monospace',
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static const TextStyle codeMediumBlue = TextStyle(
    fontSize: 12,
    fontFamily: 'monospace',
    color: AppColors.accentBlueDark,
  );

  static const TextStyle codeMediumRed = TextStyle(
    fontSize: 12,
    fontFamily: 'monospace',
    color: AppColors.accentRedDark,
  );

  static const TextStyle codeHeader = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    fontFamily: 'monospace',
    color: AppColors.textPrimary,
  );

  static const TextStyle codeInline = TextStyle(
    fontSize: 14,
    fontFamily: 'monospace',
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle codeBlock = TextStyle(
    fontSize: 14,
    fontFamily: 'monospace',
    color: AppColors.codeText,
    height: 1.5,
  );

  static const TextStyle codeSnippetTitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.codeSnippetText,
  );

  static const TextStyle codeSnippetCopy = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.codeComment,
  );

  static const TextStyle browserUrl = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
  );
}
