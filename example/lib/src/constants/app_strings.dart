/// Centralized application strings, copy text, labels, and constants
/// for the Flutter Agentation showcase and documentation application.
abstract final class AppStrings {
  // ── App & Brand ──
  static const String appTitle = 'Flutter Agentation';
  static const String appName = 'Flutter Agentation';
  static const String appDescription = 'Visual UI feedback & MCP server engine for Flutter apps and AI coding agents.';
  static const String defaultRepoUrl = 'https://github.com';
  static const String defaultHomepageUrl = 'https://pub.dev/packages/flutter_agentation';
  static const String changelogPath = '/blob/main/CHANGELOG.md';

  // ── Navigation & Sections ──
  static const String navOverview = 'Overview';
  static const String navInstallation = 'Installation';
  static const String navMcp = 'MCP & Webhooks';
  static const String navPlatforms = 'Toolbar & Platforms';
  static const String navChangelog = 'Changelog';
  static const String navFaq = 'FAQ';
  static const String navGitHub = 'GitHub';
  static const String navGetStarted = 'Get Started';

  // ── Hero Section ──
  static const String heroBadgeLive = 'pub.dev live';
  static const String heroDisplay = 'Visual UI Feedback & MCP Server Engine for Flutter and AI Coding Agents';
  static const String heroSubtitle = 'Agentation turns UI annotations into structured context that AI coding agents can understand and act on. Click any element, add a note, and stream exact widget RenderBox coordinates, file:line paths, and widget hierarchy straight to Cursor, Claude Code, Windsurf, Codex, Grok, or any AI tool.';
  static const String heroCtaGetStarted = 'Get Started with pub.dev';
  static const String heroCtaCliSetup = 'CLI Setup';
  static const String heroCommandSetup = 'dart run flutter_agentation:setupmcp';

  // ── Metrics Section ──
  static const String metricsPubPoints = 'Pub Points';
  static const String metricsQualityScore = 'pub.dev scoring / Quality score';
  static const String metricsDownloads = 'Downloads';
  static const String metricsDownloads30Days = 'pub.dev 30-day downloads';
  static const String metricsLikes = 'Likes';
  static const String metricsCommunityLikes = 'pub.dev package community likes';
  static const String metricsPlatforms = 'Platforms';
  static const String metricsWasmReady = 'WASM-ready';

  // ── Quickstart Section ──
  static const String quickstartOverline = 'QUICKSTART GUIDE';
  static const String quickstartTitle = 'Installation & Setup';
  static const String quickstartSubtitle = 'Get started in under 3 minutes with native pub.dev integration, MaterialApp wrapper, and MCP agent skill auto-configuration.';
  static const String quickstartStep1Tag = '01 / DEPENDENCY';
  static const String quickstartStep1File = 'pubspec.yaml';
  static const String quickstartStep1Title = 'Add Dependency';
  static const String quickstartStep1Desc = 'Add the official release from pub.dev directly into your project dependencies via terminal or pubspec.yaml:';
  static const String quickstartStep1CliLabel = 'CLI Command';
  static const String quickstartStep1CliCode = 'flutter pub add flutter_agentation';
  static const String quickstartStep1YamlLabel = 'Or pubspec.yaml';
  static const String quickstartStep1YamlCode = 'dependencies:\n  flutter:\n    sdk: flutter\n  flutter_agentation: ^1.0.0';
  static const String quickstartStep1Req = 'Requires Dart 3.x+ & Flutter 3.22+';
  static const String quickstartStep1Version = '^1.0.0';

  static const String quickstartStep2Tag = '02 / ENTRYPOINT';
  static const String quickstartStep2File = 'lib/main.dart';
  static const String quickstartStep2Title = 'Wrap Your App';
  static const String quickstartStep2Desc = 'Attach the inspection builder wrapper at the MaterialApp root to persist across all navigator routes and modals:';
  static const String quickstartStep2Note = 'Note: debugOnly: true is enabled by default. In release mode (kDebugMode == false), Flutter Agentation returns child widget tree directly with zero overhead.';

