import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_agentation/flutter_agentation.dart';

void main() {
  runApp(const AgentationExampleApp());
}

/// Root widget for the Flutter Agentation showcase and landing page.
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
      title: 'Agentation - Visual Feedback for Flutter & AI Agents',
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
        ),
      ),
      // FlutterAgentation.builder() injects the floating inspection toolbar
      // and overlay across every page and route in the application.
      builder: FlutterAgentation.builder(),
      home: AgentationLandingPage(
        isDark: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

/// Interactive landing page showcasing Flutter Agentation features.
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
  int _counter = 12;
  String _selectedChip = 'Realtime Sync';
  bool _copied = false;

  void _copyCliCommand() {
    Clipboard.setData(
      const ClipboardData(text: 'dart run flutter_agentation:setupmcp'),
    );
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied: dart run flutter_agentation:setupmcp'),
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
    final primaryColor = const Color(0xFF6366F1);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Top Navigation Bar ──
            _buildNavBar(context, isDark),

            // ── Hero Section ──
            _buildHeroSection(context, isDark, primaryColor),

            // ── Interactive Playground Section (Live widgets to inspect) ──
            _buildPlaygroundSection(context, isDark, primaryColor),

            // ── Features Grid ──
            _buildFeaturesSection(context, isDark, primaryColor),

            // ── AI Agent Workflow Section ──
            _buildWorkflowSection(context, isDark, primaryColor),

            // ── Testimonial Quote ──
            _buildTestimonialSection(context, isDark),

            // ── Footer ──
            _buildFooter(context, isDark),
          ],
        ),
      ),
    );
  }

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
              // Eyebrow badge
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
                'Inspect live Flutter widget trees, drop precision feedback pins, prototype layout ideas, '
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

              // Action buttons & CLI snippet
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
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
                ],
              ),
              const SizedBox(height: 18),

              // Micro guide prompt
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
                    'Tip: Tap the target crosshair icon on the floating toolbar below to inspect any widget!',
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

  Widget _buildPlaygroundSection(
    BuildContext context,
    bool isDark,
    Color primaryColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Interactive Inspection Playground',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Try selecting or commenting on any of the interactive components below using Flutter Agentation.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),

              // Cards row / grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  return isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildProfileCard(isDark)),
                            const SizedBox(width: 20),
                            Expanded(child: _buildMetricCard(isDark)),
                            const SizedBox(width: 20),
                            Expanded(child: _buildCounterCard(isDark)),
                          ],
                        )
                      : Column(
                          children: [
                            _buildProfileCard(isDark),
                            const SizedBox(height: 16),
                            _buildMetricCard(isDark),
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

  Widget _buildMetricCard(bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sync Health',
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
                      Text('Active', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Port 4747 (SSE + JSON-RPC)',
              style: TextStyle(fontSize: 13, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: 0.94,
              color: const Color(0xFF6366F1),
              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Interactive State',
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
              selected: {_selectedChip == 'Realtime Sync' ? 'Inspect' : 'Draft'},
              onSelectionChanged: (val) {
                setState(() => _selectedChip = val.first);
              },
            ),
          ],
        ),
      ),
    );
  }

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
            'Resolves render coordinates, bounding boxes, element types, and developer keys with breadcrumb ancestor traversal.',
      ),
      (
        icon: Icons.sync_alt_rounded,
        title: 'Multi-Platform MCP Sync',
        description:
            'Uniform Model Context Protocol SSE and JSON-RPC streaming across Web (Chrome/Edge), Desktop (Windows, macOS, Linux), and Mobile (Android, iOS).',
      ),
      (
        icon: Icons.dashboard_customize_outlined,
        title: 'Visual Wireframing & Layout Mode',
        description:
            'Drag-and-drop realistic skeleton components (Buttons, Cards, Inputs, Lists) directly onto live UI to propose architectural changes.',
      ),
      (
        icon: Icons.send_and_archive_outlined,
        title: 'Draft Batch Protection',
        description:
            'Created annotations remain safe local drafts. They are only dispatched to AI agents when you tap the Send toolbar button or press S.',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      color: isDark ? const Color(0xFF0B132B) : const Color(0xFFF1F5F9),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Engine Capabilities',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Built from the ground up for Flutter developers and AI coding agents.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 650;
                  return Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: features.map((f) {
                      return SizedBox(
                        width: isWide
                            ? (constraints.maxWidth - 20) / 2
                            : constraints.maxWidth,
                        child: Card(
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
                                    fontSize: 17,
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
        description: 'Auto-generates .flutter_agentation/mcp.json and registers agent skills.',
      ),
      (
        step: '02',
        title: 'Verify Connection',
        command: '/flutter-agentation-check-mcp',
        description: 'Check active port, transport endpoints, and submitted pin counts.',
      ),
      (
        step: '03',
        title: 'Review & Fix Code',
        command: '/flutter-agentation-review-feedback',
        description: 'Agent reads submitted annotations, identifies target source files, and writes fixes.',
      ),
    ];

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
                'Spec-Kit AI Coding Agent Workflow',
                style: TextStyle(
                  fontSize: 22,
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
      color: isDark ? const Color(0xFF0F172A) : Colors.white,
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
        color: isDark ? const Color(0xFF0A0F1D) : const Color(0xFFF8FAFC),
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
