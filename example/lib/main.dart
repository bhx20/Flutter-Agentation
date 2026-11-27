library;

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'src/app.dart';

export 'src/app.dart';
export 'src/constants/app_strings.dart';
export 'src/pages/changelog_page.dart';
export 'src/pages/code_mapping_page.dart';
export 'src/pages/faq_page.dart';
export 'src/pages/installation_page.dart';
export 'src/pages/interactive_preview_page.dart';
export 'src/pages/landing_page.dart';
export 'src/pages/mcp_webhooks_page.dart';
export 'src/pages/overview_page.dart';
export 'src/pages/toolbar_platforms_page.dart';
export 'src/pages/workflow_page.dart';
export 'src/routes/app_router.dart';

void main() {
  usePathUrlStrategy();
  runApp(const AgentationExampleApp());
}
