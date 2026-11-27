import 'package:flutter/material.dart';
import 'package:example/src/theme/app_dimensions.dart';

import 'package:flutter_agentation/flutter_agentation.dart';

import '../constants/app_strings.dart';
import '../routes/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_insets.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../utils/clipboard_helper.dart';
import 'agentation_logo.dart';

/// Responsive navigation drawer for mobile and compact viewports.
class MobileDrawer extends StatelessWidget {
  const MobileDrawer({
    super.key,
    required this.activeRoute,
    required this.onNavigate,
  });

  final String activeRoute;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.cardBackground,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: AppInsets.h20v16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(child: AgentationLogo(height: AppDimensions.d18)),
                  IconButton(
                    icon: AgentationIcons.close(size: AppDimensions.d18, color: AppColors.textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.borderSubtle, height: AppDimensions.d1),
            Expanded(
              child: ListView(
                padding: AppInsets.v8,
                children: [
                  _DrawerTile(
                    label: AppStrings.navOverview,
                    routeKey: AppRouter.overview,
                    isActive: activeRoute == AppRouter.overview,
                    icon: AgentationIcons.eye(
                      size: AppDimensions.d18,
                      color: activeRoute == AppRouter.overview ? AppColors.accentBlue : AppColors.textPrimary,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      onNavigate(AppRouter.overview);
                    },
                  ),
                  _DrawerTile(
                    label: AppStrings.navInstallation,
                    routeKey: AppRouter.installation,
                    isActive: activeRoute == AppRouter.installation,
                    icon: AgentationIcons.component(
                      size: AppDimensions.d18,
                      color: activeRoute == AppRouter.installation ? AppColors.accentBlue : AppColors.textPrimary,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      onNavigate(AppRouter.installation);
                    },
                  ),
                  _DrawerTile(
                    label: AppStrings.navMcp,
                    routeKey: AppRouter.mcp,
                    isActive: activeRoute == AppRouter.mcp,
                    icon: AgentationIcons.layout(
                      size: AppDimensions.d18,
                      color: activeRoute == AppRouter.mcp ? AppColors.accentBlue : AppColors.textPrimary,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      onNavigate(AppRouter.mcp);
                    },
                  ),
                  _DrawerTile(
                    label: AppStrings.navPlatforms,
                    routeKey: AppRouter.platforms,
                    isActive: activeRoute == AppRouter.platforms,
                    icon: AgentationIcons.wireframe(
                      size: AppDimensions.d18,
                      color: activeRoute == AppRouter.platforms ? AppColors.accentBlue : AppColors.textPrimary,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      onNavigate(AppRouter.platforms);
                    },
                  ),
                  _DrawerTile(
                    label: AppStrings.navChangelog,
                    routeKey: AppRouter.changelog,
                    isActive: activeRoute == AppRouter.changelog,
                    icon: AgentationIcons.layout(
                      size: AppDimensions.d18,
                      color: activeRoute == AppRouter.changelog ? AppColors.accentBlue : AppColors.textPrimary,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      onNavigate(AppRouter.changelog);
                    },
                  ),
                  _DrawerTile(
                    label: AppStrings.navFaq,
                    routeKey: AppRouter.faq,
                    isActive: activeRoute == AppRouter.faq,
                    icon: AgentationIcons.help(
                      size: AppDimensions.d18,
                      color: activeRoute == AppRouter.faq ? AppColors.accentBlue : AppColors.textPrimary,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      onNavigate(AppRouter.faq);
                    },
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.borderSubtle, height: AppDimensions.d1),
            Padding(
              padding: AppInsets.all16,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: AppTheme.drawerPrimaryButton,
                      onPressed: () {
                        Navigator.of(context).pop();
                        ClipboardHelper.copy(
                          context,
                          AppStrings.defaultRepoUrl,
                          successMessage: AppStrings.msgGithubCopied,
                        );
                      },
                      icon: AgentationIcons.component(size: AppDimensions.d14, color: AppColors.textWhite),
                      label: const Text(AppStrings.navGitHub, style: AppTypography.buttonBold),
                    ),
                  ),
                  AppDimensions.h10,
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: AppTheme.drawerOutlinedButton,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onNavigate(AppRouter.installation);
                      },
                      child: const Text(AppStrings.navGetStarted, style: AppTypography.button),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.label,
    required this.routeKey,
    required this.isActive,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String routeKey;
  final bool isActive;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon,
      title: Text(
        label,
        style: isActive ? AppTypography.navLinkActive : AppTypography.navLink,
      ),
      onTap: onTap,
    );
  }
}
