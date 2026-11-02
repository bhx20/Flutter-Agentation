import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_agentation/flutter_agentation.dart';

/// Entry point for the official Flutter Agentation example application.
void main() {
  runApp(const AgentationExampleApp());
}

/// The root application widget configured with Flutter Agentation.
///
/// Demonstrates the official landing page and feature showcase for the package.
/// [FlutterAgentation.builder] is injected at the `builder` parameter of [MaterialApp]
/// to provide persistent inspection, annotation markers, and MCP streaming across all routes.
class AgentationExampleApp extends StatefulWidget {
  const AgentationExampleApp({super.key});

  @override
  State<AgentationExampleApp> createState() => _AgentationExampleAppState();
}

class _AgentationExampleAppState extends State<AgentationExampleApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Agentation - Visual Feedback for Flutter & AI Agents',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF6366F1),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 1,
          margin: EdgeInsets.zero,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF6366F1),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          color: Color(0xFF1E293B),
          elevation: 1,
          margin: EdgeInsets.zero,
        ),
      ),
      // ── FLUTTER AGENTATION INTEGRATION ──
      // Wraps the application to inject the visual inspection overlay and floating toolbar.
      builder: FlutterAgentation.builder(
        onSubmit: (sessionId, annotations) {
          debugPrint(
            '[FlutterAgentation] Session $sessionId submitted ${annotations.length} annotation(s).',
          );
        },
      ),
      home: AgentationLandingPage(
        isDark: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

/// Landing page showcasing Flutter Agentation's features and capabilities.
class AgentationLandingPage extends StatefulWidget {
  const AgentationLandingPage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<AgentationLandingPage> createState() => _AgentationLandingPageState();
}

class _AgentationLandingPageState extends State<AgentationLandingPage> {
  int _counter = 16;
  bool _copied = false;
  String _selectedMode = 'Inspect';

  void _copyCliCommand() {
    Clipboard.setData(
      const ClipboardData(text: 'dart run flutter_agentation:setupmcp'),
    );
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied CLI: dart run flutter_agentation:setupmcp'),
        duration: Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    const primaryColor = Color(0xFF6366F1);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Top Navigation Bar ──
            _buildNavBar(context, isDark),

            // ── Hero Section ──
            _buildHeroSection(context, isDark, primaryColor),

            // ── Features Grid (Showcasing all package features) ──
            _buildFeaturesSection(context, isDark, primaryColor),

            // ── Interactive Playground Section (Live widgets to inspect) ──
            _buildPlaygroundSection(context, isDark, primaryColor),

            // ── Spec-Kit AI Coding Agent Workflow ──
            _buildWorkflowSection(context, isDark, primaryColor),

            // ── Testimonial Section ──
            _buildTestimonialSection(context, isDark),

            // ── Footer ──
            _buildFooter(context, isDark),
          ],
        ),
      ),
    );
  }

  /// Builds the top navigation bar with brand, version, and theme toggle.
  Widget _buildNavBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.track_changes_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Agentation',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0x266366F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'v0.1.0',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6366F1),
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: widget.onToggleTheme,
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonal(
            onPressed: _copyCliCommand,
            child: Text(_copied ? 'Copied CLI' : 'Get CLI'),
          ),
        ],
      ),
    );
  }

  /// Builds the high-impact hero section.
  Widget _buildHeroSection(
    BuildContext context,
    bool isDark,
    Color primaryColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            children: [
              // Eyebrow pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: primaryColor.withAlpha(77)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, size: 16, color: primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      'Universal Model Context Protocol (MCP) Bridge',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Visual Feedback & AI Agent Bridge for Flutter',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width < 600 ? 32 : 46,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.2,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 18),

              // Subtitle
              Text(
                'Inspect live Flutter widget hierarchies, drop precision feedback pins, prototype layout changes, '
                'and stream exact source code locations directly into Cursor, Claude Desktop, Windsurf, or Antigravity.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 32),

              // Terminal CLI Copy Button
              InkWell(
                onTap: _copyCliCommand,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.terminal_rounded,
                        size: 18,
                        color: Color(0xFF6366F1),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'dart run flutter_agentation:setupmcp',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        _copied ? Icons.check : Icons.copy_rounded,
                        size: 16,
                        color: _copied ? Colors.green : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Interactive prompt
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tap the crosshair icon on the toolbar below to inspect any widget!',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the feature showcase displaying all core package capabilities.
  Widget _buildFeaturesSection(
    BuildContext context,
    bool isDark,
    Color primaryColor,
  ) {
    final features = [
      (
        icon: Icons.search_rounded,
        title: 'Deep Widget Inspection',
        description:
            'Resolves exact RenderBox bounding boxes, ancestor breadcrumb paths, developer keys, semantics, and Dart source code line numbers.',
      ),
      (
        icon: Icons.sync_alt_rounded,
        title: 'Multi-Platform MCP Server',
        description:
            'Embedded and standalone Model Context Protocol SSE & JSON-RPC streaming across Web (Chrome/Edge), Desktop (Windows, macOS, Linux), and Mobile (Android, iOS).',
      ),
      (
        icon: Icons.dashboard_customize_outlined,
        title: 'Visual Wireframing & Layout Mode',
        description:
            'Drag-and-drop realistic skeleton components (Buttons, Cards, Inputs, Lists, Headers) directly onto live UI with counter-question configuration dialogs.',
      ),
      (
        icon: Icons.security_rounded,
        title: 'Draft Annotation Protection',
        description:
            'Created annotations remain local drafts until submitted. When autoSendMcp is OFF, pins will never leak to agents without explicit permission.',
      ),
      (
        icon: Icons.gesture_rounded,
        title: 'Multi-Mode Annotation Canvas',
        description:
            'Supports single element inspection, marquee area selection, multi-element picking, and freeform pencil drawing directly on the screen.',
      ),
      (
        icon: Icons.file_download_outlined,
        title: 'Rich Export Formats & Webhooks',
        description:
            'Export to AI-ready Markdown, JSON envelopes, or plain source paths, with real-time webhook dispatching for external review tools.',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
      color: isDark ? const Color(0xFF0B132B) : const Color(0xFFF1F5F9),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Package Features & Architecture',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Complete visual inspection and agent synchronization tooling for Flutter developers.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 28),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 720;
                  return Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: features.map((f) {
                      return SizedBox(
                        width: isWide
                            ? (constraints.maxWidth - 40) / 3
                            : constraints.maxWidth,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withAlpha(30),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(f.icon, color: primaryColor, size: 24),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  f.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  f.description,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.5,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the interactive playground cards for testing inspection.
  Widget _buildPlaygroundSection(
    BuildContext context,
    bool isDark,
    Color primaryColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Live Inspection Playground',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Select any of the components below using the floating toolbar to test real-time inspection, code resolution, and draft pins.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  return isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildProfileCard(isDark)),
                            const SizedBox(width: 20),
                            Expanded(child: _buildSyncCard(isDark)),
                            const SizedBox(width: 20),
                            Expanded(child: _buildCounterCard(isDark)),
                          ],
                        )
                      : Column(
                          children: [
                            _buildProfileCard(isDark),
                            const SizedBox(height: 16),
                            _buildSyncCard(isDark),
                            const SizedBox(height: 16),
                            _buildCounterCard(isDark),
                          ],
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(bool isDark) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  child: const Text('LG', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Liam Gallagher',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Founder - ShipFlutter Studio',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Design mode wireframing saved us hours of back-and-forth. Dragging skeleton cards directly onto live UI makes refinement effortless.',
              style: TextStyle(fontSize: 13, height: 1.45),
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(
                5,
                (index) => const Icon(Icons.star_rounded, size: 18, color: Color(0xFFF59E0B)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncCard(bool isDark) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'MCP Connection',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(38),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(radius: 3, backgroundColor: Colors.green),
                      SizedBox(width: 6),
                      Text('Live', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Port 4747 (SSE & JSON-RPC)',
              style: TextStyle(fontSize: 13, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: 1.0,
              color: const Color(0xFF6366F1),
              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 6,
              children: ['Web', 'Mobile', 'Desktop'].map((tag) {
                return Chip(
                  label: Text(tag, style: const TextStyle(fontSize: 11)),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterCard(bool isDark) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Interactive Element',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Verify that inspecting element states maintains zero interference with host gestures.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: () => setState(() => _counter--),
                  icon: const Icon(Icons.remove, size: 16),
                ),
                const SizedBox(width: 14),
                Text(
                  '$_counter',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 14),
                IconButton.filledTonal(
                  onPressed: () => setState(() => _counter++),
                  icon: const Icon(Icons.add, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Inspect', label: Text('Inspect')),
                ButtonSegment(value: 'Draft', label: Text('Draft')),
              ],
              selected: {_selectedMode},
              onSelectionChanged: (val) {
                setState(() => _selectedMode = val.first);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the Spec-Kit agent workflow steps.
  Widget _buildWorkflowSection(
    BuildContext context,
    bool isDark,
    Color primaryColor,
  ) {
    final steps = [
      (
        step: '01',
        title: 'Run CLI Setup',
        command: 'dart run flutter_agentation:setupmcp',
        description: 'Generates .flutter_agentation/mcp.json and registers slash command skills.',
      ),
      (
        step: '02',
        title: 'Verify Connection',
        command: '/flutter-agentation-check-mcp',
        description: 'Checks port, endpoint health, and pending/submitted annotation counts.',
      ),
      (
        step: '03',
        title: 'Review & Fix Code',
        command: '/flutter-agentation-review-feedback',
        description: 'Agent reads submitted annotations, identifies target source files, and writes code fixes.',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
      color: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Spec-Kit AI Coding Agent Workflow',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Streamline promptless feedback loops with Cursor, Claude, Windsurf, or Antigravity.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 28),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 750;
                  return isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: steps.map((s) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: _buildStepCard(s, isDark, primaryColor),
                              ),
                            );
                          }).toList(),
                        )
                      : Column(
                          children: steps.map((s) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: _buildStepCard(s, isDark, primaryColor),
                            );
                          }).toList(),
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(
    ({String command, String description, String step, String title}) s,
    bool isDark,
    Color primaryColor,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.step,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: primaryColor.withAlpha(102),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              s.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                s.command,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              s.description,
              style: TextStyle(
                fontSize: 12,
                height: 1.45,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonialSection(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      color: isDark ? const Color(0xFF0B132B) : const Color(0xFFF8FAFC),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const Icon(
                Icons.format_quote_rounded,
                size: 40,
                color: Color(0xFF6366F1),
              ),
              const SizedBox(height: 12),
              const Text(
                '"With Flutter Agentation, design reviews and bug reports connect directly to our agent. '
                'The agent reads the exact widget hierarchy and applies fixes in minutes without ambiguity."',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Production Ready - Flutter 3.16+ Across All Platforms',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6366F1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0F1D) : const Color(0xFFF1F5F9),
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Flutter Agentation v0.1.0',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                ),
              ),
              Text(
                'Published under MIT License',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
