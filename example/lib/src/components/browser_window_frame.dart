import 'package:flutter/material.dart';
import 'package:example/src/theme/app_dimensions.dart';

import '../theme/app_insets.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';
import 'app_icons.dart';
import '../theme/app_colors.dart';

class BrowserWindowFrame extends StatelessWidget {
  const BrowserWindowFrame({
    super.key,
    required this.child,
    this.title = 'Dashboard - Demo',
    this.url = 'localhost:8080/dashboard',
  });

  final Widget child;
  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadii.rounded12,
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSubtle,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Browser Top Bar
          Container(
            padding: AppInsets.h16v10,
            decoration: const BoxDecoration(
              color: AppColors.cardBackgroundAlt,
              border: Border(
                bottom: BorderSide(color: AppColors.borderSubtle),
              ),
            ),
            child: Row(
              children: [
                // Traffic light controls
                Row(
                  children: [
                    Container(
                      width: AppDimensions.d10,
                      height: AppDimensions.d10,
                      decoration: const BoxDecoration(
                        color: AppColors.trafficRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppDimensions.w6,
                    Container(
                      width: AppDimensions.d10,
                      height: AppDimensions.d10,
                      decoration: const BoxDecoration(
                        color: AppColors.trafficYellow,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppDimensions.w6,
                    Container(
                      width: AppDimensions.d10,
                      height: AppDimensions.d10,
                      decoration: const BoxDecoration(
                        color: AppColors.trafficGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                AppDimensions.w16,
                // Title and URL Pill
                Expanded(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: AppDimensions.d340),
                      padding: AppInsets.h12v4,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: AppRadii.rounded6,
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppIcons.lock(size: AppDimensions.d11, color: AppColors.textMuted),
                          AppDimensions.w6,
                          Flexible(
                            child: Text(
                              url,
                              style: AppTypography.browserUrl,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Window Body
          child,
        ],
      ),
    );
  }
}
