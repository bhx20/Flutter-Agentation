import 'package:flutter/material.dart';
import 'package:example/src/theme/app_dimensions.dart';

import '../theme/app_insets.dart';
import '../theme/app_radii.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_text.dart';

class SectionBadge extends StatelessWidget {
  const SectionBadge({
    super.key,
    required this.label,
    this.dotColor,
    this.icon,
    this.isLight = true,
  });

  final String label;
  final Color? dotColor;
  final IconData? icon;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppInsets.h8v4,
      decoration: BoxDecoration(
        color: isLight ? AppColors.cardBackgroundAlt : AppColors.primaryButton,
        borderRadius: AppRadii.rounded4,
        border: Border.all(
          color: isLight ? AppColors.borderSubtle : AppColors.primaryButton,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            Container(
              width: AppDimensions.d6,
              height: AppDimensions.d6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            AppDimensions.w6,
          ],
          if (icon != null) ...[
            Icon(
              icon,
              size: AppDimensions.d12,
              color: isLight ? AppColors.textTertiary : AppColors.textWhite,
            ),
            AppDimensions.w4,
          ],
          Flexible(
            child: AppText(
              label.toUpperCase(),
              style: AppTypography.overline.copyWith(
                color: isLight ? AppColors.textSecondary : AppColors.textWhite,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
