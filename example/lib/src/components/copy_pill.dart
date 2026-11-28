import 'package:flutter/material.dart';
import 'package:example/src/theme/app_dimensions.dart';

import '../theme/app_insets.dart';
import '../theme/app_radii.dart';
import 'package:flutter_agentation/flutter_agentation.dart';
import '../components/app_text.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/clipboard_helper.dart';

class CopyPill extends StatefulWidget {
  const CopyPill({
    super.key,
    required this.command,
    this.label,
    this.onCopied,
  });

  final String command;
  final String? label;
  final VoidCallback? onCopied;

  @override
  State<CopyPill> createState() => _CopyPillState();
}

class _CopyPillState extends State<CopyPill> {
  final ValueNotifier<bool> _copiedNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _copiedNotifier.dispose();
    super.dispose();
  }

  Future<void> _handleCopy() async {
    final success = await ClipboardHelper.copy(
      context,
      widget.command,
      successMessage: 'Copied: ${widget.command}',
    );
    if (success && mounted) {
      _copiedNotifier.value = true;
      widget.onCopied?.call();
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _copiedNotifier.value = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SelectionContainer.disabled(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleCopy,
          child: ValueListenableBuilder<bool>(
            valueListenable: _copiedNotifier,
            builder: (context, copied, _) {
              return Container(
                padding: AppInsets.h10v6,
                decoration: BoxDecoration(
                  color: copied ? AppColors.accentGreenSubtle : AppColors.cardBackgroundAlt,
                  borderRadius: AppRadii.rounded6,
                  border: Border.all(
                    color: copied ? AppColors.accentGreen : AppColors.borderSubtle,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.label != null) ...[
                      AppText(
                        widget.label!,
                        mouseCursor: SystemMouseCursors.click,
                        style: AppTypography.codeSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      AppDimensions.w6,
                    ],
                    Flexible(
                      child: AppText(
                        widget.command,
                        mouseCursor: SystemMouseCursors.click,
                        style: AppTypography.codeSmall.copyWith(
                          color: copied ? AppColors.accentGreen : AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppDimensions.w8,
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                      child: copied
                          ? KeyedSubtree(
                              key: const ValueKey('pill_check'),
                              child: AgentationIcons.check(
                                size: AppDimensions.d13,
                                color: AppColors.accentGreen,
                              ),
                            )
                          : KeyedSubtree(
                              key: const ValueKey('pill_copy'),
                              child: AgentationIcons.copy(
                                size: AppDimensions.d13,
                                color: AppColors.textTertiary,
                              ),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
