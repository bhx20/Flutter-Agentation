import 'package:flutter/material.dart';
import 'package:example/src/theme/app_dimensions.dart';

import '../constants/app_strings.dart';
import '../theme/app_insets.dart';
import '../theme/app_radii.dart';
import '../theme/app_colors.dart';
import 'package:flutter_agentation/flutter_agentation.dart';
import '../theme/app_typography.dart';
import '../utils/breakpoints.dart';
import '../components/copy_action_button.dart';

class McpWebhooksPage extends StatefulWidget {
  const McpWebhooksPage({super.key});

  @override
  State<McpWebhooksPage> createState() => _McpWebhooksPageState();
}

class _McpWebhooksPageState extends State<McpWebhooksPage> {
  final ValueNotifier<int> _selectedPayloadTab = ValueNotifier<int>(0);

  @override
  void dispose() {
    _selectedPayloadTab.dispose();
    super.dispose();
  }

  final List<String> _tabs = ['Generic JSON', 'Slack Incoming', 'Discord Webhook'];

  static const String _httpHeaders = '''Content-Type: application/json
User-Agent: FlutterAgentation-Webhook/1.0
X-Agentation-Delivery: 8fa31b20-1a22-4876-90c7-bfef04423019
X-Agentation-Event: annotation_created
X-Agentation-Timestamp: 1747578720
X-Agentation-Signature: sha256=d3f789ab5c81...''';

  static const String _genericJson = '''{
  "event": "annotation_created",
  "id": "ann_1729864200000",
  "timestamp": "2025-05-18T14:32:00Z",
  "coordinates": {
    "x": 140.0,
    "y": 280.0,
    "width": 190.0,
    "height": 56.0
  },
  "widget": {
    "type": "ElevatedButton",
    "key": "action_btn",
    "ancestry": "Scaffold > SafeArea > Padding > ElevatedButton",
    "sourceLocation": "lib/screens/dashboard.dart:64"
  },
  "comment": "Change to primary style with 24.0 padding",
  "author": "designer@flutteragentation.dev"
}''';

  static const String _slackJson = '''{
  "text": "New visual feedback submitted on ElevatedButton",
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*Visual Pin:* `lib/screens/dashboard.dart:64`\\n*Comment:* Change to primary style with 24.0 padding"
      }
    }
  ]
}''';

  static const String _discordJson = '''{
  "content": "**Flutter Agentation Feedback Event**",
  "embeds": [
    {
      "title": "ElevatedButton (dashboard.dart:64)",
      "description": "Change to primary style with 24.0 padding",
      "color": 2451950
    }
  ]
}''';

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

    final endpoints = [
      (method: 'GET', path: '/health, /status', desc: 'Server health check, active platform, port, and connected client count'),
      (method: 'GET', path: '/sse, /events', desc: 'Server-Sent Events stream for live annotation additions, status changes, and action requests'),
      (method: 'POST', path: '/mcp, /messages', desc: 'JSON-RPC 2.0 protocol endpoint for agent tool invocations and initialization'),
      (method: 'GET', path: '/pending', desc: 'Retrieves all active, submitted annotations across sessions'),
      (method: 'POST', path: '/sessions/{id}/action', desc: 'Triggers a sync action and dispatches configured webhooks'),
      (method: 'POST', path: '/annotations/{id}/thread', desc: 'Appends a comment from an agent or human into the annotation thread'),
      (method: 'PATCH', path: '/annotations/{id}', desc: 'Updates annotation status (open, in_progress, resolved, rejected)'),
      (method: 'DELETE', path: '/annotations/{id}', desc: 'Deletes a resolved or dismissed annotation'),
    ];

