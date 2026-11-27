import 'package:flutter/material.dart';
import 'package:example/src/theme/app_dimensions.dart';

import '../components/app_icons.dart';
import '../constants/app_strings.dart';
import '../theme/app_insets.dart';
import '../theme/app_radii.dart';
import 'package:flutter_agentation/flutter_agentation.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/breakpoints.dart';

class InteractivePreviewPage extends StatefulWidget {
  const InteractivePreviewPage({super.key});

  @override
  State<InteractivePreviewPage> createState() =>
      _InteractivePreviewPageState();
}

class _InteractivePreviewPageState extends State<InteractivePreviewPage> {
  bool _isCalloutVisible = true;

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.playgroundBackground,
        borderRadius: AppRadii.rounded8,
      ),
      padding: isMobile
          ? AppInsets.playgroundPaddingMobile
          : AppInsets.playgroundPaddingDesktop,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overline & Header Row (Figma Node 2399:55)
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: AppDimensions.d16,
            runSpacing: AppDimensions.d10,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.previewEyebrow,
                    style: AppTypography.eyebrow,
                  ),
                  AppDimensions.h4,
                  Text(
                    AppStrings.previewTitle,
                    style: isMobile
                        ? AppTypography.h3
                        : AppTypography.displayMedium,
                  ),
                ],
              ),
              Container(
                padding: AppInsets.h10v4,
                decoration: BoxDecoration(
                  color: AppColors.textWhite,
                  borderRadius: AppRadii.roundedFull,
                  border: Border.all(color: AppColors.borderMedium),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: AppDimensions.d7,
                      height: AppDimensions.d7,
                      decoration: const BoxDecoration(
                        color: AppColors.accentBlueDot,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppDimensions.w7,
                    const Flexible(
                      child: Text(
                        AppStrings.previewTargetScreen,
                        style: AppTypography.bodySmallCodeDark,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppDimensions.h24,

          // macOS Window Frame
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.textWhite,
              borderRadius: AppRadii.rounded8,
              border: Border.all(color: AppColors.borderMedium),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // macOS Header
                Container(
                  height: AppDimensions.d44,
                  padding: AppInsets.h14,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceLight,
                    border: Border(
                      bottom: BorderSide(color: AppColors.borderMedium),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Traffic lights
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _Dot(AppColors.accentRed),
                          AppDimensions.w6,
                          _Dot(AppColors.accentAmber),
                          AppDimensions.w6,
                          _Dot(AppColors.accentGreen),
                        ],
                      ),
                      AppDimensions.w20,

                      // URL bar
                      Container(
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
                            Text(
                              'localhost:3000',
                              style: AppTypography.codeMedium.copyWith(color: AppColors.textCodeDark),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),

                      // Engine info
                      if (!isMobile)
                        const Text(
                          'Flutter 3.27 Web Engine',
                          style: AppTypography.codeSmallMuted,
                        ),
                    ],
                  ),
                ),

                // Mock App Canvas
                Container(
                  color: AppColors.pageBackground,
                  padding: isMobile
                      ? AppInsets.cardCompact
                      : AppInsets.cardComfortable,
                  child: Stack(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left sidebar icons (hidden on small mobile)
                          if (!isMobile) ...[
                            Column(
                              children: [
                                ...List.generate(
                                  4,
                                  (i) => Container(
                                    width: AppDimensions.d28,
                                    height: AppDimensions.d28,
                                    margin: AppInsets.b12,
                                    decoration: BoxDecoration(
                                      color: AppColors.scrollbarTrack,
                                      borderRadius: AppRadii.rounded6,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.d180),
                                Container(
                                  width: AppDimensions.d24,
                                  height: AppDimensions.d24,
                                  decoration: const BoxDecoration(
                                    color: AppColors.borderMedium,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                            AppDimensions.w16,
                          ],

                          // Main Content Area
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Bar: Benji's dashboard
                                Row(
                                  children: [
                                    Container(
                                      width: AppDimensions.d22,
                                      height: AppDimensions.d22,
                                      decoration: BoxDecoration(
                                        color: AppColors.borderMedium,
                                        borderRadius: AppRadii.rounded6,
                                      ),
                                    ),
                                    AppDimensions.w10,
                                    const Flexible(
                                      child: Text(
                                        "Benji's dashboard",
                                        style: AppTypography.cardTitleSlate,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      width: AppDimensions.d80,
                                      height: AppDimensions.d24,
                                      decoration: BoxDecoration(
                                        color: AppColors.scrollbarTrack,
                                        borderRadius: AppRadii.rounded6,
                                      ),
                                    ),
                                  ],
                                ),
                                AppDimensions.h16,

                                // 3 Cards in a row
                                if (isMobile)
                                  Column(
                                    children: [
                                      _buildMockCard(showPin1: true),
                                      AppDimensions.h12,
                                      _buildMockCard(showPin2: true),
                                      AppDimensions.h12,
                                      _buildMockCard(),
                                    ],
                                  )
                                else
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildMockCard(showPin1: true),
                                      ),
                                      AppDimensions.w14,
                                      Expanded(
                                        child: _buildMockCard(showPin2: true),
                                      ),
                                      AppDimensions.w14,
                                      Expanded(child: _buildMockCard()),
                                    ],
                                  ),
                                AppDimensions.h16,

                                // Large Table / List Skeleton Container
                                Container(
                                  width: double.infinity,
                                  padding: AppInsets.all20,
                                  decoration: BoxDecoration(
                                    color: AppColors.textWhite,
                                    borderRadius: AppRadii.rounded8,
                                    border: Border.all(
                                      color: AppColors.borderSubtle,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Row 1
                                      Wrap(
                                        spacing: AppDimensions.d12,
                                        runSpacing: AppDimensions.d6,
                                        children: [
                                          _skeletonBar(80, 12),
                                          _skeletonBar(110, 12),
                                          _skeletonBar(70, 12),
                                        ],
                                      ),
                                      AppDimensions.h18,

                                      // Row 2
                                      Wrap(
                                        spacing: AppDimensions.d12,
                                        runSpacing: AppDimensions.d6,
                                        children: [
                                          _skeletonBar(100, 12),
                                          _skeletonBar(70, 12),
                                        ],
                                      ),
                                      AppDimensions.h16,

                                      // Row 3
                                      Wrap(
                                        spacing: AppDimensions.d12,
                                        runSpacing: AppDimensions.d6,
                                        children: [
                                          _skeletonBar(80, 12),
                                          _skeletonBar(50, 12),
                                        ],
                                      ),
                                      AppDimensions.h16,

                                      // Row 4
                                      Wrap(
                                        spacing: AppDimensions.d12,
                                        runSpacing: AppDimensions.d6,
                                        children: [
                                          _skeletonBar(90, 12),
                                          _skeletonBar(80, 12),
                                        ],
                                      ),
                                      AppDimensions.h32,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Floating "Feedback for your agent" Window matching screenshot
                      if (_isCalloutVisible)
                        Positioned(
                          top: isMobile ? 36 : 24,
                          right: isMobile ? 8 : 24,
                          child: Container(
                            width: isMobile ? AppDimensions.d260 : AppDimensions.d310,
                            decoration: BoxDecoration(
                              color: AppColors.textWhite,
                              borderRadius: AppRadii.rounded8,
                              border: Border.all(
                                color: AppColors.borderMedium,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.shadowMedium,
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // macOS Titlebar: Red, Yellow, Green dots + Title + Close button
                                Container(
                                  padding: AppInsets.h10v8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.surfaceMuted,
                                    borderRadius: AppRadii.cardTop,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: AppColors.borderMedium,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: AppDimensions.d8,
                                        height: AppDimensions.d8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.accentRed,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      AppDimensions.w5,
                                      Container(
                                        width: AppDimensions.d8,
                                        height: AppDimensions.d8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.accentAmber,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      AppDimensions.w5,
                                      Container(
                                        width: AppDimensions.d8,
                                        height: AppDimensions.d8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.accentGreen,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      AppDimensions.w10,
                                      const Expanded(
                                        child: Text(
                                          'Feedback for your agent',
                                          style: AppTypography.captionSlateBold,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      InkWell(
                                        key: const ValueKey(
                                          'close_callout_button',
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _isCalloutVisible = false;
                                          });
                                        },
                                        child: AgentationIcons.close(
                                          size: AppDimensions.d14,
                                          color: AppColors.slateMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Markdown Feedback Body matching screenshot
                                Padding(
                                  padding: AppInsets.all12,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Text(
                                            '## Page: Feedback',
                                            style: AppTypography.codeSmallSlateDark,
                                          ),
                                          AppDimensions.w2,
                                          Text(
                                            '|',
                                            style: AppTypography.badgeSmall,
                                          ),
                                        ],
                                      ),
                                      AppDimensions.h8,
                                      const Text(
                                        'Change to primary style',
                                        style: AppTypography.badgeBoldSlate,
                                      ),
                                      AppDimensions.h6,
                                      Container(
                                        padding: AppInsets.h6v2,
                                        decoration: BoxDecoration(
                                          color: AppColors.scrollbarTrack,
                                          borderRadius: AppRadii.rounded4,
                                        ),
                                        child: const Text(
                                          'button.submit-btn • lib/dashboard.dart:42',
                                          style: AppTypography.codeNano,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Floating Dark Pill Toolbar at Bottom Right matching Figma / Screenshot
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          height: AppDimensions.d38,
                          padding: AppInsets.h14,
                          decoration: BoxDecoration(
                            color: AppColors.slateCard,
                            borderRadius: AppRadii.roundedFull,
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadowHeavy,
                                blurRadius: 16,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AgentationIcons.pause(
                                size: AppDimensions.d14,
                                color: AppColors.slateBorder,
                              ),
                              AppDimensions.w12,
                              AgentationIcons.eye(
                                size: AppDimensions.d14,
                                color: AppColors.slateBorder,
                              ),
                              AppDimensions.w12,
                              AgentationIcons.copy(
                                size: AppDimensions.d14,
                                color: AppColors.slateBorder,
                              ),
                              AppDimensions.w12,
                              AgentationIcons.trash(
                                size: AppDimensions.d14,
                                color: AppColors.slateBorder,
                              ),
                              AppDimensions.w12,
                              AgentationIcons.gear(
                                size: AppDimensions.d14,
                                color: AppColors.slateBorder,
                              ),
                              AppDimensions.w10,
                              Container(
                                width: AppDimensions.d1,
                                height: AppDimensions.d14,
                                color: AppColors.slateText,
                              ),
                              AppDimensions.w10,
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isCalloutVisible = !_isCalloutVisible;
                                      });
                                    },
                                    child: AgentationIcons.close(
                                      size: AppDimensions.d14,
                                      color: AppColors.textWhite,
                                    ),
                                  ),
                                  // Mouse cursor hover icon
                                  Positioned(
                                    right: -6,
                                    bottom: -8,
                                    child: AgentationIcons.send(
                                      size: AppDimensions.d13,
                                      color: AppColors.textWhite70,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonBar(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.borderMedium,
        borderRadius: AppRadii.rounded6,
      ),
    );
  }

  Widget _buildMockCard({bool showPin1 = false, bool showPin2 = false}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: AppDimensions.d110,
          padding: AppInsets.all16,
          decoration: BoxDecoration(
            color: AppColors.textWhite,
            borderRadius: AppRadii.rounded8,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _skeletonBar(70, 12),
              Container(
                width: AppDimensions.d90,
                height: AppDimensions.d30,
                decoration: BoxDecoration(
                  color: AppColors.scrollbarTrack,
                  borderRadius: AppRadii.rounded6,
                ),
              ),
            ],
          ),
        ),

        // Pin 1 Marker
        if (showPin1) Positioned(top: 6, left: 10, child: _buildPinBadge('1')),

        // Pin 2 Marker
        if (showPin2)
          Positioned(
            bottom: 6,
            left: 8,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isCalloutVisible = !_isCalloutVisible;
                });
              },
              child: _buildPinBadge('2'),
            ),
          ),
      ],
    );
  }

  Widget _buildPinBadge(String number) {
    return Container(
      width: AppDimensions.d18,
      height: AppDimensions.d18,
      decoration: const BoxDecoration(
        color: AppColors.accentBlue,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.accentBlueGlow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          number,
          style: AppTypography.badgeTagBold.copyWith(color: AppColors.textWhite),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot(this.color);
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

typedef InteractivePreviewSection = InteractivePreviewPage;
