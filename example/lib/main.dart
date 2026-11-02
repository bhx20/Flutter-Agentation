library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_agentation/flutter_agentation.dart';

void main() {
  runApp(const AgentationExampleApp());
}

/// Root widget for the Flutter Agentation showcase and landing page.
class AgentationExampleApp extends StatelessWidget {
  const AgentationExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agentation - Visual Feedback for Flutter & AI Agents',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF09090B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          surface: Color(0xFF121215),
        ),
        useMaterial3: true,
      ),
      // FlutterAgentation.builder() wraps the entire app to inject the
      // floating inspection toolbar, design canvas, and MCP streaming overlay.
      builder: FlutterAgentation.builder(),
      home: const MinimalLandingPage(),
    );
  }
}

/// Boxless, truly minimal, full-width showcase landing page for Flutter Agentation.
///
/// Designed with pure typographic hierarchy, open whitespace, subtle hairline
/// dividers, and no rectangular card enclosures.
class MinimalLandingPage extends StatefulWidget {
  const MinimalLandingPage({super.key});

  @override
  State<MinimalLandingPage> createState() => _MinimalLandingPageState();
}

class _MinimalLandingPageState extends State<MinimalLandingPage> {
  int _counter = 24;
  bool _copied = false;
  double _sliderValue = 72;
  bool _toggleSwitch = true;

  void _copyCommand(String command) {
    Clipboard.setData(ClipboardData(text: command));
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $command'),
        duration: const Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 20 : 48,
            vertical: 24,
          ),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header (Boxless) ──
                _buildHeader(isCompact),
                const SizedBox(height: 56),

                // ── Hero Section (Boxless) ──
                _buildHeroSection(),
                const SizedBox(height: 48),

                // ── Metrics Strip (Typographic, Hairline Dividers) ──
                _buildMetricsStrip(isCompact),
                const SizedBox(height: 64),

                // ── Section 1: Live Inspection Playground (Open Layout) ──
                _buildSectionHeader('01', 'Live Inspection Playground', 'Interact directly with live target widgets. Activate the crosshair on the toolbar below to inspect.'),
                const SizedBox(height: 28),
                _buildPlayground(isCompact),
                const SizedBox(height: 72),

                // ── Section 2: Core Capabilities (Typographic Grid) ──
                _buildSectionHeader('02', 'Engine Capabilities', 'Comprehensive architectural features connecting Flutter widgets to autonomous AI coding agents.'),
                const SizedBox(height: 28),
                _buildCapabilities(isCompact),
                const SizedBox(height: 72),

                // ── Section 3: Compatible AI Agents (Open Row) ──
                _buildSectionHeader('03', 'AI Coding Agent Integrations', 'Connect your live application with zero prompt engineering.'),
                const SizedBox(height: 28),
                _buildSupportedAgents(isCompact),
                const SizedBox(height: 72),

                // ── Section 4: Target Platforms (Open Table) ──
                _buildSectionHeader('04', 'Target Platform Transports', 'Built to work seamlessly across mobile, desktop, and web.'),
                const SizedBox(height: 28),
                _buildPlatformArchitecture(),
                const SizedBox(height: 72),

                // ── Section 5: Spec-Kit Workflow (Open Step Flow) ──
                _buildSectionHeader('05', 'Agent Workflow', 'Promptless coding using Spec-Kit slash commands in your agent environment.'),
                const SizedBox(height: 28),
                _buildWorkflow(isCompact),
                const SizedBox(height: 72),

                // ── Section 6: Keyboard Shortcuts (Open List) ──
                _buildSectionHeader('06', 'Keyboard Shortcuts', 'Quick canvas navigation and shortcut actions.'),
                const SizedBox(height: 28),
                _buildKeymap(isCompact),
                const SizedBox(height: 80),

