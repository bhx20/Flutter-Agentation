import 'package:flutter/material.dart';

import '../components/desktop_scrollbar.dart';
import '../components/footer.dart';
import '../components/mobile_drawer.dart';
import '../components/navbar.dart';
import '../components/smooth_scroll.dart';
import '../routes/app_router.dart';
import '../services/pub_dev_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_insets.dart';
import '../utils/breakpoints.dart';
import '../utils/web_loader_controller.dart';
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
  const LandingPage({super.key, this.route = AppRouter.overview});

  final String route;

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with WidgetsBindingObserver {
  static bool _initialLoaderDismissed = false;

  late final ValueNotifier<String> _activeRouteNotifier =
      ValueNotifier<String>(AppRouter.normalizeRoute(widget.route));

  final ScrollController _scrollController = SmoothScrollController(
    damping: 4.2,
    speedMultiplier: 1.35,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Fetch live real-time package metrics from pub.dev APIs
    PubDevService.instance.fetchPackageData();

    if (!_initialLoaderDismissed) {
      _initialLoaderDismissed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Guarantee LandingPage has completely laid out, painted, and presented
        // pixels to the display buffer before initiating loader fade-out.
        WidgetsBinding.instance.endOfFrame.then((_) {
          dismissWebLoader();
        });
      });
    }
  }

  @override
  void didUpdateWidget(covariant LandingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.route != oldWidget.route) {
      final normalized = AppRouter.normalizeRoute(widget.route);
      if (normalized != _activeRouteNotifier.value) {
        _activeRouteNotifier.value = normalized;
      }
    }
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) async {
    final location = routeInformation.uri.path;
    final normalized = AppRouter.normalizeRoute(location);
    if (normalized != _activeRouteNotifier.value) {
      _activeRouteNotifier.value = normalized;
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _activeRouteNotifier.dispose();
    super.dispose();
  }

  void _navigateToRoute(BuildContext context, String targetRoute) {
    final normalized = AppRouter.normalizeRoute(targetRoute);
    if (normalized == _activeRouteNotifier.value) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
      return;
    }

    _activeRouteNotifier.value = normalized;

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }

    AppRouter.updateUrl(normalized);
  }

  /// Resolves the child page widget corresponding to the active route.
  Widget _buildChildPage(BuildContext context, String activeRoute, double verticalSpacing) {
    switch (activeRoute) {
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

    return ValueListenableBuilder<String>(
      valueListenable: _activeRouteNotifier,
      builder: (context, activeRoute, _) {
        return Scaffold(
          backgroundColor: AppColors.cardBackground,
          drawer: isMobile
              ? MobileDrawer(
                  activeRoute: activeRoute,
                  onNavigate: (r) => _navigateToRoute(context, r),
                )
              : null,
          body: SafeArea(
            child: DefaultSelectionStyle(
              selectionColor: AppColors.textSelection,
              cursorColor: AppColors.textPrimary,
              child: SelectionArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;
                    final isDesktop = screenWidth >= Breakpoints.tabletMax;
                    final isMobileView = screenWidth < Breakpoints.mobileMax;
                    final verticalSectionSpacing = isMobileView ? 48.0 : 64.0;
                    final childPage = _buildChildPage(context, activeRoute, verticalSectionSpacing);

                    if (isDesktop) {
                      const double sidebarWidth = 200.0;
                      const double contentWidth = 720.0;
                      const double gap = 32.0;
                      final double idealLeftMargin =
                          (screenWidth - (sidebarWidth + gap + contentWidth)) / 2;
                      final double leftMargin = idealLeftMargin > 24.0
                          ? idealLeftMargin
                          : 24.0;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(width: leftMargin),
                          SizedBox(
                            width: sidebarWidth,
                            child: NavbarSection(
                              isVertical: true,
                              onNavigate: (r) => _navigateToRoute(context, r),
                              activeSection: activeRoute,
                            ),
                          ),
                          const SizedBox(width: gap),
                          Expanded(
                            child: DesktopScrollbar(
                              controller: _scrollController,
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                physics: const ClampingScrollPhysics(),
                                clipBehavior: Clip.none,
                                padding: AppInsets.modalScroll,
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: contentWidth,
                                    ),
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
                          activeSection: activeRoute,
                        ),
                        Expanded(
                          child: DesktopScrollbar(
                            controller: _scrollController,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              physics: const ClampingScrollPhysics(),
                              clipBehavior: Clip.none,
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
            ),
          ),
        );
      },
    );
  }
}