    final retryStats = [
      (title: 'Max 4 tries', sub: '1 initial + 3 retries', label: 'ATTEMPTS'),
      (title: 'Exponential', sub: 'base * 2^(n)', label: 'FORMULA'),
      (title: '0% – 25%', sub: 'Prevents stampede', label: 'JITTER VARIANCE'),
      (title: '30 Seconds', sub: 'Ceiling limit per retry', label: 'MAX DELAY CAP'),
      (title: 'Retry-After', sub: 'Parses HTTP header', label: 'RATE LIMITING'),
      (title: '429 & 5xx', sub: 'Auto recover', label: 'TRIGGERS'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: AppDimensions.d16,
          runSpacing: AppDimensions.d8,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.mcpWebhooksOverline,
                  style: AppTypography.overline,
                ),
                AppDimensions.h6,
                Text(
                  AppStrings.navMcp,
                  style: isMobile ? AppTypography.h3 : AppTypography.h2,
                ),
              ],
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppDimensions.d440),
              child: const Text(
                'Real-time SSE synchronization and resilient HTTP webhook dispatch.',
                style: AppTypography.bodyMedium,
              ),
            ),
          ],
        ),
        AppDimensions.h28,

        // Visual Architecture Flow Container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.textWhite,
            borderRadius: AppRadii.rounded8,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: AppInsets.h20v14,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppDimensions.d12,
                  runSpacing: AppDimensions.d8,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppDimensions.d10,
                      runSpacing: AppDimensions.d4,
                      children: [
                        AgentationIcons.layout(size: AppDimensions.d18, color: AppColors.textDark),
                        const Text(
                          'Visual Architecture Flow',
                          style: AppTypography.sectionItemTitleBold,
                        ),
                        const Text(
                          'Flutter runtime & AI agents via SSE/stdio, sharing the same data store.',
                          style: AppTypography.bodySmallTertiary,
                        ),
                      ],
                    ),
                    Container(
                      padding: AppInsets.h8v4,
                      decoration: BoxDecoration(
                        color: AppColors.pageBackground,
                        borderRadius: AppRadii.rounded6,
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: const Text(
                        'toolbar → server → agent',
                        style: AppTypography.codeSmallSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.borderSubtle, height: AppDimensions.d1),

              // True Sequence Diagram
              Padding(
                padding: AppInsets.all24,
                child: _buildSequenceDiagram(isMobile),
              ),
            ],
          ),
        ),
        AppDimensions.h48,

        // MCP Server & Endpoints Header
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: AppDimensions.d16,
          runSpacing: AppDimensions.d8,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('MCP Server & Endpoints', style: AppTypography.h3),
                AppDimensions.h6,
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AppDimensions.d680),
                  child: RichText(
                    text: TextSpan(
                      style: AppTypography.bodySmallSecondary,
                      children: [
                        const TextSpan(text: 'The built-in HTTP and SSE daemon binds to '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Container(
                            padding: AppInsets.h4v1,
                            decoration: BoxDecoration(
                              color: AppColors.cardBackgroundAlt,
                              borderRadius: AppRadii.rounded4,
                            ),
                            child: const Text('0.0.0.0', style: AppTypography.codeSmall),
                          ),
                        ),
                        const TextSpan(text: ' (with '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Container(
                            padding: AppInsets.h4v1,
                            decoration: BoxDecoration(
                              color: AppColors.cardBackgroundAlt,
                              borderRadius: AppRadii.rounded4,
                            ),
                            child: const Text('127.0.0.1', style: AppTypography.codeSmall),
                          ),
                        ),
                        const TextSpan(text: ' fallback). Port collisions automatically trigger monotonic allocation through 4757.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (!isMobile)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: AppDimensions.d7,
                    height: AppDimensions.d7,
                    decoration: const BoxDecoration(
                      color: AppColors.accentGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  AppDimensions.w8,
                  const Text(
                    'JSON-RPC 2.0 SSE Core',
                    style: AppTypography.bodySmallCodeDark,
                  ),
                ],
              ),
          ],
        ),
        AppDimensions.h20,

        // Endpoints Table
        Container(
          decoration: BoxDecoration(
            color: AppColors.textWhite,
            borderRadius: AppRadii.rounded8,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            children: [
              Padding(
                padding: AppInsets.h16v12,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppDimensions.d8,
                  runSpacing: AppDimensions.d4,
                  children: const [
                    Text('HTTP & STREAM ENDPOINTS', style: AppTypography.overlineMini),
                    Text('8 active routes', style: AppTypography.captionMuted),
                  ],
                ),
              ),
              const Divider(color: AppColors.borderSubtle, height: AppDimensions.d1),
              ...List.generate(endpoints.length, (index) {
                final e = endpoints[index];
                return Column(
                  children: [
                    Padding(
                      padding: AppInsets.h16v12,
                      child: isMobile
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _buildMethodBadge(e.method),
                                    AppDimensions.w10,
                                    Expanded(
                                      child: Text(
                                        e.path,
                                        style: AppTypography.codeMediumDarkBold,
                                      ),
                                    ),
                                  ],
                                ),
                                AppDimensions.h6,
                                Text(e.desc, style: AppTypography.bodySmallTertiary),
                              ],
                            )
                          : Row(
                              children: [
                                SizedBox(width: AppDimensions.d65, child: _buildMethodBadge(e.method)),
                                SizedBox(
                                  width: AppDimensions.d240,
                                  child: Text(
                                    e.path,
                                    style: AppTypography.codeMediumDarkBold,
                                  ),
                                ),
                                AppDimensions.w16,
                                Expanded(
                                  child: Text(e.desc, style: AppTypography.bodySmallTertiary),
                                ),
                              ],
                            ),
                    ),
                    if (index < endpoints.length - 1)
                      const Divider(color: AppColors.borderSubtle, height: AppDimensions.d1),
                  ],
                );
              }),
            ],
          ),
        ),
        AppDimensions.h48,

        // Webhook Section Header
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: AppDimensions.d16,
          runSpacing: AppDimensions.d8,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Webhook Dispatcher & Resilience', style: AppTypography.h3),
                AppDimensions.h6,
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AppDimensions.d680),
                  child: const Text(
                    'Outbound event synchronization with exponential backoff, collision mitigation jitter, and RFC-compliant rate limit renegotiation.',
                    style: AppTypography.bodySmallSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        AppDimensions.h20,

        // Webhook Delivery Flow Container
        Container(
          decoration: BoxDecoration(
            color: AppColors.textWhite,
            borderRadius: AppRadii.rounded8,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: AppInsets.h16v12,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppDimensions.d8,
                  runSpacing: AppDimensions.d4,
                  children: const [
                    Text('WEBHOOK DELIVERY FLOW', style: AppTypography.overlineMini),
                    Text('Automatic retry loop', style: AppTypography.captionMuted),
                  ],
                ),
              ),
              const Divider(color: AppColors.borderSubtle, height: AppDimensions.d1),
              Padding(
                padding: AppInsets.all20,
                child: isMobile
                    ? Column(
                        children: [
                          _buildWebhookStep('01', 'Event Trigger', 'Annotation created, updated, or status resolved in Flutter canvas.', AgentationIcons.listSparkle(size: AppDimensions.d16, color: AppColors.textTertiary)),
                          AppDimensions.h16,
                          _buildWebhookStep('02', 'Payload Assembly', 'Serializes widget type, RenderBox bounding rect, and exact Dart source line.', AgentationIcons.component(size: AppDimensions.d16, color: AppColors.textTertiary)),
                          AppDimensions.h16,
                          _buildWebhookStep('03', 'Resilient Dispatch', 'Exponential backoff (base * 2^n) with 0-25% jitter mitigation on 429 / 5xx.', AgentationIcons.gear(size: AppDimensions.d16, color: AppColors.textTertiary)),
                          AppDimensions.h16,
                          _buildWebhookStep('04', 'Subscriber Ingest', 'IDE daemon or CI pipeline ingests payload with idempotency guarantee.', AgentationIcons.check(size: AppDimensions.d16, color: AppColors.textTertiary)),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildWebhookStep('01', 'Event Trigger', 'Annotation created, updated, or status resolved in Flutter canvas.', AgentationIcons.listSparkle(size: AppDimensions.d16, color: AppColors.textTertiary))),
                          AppDimensions.w16,
                          Expanded(child: _buildWebhookStep('02', 'Payload Assembly', 'Serializes widget type, RenderBox bounding rect, and exact Dart source line.', AgentationIcons.component(size: AppDimensions.d16, color: AppColors.textTertiary))),
                          AppDimensions.w16,
                          Expanded(child: _buildWebhookStep('03', 'Resilient Dispatch', 'Exponential backoff (base * 2^n) with 0-25% jitter mitigation on 429 / 5xx.', AgentationIcons.gear(size: AppDimensions.d16, color: AppColors.textTertiary))),
                          AppDimensions.w16,
                          Expanded(child: _buildWebhookStep('04', 'Subscriber Ingest', 'IDE daemon or CI pipeline ingests payload with idempotency guarantee.', AgentationIcons.check(size: AppDimensions.d16, color: AppColors.textTertiary))),
                        ],
                      ),
              ),
              const Divider(color: AppColors.borderSubtle, height: AppDimensions.d1),

              // Reliability Stats Grid
              Padding(
                padding: AppInsets.h16v12,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppDimensions.d8,
                  runSpacing: AppDimensions.d4,
                  children: const [
                    Text('RELIABILITY & RETRY POLICY', style: AppTypography.overlineMini),
                    Text('RFC 7231 Compliant', style: AppTypography.captionMuted),
                  ],
                ),
              ),
              const Divider(color: AppColors.borderSubtle, height: AppDimensions.d1),
              Padding(
                padding: AppInsets.all20,
                child: Wrap(
                  spacing: AppDimensions.d24,
                  runSpacing: AppDimensions.d18,
                  children: retryStats.map((s) {
                    return SizedBox(
                      width: isMobile ? AppDimensions.d140 : AppDimensions.d170,
                      child: _buildStatItem(s.label, s.title, s.sub),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        AppDimensions.h28,

        // Webhook Payload Presets Container
        Container(
          decoration: BoxDecoration(
            color: AppColors.textWhite,
            borderRadius: AppRadii.rounded8,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: AppInsets.h16v12,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppDimensions.d12,
                  runSpacing: AppDimensions.d8,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppDimensions.d8,
                      runSpacing: AppDimensions.d4,
                      children: [
                        AgentationIcons.wireframe(size: AppDimensions.d16, color: AppColors.textDark),
                        const Text(
                          'WEBHOOK PAYLOAD PRESETS',
                          style: AppTypography.overlineDark,
                        ),
                        const Text(
                          'POST /api/webhooks/agentation',
                          style: AppTypography.codeSmallTertiary,
                        ),
                      ],
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: _selectedPayloadTab,
                      builder: (context, selectedTab, _) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(_tabs.length, (idx) {
                              final isSelected = selectedTab == idx;
                              return Padding(
                                padding: AppInsets.l6,
                                child: InkWell(
                                  onTap: () => _selectedPayloadTab.value = idx,
                                  borderRadius: AppRadii.rounded6,
                                  child: Container(
                                    padding: AppInsets.h10v5,
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.textDark : AppColors.pageBackground,
                                      borderRadius: AppRadii.rounded6,
                                      border: Border.all(
                                        color: isSelected ? AppColors.textDark : AppColors.borderSubtle,
                                      ),
                                    ),
                                    child: Text(
                                      _tabs[idx],
                                      style: isSelected ? AppTypography.captionBold.copyWith(color: AppColors.textWhite) : AppTypography.captionSecondary,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.borderSubtle, height: AppDimensions.d1),
              Padding(
                padding: AppInsets.all20,
                child: ValueListenableBuilder<int>(
                  valueListenable: _selectedPayloadTab,
                  builder: (context, selectedTab, _) {
                    return isMobile
                        ? Column(
                            children: [
                              _buildCodeSnippetBox('HTTP Headers', _httpHeaders),
                              AppDimensions.h16,
                              _buildCodeSnippetBox('Generic JSON Schema application/json', _getActivePayloadJson(selectedTab)),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildCodeSnippetBox('HTTP Headers', _httpHeaders)),
                              AppDimensions.w16,
                              Expanded(child: _buildCodeSnippetBox('Generic JSON Schema application/json', _getActivePayloadJson(selectedTab))),
                            ],
                          );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getActivePayloadJson(int selectedTab) {
    switch (selectedTab) {
      case 1:
        return _slackJson;
      case 2:
        return _discordJson;
      default:
        return _genericJson;
    }
  }

  Widget _buildMethodBadge(String method) {
    Color bg;
    Color fg;
    switch (method) {
      case 'GET':
        bg = AppColors.accentBlueSubtle;
        fg = AppColors.accentBlueDark;
        break;
      case 'POST':
        bg = AppColors.accentGreenSubtle;
        fg = AppColors.accentGreenDark;
        break;
      case 'PATCH':
        bg = AppColors.accentAmberSubtle;
        fg = AppColors.accentAmberDeep;
        break;
      case 'DELETE':
        bg = AppColors.accentRedSubtle;
        fg = AppColors.accentRedDark;
        break;
      default:
        bg = AppColors.cardBackgroundAlt;
        fg = AppColors.textCodeDark;
    }
    return Container(
      padding: AppInsets.h6v2,
      decoration: BoxDecoration(color: bg, borderRadius: AppRadii.rounded4),
      child: Text(method, style: AppTypography.codeMicro.copyWith(fontWeight: FontWeight.w500, color: fg)),
    );
  }

  Widget _buildWebhookStep(String num, String title, String desc, Widget iconWidget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(num, style: AppTypography.cardTitleSmall),
            iconWidget,
          ],
        ),
        AppDimensions.h8,
        Text(title, style: AppTypography.sectionItemTitlePrimaryBold),
        AppDimensions.h4,
        Text(desc, style: AppTypography.bodySmallSecondary.copyWith(height: 1.4)),
      ],
    );
  }

  Widget _buildStatItem(String label, String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.overlineMiniMuted),
        AppDimensions.h6,
        Text(title, style: AppTypography.cardTitleSmall),
        AppDimensions.h4,
        Text(sub, style: AppTypography.captionTertiary),
      ],
    );
  }

  Widget _buildCodeSnippetBox(String label, String code) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: AppRadii.rounded8,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: AppInsets.h14v10,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppDimensions.d8,
              runSpacing: AppDimensions.d4,
              children: [
                Text(label, style: AppTypography.captionTertiary),
                CopyActionButton(text: code),
              ],
            ),
          ),
          const Divider(color: AppColors.borderSubtle, height: AppDimensions.d1),
          Padding(
            padding: AppInsets.all14,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(
                code,
                style: AppTypography.codeSmallDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSequenceDiagram(bool isMobile) {
    const double diagramWidth = 720.0;
    const double diagramHeight = 360.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: diagramWidth,
        height: diagramHeight,
        child: Stack(
          children: [
            // Actor Nodes Header Row
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _ActorNode('Flutter App', 'Toolbar'),
                  _ActorNode('HTTP', 'Server'),
                  _ActorNode('MCP', 'Server'),
                  _ActorNode('AI Agent', 'Claude / Cursor'),
                ],
              ),
            ),

            // Canvas with vertical dashed lifelines and horizontal message arrows
            Positioned.fill(
              top: 50,
              bottom: 30,
              child: CustomPaint(
                painter: _SequenceDiagramPainter(),
              ),
            ),

            // Message Label Pills positioned along the diagram
            // Step 1: POST /annotations (Node 0 to 1 at y = 80)
            const Positioned(
              top: 80,
              left: 140,
              child: _MessageBadge('POST /annotations'),
            ),

            // Step 2: Store annotation (Node 1 to 2 at y = 120)
            const Positioned(
              top: 120,
              left: 310,
              child: _MessageBadge('Store annotation'),
            ),

            // Step 3: get_pending (Node 2 to 3 at y = 160)
            const Positioned(
              top: 160,
              left: 490,
              child: _MessageBadge('get_pending'),
            ),

            // Step 4: annotations (Node 3 to 2 at y = 200, return)
            const Positioned(
              top: 200,
              left: 490,
              child: _MessageBadge('annotations'),
            ),

            // Step 5: resolve (Node 3 to 2 at y = 240)
            const Positioned(
              top: 240,
              left: 495,
              child: _MessageBadge('resolve'),
            ),

            // Step 6: status (Node 2 to 1 at y = 280, return)
            const Positioned(
              top: 280,
              left: 330,
              child: _MessageBadge('status'),
            ),

            // Step 7: resolved (Node 1 to 0 at y = 310, return)
            const Positioned(
              top: 310,
              left: 170,
              child: _MessageBadge('resolved'),
            ),

            // Legend at bottom
            Positioned(
              bottom: 4,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('—>  request', style: AppTypography.codeSmallSecondary),
                  AppDimensions.w32,
                  Text('- - ->  response', style: AppTypography.codeSmallMuted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActorNode extends StatelessWidget {
  const _ActorNode(this.title, this.subtitle);

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.d125,
      padding: AppInsets.v8,
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: AppRadii.rounded8,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: AppTypography.itemTitleSmall,
          ),
          AppDimensions.h2,
          Text(
            subtitle,
            style: AppTypography.microTertiary,
          ),
        ],
      ),
    );
  }
}

class _MessageBadge extends StatelessWidget {
  const _MessageBadge(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppInsets.h8v3,
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: AppRadii.rounded4,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Text(
        text,
        style: AppTypography.codeMicro,
      ),
    );
  }
}

class _SequenceDiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 4 Column centers based on ActorNode width (125) and diagram width (720)
    // 0: ~62.5, 1: ~255.0, 2: ~465.0, 3: ~657.5
    final double col0 = 62.5;
    final double col1 = (size.width - 250) / 3 + 62.5;
    final double col2 = (size.width - 250) * 2 / 3 + 125 + 62.5 / 2;
    final double col3 = size.width - 62.5;

    final cols = [col0, col1, col2, col3];

    // Draw vertical dashed lifelines
    final dashPaint = Paint()
      ..color = AppColors.borderLight
      ..strokeWidth = 1.0;

    for (final col in cols) {
      double startY = 0;
      while (startY < size.height) {
        canvas.drawLine(Offset(col, startY), Offset(col, startY + 5), dashPaint);
        startY += 9;
      }
    }

    // Horizontal arrow painter
    final solidPaint = Paint()
      ..color = AppColors.textSecondary
      ..strokeWidth = 1.2;

    final responsePaint = Paint()
      ..color = AppColors.textMuted
      ..strokeWidth = 1.0;

    void drawArrow({
      required double fromX,
      required double toX,
      required double y,
      required bool isDashed,
      required bool isReverse,
    }) {
      final p = isDashed ? responsePaint : solidPaint;
      if (!isDashed) {
        canvas.drawLine(Offset(fromX, y), Offset(toX, y), p);
      } else {
        final double minX = fromX < toX ? fromX : toX;
        final double maxX = fromX < toX ? toX : fromX;
        double currX = minX;
        while (currX < maxX) {
          canvas.drawLine(Offset(currX, y), Offset(currX + 5 > maxX ? maxX : currX + 5, y), p);
          currX += 8;
        }
      }

      // Draw Arrow Head
      final path = Path();
      if (!isReverse) {
        // Pointing Right
        path.moveTo(toX, y);
        path.lineTo(toX - 6, y - 3.5);
        path.lineTo(toX - 6, y + 3.5);
      } else {
        // Pointing Left
        path.moveTo(toX, y);
        path.lineTo(toX + 6, y - 3.5);
        path.lineTo(toX + 6, y + 3.5);
      }
      path.close();
      canvas.drawPath(path, p..style = PaintingStyle.fill);
    }

    // Arrow 1: POST /annotations (col0 -> col1 at y=40)
    drawArrow(fromX: col0, toX: col1, y: 40, isDashed: false, isReverse: false);

    // Arrow 2: Store annotation (col1 -> col2 at y=80)
    drawArrow(fromX: col1, toX: col2, y: 80, isDashed: false, isReverse: false);

    // Arrow 3: get_pending (col2 -> col3 at y=120)
    drawArrow(fromX: col2, toX: col3, y: 120, isDashed: false, isReverse: false);

    // Arrow 4: annotations (col3 -> col2 at y=160, return)
    drawArrow(fromX: col3, toX: col2, y: 160, isDashed: true, isReverse: true);

    // Arrow 5: resolve (col3 -> col2 at y=200)
    drawArrow(fromX: col3, toX: col2, y: 200, isDashed: false, isReverse: true);

    // Arrow 6: status (col2 -> col1 at y=240, return)
    drawArrow(fromX: col2, toX: col1, y: 240, isDashed: true, isReverse: true);

    // Arrow 7: resolved (col1 -> col0 at y=270, return)
    drawArrow(fromX: col1, toX: col0, y: 270, isDashed: true, isReverse: true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

typedef McpWebhooksSection = McpWebhooksPage;