                // ── Footer (Boxless Hairline) ──
                _buildFooter(isCompact),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SECTION HEADER HELPER
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String index, String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              index,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6366F1),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(width: 12),
            Container(width: 24, height: 1, color: const Color(0xFF6366F1)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF71717A),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TOP HEADER (BOXLESS)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHeader(bool isCompact) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6366F1),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Flutter Agentation',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '0.1.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF71717A),
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () => _copyCommand('dart run flutter_agentation:setupmcp'),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _copied ? 'Copied to clipboard' : 'dart run flutter_agentation:setupmcp',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _copied ? const Color(0xFF10B981) : const Color(0xFFA1A1AA),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      _copied ? Icons.check_rounded : Icons.copy_rounded,
                      size: 13,
                      color: _copied ? const Color(0xFF10B981) : const Color(0xFF71717A),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Divider(color: Color(0xFF27272A), height: 1),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HERO SECTION (BOXLESS)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'MODEL CONTEXT PROTOCOL (JSON-RPC 2.0 SSE)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF71717A),
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Text(
          'Visual Feedback for Flutter & AI Coding Agents',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            letterSpacing: -1.0,
            height: 1.15,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Directly inspect live widget hierarchies, drop precision feedback pins, wireframe layout changes, '
          'and stream exact source code locations into Cursor, Claude Desktop, Windsurf, or Antigravity via MCP.',
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Color(0xFFA1A1AA),
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => _copyCommand('dart run flutter_agentation:setupmcp'),
              child: const Text(
                'Copy Setup CLI',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Tap the crosshair icon on the toolbar to inspect any element',
              style: TextStyle(fontSize: 13, color: Color(0xFF71717A)),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // METRICS STRIP (BOXLESS, HAIRLINE DIVIDERS)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildMetricsStrip(bool isCompact) {
    final metrics = [
      (value: '0 Overhead', label: 'In release builds'),
      (value: '100% Exact', label: 'Source line mapping'),
      (value: '6 Platforms', label: 'Mobile, desktop & web'),
      (value: 'JSON-RPC 2.0', label: 'Model Context Protocol'),
    ];

    return Column(
      children: [
        const Divider(color: Color(0xFF27272A), height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: isCompact
              ? Wrap(
                  spacing: 32,
                  runSpacing: 20,
                  alignment: WrapAlignment.spaceBetween,
                  children: metrics.map(_buildMetricItem).toList(),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: metrics.map(_buildMetricItem).toList(),
                ),
        ),
        const Divider(color: Color(0xFF27272A), height: 1),
      ],
    );
  }

  Widget _buildMetricItem(({String label, String value}) m) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          m.value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          m.label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF71717A),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LIVE INSPECTION PLAYGROUND (OPEN LAYOUT)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildPlayground(bool isCompact) {
    return Column(
      children: [
        const Divider(color: Color(0xFF27272A), height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPlaygroundColumn1(),
                    const SizedBox(height: 32),
                    const Divider(color: Color(0xFF1E1E22), height: 1),
                    const SizedBox(height: 32),
                    _buildPlaygroundColumn2(),
                    const SizedBox(height: 32),
                    const Divider(color: Color(0xFF1E1E22), height: 1),
                    const SizedBox(height: 32),
                    _buildPlaygroundColumn3(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildPlaygroundColumn1()),
                    Container(width: 1, height: 180, color: const Color(0xFF27272A)),
                    const SizedBox(width: 32),
                    Expanded(child: _buildPlaygroundColumn2()),
                    Container(width: 1, height: 180, color: const Color(0xFF27272A)),
                    const SizedBox(width: 32),
                    Expanded(child: _buildPlaygroundColumn3()),
                  ],
                ),
        ),
        const Divider(color: Color(0xFF27272A), height: 1),
      ],
    );
  }

  Widget _buildPlaygroundColumn1() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Interactive State Counter',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFA1A1AA)),
          ),
          const SizedBox(height: 12),
          Text(
            '$_counter',
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF3F3F46)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () => setState(() => _counter = 0),
                child: const Text('Reset', style: TextStyle(fontSize: 12, color: Color(0xFFA1A1AA))),
              ),
              const SizedBox(width: 10),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () => setState(() => _counter++),
                child: const Text('+1 Increment', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaygroundColumn2() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Controls & Toggles',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFA1A1AA)),
              ),
              Switch(
                value: _toggleSwitch,
                onChanged: (v) => setState(() => _toggleSwitch = v),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Adjustment Slider: ${_sliderValue.round()}%',
            style: const TextStyle(fontSize: 12, color: Color(0xFF71717A)),
          ),
          Slider(
            value: _sliderValue,
            min: 0,
            max: 100,
            activeColor: const Color(0xFF6366F1),
            onChanged: (v) => setState(() => _sliderValue = v),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaygroundColumn3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Target Telemetry',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFA1A1AA)),
        ),
        const SizedBox(height: 14),
        _buildTelemetryRow('Resolved Widget', 'ElevatedButton'),
        _buildTelemetryRow('Source Location', 'example/lib/main.dart'),
        _buildTelemetryRow('Active Transport', 'Port 4747 (SSE Bridge)'),
        _buildTelemetryRow('Draft Protection', 'Safe (Local only)'),
      ],
    );
  }

  Widget _buildTelemetryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF71717A))),
          Text(value, style: const TextStyle(fontSize: 12, color: Color(0xFFE4E4E7), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CORE CAPABILITIES (TYPOGRAPHIC OPEN GRID)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildCapabilities(bool isCompact) {
    final items = [
      (
        index: '01',
        title: 'Deep Widget Inspection',
        description: 'Resolves RenderBox bounds, ancestor breadcrumb paths, developer keys, semantics, and Dart source line numbers.',
      ),
      (
        index: '02',
        title: 'Multi-Platform MCP Sync',
        description: 'Embedded and standalone Model Context Protocol SSE & JSON-RPC streaming across Web, Desktop, and Mobile.',
      ),
      (
        index: '03',
        title: 'Visual Wireframing & Layout Mode',
        description: 'Drag-and-drop realistic skeleton components (Buttons, Cards, Inputs, Lists) directly onto live UI with counter-question dialogs.',
      ),
      (
        index: '04',
        title: 'Draft Annotation Protection',
        description: 'Annotations remain local drafts until submitted. When autoSendMcp is OFF, pins will never leak to agents without explicit permission.',
      ),
      (
        index: '05',
        title: 'Multi-Mode Annotation Canvas',
        description: 'Supports single element inspection, marquee area selection, multi-element picking, and freeform pencil drawing directly on the screen.',
      ),
      (
        index: '06',
        title: 'Rich Export Formats & Webhooks',
        description: 'Export to AI-ready Markdown, JSON envelopes, or plain source paths, with real-time webhook dispatching for external review tools.',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 1;
        if (constraints.maxWidth > 1000) {
          columns = 3;
        } else if (constraints.maxWidth > 600) {
          columns = 2;
        }

        final spacing = 32.0;
        final itemWidth = (constraints.maxWidth - (columns - 1) * spacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: 40,
          children: items.map((item) {
            return SizedBox(
              width: itemWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.index,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.55,
                      color: Color(0xFF71717A),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // COMPATIBLE AI AGENTS (OPEN ROW)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSupportedAgents(bool isCompact) {
    final agents = [
      (name: 'Cursor', desc: 'mcp.json SSE'),
      (name: 'Claude Desktop', desc: 'Stdio & SSE'),
      (name: 'Windsurf', desc: 'mcp_config.json'),
      (name: 'VS Code (Cline / Roo)', desc: 'MCP Settings'),
      (name: 'Antigravity', desc: 'Universal Native Bridge'),
    ];

    return Column(
      children: [
        const Divider(color: Color(0xFF27272A), height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Wrap(
            spacing: 36,
            runSpacing: 16,
            children: agents.map((a) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6366F1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    a.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '(${a.desc})',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF71717A),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        const Divider(color: Color(0xFF27272A), height: 1),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TARGET PLATFORM ARCHITECTURE (OPEN TABLE)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildPlatformArchitecture() {
    final platforms = [
      (platform: 'Web (Chrome / Edge / Safari)', protocol: 'HTTP live bidirectional bridge (/sync)'),
      (platform: 'Desktop (Windows / macOS / Linux)', protocol: 'Embedded direct TCP socket listening on port 4747'),
      (platform: 'Android (Device & Emulator)', protocol: 'ADB reverse port forwarding (adb forward tcp:4747 tcp:4747)'),
      (platform: 'iOS (Simulator & Physical Device)', protocol: 'Localhost on Simulator; local Wi-Fi LAN IP on physical device'),
    ];

    return Column(
      children: [
        const Divider(color: Color(0xFF27272A), height: 1),
        Column(
          children: platforms.map((p) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          p.platform,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          p.protocol,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF71717A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFF1E1E22), height: 1),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SPEC-KIT WORKFLOW (OPEN STEP FLOW)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildWorkflow(bool isCompact) {
    final steps = [
      (
        step: 'Step 01',
        title: 'Run CLI Setup',
        command: 'dart run flutter_agentation:setupmcp',
        desc: 'Generates .flutter_agentation/mcp.json and registers agent skills.',
      ),
      (
        step: 'Step 02',
        title: 'Verify Connection',
        command: '/flutter-agentation-check-mcp',
        desc: 'Validates port health, active transports, and submitted feedback pins.',
      ),
      (
        step: 'Step 03',
        title: 'Review & Fix Code',
        command: '/flutter-agentation-review-feedback',
        desc: 'Agent reads annotations, locates target source lines, and applies fixes.',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        return isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: steps.map((s) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 32.0),
                      child: _buildWorkflowItem(s),
                    ),
                  );
                }).toList(),
              )
            : Column(
                children: steps.map((s) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 28.0),
                    child: _buildWorkflowItem(s),
                  );
                }).toList(),
              );
      },
    );
  }

  Widget _buildWorkflowItem(
    ({String command, String desc, String step, String title}) s,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.step,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6366F1),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          s.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          s.command,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF818CF8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          s.desc,
          style: const TextStyle(
            fontSize: 13,
            height: 1.5,
            color: Color(0xFF71717A),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // KEYBOARD SHORTCUTS (OPEN LIST)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildKeymap(bool isCompact) {
    final shortcuts = [
      (key: 'Ctrl + Shift + A', desc: 'Toggle visual inspection mode'),
      (key: 'S', desc: 'Submit draft annotations to agent transport'),
      (key: 'Del / Backspace', desc: 'Delete selected feedback pin or skeleton'),
      (key: 'Esc', desc: 'Close modals, detail panels, or clear selection'),
      (key: 'C', desc: 'Copy annotations as structured Markdown to clipboard'),
      (key: 'D', desc: 'Toggle visual wireframing & layout mode palette'),
    ];

    return Column(
      children: [
        const Divider(color: Color(0xFF27272A), height: 1),
        Column(
          children: shortcuts.map((s) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 180,
                        child: Text(
                          s.key,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          s.desc,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF71717A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFF1E1E22), height: 1),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MINIMAL FOOTER (HAIRLINE DIVIDER)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildFooter(bool isCompact) {
    return Column(
      children: [
        const Divider(color: Color(0xFF27272A), height: 1),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Flutter Agentation',
              style: TextStyle(fontSize: 12, color: Color(0xFF52525B)),
            ),
            Text(
              'MIT License • Flutter 3.16+',
              style: TextStyle(fontSize: 12, color: Color(0xFF52525B)),
            ),
          ],
        ),
      ],
    );
  }
}
