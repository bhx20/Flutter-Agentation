import 'package:flutter/material.dart';
import 'package:example/src/theme/app_dimensions.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

enum ActionButtonVariant {
  primary,
  secondary,
  outline,
}

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.variant = ActionButtonVariant.primary,
  });

  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final ActionButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final hasIcon = icon != null;

    switch (variant) {
      case ActionButtonVariant.primary:
        return FilledButton(
          style: AppTheme.actionButtonPrimary,
          onPressed: onPressed,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasIcon) ...[
                Icon(icon, size: AppDimensions.d16),
                AppDimensions.w8,
              ],
              Text(text, style: AppTypography.button),
            ],
          ),
        );

      case ActionButtonVariant.secondary:
        return FilledButton(
          style: AppTheme.actionButtonSecondary,
          onPressed: onPressed,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasIcon) ...[
                Icon(icon, size: AppDimensions.d16, color: AppColors.textPrimary),
                AppDimensions.w8,
              ],
              Text(
                text,
                style: AppTypography.button.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
        );

      case ActionButtonVariant.outline:
        return OutlinedButton(
          style: AppTheme.actionButtonOutline,
          onPressed: onPressed,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasIcon) ...[
                Icon(icon, size: AppDimensions.d16, color: AppColors.textPrimary),
                AppDimensions.w8,
              ],
              Text(
                text,
                style: AppTypography.button.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
        );
    }
  }
}
