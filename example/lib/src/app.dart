import 'package:flutter/material.dart';
import 'package:flutter_agentation/flutter_agentation.dart';

import 'constants/app_strings.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

/// Root application widget for the Flutter Agentation showcase and documentation app.
class AgentationExampleApp extends StatelessWidget {
  const AgentationExampleApp({super.key});

  /// Canonical section normalizer for backwards compatibility.
  static String normalizeRoute(String? name) => AppRouter.normalizeRoute(name);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        scrollbars: false,
      ),
      // Wrap MaterialApp with FlutterAgentation.builder() to enable the
      // in-app visual inspection toolbar, skeleton palette, and live MCP daemon.
      builder: FlutterAgentation.builder(),
      initialRoute: '/',
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
