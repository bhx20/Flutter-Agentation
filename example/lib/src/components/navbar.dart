import 'package:flutter/material.dart';
import 'package:example/src/theme/app_dimensions.dart';

import '../constants/app_strings.dart';
import '../routes/app_router.dart';
import '../theme/app_theme.dart';
import '../theme/app_insets.dart';
import '../theme/app_typography.dart';
import 'package:flutter_agentation/flutter_agentation.dart';
import 'agentation_logo.dart';
import 'hover_tile.dart';
import 'native_link_wrapper.dart';
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
    return SelectionContainer.disabled(
      child: ValueListenableBuilder<PubPackageData>(
        valueListenable: PubDevService.instance.packageNotifier,
        builder: (context, data, _) {
          if (isVertical) {
            return _buildVerticalSidebar(context, data);
          }
          return _buildHorizontalNavbar(context, data);
        },
      ),
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
          NativeLinkWrapper(
            url: AppRouter.pathFor(AppRouter.overview),
            target: LinkTarget.self,
            onTap: () => onNavigate?.call(AppRouter.overview),
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
            routeKey: AppRouter.overview,
            isActive: activeSection == AppRouter.overview,
            onTap: () => onNavigate?.call(AppRouter.overview),
          ),
          AppDimensions.h10,
          _SidebarLink(
            label: AppStrings.navInstallation,
            routeKey: AppRouter.installation,
            isActive: activeSection == AppRouter.installation,
            onTap: () => onNavigate?.call(AppRouter.installation),
          ),
          AppDimensions.h10,
          _SidebarLink(
            label: AppStrings.navMcp,
            routeKey: AppRouter.mcp,
            isActive: activeSection == AppRouter.mcp,
            onTap: () => onNavigate?.call(AppRouter.mcp),
          ),
          AppDimensions.h10,
          _SidebarLink(
            label: AppStrings.navPlatforms,
            routeKey: AppRouter.platforms,
            isActive: activeSection == AppRouter.platforms,
            onTap: () => onNavigate?.call(AppRouter.platforms),
          ),
          AppDimensions.h10,
          _SidebarLink(
            label: AppStrings.navChangelog,
            routeKey: AppRouter.changelog,
            isActive: activeSection == AppRouter.changelog,
            onTap: () => onNavigate?.call(AppRouter.changelog),
          ),
          AppDimensions.h10,
          _SidebarLink(
            label: AppStrings.navFaq,
            routeKey: AppRouter.faq,
            isActive: activeSection == AppRouter.faq,
            onTap: () => onNavigate?.call(AppRouter.faq),
          ),

          AppDimensions.h24,

          // Resources Link
          _SidebarLink(
            label: AppStrings.navGitHub,
            url: data.repositoryUrl,
            target: LinkTarget.blank,
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
            url: data.homepageUrl,
            target: LinkTarget.blank,
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
              bottom: BorderSide(
                color: AppColors.borderSubtle,
                width: AppDimensions.d1,
              ),
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
                      child: NativeLinkWrapper(
                        url: AppRouter.pathFor(AppRouter.overview),
                        target: LinkTarget.self,
                        onTap: () => onNavigate?.call(AppRouter.overview),
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
                                  routeKey: AppRouter.overview,
                                  isActive: activeSection == AppRouter.overview,
                                  onTap: () =>
                                      onNavigate?.call(AppRouter.overview),
                                ),
                                AppDimensions.w20,
                                _NavLink(
                                  label: AppStrings.navInstallation,
                                  routeKey: AppRouter.installation,
                                  isActive:
                                      activeSection == AppRouter.installation,
                                  onTap: () =>
                                      onNavigate?.call(AppRouter.installation),
                                ),
                                AppDimensions.w20,
                                _NavLink(
                                  label: AppStrings.navMcp,
                                  routeKey: AppRouter.mcp,
                                  isActive: activeSection == AppRouter.mcp,
                                  onTap: () => onNavigate?.call(AppRouter.mcp),
                                ),
                                AppDimensions.w20,
                                _NavLink(
                                  label: AppStrings.navPlatforms,
                                  routeKey: AppRouter.platforms,
                                  isActive:
                                      activeSection == AppRouter.platforms,
                                  onTap: () =>
                                      onNavigate?.call(AppRouter.platforms),
                                ),
                                AppDimensions.w20,
                                _NavLink(
                                  label: AppStrings.navChangelog,
                                  routeKey: AppRouter.changelog,
                                  isActive:
                                      activeSection == AppRouter.changelog,
                                  onTap: () =>
                                      onNavigate?.call(AppRouter.changelog),
                                ),
                                AppDimensions.w20,
                                _NavLink(
                                  label: AppStrings.navFaq,
                                  routeKey: AppRouter.faq,
                                  isActive: activeSection == AppRouter.faq,
                                  onTap: () => onNavigate?.call(AppRouter.faq),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Right Action Button: < > GitHub
                      NativeLinkWrapper(
                        url: data.repositoryUrl,
                        target: LinkTarget.blank,
                        child: FilledButton.icon(
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

class _SidebarLink extends StatefulWidget {
  const _SidebarLink({
    super.key,
    required this.label,
    required this.isActive,
    this.routeKey,
    this.url,
    this.target = LinkTarget.self,
    this.onTap,
  });

  final String label;
  final bool isActive;
  final String? routeKey;
  final String? url;
  final LinkTarget target;
  final VoidCallback? onTap;

  @override
  State<_SidebarLink> createState() => _SidebarLinkState();
}

class _SidebarLinkState extends State<_SidebarLink> {
  final ValueNotifier<bool> _isHovered = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isHovered.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveUrl = widget.url ??
        (widget.routeKey != null ? AppRouter.pathFor(widget.routeKey!) : '');

    return SelectionContainer.disabled(
      child: NativeLinkWrapper(
        url: effectiveUrl,
        target: widget.target,
        onTap: widget.onTap,
        hoverNotifier: _isHovered,
        child: HoverTile(
          isSelected: widget.isActive,
          onTap: widget.onTap,
          hoverNotifier: _isHovered,
          cursor: SystemMouseCursors.click,
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
              widget.label,
              style: AppTypography.sidebarLink.copyWith(
                color: textColor,
                fontWeight: fontWeight,
              ),
            );
          },
          child: const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.label,
    required this.isActive,
    required this.routeKey,
    this.onTap,
  });

  final String label;
  final bool isActive;
  final String routeKey;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SelectionContainer.disabled(
      child: NativeLinkWrapper(
        url: AppRouter.pathFor(routeKey),
        target: LinkTarget.self,
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Padding(
            padding: AppInsets.h4v4,
            child: Text(
              label,
              style: isActive ? AppTypography.navLinkActive : AppTypography.navLink,
            ),
          ),
        ),
      ),
    );
  }
}

typedef AppNavbar = NavbarSection;
