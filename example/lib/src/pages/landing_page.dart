import 'package:flutter/material.dart';

import '../components/footer.dart';
import '../components/mobile_drawer.dart';
import '../components/navbar.dart';
import '../routes/app_router.dart';
import '../services/pub_dev_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_insets.dart';
import '../utils/breakpoints.dart';
import 'changelog_page.dart';
import 'code_mapping_page.dart';
import 'faq_page.dart';
import 'installation_page.dart';
import 'interactive_preview_page.dart';
import 'mcp_webhooks_page.dart';
import 'overview_page.dart';
import 'toolbar_platforms_page.dart';
import 'workflow_page.dart';

/// Responsive multi-route page shell for Flutter Agentation.
/// Serves as the single parent screen hosting the persistent sidebar/navbar,
/// scrollbar, child route page, and global footer.
class LandingPage extends StatefulWidget {
  const LandingPage({
    super.key,
    this.route = AppRouter.overview,
  });

  final String route;

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch live real-time package metrics from pub.dev APIs
    PubDevService.instance.fetchPackageData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToRoute(BuildContext context, String targetRoute) {
    AppRouter.navigateTo(
      context,
      targetRoute,
      currentRoute: widget.route,
      scrollController: _scrollController,
    );
  }

  /// Resolves the child page widget corresponding to the active route.
  Widget _buildChildPage(BuildContext context, double verticalSpacing) {
    switch (widget.route) {
      case AppRouter.installation:
        return const InstallationPage();
      case AppRouter.mcp:
        return const McpWebhooksPage();
      case AppRouter.platforms:
        return const ToolbarPlatformsPage();
      case AppRouter.changelog:
        return const ChangelogPage();
      case AppRouter.faq:
        return const FaqPage();
      case AppRouter.preview:
        return const InteractivePreviewPage();
      case AppRouter.workflow:
        return const WorkflowPage();
      case AppRouter.codeMapping:
        return const CodeMappingPage();
      case AppRouter.overview:
      default:
        return OverviewPage(
          verticalSpacing: verticalSpacing,
          onNavigate: (r) => _navigateToRoute(context, r),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      drawer: isMobile
          ? MobileDrawer(
              activeRoute: widget.route,
              onNavigate: (r) => _navigateToRoute(context, r),
            )
          : null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isDesktop = screenWidth >= Breakpoints.tabletMax;
            final isMobileView = screenWidth < Breakpoints.mobileMax;
            final verticalSectionSpacing = isMobileView ? 48.0 : 64.0;
            final childPage = _buildChildPage(context, verticalSectionSpacing);

            if (isDesktop) {
              const double sidebarWidth = 200.0;
              const double contentWidth = 720.0;
              const double gap = 32.0;
              final double idealLeftMargin = (screenWidth - (sidebarWidth + gap + contentWidth)) / 2;
              final double leftMargin = idealLeftMargin > 24.0 ? idealLeftMargin : 24.0;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(width: leftMargin),
                  SizedBox(
                    width: sidebarWidth,
                    child: NavbarSection(
                      isVertical: true,
                      onNavigate: (r) => _navigateToRoute(context, r),
                      activeSection: widget.route,
                    ),
                  ),
                  const SizedBox(width: gap),
                  Expanded(
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      interactive: true,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: AppInsets.modalScroll,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: contentWidth),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                childPage,
                                SizedBox(height: verticalSectionSpacing),
                                const FooterSection(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                NavbarSection(
                  isVertical: false,
                  onNavigate: (r) => _navigateToRoute(context, r),
                  activeSection: widget.route,
                ),
                Expanded(
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    interactive: true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: isMobileView
                          ? AppInsets.pagePaddingMobile
                          : AppInsets.pagePaddingDesktop,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          childPage,
                          SizedBox(height: verticalSectionSpacing),
                          const FooterSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
