import 'package:flutter/material.dart';
import 'package:example/src/theme/app_dimensions.dart';

import '../constants/app_strings.dart';
import '../theme/app_insets.dart';
import '../theme/app_radii.dart';
import '../theme/app_colors.dart';
import 'package:flutter_agentation/flutter_agentation.dart';
import '../theme/app_typography.dart';
import '../utils/breakpoints.dart';
import '../components/copy_action_button.dart';

class InstallationPage extends StatelessWidget {
  const InstallationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

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
                  AppStrings.quickstartOverline,
                  style: AppTypography.overline,
                ),
                AppDimensions.h6,
                Text(
                  AppStrings.quickstartTitle,
                  style: isMobile ? AppTypography.h3 : AppTypography.h2,
                ),
              ],
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppDimensions.d480),
              child: const Text(
                AppStrings.quickstartSubtitle,
                style: AppTypography.bodyMedium,
              ),
            ),
          ],
        ),
        AppDimensions.h28,
        const Divider(color: AppColors.borderSubtle, height: AppDimensions.d1),

        // Row 1: Cards 1 & 2
        Padding(
          padding: AppInsets.v24,
          child: isMobile
              ? Column(
                  children: [
                    _buildCard1(context),
                    AppDimensions.h28,
                    const Divider(color: AppColors.borderSubtle, height: AppDimensions.d1),
                    AppDimensions.h28,
                    _buildCard2(context),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildCard1(context)),
                    const SizedBox(width: AppDimensions.d36),
                    Expanded(child: _buildCard2(context)),
                  ],
                ),
        ),
        const Divider(color: AppColors.borderSubtle, height: AppDimensions.d1),

        // Row 2: Cards 3 & 4
        Padding(
          padding: AppInsets.v24,
          child: isMobile
              ? Column(
                  children: [
                    _buildCard3(context),
                    AppDimensions.h28,
                    const Divider(color: AppColors.borderSubtle, height: AppDimensions.d1),
                    AppDimensions.h28,
                    _buildCard4(context),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildCard3(context)),
                    const SizedBox(width: AppDimensions.d36),
                    Expanded(child: _buildCard4(context)),
                  ],
                ),
        ),
        const Divider(color: AppColors.borderSubtle, height: AppDimensions.d1),
      ],
    );
  }

  Widget _buildCard1(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppDimensions.d8,
          runSpacing: AppDimensions.d4,
          children: [
            Container(
              padding: AppInsets.h6v3,
              decoration: BoxDecoration(
                color: AppColors.cardBackgroundAlt,
                borderRadius: AppRadii.rounded4,
              ),
              child: const Text(
                '01 / DEPENDENCY',
                style: AppTypography.codeMicroSecondaryBold,
              ),
            ),
            const Text(
              'pubspec.yaml',
              style: AppTypography.codeSmallMuted,
            ),
          ],
        ),
        AppDimensions.h12,
        const Text(AppStrings.quickstartStep1Title, style: AppTypography.h3),
        AppDimensions.h6,
        const Text(
          'Add the official release from pub.dev directly into your project dependencies via terminal or pubspec.yaml:',
          style: AppTypography.bodySmallSecondary,
        ),
        AppDimensions.h16,

        _buildSnippet(
          context,
          label: 'CLI Command',
          code: 'flutter pub add flutter_agentation',
        ),
        AppDimensions.h12,
        _buildSnippet(
          context,
          label: 'Or pubspec.yaml',
          code: 'dependencies:\n  flutter:\n    sdk: flutter\n  flutter_agentation: ^1.0.0',
        ),
        AppDimensions.h24,

        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppDimensions.d8,
          runSpacing: AppDimensions.d4,
          children: const [
            Text(
              'Requires Dart 3.x+ & Flutter 3.22+',
              style: AppTypography.captionTertiary,
            ),
            Text(
              '^1.0.0',
              style: AppTypography.codeSmallTertiary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard2(BuildContext context) {
    const codeSnippet = '''import 'package:flutter/material.dart';
import 'package:flutter_agentation/flutter_agentation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      // Attach at the builder level to persist across all routes and modals:
      builder: FlutterAgentation.builder(),
      home: const HomeScreen(),
    );
  }
}''';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppDimensions.d8,
          runSpacing: AppDimensions.d4,
          children: [
            Container(
              padding: AppInsets.h6v3,
              decoration: BoxDecoration(
                color: AppColors.cardBackgroundAlt,
                borderRadius: AppRadii.rounded4,
              ),
              child: const Text(
                '02 / ENTRYPOINT',
                style: AppTypography.codeMicroSecondaryBold,
              ),
            ),
            const Text(
              'lib/main.dart',
              style: AppTypography.codeSmallMuted,
            ),
          ],
        ),
        AppDimensions.h12,
        const Text(AppStrings.quickstartStep2Title, style: AppTypography.h3),
        AppDimensions.h6,
        const Text(
          'Attach the inspection builder wrapper at the MaterialApp root to persist across all navigator routes and modals:',
          style: AppTypography.bodySmallSecondary,
        ),
        AppDimensions.h16,

        _buildSnippet(
          context,
          label: 'lib/main.dart',
          code: codeSnippet,
        ),
        AppDimensions.h14,

        Container(
          width: double.infinity,
          padding: AppInsets.all12,
          decoration: BoxDecoration(
            color: AppColors.pageBackground,
            borderRadius: AppRadii.rounded6,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: const Text(
            'Note: debugOnly: true is enabled by default. In release mode (kDebugMode == false), Flutter Agentation returns child widget tree directly with zero overhead.',
            style: AppTypography.captionSecondaryLoose,
          ),
        ),
      ],
    );
  }

  Widget _buildCard3(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppDimensions.d8,
          runSpacing: AppDimensions.d4,
          children: [
            Container(
              padding: AppInsets.h6v3,
              decoration: BoxDecoration(
                color: AppColors.cardBackgroundAlt,
                borderRadius: AppRadii.rounded4,
              ),
              child: const Text(
                '03 / SCAFFOLDING',
                style: AppTypography.codeMicroSecondaryBold,
              ),
            ),
            const Text(
              'Agent Auto-Config',
              style: AppTypography.codeSmallMuted,
            ),
          ],
        ),
        AppDimensions.h12,
        const Text(AppStrings.quickstartStep3Title, style: AppTypography.h3),
        AppDimensions.h6,
        const Text(
          'Run the scaffolding generator command in your project terminal to register MCP agent capabilities and promptless slash commands:',
          style: AppTypography.bodySmallSecondary,
        ),
        AppDimensions.h16,

        _buildSnippet(
          context,
          label: 'CLI Command',
          code: 'dart run flutter_agentation:setupmcp',
        ),
        AppDimensions.h16,

        const Text(
          'SCAFFOLDS .FLUTTER_AGENTATION/ DIRECTORY:',
          style: AppTypography.overlineMini,
        ),
        AppDimensions.h8,
        _buildScaffoldItem('mcp.json & config.json', 'SSE host & port 4747 bridge'),
        _buildScaffoldItem('tools.json', 'Schemas for all 6 native inspection tools'),
        _buildScaffoldItem('llm_instructions.md & SKILL.md', 'Agent prompt guidelines'),
        _buildScaffoldItem('Preconfigured slash commands', 'For Cursor, Windsurf, Claude & Cline'),
        AppDimensions.h20,

        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppDimensions.d8,
          runSpacing: AppDimensions.d4,
          children: const [
            Text(
              'Creates zero-config IDE bindings',
              style: AppTypography.captionTertiary,
            ),
            Text(
              ':4747/sse',
              style: AppTypography.codeSmallTertiary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard4(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppDimensions.d8,
          runSpacing: AppDimensions.d4,
          children: [
            Container(
              padding: AppInsets.h6v3,
              decoration: BoxDecoration(
                color: AppColors.cardBackgroundAlt,
                borderRadius: AppRadii.rounded4,
              ),
              child: const Text(
                '04 / EXECUTION',
                style: AppTypography.codeMicroSecondaryBold,
              ),
            ),
            const Text(
              'Runtime Inspection',
              style: AppTypography.codeSmallMuted,
            ),
          ],
        ),
        AppDimensions.h12,
        const Text(AppStrings.quickstartStep4Title, style: AppTypography.h3),
        AppDimensions.h6,
        const Text(
          'Launch your app on any supported device, desktop window, or emulator:',
          style: AppTypography.bodySmallSecondary,
        ),
        AppDimensions.h16,

        _buildSnippet(
          context,
          label: 'CLI Command',
          code: 'flutter run',
        ),
        AppDimensions.h14,

        const Text(
          'A floating toolbar with a crosshair icon will appear at the bottom-right corner of your running app.',
          style: AppTypography.bodySmallSecondary,
        ),
        AppDimensions.h12,

        Container(
          width: double.infinity,
          padding: AppInsets.h12v9,
          decoration: BoxDecoration(
            color: AppColors.pageBackground,
            borderRadius: AppRadii.rounded6,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              AgentationIcons.wireframe(size: AppDimensions.d16, color: AppColors.textTertiary),
              AppDimensions.w8,
              const Expanded(
                child: Text(
                  'Press Ctrl+Shift+A (Cmd+Shift+A on macOS) or tap toolbar icon to toggle inspection.',
                  style: AppTypography.captionDark,
                ),
              ),
            ],
          ),
        ),
        AppDimensions.h20,

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
                    color: AppColors.accentGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                AppDimensions.w7,
                const Text(
                  'Live SSE Server Active',
                  style: AppTypography.captionTertiary,
                ),
              ],
            ),
            const Text(
              '127.0.0.1:4747',
              style: AppTypography.codeSmallTertiary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSnippet(BuildContext context, {required String label, required String code}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppDimensions.d8,
          runSpacing: AppDimensions.d4,
          children: [
            Text(
              label,
              style: AppTypography.captionTertiary,
            ),
            CopyActionButton(text: code),
          ],
        ),
        AppDimensions.h6,
        Container(
          width: double.infinity,
          padding: AppInsets.h14v10,
          decoration: BoxDecoration(
            color: AppColors.textWhite,
            borderRadius: AppRadii.rounded6,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: SelectableText(
            code,
            style: AppTypography.codeMediumDark,
          ),
        ),
      ],
    );
  }

  Widget _buildScaffoldItem(String title, String desc) {
    return Padding(
      padding: AppInsets.b6,
      child: RichText(
        text: TextSpan(
          style: AppTypography.captionSecondary,
          children: [
            const TextSpan(text: '• ', style: AppTypography.sectionItemTitlePrimaryBold),
            TextSpan(
              text: title,
              style: AppTypography.codeSmallDarkBold,
            ),
            const TextSpan(text: ' : '),
            TextSpan(text: desc),
          ],
        ),
      ),
    );
  }
}

typedef QuickstartSection = InstallationPage;
