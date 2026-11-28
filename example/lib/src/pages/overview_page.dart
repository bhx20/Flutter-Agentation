import 'package:flutter/material.dart';
import 'package:example/src/theme/app_dimensions.dart';

import '../constants/app_strings.dart';
import '../components/app_icons.dart';
import '../components/native_link_wrapper.dart';
import '../routes/app_router.dart';
import '../services/pub_dev_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_insets.dart';
import '../theme/app_typography.dart';
import '../utils/breakpoints.dart';
import 'code_mapping_page.dart';
import 'interactive_preview_page.dart';
import 'workflow_page.dart';

/// Overview content page containing hero, live metrics, interactive preview,
/// workflow steps, and code mapping pages.
class OverviewPage extends StatelessWidget {
  const OverviewPage({
    super.key,
    required this.verticalSpacing,
    required this.onNavigate,
  });

  final double verticalSpacing;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HeroSection(
          onNavigate: onNavigate,
          activeSection: AppRouter.overview,
        ),
        SizedBox(height: verticalSpacing),
        const InteractivePreviewPage(),
        SizedBox(height: verticalSpacing),
        const WorkflowPage(),
        SizedBox(height: verticalSpacing),
        const CodeMappingPage(),
      ],
    );
  }
}


class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    this.onGetStarted,
    this.onNavigate,
    this.activeSection = 'overview',
  });

  final VoidCallback? onGetStarted;
  final ValueChanged<String>? onNavigate;
  final String activeSection;

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

    return ValueListenableBuilder<PubPackageData>(
      valueListenable: PubDevService.instance.packageNotifier,
      builder: (context, data, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top quick CTA pill
            Align(
              alignment: isMobile ? Alignment.centerLeft : Alignment.centerRight,
              child: _InstallPill(
                url: data.homepageUrl,
                onTap: onGetStarted,
              ),
            ),
            AppDimensions.h24,

            // Display Headline
            Text(
              AppStrings.heroDisplay,
              style: isMobile ? AppTypography.displayMobile : AppTypography.display,
            ),
            AppDimensions.h14,

            // Subtitle / Description paragraph matching screenshot
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppDimensions.d720),
              child: Text(
                AppStrings.heroSubtitle,
                style: isMobile ? AppTypography.body : AppTypography.lead,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InstallPill extends StatefulWidget {
  const _InstallPill({this.url, this.onTap});

  final String? url;
  final VoidCallback? onTap;

  @override
  State<_InstallPill> createState() => _InstallPillState();
}

class _InstallPillState extends State<_InstallPill> {
  final ValueNotifier<bool> _isHoveredNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isHoveredNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetUrl = widget.url ?? AppStrings.defaultHomepageUrl;

    return SelectionContainer.disabled(
      child: NativeLinkWrapper(
        url: targetUrl,
        target: LinkTarget.blank,
        onTap: widget.onTap,
        hoverNotifier: _isHoveredNotifier,
        child: Padding(
          padding: AppInsets.v4,
          child: ValueListenableBuilder<bool>(
            valueListenable: _isHoveredNotifier,
            builder: (context, isHovered, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOut,
                      style: AppTypography.codeMedium.copyWith(
                        color: isHovered
                            ? AppColors.primaryButton
                            : AppColors.textCodeDark,
                        fontWeight: FontWeight.w500,
                      ),
                      child: const Text(
                        AppStrings.heroCtaGetStarted,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  AppDimensions.w8,
                  AnimatedSlide(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    offset: isHovered ? const Offset(0.3, 0) : Offset.zero,
                    child: AppIcons.arrowRight(
                      size: AppDimensions.d13,
                      color: isHovered
                          ? AppColors.primaryButton
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}


class MetricsSection extends StatelessWidget {
  const MetricsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final isTablet = Breakpoints.isTablet(context);

    return ValueListenableBuilder<PubPackageData>(
      valueListenable: PubDevService.instance.packageNotifier,
      builder: (context, data, _) {
        final platformSummary = data.isWasmReady
            ? '${AppStrings.metricsWasmReady} • ${data.platforms.map((p) => p[0].toUpperCase() + p.substring(1)).join(', ')}'
            : data.platforms
                  .map((p) => p[0].toUpperCase() + p.substring(1))
                  .join(', ');

        final metrics = [
          (
            value: '${data.grantedPoints}',
            label: AppStrings.metricsPubPoints,
          ),
          (
            value: '${data.downloadCount30Days} ${AppStrings.metricsDownloads}',
            label: AppStrings.metricsDownloads30Days,
          ),
          (
            value: '${data.likeCount} ${AppStrings.metricsLikes}',
            label: AppStrings.metricsCommunityLikes,
          ),
          (
            value: '${data.platforms.length}/6 ${AppStrings.metricsPlatforms}',
            label: platformSummary,
          ),
        ];

        return Container(
          width: double.infinity,
          padding: isMobile ? AppInsets.v18 : AppInsets.v22,
          decoration: const BoxDecoration(
            color: AppColors.transparent,
            border: Border(
              top: BorderSide(color: AppColors.borderSubtle, width: AppDimensions.d1),
              bottom: BorderSide(color: AppColors.borderSubtle, width: AppDimensions.d1),
            ),
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(metrics.length, (index) {
                    final m = metrics[index];
                    return Padding(
                      padding: index < metrics.length - 1
                          ? AppInsets.b16
                          : AppInsets.none,
                      child: _buildMetricItem(m.value, m.label),
                    );
                  }),
                )
              : isTablet
              ? Wrap(
                  spacing: AppDimensions.d24,
                  runSpacing: AppDimensions.d16,
                  children: metrics.map((m) {
                    return SizedBox(
                      width: AppDimensions.d260,
                      child: _buildMetricItem(m.value, m.label),
                    );
                  }).toList(),
                )
              : Row(
                  children: List.generate(metrics.length, (index) {
                    final m = metrics[index];
                    return Expanded(child: _buildMetricItem(m.value, m.label));
                  }),
                ),
        );
      },
    );
  }

  Widget _buildMetricItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTypography.metricValue.copyWith(letterSpacing: -0.4),
        ),
        AppDimensions.h4,
        Text(
          label,
          style: AppTypography.captionTertiary.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}
