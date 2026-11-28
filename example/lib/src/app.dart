import 'package:flutter/material.dart';
import 'package:flutter_agentation/flutter_agentation.dart';

import 'constants/app_strings.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';
import 'utils/web_loader_controller.dart';

/// Root application widget for the Flutter Agentation showcase and documentation app.
class AgentationExampleApp extends StatefulWidget {
  const AgentationExampleApp({super.key});

  /// Canonical section normalizer for backwards compatibility.
  static String normalizeRoute(String? name) => AppRouter.normalizeRoute(name);

  @override
  State<AgentationExampleApp> createState() => _AgentationExampleAppState();
}

class _AgentationExampleAppState extends State<AgentationExampleApp> {
  @override
  void reassemble() {
    super.reassemble();
    // Dismiss splash loader seamlessly after hot reload completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.endOfFrame.then((_) {
        dismissWebLoader();
      });
    });
  }

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
