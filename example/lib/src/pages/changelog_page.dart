import 'package:flutter/material.dart';
import 'package:example/src/theme/app_dimensions.dart';

import '../constants/app_strings.dart';
import '../theme/app_theme.dart';
import '../theme/app_insets.dart';
import '../theme/app_radii.dart';
import 'package:flutter_agentation/flutter_agentation.dart';
import '../services/pub_dev_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/breakpoints.dart';
import '../utils/clipboard_helper.dart';

class ChangelogPage extends StatelessWidget {
  const ChangelogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

    return ValueListenableBuilder<PubPackageData>(
      valueListenable: PubDevService.instance.packageNotifier,
      builder: (context, data, _) {
        final releases = data.releases.isNotEmpty
            ? data.releases
            : PubPackageData.initial.releases;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: AppDimensions.d16,
              runSpacing: AppDimensions.d8,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.changelogOverline,
                      style: AppTypography.overline,
                    ),
                    AppDimensions.h6,
                    Text(
                      AppStrings.changelogTitle,
                      style: isMobile ? AppTypography.h3 : AppTypography.h2,
                    ),
                  ],
                ),
                Wrap(
                  spacing: AppDimensions.d8,
                  runSpacing: AppDimensions.d8,
                  children: [
                    OutlinedButton.icon(
                      style: AppTheme.compactOutlinedButton,
                      onPressed: () {
                        ClipboardHelper.copy(
                          context,
                          data.homepageUrl,
                          successMessage: AppStrings.msgPubDevCopied,
                        );
                      },
                      icon: AgentationIcons.send(
                          size: AppDimensions.d12, color: AppColors.textSecondary),
                      label: const Text(
                        AppStrings.changelogPubPackageBtn,
                        style: AppTypography.buttonSmall,
                      ),
                    ),
                    OutlinedButton.icon(
                      style: AppTheme.compactOutlinedButton,
                      onPressed: () {
                        ClipboardHelper.copy(
                          context,
                          '${data.repositoryUrl}${AppStrings.changelogPath}',
                          successMessage: AppStrings.msgChangelogCopied,
                        );
                      },
                      icon: AgentationIcons.component(
                          size: AppDimensions.d13, color: AppColors.textSecondary),
                      label: const Text(
                        AppStrings.changelogMdBtn,
                        style: AppTypography.buttonSmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            AppDimensions.h28,
            const Divider(color: AppColors.borderSubtle, height: AppDimensions.d1),
            AppDimensions.h24,

            // Releases List dynamically sourced from pub.dev / CHANGELOG.md
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: releases.length,
              separatorBuilder: (context, index) => const Padding(
                padding: AppInsets.v24,
                child: Divider(color: AppColors.borderSubtle, height: AppDimensions.d1),
              ),
              itemBuilder: (context, index) {
                final release = releases[index];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Release Header
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppDimensions.d10,
                      runSpacing: AppDimensions.d6,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              release.version,
                              style: AppTypography.codeHeader,
                            ),
                            AppDimensions.w10,
                            Container(
                              padding: AppInsets.h8v2,
                              decoration: BoxDecoration(
                                color: release.badge == 'Latest Release'
                                    ? AppColors.accentBlueLight
                                    : AppColors.cardBackgroundAlt,
                                borderRadius: AppRadii.rounded4,
                                border: Border.all(
                                  color: release.badge == 'Latest Release'
                                      ? AppColors.codeKeyword
                                      : AppColors.borderSubtle,
                                ),
                              ),
                              child: Text(
                                release.badge,
                                style: AppTypography.badgeTag.copyWith(color: release.badge == 'Latest Release' ? AppColors.accentBlueDark : AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          release.date,
                          style: AppTypography.bodySmallMuted,
                        ),
                      ],
                    ),
                    AppDimensions.h8,
                    Text(
                      release.description,
                      style: AppTypography.bodyMediumLoose.copyWith(height: 1.5),
                    ),
                    AppDimensions.h16,

                    // Changes list
                    ...release.changes.map((change) {
                      return Padding(
                        padding: AppInsets.b12,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: AppInsets.t2,
                              padding: AppInsets.h6v2,
                              decoration: BoxDecoration(
                                color: change.isAdded
                                    ? AppColors.accentGreenLight
                                    : AppColors.accentAmberLight,
                                borderRadius: AppRadii.rounded3,
                              ),
                              child: Text(
                                change.isAdded ? 'ADDED' : 'IMPROVED',
                                style: AppTypography.badgeMicro.copyWith(color: change.isAdded ? AppColors.accentGreenDark : AppColors.accentAmberDark),
                              ),
                            ),
                            AppDimensions.w10,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    change.title,
                                    style: AppTypography.sectionItemTitle,
                                  ),
                                  if (change.description != change.title &&
                                      change.description.isNotEmpty) ...[
                                    AppDimensions.h2,
                                    Text(
                                      change.description,
                                      style: AppTypography.bodySmallTertiary,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

typedef ChangelogSection = ChangelogPage;
