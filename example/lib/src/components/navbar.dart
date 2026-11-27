import 'package:flutter/material.dart';
import 'package:example/src/theme/app_dimensions.dart';

import '../constants/app_strings.dart';
import '../theme/app_theme.dart';
import '../theme/app_insets.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';
import 'package:flutter_agentation/flutter_agentation.dart';
import 'agentation_logo.dart';
import 'hover_tile.dart';
import '../services/pub_dev_service.dart';
import '../theme/app_colors.dart';
import '../utils/breakpoints.dart';
import '../utils/clipboard_helper.dart';

class NavbarSection extends StatelessWidget {
  const NavbarSection({
    super.key,
    this.onNavigate,
    this.isVertical = false,
    this.activeSection = 'overview',
  });

  final ValueChanged<String>? onNavigate;
  final bool isVertical;
  final String activeSection;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PubPackageData>(
      valueListenable: PubDevService.instance.packageNotifier,
      builder: (context, data, _) {
        if (isVertical) {
          return _buildVerticalSidebar(context, data);
        }
        return _buildHorizontalNavbar(context, data);
      },
    );
  }

  Widget _buildVerticalSidebar(BuildContext context, PubPackageData data) {
    return Container(
      width: AppDimensions.d220,
      color: AppColors.cardBackground,
      padding: AppInsets.sidebarVertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo at top
          InkWell(
            onTap: () => onNavigate?.call('overview'),
            borderRadius: AppRadii.rounded4,
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: AgentationLogo(height: AppDimensions.d16),
            ),
          ),
          AppDimensions.h24,

          // Working Primary Navigation Links
          _SidebarLink(
            label: AppStrings.navOverview,
            isActive: activeSection == 'overview',
            onTap: () => onNavigate?.call('overview'),
          ),
          AppDimensions.h10,
          _SidebarLink(
            label: AppStrings.navInstallation,
            isActive: activeSection == 'installation',
            onTap: () => onNavigate?.call('installation'),
          ),
          AppDimensions.h10,
          _SidebarLink(
            label: AppStrings.navMcp,
            isActive: activeSection == 'mcp',
            onTap: () => onNavigate?.call('mcp'),
          ),
          AppDimensions.h10,
          _SidebarLink(
            label: AppStrings.navPlatforms,
            isActive: activeSection == 'platforms',
            onTap: () => onNavigate?.call('platforms'),
          ),
          AppDimensions.h10,
          _SidebarLink(
            label: AppStrings.navChangelog,
            isActive: activeSection == 'changelog',
            onTap: () => onNavigate?.call('changelog'),
          ),
          AppDimensions.h10,
          _SidebarLink(
            label: AppStrings.navFaq,
            isActive: activeSection == 'faq',
            onTap: () => onNavigate?.call('faq'),
          ),

          AppDimensions.h24,

          // Resources Link
          _SidebarLink(
            label: AppStrings.navGitHub,
            isActive: false,
            onTap: () {
              ClipboardHelper.copy(
                context,
                data.repositoryUrl,
                successMessage: AppStrings.msgGithubCopied,
              );
            },
          ),
          AppDimensions.h10,
          _SidebarLink(
            label: 'pub.dev Package',
            isActive: false,
            onTap: () {
              ClipboardHelper.copy(
                context,
                data.homepageUrl,
                successMessage: 'pub.dev package link copied to clipboard',
              );
            },
          ),

          AppDimensions.h24,

          // Version Tag at Bottom
          HoverTile(
            onTap: () {
              ClipboardHelper.copy(
                context,
                data.homepageUrl,
                successMessage: 'Package link copied to clipboard',
              );
            },
            padding: AppInsets.v4,
            builder: (context, isHovered, isSelected) {
              return Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppDimensions.d4,
                children: [
                  Text(
                    'v${data.version}',
                    style: AppTypography.codeMedium.copyWith(
                      color: isHovered
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                  AgentationIcons.send(
                    size: AppDimensions.d11,
                    color: isHovered
                        ? AppColors.accentBlue
                        : AppColors.textMuted,
                  ),
                ],
              );
            },
            child: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalNavbar(BuildContext context, PubPackageData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < Breakpoints.mobileMax;

        return Container(
          width: double.infinity,
          height: AppDimensions.d64,
          decoration: const BoxDecoration(
            color: AppColors.cardBackground,
            border: Border(
              bottom: BorderSide(color: AppColors.borderSubtle, width: AppDimensions.d1),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: Breakpoints.maxContentWidth,
              ),
              child: Padding(
                padding: isMobile
                    ? AppInsets.navbarMobile
                    : AppInsets.navbarHorizontal,
                child: Row(
                  children: [
                    // Brand Logo on Left (Official SVG Logo)
                    Flexible(
                      child: InkWell(
                        onTap: () => onNavigate?.call('overview'),
                        borderRadius: AppRadii.rounded4,
                        child: const Padding(
                          padding: AppInsets.v4,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: AgentationLogo(height: AppDimensions.d18),
                          ),
                        ),
                      ),
                    ),

                    if (isMobile) ...[
                      const Spacer(),
                      IconButton(
                        key: const ValueKey('mobile_menu_button'),
                        icon: AgentationIcons.listSparkle(
                          size: AppDimensions.d18,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                    ] else ...[
                      // Center Navigation Links
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _NavLink(
                                  label: AppStrings.navOverview,
                                  isActive: activeSection == 'overview',
                                  onTap: () => onNavigate?.call('overview'),
                                ),
                                AppDimensions.w20,
                                _NavLink(
                                  label: AppStrings.navInstallation,
                                  isActive: activeSection == 'installation',
                                  onTap: () => onNavigate?.call('installation'),
                                ),
                                AppDimensions.w20,
                                _NavLink(
                                  label: AppStrings.navMcp,
                                  isActive: activeSection == 'mcp',
                                  onTap: () => onNavigate?.call('mcp'),
                                ),
                                AppDimensions.w20,
                                _NavLink(
                                  label: AppStrings.navPlatforms,
                                  isActive: activeSection == 'platforms',
                                  onTap: () => onNavigate?.call('platforms'),
                                ),
                                AppDimensions.w20,
                                _NavLink(
                                  label: AppStrings.navChangelog,
                                  isActive: activeSection == 'changelog',
                                  onTap: () => onNavigate?.call('changelog'),
                                ),
                                AppDimensions.w20,
                                _NavLink(
                                  label: AppStrings.navFaq,
                                  isActive: activeSection == 'faq',
                                  onTap: () => onNavigate?.call('faq'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Right Action Button: < > GitHub
                      FilledButton.icon(
                        style: AppTheme.compactPrimaryButton,
                        onPressed: () {
                          ClipboardHelper.copy(
                            context,
                            data.repositoryUrl,
                            successMessage:
                                'GitHub repository link copied to clipboard',
                          );
                        },
                        icon: AgentationIcons.component(
                          size: AppDimensions.d13,
                          color: AppColors.textWhite,
                        ),
                        label: const Text(
                          'GitHub',
                          style: AppTypography.captionWhite,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SidebarLink extends StatelessWidget {
  const _SidebarLink({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HoverTile(
      isSelected: isActive,
      onTap: onTap,
      padding: AppInsets.v4,
      builder: (context, isHovered, isSelected) {
        final Color textColor;
        final FontWeight fontWeight;

        if (isSelected) {
          textColor = AppColors.accentBlue;
          fontWeight = FontWeight.w500;
        } else if (isHovered) {
          textColor = AppColors.textPrimary;
          fontWeight = FontWeight.w500;
        } else {
          textColor = AppColors.textTertiary;
          fontWeight = FontWeight.w400;
        }

        return Text(
          label,
          style: AppTypography.sidebarLink.copyWith(
            color: textColor,
            fontWeight: fontWeight,
          ),
        );
      },
      child: const SizedBox.shrink(),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.rounded4,
      child: Padding(
        padding: AppInsets.h4v4,
        child: Text(
          label,
          style: isActive ? AppTypography.navLinkActive : AppTypography.navLink,
        ),
      ),
    );
  }
}

typedef AppNavbar = NavbarSection;
