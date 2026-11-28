import 'package:flutter/material.dart';
import 'package:example/src/theme/app_dimensions.dart';

import '../components/app_text.dart';
import '../constants/app_strings.dart';
import '../theme/app_insets.dart';
import '../theme/app_radii.dart';
import 'package:flutter_agentation/flutter_agentation.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/breakpoints.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final ValueNotifier<Set<int>> _expandedIndicesNotifier =
      ValueNotifier<Set<int>>({0, 1});

  @override
  void dispose() {
    _expandedIndicesNotifier.dispose();
    super.dispose();
  }

  static const List<_FaqData> _faqs = [
    _FaqData(
      category: 'BASICS',
      question: 'What is Flutter Agentation?',
      answer:
          'Flutter Agentation is an in-app visual feedback overlay and MCP server runtime designed for Flutter. It lets developers and reviewers click any live widget in a running Flutter application, capture exact RenderBox bounds and Dart source file locations, add actionable notes, and stream structured context directly to AI coding agents.',
    ),
    _FaqData(
      category: 'BASICS',
      question: 'Why not just take a screenshot and annotate?',
      answer:
          'Screenshots lose the direct connection to source code. When annotating a screenshot, an AI agent must guess what "the blue button" refers to. Flutter Agentation generates direct Dart source locations (e.g. lib/src/screens/dashboard.dart:42) and runtime widget hierarchy that agents can grep for and modify directly.',
    ),
    _FaqData(
      category: 'SETUP',
      question: 'How do I install and enable it in my app?',
      answer:
          'Add flutter_agentation to your pubspec.yaml dependencies. Then wrap your MaterialApp in builder: FlutterAgentation.builder(). The floating inspection launcher will automatically appear across Web, macOS, Windows, Linux, iOS, and Android.',
    ),
    _FaqData(
      category: 'MCP & AGENTS',
      question: 'How do AI coding agents connect to the feedback stream?',
      answer:
          'Run the agentation_mcp daemon or connect your agent to http://localhost:4747. Coding agents such as Claude Code, Codex, and Google Gemini CLI use standard Model Context Protocol (MCP) tools to query open pins, inspect widget properties, and mark items resolved.',
    ),
    _FaqData(
      category: 'WORKFLOW',
      question: 'Can I pause animations to inspect dynamic elements?',
      answer:
          'Yes. The floating inspection toolbar includes an instant animation pause toggle. Clicking pause freezes all Flutter tickers and transition controllers, letting you inspect and pin ephemeral toasts, dialogs, or motion states with ease.',
    ),
    _FaqData(
      category: 'OUTPUT',
      question: 'What output formats are supported?',
      answer:
          'You can copy structured Markdown formatted for coding agents, or export JSON conforming to the Agentation Feedback Schema (AFS 1.1) containing widget names, element keys, text values, and exact bounding boxes.',
    ),
  ];

  void _toggleIndex(int index) {
    final next = Set<int>.from(_expandedIndicesNotifier.value);
    if (next.contains(index)) {
      next.remove(index);
    } else {
      next.add(index);
    }
    _expandedIndicesNotifier.value = next;
  }

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
                const AppText(
                  AppStrings.faqOverline,
                  style: AppTypography.overline,
                ),
                AppDimensions.h6,
                AppText(
                  AppStrings.faqTitle,
                  style: isMobile ? AppTypography.h3 : AppTypography.h2,
                ),
              ],
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppDimensions.d480),
              child: const AppText(
                AppStrings.faqSubtitle,
                style: AppTypography.bodyMedium,
              ),
            ),
          ],
        ),
        AppDimensions.h28,
        const Divider(color: AppColors.borderSubtle, height: AppDimensions.d1),
        AppDimensions.h20,

        // Accordion List
        ValueListenableBuilder<Set<int>>(
          valueListenable: _expandedIndicesNotifier,
          builder: (context, expandedIndices, _) {
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _faqs.length,
              separatorBuilder: (context, index) => AppDimensions.h12,
              itemBuilder: (context, index) {
                final faq = _faqs[index];
                final isExpanded = expandedIndices.contains(index);

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: AppRadii.rounded8,
                    border: Border.all(
                      color: isExpanded ? AppColors.accentBlue : AppColors.borderSubtle,
                      width: isExpanded ? AppDimensions.d1_5 : AppDimensions.d1,
                    ),
                    boxShadow: isExpanded
                        ? const [
                            BoxShadow(
                              color: AppColors.accentBlueGlow,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: InkWell(
                    onTap: () => _toggleIndex(index),
                    borderRadius: AppRadii.rounded8,
                    mouseCursor: SystemMouseCursors.click,
                    child: Padding(
                      padding: AppInsets.h20v16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectionContainer.disabled(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: AppInsets.h6v2,
                                    decoration: BoxDecoration(
                                      color: AppColors.cardBackgroundAlt,
                                      borderRadius: AppRadii.rounded4,
                                    ),
                                    child: AppText(
                                      faq.category,
                                      style: AppTypography.badgeMicro,
                                      mouseCursor: SystemMouseCursors.click,
                                    ),
                                  ),
                                  AppDimensions.w12,
                                  Expanded(
                                    child: AppText(
                                      faq.question,
                                      mouseCursor: SystemMouseCursors.click,
                                      style: isExpanded
                                          ? AppTypography.faqQuestion.copyWith(
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.accentBlue,
                                              height: 1.3,
                                            )
                                          : AppTypography.faqQuestion.copyWith(height: 1.3),
                                    ),
                                  ),
                                  AppDimensions.w12,
                                  AnimatedRotation(
                                    turns: isExpanded ? 0.25 : 0.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: AgentationIcons.send(
                                      size: AppDimensions.d14,
                                      color: isExpanded ? AppColors.accentBlue : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isExpanded) ...[
                            AppDimensions.h12,
                            const Divider(color: AppColors.cardBackgroundAlt, height: AppDimensions.d1),
                            AppDimensions.h12,
                            AppText(
                              faq.answer,
                              style: AppTypography.faqAnswer,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _FaqData {
  const _FaqData({
    required this.category,
    required this.question,
    required this.answer,
  });

  final String category;
  final String question;
  final String answer;
}

typedef FaqSection = FaqPage;
