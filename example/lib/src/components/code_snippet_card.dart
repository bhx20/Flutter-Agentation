import 'package:flutter/material.dart';
import 'package:example/src/theme/app_dimensions.dart';

import '../theme/app_insets.dart';
import '../theme/app_radii.dart';
import 'package:flutter_agentation/flutter_agentation.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/clipboard_helper.dart';
import 'app_text.dart';

class CodeSnippetCard extends StatefulWidget {
  const CodeSnippetCard({
    super.key,
    required this.code,
    this.title,
    this.language = 'dart',
    this.showLineNumbers = false,
  });

  final String code;
  final String? title;
  final String language;
  final bool showLineNumbers;

  @override
  State<CodeSnippetCard> createState() => _CodeSnippetCardState();
}

class _CodeSnippetCardState extends State<CodeSnippetCard> {
  final ValueNotifier<bool> _copiedNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _copiedNotifier.dispose();
    super.dispose();
  }

  Future<void> _handleCopy() async {
    final success = await ClipboardHelper.copy(
      context,
      widget.code,
      successMessage: 'Code copied to clipboard',
    );
    if (success && mounted) {
      _copiedNotifier.value = true;
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _copiedNotifier.value = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.codeBackground,
        borderRadius: AppRadii.rounded8,
        border: Border.all(color: AppColors.codeSnippetBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.title != null) ...[
            Container(
              padding: AppInsets.h14v8,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.codeSnippetBorder),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(widget.title!, style: AppTypography.codeSnippetTitle),
                  InkWell(
                    onTap: _handleCopy,
                    child: Padding(
                      padding: AppInsets.all2,
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _copiedNotifier,
                        builder: (context, copied, _) {
                          return Row(
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(scale: anim, child: child),
                                child: copied
                                    ? KeyedSubtree(
                                        key: const ValueKey('code_check'),
                                        child: AgentationIcons.check(
                                          size: AppDimensions.d13,
                                          color: AppColors.accentGreen,
                                        ),
                                      )
                                    : KeyedSubtree(
                                        key: const ValueKey('code_copy'),
                                        child: AgentationIcons.copy(
                                          size: AppDimensions.d13,
                                          color: AppColors.codeComment,
                                        ),
                                      ),
                              ),
                              AppDimensions.w4,
                              AppText(
                                copied ? 'Copied' : 'Copy',
                                style: copied
                                    ? AppTypography.codeSnippetCopy.copyWith(
                                        color: AppColors.accentGreen,
                                      )
                                    : AppTypography.codeSnippetCopy,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Padding(
            padding: AppInsets.all14,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: AppText(widget.code, style: AppTypography.code),
            ),
          ),
        ],
      ),
    );
  }
}
