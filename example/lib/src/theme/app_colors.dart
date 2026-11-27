import 'package:flutter/material.dart';

/// Design tokens and semantic color palette matching the Flutter Agentation design system.
/// All colors across the landing page and showcase application are centralized here.
abstract final class AppColors {
  // Page & Background Surfaces
  static const Color pageBackground = Color(0xFFF9FAFB);
  static const Color playgroundBackground = Color(0xFFF7F9FB);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBackgroundAlt = Color(0xFFF3F4F6);
  static const Color surfaceMuted = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color darkBackground = Color(0xFF09090B);

  // Borders & Dividers
  static const Color borderSubtle = Color(0xFFE5E7EB);
  static const Color borderMedium = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFD1D5DB);
  static const Color borderStrong = Color(0xFF9CA3AF);

  // Scrollbar
  static const Color scrollbarThumb = Color(0xFF94A3B8);
  static const Color scrollbarThumbHover = Color(0xFF64748B);
  static const Color scrollbarTrack = Color(0xFFF1F5F9);

  // Typography
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color textEyebrow = Color(0xFF505F76);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textWhite70 = Color(0xB3FFFFFF);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textHeadingDark = Color(0xFF191C1E);
  static const Color textCodeDark = Color(0xFF374151);

  // Slate Neutral Palette
  static const Color slateDark = Color(0xFF0F172A);
  static const Color slateCard = Color(0xFF1E293B);
  static const Color slateText = Color(0xFF334155);
  static const Color slateMuted = Color(0xFF64748B);
  static const Color slateBorder = Color(0xFF94A3B8);

  // Accents & Brand: Primary
  static const Color primaryButton = Color(0xFF2563EB);
  static const Color primaryButtonHover = Color(0xFF1D4ED8);

  // Accents: Blue
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color accentBlueDark = Color(0xFF1D4ED8);
  static const Color accentBlueDot = Color(0xFF3B82F6);
  static const Color accentBlueLight = Color(0xFFDBEAFE);
  static const Color accentBlueBorder = Color(0xFFBFDBFE);
  static const Color accentBlueSubtle = Color(0xFFEFF6FF);
  static const Color accentBlueGlow = Color(0x332563EB);

  // Accents: Green
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentGreenDark = Color(0xFF15803D);
  static const Color accentGreenLight = Color(0xFFDCFCE7);
  static const Color accentGreenBorder = Color(0xFFBBF7D0);
  static const Color accentGreenSubtle = Color(0xFFF0FDF4);

  // Accents: Purple
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentPurpleSubtle = Color(0xFFF5F3FF);

  // Accents: Amber / Yellow
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentAmberDark = Color(0xFFB45309);
  static const Color accentAmberDeep = Color(0xFFA16207);
  static const Color accentAmberLight = Color(0xFFFEF3C7);
  static const Color accentAmberBorder = Color(0xFFFDE68A);
  static const Color accentAmberSubtle = Color(0xFFFEFCE8);

  // Accents: Red
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentRedMedium = Color(0xFFDC2626);
  static const Color accentRedDark = Color(0xFFB91C1C);
  static const Color accentRedLight = Color(0xFFFECDD3);
  static const Color accentRedSubtle = Color(0xFFFFF1F2);
  static const Color accentRedBorder = Color(0xFFFECDD3);

  // Traffic Lights (Window frame)
  static const Color trafficRed = Color(0xFFFF5F56);
  static const Color trafficYellow = Color(0xFFFFBD2E);
  static const Color trafficGreen = Color(0xFF27C93F);

  // Code & Syntax Highlights
  static const Color codeBackground = Color(0xFF18181B);
  static const Color codeText = Color(0xFFE4E4E7);
  static const Color codeKeyword = Color(0xFF93C5FD);
  static const Color codeString = Color(0xFF86EFAC);
  static const Color codeComment = Color(0xFF71717A);
  static const Color codeSnippetBorder = Color(0xFF27272A);
  static const Color codeSnippetText = Color(0xFFA1A1AA);

  // Shadows
  static const Color shadowSubtle = Color(0x0A000000);
  static const Color shadowLight = Color(0x0D000000);
  static const Color shadowMedium = Color(0x22000000);
  static const Color shadowHeavy = Color(0x33000000);
}
