import 'package:flutter/material.dart';
import 'package:example/src/theme/app_dimensions.dart';

import '../theme/app_insets.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';
import '../theme/app_colors.dart';
import 'app_text.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.value,
    required this.label,
    this.badge,
  });

  final String value;
  final String label;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppInsets.h16v16,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadii.rounded8,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppDimensions.d6,
            runSpacing: AppDimensions.d4,
            children: [
              AppText(
                value,
                style: AppTypography.metricValue,
              ),
              if (badge != null)
                Container(
                  padding: AppInsets.h4v2,
                  decoration: BoxDecoration(
                    color: AppColors.accentGreenSubtle,
                    borderRadius: AppRadii.rounded4,
                  ),
                  child: AppText(
                    badge!,
                    style: AppTypography.metricSub,
                  ),
                ),
            ],
          ),
          AppDimensions.h4,
          AppText(
            label,
            style: AppTypography.metricLabel,
          ),
        ],
      ),
    );
  }
}
