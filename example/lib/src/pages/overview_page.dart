import 'package:flutter/material.dart';
import 'package:example/src/theme/app_dimensions.dart';

import 'package:flutter_agentation/flutter_agentation.dart';

import '../constants/app_strings.dart';
import '../routes/app_router.dart';
import '../services/pub_dev_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_insets.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';
import '../utils/breakpoints.dart';
import '../utils/clipboard_helper.dart';
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
          onGetStarted: () => onNavigate(AppRouter.installation),
          onNavigate: onNavigate,
          activeSection: AppRouter.overview,
        ),
        AppDimensions.h36,
        const MetricsSection(),
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
            // Top quick install pill
            Align(
              alignment: isMobile ? Alignment.centerLeft : Alignment.centerRight,
              child: _InstallPill(command: 'flutter pub add ${data.name}'),
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
            AppDimensions.h24,

            // Focused CTAs Row (rounded 4px, py 10, px 16)
            Wrap(
              spacing: AppDimensions.d8,
              runSpacing: AppDimensions.d10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton(
                  onPressed: onGetStarted ??
                      () {
                        ClipboardHelper.copy(
                          context,
                          'flutter pub add ${data.name}',
                          successMessage: 'Added ${data.name} to pubspec.yaml',
                        );
                      },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Flexible(
                        child: Text(
                          AppStrings.heroCtaGetStarted,
                          style: AppTypography.buttonWhite,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AppDimensions.w8,
                      AgentationIcons.send(size: AppDimensions.d13, color: AppColors.textWhite),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    ClipboardHelper.copy(
                      context,
                      AppStrings.heroCommandSetup,
                      successMessage: AppStrings.msgSetupMcpCopied,
                    );
                  },
                  icon: AgentationIcons.component(size: AppDimensions.d15, color: AppColors.textSecondary),
                  label: const Text(
                    AppStrings.heroCtaCliSetup,
                    style: AppTypography.button,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _InstallPill extends StatefulWidget {
  const _InstallPill({required this.command});

  final String command;

  @override
  State<_InstallPill> createState() => _InstallPillState();
}

class _InstallPillState extends State<_InstallPill> {
  bool _copied = false;

  void _onTap() {
    ClipboardHelper.copy(context, widget.command);
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _onTap,
      borderRadius: AppRadii.rounded6,
      child: Padding(
        padding: AppInsets.v4,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: _copied
                    ? AppTypography.codeMedium.copyWith(color: AppColors.accentGreen, fontWeight: FontWeight.w500)
                    : AppTypography.codeMedium.copyWith(color: AppColors.textCodeDark, fontWeight: FontWeight.w500),
                child: Text(
                  widget.command,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            AppDimensions.w8,
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: _copied
                  ? KeyedSubtree(
                      key: const ValueKey('install_check'),
                      child: AgentationIcons.check(
                        size: AppDimensions.d13,
                        color: AppColors.accentGreen,
                      ),
                    )
                  : KeyedSubtree(
                      key: const ValueKey('install_copy'),
                      child: AgentationIcons.copy(
                        size: AppDimensions.d13,
                        color: AppColors.textTertiary,
                      ),
                    ),
            ),
          ],
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
            color: Colors.transparent,
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
