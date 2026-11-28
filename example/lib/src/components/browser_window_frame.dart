import 'package:flutter/material.dart';
import 'package:example/src/theme/app_dimensions.dart';

import '../theme/app_colors.dart';
import '../theme/app_insets.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';
import '../utils/breakpoints.dart';
import 'app_icons.dart';

/// Reusable browser tab / macOS window mockup frame.
///
/// Features:
/// - Fixed / managed URL and title bar decoration.
/// - Built-in window body decoration (background color and padding).
/// - Only inner use-case content is provided via [child].
/// - 10px corner radius with visible, crisp border and soft elevation shadow.
class BrowserWindowFrame extends StatelessWidget {
  const BrowserWindowFrame({
    super.key,
    required this.child,
    this.url = 'localhost:3000',
    this.title,
    this.trailing,
    this.borderRadius = AppRadii.browserWindow,
    this.borderColor = AppColors.borderLight,
    this.borderWidth = 1.0,
    this.backgroundColor = AppColors.cardBackground,
    this.headerColor = AppColors.surfaceLight,
    this.bodyColor = AppColors.pageBackground,
    this.bodyPadding,
    this.showTrafficLights = true,
    this.margin = const EdgeInsets.only(left: 6.0, right: 6.0, top: 4.0, bottom: 20.0),
  });

  final Widget child;
  final String url;
  final String? title;
  final Widget? trailing;
  final BorderRadius borderRadius;
  final Color borderColor;
  final double borderWidth;
  final Color backgroundColor;
  final Color headerColor;
  final Color bodyColor;
  final EdgeInsetsGeometry? bodyPadding;
  final bool showTrafficLights;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

    return Container(
      width: double.infinity,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 24,
            offset: Offset(0, 10),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Browser Top Bar / macOS Header
          Container(
            height: AppDimensions.d44,
            padding: AppInsets.h14,
            decoration: BoxDecoration(
              color: headerColor,
              border: Border(
                bottom: BorderSide(color: borderColor, width: 1.0),
              ),
            ),
            child: Row(
              children: [
                if (showTrafficLights) ...[
                  // Traffic light controls
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _TrafficDot(AppColors.accentRed),
                      AppDimensions.w6,
                      _TrafficDot(AppColors.accentAmber),
                      AppDimensions.w6,
                      _TrafficDot(AppColors.accentGreen),
                    ],
                  ),
                  AppDimensions.w16,
                ],

                // URL Bar Pill
                Flexible(
                  child: Container(
                    padding: AppInsets.h12v5,
                    decoration: BoxDecoration(
                      color: AppColors.textWhite,
                      borderRadius: AppRadii.rounded6,
                      border: Border.all(color: AppColors.borderMedium),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcons.lock(
                          size: AppDimensions.d12,
                          color: AppColors.textTertiary,
                        ),
                        AppDimensions.w6,
                        Flexible(
                          child: Text(
                            url,
                            style: AppTypography.codeMedium.copyWith(color: AppColors.textCodeDark),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (title != null) ...[
                  AppDimensions.w12,
                  Flexible(
                    child: Text(
                      title!,
                      style: AppTypography.codeSmallMuted,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],

                if (trailing != null) ...[
                  const Spacer(),
                  trailing!,
                ],
              ],
            ),
          ),

          // Window Body Container with built-in background & padding
          Container(
            width: double.infinity,
            color: bodyColor,
            padding: bodyPadding ??
                (isMobile ? AppInsets.cardCompact : AppInsets.all16),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _TrafficDot extends StatelessWidget {
  const _TrafficDot(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.d10,
      height: AppDimensions.d10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
