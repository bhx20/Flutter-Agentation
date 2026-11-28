import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../pages/landing_page.dart';

/// Centralized route definitions, URL normalization, and page route generator
/// for the Flutter Agentation showcase and documentation application.
abstract final class AppRouter {
  // Canonical section identifiers
  static const String overview = 'overview';
  static const String installation = 'installation';
  static const String mcp = 'mcp';
  static const String platforms = 'platforms';
  static const String changelog = 'changelog';
  static const String faq = 'faq';
  static const String preview = 'preview';
  static const String workflow = 'workflow';
  static const String codeMapping = 'code-mapping';

  /// Normalizes incoming URL paths and route names to one of the canonical
  /// section identifiers.
  static String normalizeRoute(String? name) {
    if (name == null || name.isEmpty || name == '/') return overview;
    final cleaned = name.replaceAll('/', '').trim().toLowerCase();
    switch (cleaned) {
      case 'overview':
        return overview;
      case 'installation':
      case 'install':
        return installation;
      case 'mcp':
      case 'webhooks':
      case 'mcp-webhooks':
        return mcp;
      case 'platforms':
      case 'toolbar':
      case 'toolbar-platforms':
        return platforms;
      case 'changelog':
        return changelog;
      case 'faq':
        return faq;
      case 'preview':
      case 'interactive-preview':
        return preview;
      case 'workflow':
        return workflow;
      case 'code-mapping':
      case 'mapping':
        return codeMapping;
      default:
        return overview;
    }
  }

  /// Converts a section key to its corresponding URL path.
  static String pathFor(String routeKey) {
    final normalized = normalizeRoute(routeKey);
    return normalized == overview ? '/' : '/$normalized';
  }

  /// Updates the browser address bar with the canonical URL path without reconstructing routes.
  static void updateUrl(String targetRoute) {
    final normalized = normalizeRoute(targetRoute);
    try {
      SystemNavigator.routeInformationUpdated(
        uri: Uri.parse(pathFor(normalized)),
        replace: false,
      );
    } catch (_) {}
  }

  /// Builds a clean MaterialPageRoute for initial page loading and deep links.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final route = normalizeRoute(settings.name);
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => LandingPage(route: route),
    );
  }

  /// Navigates to a target route smoothly, scrolling to top if already active.
  static void navigateTo(
    BuildContext context,
    String targetRoute, {
    required String currentRoute,
    ScrollController? scrollController,
  }) {
    final normalizedTarget = normalizeRoute(targetRoute);
    if (normalizedTarget == currentRoute) {
      if (scrollController != null && scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
      return;
    }

    updateUrl(normalizedTarget);
  }
}
