import 'package:flutter/material.dart';
import 'package:example/src/theme/app_dimensions.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/breakpoints.dart';
import 'app_text.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.tag,
    required this.title,
    required this.description,
    this.tagDotColor,
    this.trailing,
  });

  final String tag;
  final String title;
  final String description;
  final Color? tagDotColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (tagDotColor != null) ...[
              Container(
                width: AppDimensions.d6,
                height: AppDimensions.d6,
                decoration: BoxDecoration(
                  color: tagDotColor,
                  shape: BoxShape.circle,
                ),
              ),
              AppDimensions.w8,
            ],
            Expanded(
              child: AppText(
                tag.toUpperCase(),
                style: AppTypography.overline.copyWith(
                  color: AppColors.textTertiary,
                  letterSpacing: 0.8,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        AppDimensions.h8,
        if (isMobile) ...[
          AppText(title, style: AppTypography.h1),
          AppDimensions.h8,
          AppText(description, style: AppTypography.lead.copyWith(fontSize: 16)),
          if (trailing != null) ...[
            AppDimensions.h12,
            trailing!,
          ],
        ] else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: AppText(title, style: AppTypography.h1),
              ),
              AppDimensions.w32,
              Expanded(
                flex: 6,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppText(
                        description,
                        style: AppTypography.lead.copyWith(fontSize: 16),
                      ),
                    ),
                    if (trailing != null) ...[
                      AppDimensions.w16,
                      trailing!,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