  static const String quickstartStep3Tag = '03 / MCP SETUP';
  static const String quickstartStep3File = 'Terminal / CLI';
  static const String quickstartStep3Title = 'Run the CLI Setup (setupmcp)';
  static const String quickstartStep3Desc = 'Initialize the local MCP server daemon, background event dispatcher, and agent configuration with a single command:';
  static const String quickstartStep3CliCode = 'dart run flutter_agentation:setupmcp';
  static const String quickstartStep3Note = 'Automatically registers MCP configuration in ~/.cursor, ~/.config/claude, or Claude Desktop.';

  static const String quickstartStep4Tag = '04 / VERIFY';
  static const String quickstartStep4File = 'Live Application';
  static const String quickstartStep4Title = 'Run App & Inspect';
  static const String quickstartStep4Desc = 'Launch your application on any supported platform (Web, Desktop, or Mobile) and click the floating launcher:';
  static const String quickstartStep4CliCode = 'flutter run -d chrome';
  static const String quickstartStep4Note = 'Tap "Inspect" on the toolbar pill or press Ctrl+Shift+A to start pinning feedback.';

  // ── Workflow Section ──
  static const String workflowHeader = 'How you use it';
  static const String workflowStep1Title = 'Activate overlay';
  static const String workflowStep1Desc = 'Click the icon in the bottom-right corner to activate';
  static const String workflowStep2Title = 'Hover & inspect';
  static const String workflowStep2Desc = 'Hover over elements to see their names highlighted';
  static const String workflowStep3Title = 'Target element';
  static const String workflowStep3Desc = 'Click any element to add an annotation';
  static const String workflowStep4Title = 'Submit note';
  static const String workflowStep4Desc = 'Write your feedback and click Add';
  static const String workflowStep5Title = 'Copy markdown';
  static const String workflowStep5Desc = 'Click to copy formatted markdown';
  static const String workflowStep6Title = 'Paste to agent';
  static const String workflowStep6Desc = 'Paste into your agent';
  static const String workflowMcpCalloutPrefix = 'With ';
  static const String workflowMcpCalloutHighlight = 'MCP';
  static const String workflowMcpCalloutSuffix = ', your agent can read feedback directly. Connect your agent, add a note, then ask it to address your annotations.';
  static const String workflowZeroCopy = 'Zero copy-paste required';

  // ── Code Mapping Section ──
  static const String codeMappingOverline = 'FLUTTER ELEMENT RESOLUTION & AGENT LOOP';
  static const String codeMappingTitle = 'Direct Widget-to-Code Mapping';
  static const String codeMappingSubtitle = 'Eliminate guessing through nested build() trees. Stream exact Dart file:line, RenderBox coordinates, and widget ancestry directly to your AI coding agent.';
  static const String codeMappingComparisonOverline1 = 'FLUTTER WIDGET RESOLUTION • BUILD() WALK COMPARISON';
  static const String codeMappingComparisonOverline2 = 'DETERMINISTIC RETRIEVAL';
  static const String codeMappingWithoutTitle = 'WITHOUT FLUTTER AGENTATION';
  static const String codeMappingWithoutDesc = 'Ambiguous NL Prompt';
  static const String codeMappingWithTitle = 'WITH FLUTTER AGENTATION';
  static const String codeMappingWithDesc = 'Deterministic Context';
  static const String codeMappingLoopOverline = 'BIDIRECTIONAL AGENT LOOP';
  static const String codeMappingLoopTitle = 'Agents talk back';
  static const String codeMappingLoopSubtitle = 'Two-way dialogue between human reviewers and autonomous coding engines across Flutter iterations.';
  static const String codeMappingLoop1Label = 'QUERY';
  static const String codeMappingLoop1Title = '“What annotations do I have?”';
  static const String codeMappingLoop1Desc = 'List all feedback across active Flutter routes and widgets';
  static const String codeMappingLoop2Label = 'CLARIFICATION';
  static const String codeMappingLoop2Title = '“Should this be 24.0 or 16.0 EdgeInsets?”';
  static const String codeMappingLoop2Desc = 'Agent asks for clarification on constraints & padding';
  static const String codeMappingLoop3Label = 'RESOLUTION';
  static const String codeMappingLoop3Title = '“Fixed the EdgeInsets padding”';
  static const String codeMappingLoop3Desc = 'Agent modifies Dart code and hot reloads target screen';
  static const String codeMappingLoop4Label = 'CLEANUP';
  static const String codeMappingLoop4Title = '“Clear all annotations”';
  static const String codeMappingLoop4Desc = 'Dismiss resolved markers via clear_annotations MCP tool';
  static const String codeMappingNote = 'Follow-up questions and resolutions stay attached to the original widget pin.';

