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
        scaffoldBackgroundColor: const Color(0xFF070A11),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          surface: Color(0xFF0F172A),
        ),
        useMaterial3: true,
      ),
      // FlutterAgentation.builder() wraps the entire app to inject the
      // floating inspection toolbar, design canvas, and MCP streaming overlay.
      builder: FlutterAgentation.builder(),
      home: const RichEyeCatchingLandingPage(),
    );
  }
}

/// Rich, eye-catching, full-width showcase landing page for Flutter Agentation.
class RichEyeCatchingLandingPage extends StatefulWidget {
  const RichEyeCatchingLandingPage({super.key});

  @override
  State<RichEyeCatchingLandingPage> createState() =>
      _RichEyeCatchingLandingPageState();
}

class _RichEyeCatchingLandingPageState
    extends State<RichEyeCatchingLandingPage> {
  int _counter = 24;
  bool _copied = false;
  int _activeFeatureIndex = 0;
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
    final isCompact = size.width < 750;

    return Scaffold(
      backgroundColor: const Color(0xFF070A11),
      body: Stack(
        children: [
          // ── Ambient Background Glows ──
          Positioned(
            top: -140,
            left: size.width / 2 - 280,
            child: Container(
              width: 560,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6366F1).withAlpha(45),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 750,
            right: -100,
            child: Container(
              width: 450,
              height: 450,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF06B6D4).withAlpha(30),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 400,
            left: -120,
            child: Container(
              width: 480,
              height: 480,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withAlpha(25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Scrollable Page Content (Spans Full Width) ──
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 16 : 32,
                vertical: 24,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Top Navigation Bar ──
                    _buildNavBar(isCompact),
                    const SizedBox(height: 44),

                    // ── Hero Section ──
                    _buildHeroSection(),
                    const SizedBox(height: 36),

                    // ── Hero Quick Metrics Strip ──
                    _buildMetricsStrip(isCompact),
                    const SizedBox(height: 48),

                    // ── Section 1: Interactive Live Playground (Live Targets) ──
                    _buildPlaygroundSection(isCompact),
                    const SizedBox(height: 56),

                    // ── Section 2: Complete Package Capabilities Grid ──
                    _buildFeaturesSection(isCompact),
                    const SizedBox(height: 56),

                    // ── Section 3: Supported AI Coding Agents & IDEs ──
                    _buildSupportedAgentsSection(isCompact),
                    const SizedBox(height: 56),

                    // ── Section 4: Multi-Platform Architecture Breakdown ──
                    _buildPlatformArchitectureSection(isCompact),
                    const SizedBox(height: 56),

                    // ── Section 5: Spec-Kit AI Agent Workflow ──
                    _buildWorkflowSection(isCompact),
                    const SizedBox(height: 56),

                    // ── Section 6: Built-in Keyboard Shortcuts Cheat Sheet ──
                    _buildKeymapCheatSheet(isCompact),
                    const SizedBox(height: 56),

                    // ── Section 7: Community Endorsement Quote ──
                    _buildTestimonialSection(),
                    const SizedBox(height: 60),

                    // ── Section 8: Minimalist Production Footer ──
                    _buildFooter(isCompact),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TOP NAVIGATION BAR (FULL WIDTH)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildNavBar(bool isCompact) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withAlpha(160),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBrandLogo(),
                    _buildCliQuickCopy(),
                  ],
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBrandLogo(),
                _buildCliQuickCopy(),
              ],
            ),
    );
  }

  Widget _buildBrandLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: Color(0xFF6366F1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.track_changes_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'Flutter Agentation',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0x266366F1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'v0.1.0',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF818CF8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCliQuickCopy() {
    return InkWell(
      onTap: () => _copyCommand('dart run flutter_agentation:setupmcp'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withAlpha(20)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.terminal_rounded,
              size: 14,
              color: Color(0xFF818CF8),
            ),
            const SizedBox(width: 8),
            Text(
              _copied ? 'Copied' : 'dart run flutter_agentation:setupmcp',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFFCBD5E1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HERO SECTION
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Glowing status pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withAlpha(180),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF6366F1).withAlpha(80)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Universal Model Context Protocol (MCP) Bridge & Visual Inspector',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFCBD5E1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Headline
        const Text(
          'Visual Feedback for Flutter & AI Coding Agents',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            height: 1.2,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),

        // Subtitle
        const Text(
          'Directly inspect live widget hierarchies, drop precision feedback pins, wireframe layout changes, '
          'and stream exact source code locations into Cursor, Claude, Windsurf, or Antigravity via MCP.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 28),

        // CLI Snippet Pill
        InkWell(
          onTap: () => _copyCommand('dart run flutter_agentation:setupmcp'),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1424),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.terminal,
                  size: 16,
                  color: Color(0xFF6366F1),
                ),
                const SizedBox(width: 10),
                const Text(
                  'dart run flutter_agentation:setupmcp',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFE2E8F0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  _copied ? Icons.check_rounded : Icons.copy_rounded,
                  size: 15,
                  color: _copied ? const Color(0xFF10B981) : const Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Toolbar prompt
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.touch_app_outlined, size: 15, color: Color(0xFF64748B)),
            SizedBox(width: 6),
            Text(
              'Tap the crosshair icon on the floating toolbar below to begin inspecting!',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // QUICK METRICS STRIP (FULL WIDTH)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildMetricsStrip(bool isCompact) {
    final metrics = [
      (value: '0 Overhead', label: 'In Release Builds'),
      (value: '100% Exact', label: 'Source File & Line Mapping'),
      (value: '6 Platforms', label: 'Web, Mobile & Desktop'),
      (value: 'JSON-RPC 2.0', label: 'Model Context Protocol'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF0B101D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: isCompact
          ? Wrap(
              spacing: 24,
              runSpacing: 16,
              alignment: WrapAlignment.spaceAround,
              children: metrics.map(_buildMetricItem).toList(),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: metrics.map(_buildMetricItem).toList(),
            ),
    );
  }

  Widget _buildMetricItem(({String label, String value}) m) {
    return Column(
      children: [
        Text(
          m.value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF818CF8),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          m.label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INTERACTIVE LIVE PLAYGROUND (FULL WIDTH)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildPlaygroundSection(bool isCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Live Inspection Playground',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Hover and click any component below with the inspection tool active to view real-time bounds and code pointers.',
          style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 20),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withAlpha(180),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Column(
            children: [
              // Window-style bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
                ),
                child: Row(
                  children: [
                    Row(
                      children: [
                        Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '<LiveTargetHarness>',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF818CF8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Interactive elements
              Padding(
                padding: const EdgeInsets.all(22),
                child: isCompact
                    ? Column(
                        children: [
                          _buildInteractiveControlCard(),
                          const SizedBox(height: 18),
                          _buildInteractiveSliderCard(),
                          const SizedBox(height: 18),
                          _buildTelemetryInspector(),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _buildInteractiveControlCard()),
                          const SizedBox(width: 16),
                          Expanded(flex: 3, child: _buildInteractiveSliderCard()),
                          const SizedBox(width: 16),
                          Expanded(flex: 4, child: _buildTelemetryInspector()),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveControlCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF090D16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.touch_app_rounded, color: Color(0xFF818CF8), size: 16),
              ),
              const SizedBox(width: 10),
              const Text('Interactive Counter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('State Value', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              Text('$_counter', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF818CF8))),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: const BorderSide(color: Color(0xFF334155)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => setState(() => _counter = 0),
                  child: const Text('Reset', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => setState(() => _counter++),
                  child: const Text('+1', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveSliderCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF090D16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Controls & Switches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Switch(
                value: _toggleSwitch,
                onChanged: (v) => setState(() => _toggleSwitch = v),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Slider: ${_sliderValue.round()}%',
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
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

  Widget _buildTelemetryInspector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF090D16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.terminal_rounded, size: 14, color: Color(0xFF10B981)),
              SizedBox(width: 6),
              Text(
                'Agent Telemetry Readout',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTelemetryLine('Resolved Element', 'ElevatedButton'),
          _buildTelemetryLine('Target File', 'example/lib/main.dart'),
          _buildTelemetryLine('MCP Transport', 'Port 4747 (SSE + JSON-RPC)'),
          _buildTelemetryLine('Draft Protection', 'Safe (Unsent locally)'),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withAlpha(20),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Zero overhead in release builds',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF10B981),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFCBD5E1),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // COMPLETE CAPABILITIES GRID (6 CORE FEATURES)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildFeaturesSection(bool isCompact) {
    final features = [
      (
        icon: Icons.search_rounded,
        title: 'Deep Widget Inspection',
        description: 'Resolves RenderBox bounds, ancestor breadcrumb paths, developer keys, semantics, and Dart source line numbers.',
      ),
      (
        icon: Icons.sync_alt_rounded,
        title: 'Multi-Platform MCP Sync',
        description: 'Embedded and standalone Model Context Protocol SSE & JSON-RPC streaming across Web, Desktop, and Mobile.',
      ),
      (
        icon: Icons.dashboard_customize_outlined,
        title: 'Visual Wireframing & Layout Mode',
        description: 'Drag-and-drop realistic skeleton components (Buttons, Cards, Inputs, Lists) directly onto live UI with counter-question dialogs.',
      ),
      (
        icon: Icons.security_rounded,
        title: 'Draft Annotation Protection',
        description: 'Annotations remain local drafts until submitted. When autoSendMcp is OFF, pins will never leak to agents without explicit permission.',
      ),
      (
        icon: Icons.gesture_rounded,
        title: 'Multi-Mode Annotation Canvas',
        description: 'Supports single element inspection, marquee area selection, multi-element picking, and freeform pencil drawing directly on the screen.',
      ),
      (
        icon: Icons.file_download_outlined,
        title: 'Rich Export Formats & Webhooks',
        description: 'Export to AI-ready Markdown, JSON envelopes, or plain source paths, with real-time webhook dispatching for external review tools.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Engine Capabilities & Features',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Everything you need to connect visual Flutter inspection to autonomous AI coding agents.',
          style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            int columns = 1;
            if (constraints.maxWidth > 1100) {
              columns = 3;
            } else if (constraints.maxWidth > 650) {
              columns = 2;
            }
            final spacing = 16.0;
            final itemWidth = (constraints.maxWidth - (columns - 1) * spacing) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: features.asMap().entries.map((entry) {
                return SizedBox(
                  width: itemWidth,
                  child: _buildFeatureCard(entry.key, entry.value),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    int index,
    ({String description, IconData icon, String title}) f,
  ) {
    final isSelected = _activeFeatureIndex == index;

    return InkWell(
      onTap: () => setState(() => _activeFeatureIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withAlpha(isSelected ? 220 : 120),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6366F1).withAlpha(120)
                : const Color(0xFF1E293B),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6366F1).withAlpha(35)
                    : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                f.icon,
                size: 18,
                color: isSelected ? const Color(0xFF818CF8) : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              f.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              f.description,
              style: const TextStyle(
                fontSize: 12,
                height: 1.5,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SUPPORTED AI AGENTS & INTEGRATIONS (FULL WIDTH)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSupportedAgentsSection(bool isCompact) {
    final agents = [
      (name: 'Cursor', protocol: 'mcp.json SSE', status: 'Verified'),
      (name: 'Claude Desktop', protocol: 'mcp.json Stdio/SSE', status: 'Verified'),
      (name: 'Windsurf', protocol: 'mcp_config.json', status: 'Verified'),
      (name: 'VS Code (Cline/Roo)', protocol: 'MCP Settings', status: 'Verified'),
      (name: 'Antigravity', protocol: 'Universal Bridge', status: 'Native'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withAlpha(140),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.smart_toy_outlined, color: Color(0xFF6366F1), size: 18),
              SizedBox(width: 8),
              Text(
                'AI Coding Agent Integrations',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Connect your live Flutter application directly to your favorite agent environment with zero prompt drafting.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: agents.map((a) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF090D16),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(a.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        a.status,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF818CF8), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MULTI-PLATFORM ARCHITECTURE (FULL WIDTH)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildPlatformArchitectureSection(bool isCompact) {
    final platforms = [
      (platform: 'Web (Chrome / Edge)', details: 'Live bidirectional HTTP bridge (/sync) for seamless browser inspection.'),
      (platform: 'Desktop (Windows / macOS / Linux)', details: 'Direct embedded TCP socket listening on port 4747.'),
      (platform: 'Android (Device & Emulator)', details: 'Auto-provisioned ADB reverse port forwarding (adb forward tcp:4747).'),
      (platform: 'iOS (Simulator & Device)', details: 'Direct localhost connection on Simulator; local Wi-Fi IP on physical device.'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Multi-Platform Architecture',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Flutter Agentation is built to work seamlessly regardless of your target run platform.',
          style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 20),
        Column(
          children: platforms.map((p) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withAlpha(120),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981), size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.platform, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(p.details, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SPEC-KIT AI AGENT WORKFLOW (FULL WIDTH)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildWorkflowSection(bool isCompact) {
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
        description: 'Checks port health, active transports, and unsubmitted/submitted pin counts.',
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withAlpha(160),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.bolt, color: Color(0xFF6366F1), size: 18),
              SizedBox(width: 8),
              Text(
                'Spec-Kit Promptless Workflow',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Experience seamless promptless coding with Spec-Kit slash commands in your AI agent chat.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: steps.map((s) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: _buildWorkflowStepCard(s),
                    ),
                  )).toList(),
                );
              } else {
                return Column(
                  children: steps.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: _buildWorkflowStepCard(s),
                  )).toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowStepCard(
    ({String command, String description, String step, String title}) s,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF090D16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.step,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6366F1).withAlpha(100),
            ),
          ),
          const SizedBox(height: 6),
          Text(s.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Text(
              s.command,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF818CF8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.description,
            style: const TextStyle(fontSize: 11, height: 1.45, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // KEYBOARD SHORTCUTS CHEAT SHEET (FULL WIDTH)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildKeymapCheatSheet(bool isCompact) {
    final shortcuts = [
      (key: 'Ctrl+Shift+A', desc: 'Toggle Inspection Mode'),
      (key: 'S', desc: 'Submit Draft Annotations'),
      (key: 'Del / Backspace', desc: 'Delete Selected Pin'),
      (key: 'Esc', desc: 'Close Modals / Deselect'),
      (key: 'C', desc: 'Copy Annotations to Clipboard'),
      (key: 'D', desc: 'Toggle Design / Layout Mode'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withAlpha(140),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.keyboard_outlined, color: Color(0xFF6366F1), size: 18),
              SizedBox(width: 8),
              Text(
                'Power User Keyboard Shortcuts',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Control the visual inspection canvas instantly using native keyboard hotkeys.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: shortcuts.map((s) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF090D16),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        s.key,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFCBD5E1),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(s.desc, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // COMMUNITY TESTIMONIAL (FULL WIDTH)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTestimonialSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (_) => const Icon(Icons.star_rounded, size: 20, color: Color(0xFFF59E0B)),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            '"With Flutter Agentation, design reviews and bug reports connect directly to our agent. '
            'The agent reads the exact widget hierarchy and applies fixes in minutes without ambiguity."',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: Color(0xFFE2E8F0),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircleAvatar(
                radius: 12,
                backgroundColor: Color(0xFF6366F1),
                child: Text('LG', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              SizedBox(width: 8),
              Text(
                'Liam Gallagher - Founder, ShipFlutter Studio',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF818CF8)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MINIMALIST FOOTER (FULL WIDTH)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildFooter(bool isCompact) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          const Divider(color: Color(0xFF1E293B), height: 1),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Flutter Agentation v0.1.0',
                style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
              Text(
                'Published under MIT License • Flutter 3.16+',
                style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
