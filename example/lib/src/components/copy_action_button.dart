import 'package:flutter/material.dart';
import 'package:example/src/theme/app_dimensions.dart';
import 'package:flutter_agentation/flutter_agentation.dart';

import '../components/app_text.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';
import '../utils/clipboard_helper.dart';

/// Interactive button that copies text and animates to a green checkmark upon tap.
class CopyActionButton extends StatefulWidget {
  const CopyActionButton({
    super.key,
    required this.text,
    this.label = 'Copy',
    this.copiedLabel = 'Copied',
    this.iconSize = AppDimensions.d12,
    this.color,
  });

  final String text;
  final String label;
  final String copiedLabel;
  final double iconSize;
  final Color? color;

  @override
  State<CopyActionButton> createState() => _CopyActionButtonState();
}

class _CopyActionButtonState extends State<CopyActionButton> {
  final ValueNotifier<bool> _copiedNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _copiedNotifier.dispose();
    super.dispose();
  }

  void _onTap() {
    ClipboardHelper.copy(context, widget.text);
    if (!mounted) return;
    _copiedNotifier.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _copiedNotifier.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.color ?? AppColors.accentBlue;
    return InkWell(
      onTap: _onTap,
      borderRadius: AppRadii.rounded4,
      child: ValueListenableBuilder<bool>(
        valueListenable: _copiedNotifier,
        builder: (context, copied, _) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: copied
                ? Row(
                    key: const ValueKey('copied'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AgentationIcons.check(size: widget.iconSize, color: AppColors.accentGreen),
                      AppDimensions.w4,
                      AppText(
                        widget.copiedLabel,
                        style: AppTypography.badgeSmall.copyWith(color: AppColors.accentGreen),
                      ),
                    ],
                  )
                : Row(
                    key: const ValueKey('copy'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AgentationIcons.copy(size: widget.iconSize, color: activeColor),
                      AppDimensions.w4,
                      AppText(
                        widget.label,
                        style: AppTypography.badgeSmall.copyWith(color: activeColor),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