  // ── Interactive Preview Section ──
  static const String previewEyebrow = 'LIVE INSPECTION WORKSPACE';
  static const String previewTitle = 'Interactive Target App & Pin Resolver';
  static const String previewTargetScreen = 'Target Screen: /dashboard';
  static const String previewMockDashboard = "Benji's dashboard";
  static const String previewMockComment = 'Change to primary style';
  static const String previewDismissBtn = 'Dismiss Callout';

  // ── Toolbar & Platforms Section ──
  static const String toolbarPlatformsOverline = 'MULTI-PLATFORM RUNTIME';
  static const String toolbarPlatformsTitle = 'Toolbar Controls & Platform Support';
  static const String toolbarSubheader = 'Floating Toolbar & Platform Transports';
  static const String toolbarPaletteTitle = 'Flutter Skeleton Wireframe Palette';
  static const String platformDesktop = 'Desktop';
  static const String platformAndroid = 'Android';
  static const String platformIos = 'iOS';
  static const String platformWeb = 'Web';
  static const String platformMacOs = 'macOS';
  static const String platformWindows = 'Windows';
  static const String platformLinux = 'Linux';

  // ── MCP & Webhooks Section ──
  static const String mcpWebhooksOverline = 'AGENT PROTOCOL & DISPATCH';
  static const String mcpWebhooksTitle = 'Model Context Protocol & Webhooks';
  static const String mcpServerEndpoints = 'MCP Server & Endpoints';
  static const String mcpEndpointHealth = '/health, /status';
  static const String mcpEndpointSse = '/sse, /events';
  static const String mcpTabGeneric = 'Generic JSON';
  static const String mcpTabSlack = 'Slack Incoming';
  static const String mcpTabDiscord = 'Discord Webhook';

  // ── Changelog Section ──
  static const String changelogOverline = 'RELEASE HISTORY';
  static const String changelogTitle = 'Changelog & Releases';
  static const String changelogPubPackageBtn = 'pub.dev Package';
  static const String changelogMdBtn = 'CHANGELOG.md';

  // ── FAQ Section ──
  static const String faqOverline = 'FREQUENTLY ASKED QUESTIONS';
  static const String faqTitle = 'Frequently Asked Questions';
  static const String faqSubtitle = 'Everything you need to know about Flutter Agentation, widget mapping, MCP protocol integration, and AI coding agent workflows.';

  // ── Footer Section ──
  static const String footerTitle = 'Flutter Agentation';
  static const String footerSubtitle = 'Next-generation Flutter runtime instrumentation, visual UI inspection, and\nagentic MCP protocol bridges.';
  static const String footerDart = 'Dart 3.x+';
  static const String footerFlutter = 'Flutter 3.22+';
  static const String footerLicense = 'License: MIT';
  static const String footerGithubRepo = 'GitHub Repository';
  static const String footerCopyright = '© 2025 Flutter Agentation Contributors. Released under the MIT License.';
  static const String footerPrivacy = 'Privacy Notice';
  static const String footerSecurity = 'Security Policy';
  static const String footerDocumentation = 'Documentation Changelog';
  static const String footerTerms = 'Terms';
  static const String footerDocs = 'Documentation';
  static const String footerStatus = 'Status';

  // ── Clipboard & Toast Feedback Messages ──
  static const String msgCopiedGeneric = 'Copied to clipboard';
  static const String msgGithubCopied = 'GitHub repository link copied to clipboard';
  static const String msgSetupMcpCopied = 'Setup command copied to clipboard';
  static const String msgPubDevCopied = 'pub.dev package URL copied to clipboard';
  static const String msgChangelogCopied = 'CHANGELOG.md repository URL copied to clipboard';
}
