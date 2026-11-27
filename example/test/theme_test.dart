import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/src/theme/app_colors.dart';
import 'package:example/src/theme/app_theme.dart';
import 'package:example/src/theme/app_typography.dart';

void main() {
  group('AppColors Tests', () {
    test('verifies primary theme colors are defined properly', () {
      expect(AppColors.pageBackground, const Color(0xFFF9FAFB));
      expect(AppColors.cardBackground, const Color(0xFFFFFFFF));
      expect(AppColors.primaryButton, const Color(0xFF2563EB));
      expect(AppColors.accentBlue, const Color(0xFF2563EB));
      expect(AppColors.accentGreen, const Color(0xFF10B981));
      expect(AppColors.accentPurple, const Color(0xFF8B5CF6));
      expect(AppColors.accentAmber, const Color(0xFFF59E0B));
      expect(AppColors.accentRed, const Color(0xFFEF4444));
    });

    test('verifies traffic light colors for window frame', () {
      expect(AppColors.trafficRed, const Color(0xFFFF5F56));
      expect(AppColors.trafficYellow, const Color(0xFFFFBD2E));
      expect(AppColors.trafficGreen, const Color(0xFF27C93F));
    });
  });

  group('AppTheme Tests', () {
    test('verifies lightTheme generates expected ThemeData', () {
      final theme = AppTheme.lightTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, AppColors.pageBackground);
      expect(theme.colorScheme.primary, AppColors.primaryButton);
      expect(theme.colorScheme.surface, AppColors.cardBackground);
      expect(theme.dividerTheme.color, AppColors.borderSubtle);
    });
  });

  group('AppTypography Tests', () {
    test('verifies typography scales and weights', () {
      expect(AppTypography.display.fontSize, 28);
      expect(AppTypography.display.fontWeight, FontWeight.w500);
      expect(AppTypography.displayMobile.fontSize, 22);
      expect(AppTypography.h1.fontSize, 26);
      expect(AppTypography.h2.fontSize, 20);
      expect(AppTypography.h3.fontSize, 16);
      expect(AppTypography.body.fontSize, 14);
      expect(AppTypography.overline.fontSize, 12);
      expect(AppTypography.code.fontFamily, 'monospace');
    });
  });
}

