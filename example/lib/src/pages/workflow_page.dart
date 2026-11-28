import 'package:flutter/material.dart';
import 'package:example/src/theme/app_dimensions.dart';

import '../components/app_text.dart';
import '../constants/app_strings.dart';
import '../theme/app_insets.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';
import '../theme/app_colors.dart';
import 'package:flutter_agentation/flutter_agentation.dart';

class WorkflowPage extends StatelessWidget {
  const WorkflowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── "How you use it" Header with trailing rule ──
        Row(
          children: [
            const AppText(
              AppStrings.workflowHeader,
              style: AppTypography.cardTitle,
            ),
            AppDimensions.w16,
            const Expanded(
              child: Divider(color: AppColors.borderSubtle, height: AppDimensions.d1),
            ),
          ],
        ),
        AppDimensions.h20,

        // ── 6 Numbered Steps List ──
        _buildStepRow(
          number: '1.',
          title: AppStrings.workflowStep1Title,
          description: AppStrings.workflowStep1Desc,
          iconWidget: AgentationIcons.listSparkle(size: AppDimensions.d13, color: AppColors.textSecondary),
        ),
        AppDimensions.h12,
        _buildStepRow(
          number: '2.',
          title: AppStrings.workflowStep2Title,
          description: AppStrings.workflowStep2Desc,
        ),
        AppDimensions.h12,
        _buildStepRow(
          number: '3.',
          title: AppStrings.workflowStep3Title,
          description: AppStrings.workflowStep3Desc,
        ),
        AppDimensions.h12,
        _buildStepRow(
          number: '4.',
          title: AppStrings.workflowStep4Title,
          description: AppStrings.workflowStep4Desc,
        ),
        AppDimensions.h12,
        _buildStepRow(
          number: '5.',
          title: AppStrings.workflowStep5Title,
          description: AppStrings.workflowStep5Desc,
          iconWidget: AgentationIcons.copy(size: AppDimensions.d13, color: AppColors.textSecondary),
        ),
        AppDimensions.h12,
        _buildStepRow(
          number: '6.',
          title: AppStrings.workflowStep6Title,
          description: AppStrings.workflowStep6Desc,
        ),
        AppDimensions.h28,

        // ── MCP Direct Quote / Callout Block ──
        Container(
          padding: AppInsets.tagRow,
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: AppColors.borderLight, width: AppDimensions.d2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.rich(
                const TextSpan(
                  style: AppTypography.bodyMediumLoose,
                  children: [
                    TextSpan(text: AppStrings.workflowMcpCalloutPrefix),
                    TextSpan(
                      text: AppStrings.workflowMcpCalloutHighlight,
                      style: AppTypography.bodyMediumLooseAccent,
                    ),
                    TextSpan(
                      text: AppStrings.workflowMcpCalloutSuffix,
                    ),
                  ],
                ),
              ),
              AppDimensions.h6,
              Container(
                padding: AppInsets.h8v3,
                decoration: BoxDecoration(
                  color: AppColors.cardBackgroundAlt,
                  borderRadius: AppRadii.rounded4,
                ),
                child: const AppText(
                  AppStrings.workflowZeroCopy,
                  style: AppTypography.caption,
                ),
              ),
            ],
          ),
        ),
        AppDimensions.h48,

        // ── "How agents use it" Header with trailing rule ──
        Row(
          children: [
            const AppText(
              'How agents use it',
              style: AppTypography.cardTitle,
            ),
            AppDimensions.w16,
            const Expanded(
              child: Divider(color: AppColors.borderSubtle, height: AppDimensions.d1),
            ),
          ],
        ),
        AppDimensions.h16,

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.d860),
          child: const AppText(
            'Give the output to Claude, Codex, Gemini, Grok, or any coding agent with access to your codebase. Depending on your output settings and what the page contains, your agent receives widget hierarchy, file:line paths, RenderBox bounds, and screenshot context.',
            style: AppTypography.bodyMediumLoose,
          ),
        ),
      ],
    );
  }

  Widget _buildStepRow({
    required String number,
    required String title,
    required String description,
    Widget? iconWidget,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: AppDimensions.d24,
          child: AppText(
            number,
            style: AppTypography.bodyMuted,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppDimensions.d6,
                children: [
                  AppText(
                    title,
                    style: AppTypography.sectionItemTitlePrimary,
                  ),
                  if (iconWidget != null)
                    Container(
                      padding: AppInsets.h4v1,
                      decoration: BoxDecoration(
                        color: AppColors.scrollbarTrack,
                        borderRadius: AppRadii.rounded4,
                        border: Border.all(color: AppColors.borderMedium),
                      ),
                      child: iconWidget,
                    ),
                ],
              ),
              AppDimensions.h2,
              AppText(
                description,
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

typedef WorkflowSection = WorkflowPage;
