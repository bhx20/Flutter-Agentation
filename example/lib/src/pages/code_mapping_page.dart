import 'package:flutter/material.dart';
import 'package:example/src/theme/app_dimensions.dart';

import '../constants/app_strings.dart';
import '../theme/app_insets.dart';
import '../theme/app_radii.dart';
import 'package:flutter_agentation/flutter_agentation.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/breakpoints.dart';

class CodeMappingPage extends StatelessWidget {
  const CodeMappingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final isTablet = Breakpoints.isTablet(context);

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
                  AppStrings.codeMappingOverline,
                  style: AppTypography.overline,
                ),
                AppDimensions.h6,
                Text(
                  AppStrings.codeMappingTitle,
                  style: isMobile ? AppTypography.h3 : AppTypography.h2,
                ),
              ],
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppDimensions.d480),
              child: const Text(
                AppStrings.codeMappingSubtitle,
                style: AppTypography.bodyMedium,
              ),
            ),
          ],
        ),
        AppDimensions.h24,
        const Divider(color: AppColors.borderSubtle, height: AppDimensions.d1),
        AppDimensions.h24,

        // Comparison Box (Single Card with 2 columns)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: AppRadii.rounded8,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top overline inside box
              Padding(
                padding: AppInsets.h20v14,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppDimensions.d12,
                  runSpacing: AppDimensions.d6,
                  children: const [
                    Text(
                      AppStrings.codeMappingComparisonOverline1,
                      style: AppTypography.overline,
                    ),
                    Text(
                      AppStrings.codeMappingComparisonOverline2,
                      style: AppTypography.overline,
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.borderSubtle, height: AppDimensions.d1),

              // Two Comparison Columns
              Padding(
                padding: AppInsets.all20,
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWithoutAgentation(),
                          AppDimensions.h20,
                          const Divider(color: AppColors.borderSubtle),
                          AppDimensions.h20,
                          _buildWithAgentation(),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildWithoutAgentation()),
                          Container(
                            width: AppDimensions.d1,
                            height: AppDimensions.d160,
                            color: AppColors.borderSubtle,
                            margin: AppInsets.h24,
                          ),
                          Expanded(child: _buildWithAgentation()),
                        ],
                      ),
              ),
            ],
          ),
        ),
        AppDimensions.h48,

        // Bidirectional Agent Loop Header
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
                  AppStrings.codeMappingLoopOverline,
                  style: AppTypography.overline,
                ),
                AppDimensions.h6,
                Text(
                  AppStrings.codeMappingLoopTitle,
                  style: isMobile ? AppTypography.h3 : AppTypography.h2,
                ),
              ],
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppDimensions.d440),
              child: const Text(
                AppStrings.codeMappingLoopSubtitle,
                style: AppTypography.bodyMedium,
              ),
            ),
          ],
        ),
        AppDimensions.h24,

        // 4 Columns Loop with top & bottom borders
        Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.borderSubtle),
              bottom: BorderSide(color: AppColors.borderSubtle),
            ),
          ),
          child: isMobile
              ? Column(
                  children: [
                    _buildLoopColumn(AppStrings.codeMappingLoop1Label, AppStrings.codeMappingLoop1Title, AppStrings.codeMappingLoop1Desc, isLast: false),
                    _buildLoopColumn(AppStrings.codeMappingLoop2Label, AppStrings.codeMappingLoop2Title, AppStrings.codeMappingLoop2Desc, isLast: false),
                    _buildLoopColumn(AppStrings.codeMappingLoop3Label, AppStrings.codeMappingLoop3Title, AppStrings.codeMappingLoop3Desc, isLast: false),
                    _buildLoopColumn(AppStrings.codeMappingLoop4Label, AppStrings.codeMappingLoop4Title, AppStrings.codeMappingLoop4Desc, isLast: true),
                  ],
                )
              : isTablet
                  ? LayoutBuilder(
                      builder: (context, constraints) {
                        final itemWidth = (constraints.maxWidth - 24) / 2;
                        return Wrap(
                          spacing: AppDimensions.d24,
                          runSpacing: AppDimensions.d16,
                          children: [
                            SizedBox(width: itemWidth, child: _buildLoopColumn(AppStrings.codeMappingLoop1Label, AppStrings.codeMappingLoop1Title, AppStrings.codeMappingLoop1Desc, isLast: false)),
                            SizedBox(width: itemWidth, child: _buildLoopColumn(AppStrings.codeMappingLoop2Label, AppStrings.codeMappingLoop2Title, AppStrings.codeMappingLoop2Desc, isLast: false)),
                            SizedBox(width: itemWidth, child: _buildLoopColumn(AppStrings.codeMappingLoop3Label, AppStrings.codeMappingLoop3Title, AppStrings.codeMappingLoop3Desc, isLast: false)),
                            SizedBox(width: itemWidth, child: _buildLoopColumn(AppStrings.codeMappingLoop4Label, AppStrings.codeMappingLoop4Title, AppStrings.codeMappingLoop4Desc, isLast: true)),
                          ],
                        );
                      },
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildLoopColumn(AppStrings.codeMappingLoop1Label, AppStrings.codeMappingLoop1Title, AppStrings.codeMappingLoop1Desc, isLast: false)),
                        Expanded(child: _buildLoopColumn(AppStrings.codeMappingLoop2Label, AppStrings.codeMappingLoop2Title, AppStrings.codeMappingLoop2Desc, isLast: false)),
                        Expanded(child: _buildLoopColumn(AppStrings.codeMappingLoop3Label, AppStrings.codeMappingLoop3Title, AppStrings.codeMappingLoop3Desc, isLast: false)),
                        Expanded(child: _buildLoopColumn(AppStrings.codeMappingLoop4Label, AppStrings.codeMappingLoop4Title, AppStrings.codeMappingLoop4Desc, isLast: true)),
                      ],
                    ),
        ),
        AppDimensions.h16,

        // Bottom Info Note
        Row(
          children: [
            AgentationIcons.help(size: AppDimensions.d15, color: AppColors.textTertiary),
            AppDimensions.w8,
            const Flexible(
              child: Text(
                AppStrings.codeMappingNote,
                style: AppTypography.bodySmallTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWithoutAgentation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppDimensions.d8,
          runSpacing: AppDimensions.d4,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: AppDimensions.d7,
                  height: AppDimensions.d7,
                  decoration: const BoxDecoration(
                    color: AppColors.accentRedMedium,
                    shape: BoxShape.circle,
                  ),
                ),
                AppDimensions.w8,
                const Flexible(
                  child: Text(
                    'WITHOUT FLUTTER AGENTATION',
                    style: AppTypography.badgeSmallRed,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Text(
              'Ambiguous NL Prompt',
              style: AppTypography.captionMuted,
            ),
          ],
        ),
        AppDimensions.h12,
        const Text(
          'Describe widgets subjectively ("the blue rounded button in the bottom navigation") and hope the agent guesses the correct nested build() method.',
          style: AppTypography.bodyMedium,
        ),
        AppDimensions.h16,
        Container(
          width: double.infinity,
          padding: AppInsets.h14v10,
          decoration: BoxDecoration(
            color: AppColors.accentRedSubtle,
            borderRadius: AppRadii.rounded6,
            border: Border.all(color: AppColors.accentRedBorder),
          ),
          child: const Text(
            '> prompt: "Fix the blue button in the sidebar"',
            style: AppTypography.codeMediumRed,
          ),
        ),
      ],
    );
  }

  Widget _buildWithAgentation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppDimensions.d8,
          runSpacing: AppDimensions.d4,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: AppDimensions.d7,
                  height: AppDimensions.d7,
                  decoration: const BoxDecoration(
                    color: AppColors.accentBlue,
                    shape: BoxShape.circle,
                  ),
                ),
                AppDimensions.w8,
                const Flexible(
                  child: Text(
                    'WITH FLUTTER AGENTATION',
                    style: AppTypography.badgeSmallSpaced,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Text(
              'Direct Dart Source Line',
              style: AppTypography.badgeSmallSemiBold,
            ),
          ],
        ),
        AppDimensions.h12,
        RichText(
          text: TextSpan(
            style: AppTypography.bodyMedium,
            children: [
              const TextSpan(text: 'Pin the exact RenderBox with breadcrumb ancestry '),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Container(
                  padding: AppInsets.h5v2,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackgroundAlt,
                    borderRadius: AppRadii.rounded4,
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: const Text(
                    'Scaffold > SafeArea > ElevatedButton',
                    style: AppTypography.codeSmallDarkBold,
                  ),
                ),
              ),
              const TextSpan(text: ' and jump straight to the source definition.'),
            ],
          ),
        ),
        AppDimensions.h16,
        Container(
          width: double.infinity,
          padding: AppInsets.h14v10,
          decoration: BoxDecoration(
            color: AppColors.accentBlueSubtle,
            borderRadius: AppRadii.rounded6,
            border: Border.all(color: AppColors.accentBlueBorder),
          ),
          child: const Text(
            '> resolved: ElevatedButton [lib/screens/dashboard.dart:64] Key(\'action_btn\')',
            style: AppTypography.codeMediumBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildLoopColumn(String label, String title, String desc, {required bool isLast}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: isLast ? BorderSide.none : const BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      padding: AppInsets.h16v20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.overlineMini,
          ),
          AppDimensions.h10,
          Text(
            title,
            style: AppTypography.cardTitleSmall,
          ),
          AppDimensions.h6,
          Text(
            desc,
            style: AppTypography.bodySmallTertiary.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}

typedef CodeMappingSection = CodeMappingPage;
