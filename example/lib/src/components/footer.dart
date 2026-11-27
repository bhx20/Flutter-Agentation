import 'package:flutter/material.dart';
import 'package:example/src/theme/app_dimensions.dart';

import '../constants/app_strings.dart';
import '../theme/app_insets.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';
import 'package:flutter_agentation/flutter_agentation.dart';
import '../services/pub_dev_service.dart';
import '../theme/app_colors.dart';
import '../utils/breakpoints.dart';
import '../utils/clipboard_helper.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(context);

    return ValueListenableBuilder<PubPackageData>(
      valueListenable: PubDevService.instance.packageNotifier,
      builder: (context, data, _) {
        return Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.borderMedium, width: AppDimensions.d1)),
          ),
          padding: isDesktop
              ? AppInsets.footerDesktop
              : AppInsets.footerMobile,
          child: Column(
            children: [
              // Top Row: Brand & Badges
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: AppDimensions.d24,
                runSpacing: AppDimensions.d16,
                children: [
                  _buildBrand(),
                  _buildBadges(context, data),
                ],
              ),
              const SizedBox(height: AppDimensions.d25),
              const Divider(color: AppColors.borderMedium, height: AppDimensions.d1),
              AppDimensions.h16,

              // Bottom Row: Copyright & Legal
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppDimensions.d20,
                runSpacing: AppDimensions.d12,
                children: [
                  _buildCopyright(),
                  _buildLegalLinks(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          AppStrings.footerTitle,
          style: AppTypography.footerTitle,
        ),
        AppDimensions.h4,
        Text(
          AppStrings.footerSubtitle,
          style: AppTypography.footerDesc,
        ),
      ],
    );
  }

  Widget _buildBadges(BuildContext context, PubPackageData data) {
    return Wrap(
      spacing: AppDimensions.d8,
      runSpacing: AppDimensions.d8,
      children: [
        _buildPillBadge(AppStrings.footerDart),
        _buildPillBadge(AppStrings.footerFlutter),
        _buildPillBadge('${data.grantedPoints}/${data.maxPoints} pts'),
        _buildPillBadge('Publisher: ${data.publisherId}'),
        _buildPillBadge(AppStrings.footerLicense),
        InkWell(
          onTap: () {
            ClipboardHelper.copy(
              context,
              data.repositoryUrl,
              successMessage: AppStrings.msgGithubCopied,
            );
          },
          borderRadius: AppRadii.rounded4,
          child: Container(
            padding: AppInsets.h9v5,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: AppRadii.rounded4,
              border: Border.all(color: AppColors.borderMedium),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AgentationIcons.send(size: AppDimensions.d13, color: AppColors.slateText),
                AppDimensions.w5,
                const Text(
                  AppStrings.footerGithubRepo,
                  style: AppTypography.buttonSlate,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPillBadge(String text) {
    return Container(
      padding: AppInsets.h9v5,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.rounded4,
        border: Border.all(color: AppColors.borderMedium),
      ),
      child: Text(
        text,
        style: AppTypography.badge,
      ),
    );
  }

  Widget _buildCopyright() {
    return const Text(
      AppStrings.footerCopyright,
      style: AppTypography.legalLink,
    );
  }

  Widget _buildLegalLinks() {
    return Wrap(
      spacing: AppDimensions.d16,
      runSpacing: AppDimensions.d8,
      children: [
        _buildLegalLink(AppStrings.footerPrivacy),
        _buildLegalLink(AppStrings.footerSecurity),
        _buildLegalLink(AppStrings.footerDocumentation),
      ],
    );
  }

  Widget _buildLegalLink(String text) {
    return InkWell(
      onTap: () {},
      child: Text(
        text,
        style: AppTypography.legalLink,
      ),
    );
  }
}

typedef AppFooter = FooterSection;
