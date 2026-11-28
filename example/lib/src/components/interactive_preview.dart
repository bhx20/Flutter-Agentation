import 'package:flutter/material.dart';
import 'package:example/src/theme/app_dimensions.dart';
import 'package:flutter_agentation/flutter_agentation.dart';

import '../theme/app_colors.dart';
import '../theme/app_insets.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';
import '../utils/breakpoints.dart';
import 'browser_window_frame.dart';

/// Interactive UI preview component demonstrating agent feedback workflow.
class InteractivePreview extends StatefulWidget {
  const InteractivePreview({super.key});

  @override
  State<InteractivePreview> createState() => _InteractivePreviewState();
}

class _InteractivePreviewState extends State<InteractivePreview> {
  final ValueNotifier<bool> _isCalloutVisibleNotifier = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _isCalloutVisibleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppDimensions.d860),
        child: BrowserWindowFrame(
          // URL and body decoration (background color and padding)
          // are built into BrowserWindowFrame.
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
                        const SizedBox(height: AppDimensions.d110),
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
                              Expanded(child: _buildMockCard(showPin1: true)),
                              AppDimensions.w14,
                              Expanded(child: _buildMockCard(showPin2: true)),
                              AppDimensions.w14,
                              Expanded(child: _buildMockCard()),
                            ],
                          ),
                        AppDimensions.h16,

                        // Large Table / List Skeleton Container
                        Container(
                          width: double.infinity,
                          padding: AppInsets.all14,
                          decoration: BoxDecoration(
                            color: AppColors.textWhite,
                            borderRadius: AppRadii.rounded8,
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row 1
                              Wrap(
                                spacing: AppDimensions.d12,
                                runSpacing: AppDimensions.d6,
                                children: [
                                  _skeletonBar(70, 10),
                                  _skeletonBar(100, 10),
                                  _skeletonBar(60, 10),
                                ],
                              ),
                              AppDimensions.h12,

                              // Row 2
                              Wrap(
                                spacing: AppDimensions.d12,
                                runSpacing: AppDimensions.d6,
                                children: [
                                  _skeletonBar(90, 10),
                                  _skeletonBar(60, 10),
                                ],
                              ),
                              AppDimensions.h12,

                              // Row 3
                              Wrap(
                                spacing: AppDimensions.d12,
                                runSpacing: AppDimensions.d6,
                                children: [
                                  _skeletonBar(80, 10),
                                  _skeletonBar(50, 10),
                                ],
                              ),
                              AppDimensions.h12,

                              // Row 4
                              Wrap(
                                spacing: AppDimensions.d12,
                                runSpacing: AppDimensions.d6,
                                children: [
                                  _skeletonBar(100, 10),
                                  _skeletonBar(70, 10),
                                ],
                              ),
                              AppDimensions.h14,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Floating "Feedback for your agent" Window
              ValueListenableBuilder<bool>(
                valueListenable: _isCalloutVisibleNotifier,
                builder: (context, isCalloutVisible, _) {
                  if (!isCalloutVisible) return const SizedBox.shrink();
                  return Positioned(
                    top: isMobile ? 24 : 20,
                    right: isMobile ? 4 : 18,
                    child: Container(
                      width: isMobile ? AppDimensions.d220 : AppDimensions.d260,
                      decoration: BoxDecoration(
                        color: AppColors.textWhite,
                        borderRadius: AppRadii.rounded8,
                        border: Border.all(color: AppColors.borderMedium),
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
                                AppDimensions.w8,
                                const Expanded(
                                  child: Text(
                                    'Feedback for your agent',
                                    style: AppTypography.captionSlateBold,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                InkWell(
                                  key: const ValueKey('close_callout_button'),
                                  onTap: () {
                                    _isCalloutVisibleNotifier.value = false;
                                  },
                                  child: AgentationIcons.close(
                                    size: AppDimensions.d14,
                                    color: AppColors.slateMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Markdown Feedback Body
                          Padding(
                            padding: AppInsets.all12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Flexible(
                                      child: Text(
                                        '## Page: Feedback',
                                        style: AppTypography.codeSmallSlateDark,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    AppDimensions.w2,
                                    Text('|', style: AppTypography.badgeSmall),
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
                  );
                },
              ),

              // Floating Dark Pill Toolbar at Bottom Right
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
                              _isCalloutVisibleNotifier.value =
                                  !_isCalloutVisibleNotifier.value;
                            },
                            child: AgentationIcons.close(
                              size: AppDimensions.d14,
                              color: AppColors.textWhite,
                            ),
                          ),
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
          height: AppDimensions.d100,
          padding: AppInsets.all14,
          decoration: BoxDecoration(
            color: AppColors.textWhite,
            borderRadius: AppRadii.rounded8,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _skeletonBar(60, 10),
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
                _isCalloutVisibleNotifier.value =
                    !_isCalloutVisibleNotifier.value;
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
