import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_agentation/flutter_agentation.dart';

void main() {
  runApp(const AgentationExampleApp());
}

/// Root widget for the Flutter Agentation showcase.
class AgentationExampleApp extends StatelessWidget {
  const AgentationExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agentation - Visual Feedback for Flutter & AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090D16),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          surface: Color(0xFF0F172A),
          onSurface: Colors.white,
        ),
        useMaterial3: true,
      ),
      // FlutterAgentation.builder() injects the floating inspection toolbar
      // and visual feedback overlay across the entire application.
      builder: FlutterAgentation.builder(),
      home: const EyeCatchingMinimalLandingPage(),
    );
  }
}

/// Eye-catching, minimalist showcase page for Flutter Agentation.
///
/// Designed with sleek dark aesthetics, subtle ambient gradients,
/// crisp typography, and interactive cards for testing live widget inspection.
class EyeCatchingMinimalLandingPage extends StatefulWidget {
  const EyeCatchingMinimalLandingPage({super.key});

  @override
  State<EyeCatchingMinimalLandingPage> createState() =>
      _EyeCatchingMinimalLandingPageState();
}

class _EyeCatchingMinimalLandingPageState
    extends State<EyeCatchingMinimalLandingPage> {
  int _counter = 24;
  bool _copied = false;
  int _activeFeatureIndex = 0;

  void _copyCommand() {
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
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 700;

    return Scaffold(
      backgroundColor: const Color(0xFF070A11),
      body: Stack(
        children: [
          // ── Ambient Background Glows ──
          Positioned(
            top: -120,
            left: size.width / 2 - 250,
            child: Container(
              width: 500,
              height: 400,
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
            bottom: 50,
            right: -80,
            child: Container(
              width: 380,
              height: 380,
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

          // ── Scrollable Page Content ──
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 20 : 36,
                vertical: 24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 880),
                  child: Column(
                    children: [
                      // ── Top Navigation Bar ──
                      _buildNavBar(),
                      const SizedBox(height: 54),

                      // ── Hero Section ──
                      _buildHeroSection(),
                      const SizedBox(height: 44),

                      // ── Interactive Showcase Card (Live Target) ──
                      _buildInteractiveShowcaseCard(isCompact),
                      const SizedBox(height: 48),

                      // ── Sleek Feature Cards ──
                      _buildFeatureGrid(isCompact),
                      const SizedBox(height: 52),

                      // ── AI Workflow Strip ──
                      _buildWorkflowBanner(isCompact),
                      const SizedBox(height: 70),

                      // ── Minimal Footer ──
                      _buildFooter(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Minimal floating-style navigation bar.
  Widget _buildNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withAlpha(160),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Row(
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
              size: 15,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Agentation',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0x266366F1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'v0.1.0',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF818CF8),
              ),
            ),
          ),
          const SizedBox(width: 18),
          InkWell(
            onTap: _copyCommand,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.terminal_rounded,
                    size: 13,
                    color: Color(0xFF818CF8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _copied ? 'Copied' : 'CLI Setup',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Minimalist high-impact hero.
  Widget _buildHeroSection() {
    return Column(
      children: [
        // Glowing status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withAlpha(180),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF6366F1).withAlpha(80)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
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
                'Universal Model Context Protocol (MCP) Bridge',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFCBD5E1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // Bold Title
        const Text(
          'Visual Feedback for Flutter & AI Agents',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.4,
            height: 1.15,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 14),

        // Muted subtitle
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: const Text(
            'Inspect widget trees, drop precision feedback pins, prototype layout ideas, '
            'and stream exact source code locations directly into Cursor, Claude, Windsurf, or Antigravity.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Color(0xFF94A3B8),
            ),
          ),
        ),
        const SizedBox(height: 26),

        // Interactive Terminal Snippet Pill
        InkWell(
          onTap: _copyCommand,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  size: 15,
                  color: Color(0xFF6366F1),
                ),
                const SizedBox(width: 10),
                const Text(
                  'dart run flutter_agentation:setupmcp',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: Color(0xFFE2E8F0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  _copied ? Icons.check_rounded : Icons.copy_rounded,
                  size: 14,
                  color: _copied ? const Color(0xFF10B981) : const Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Eye-catching interactive showcase card with live element inspection cues.
  Widget _buildInteractiveShowcaseCard(bool isCompact) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withAlpha(200),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        children: [
          // Card top header bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                    '<InteractiveInspectionCard>',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Color(0xFF818CF8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Interactive interior
          Padding(
            padding: const EdgeInsets.all(24),
            child: isCompact
                ? Column(
                    children: [
                      _buildLiveTargetCard(),
                      const SizedBox(height: 20),
                      _buildInspectorMetadataPanel(),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(flex: 3, child: _buildLiveTargetCard()),
                      const SizedBox(width: 20),
                      Expanded(flex: 2, child: _buildInspectorMetadataPanel()),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  /// Live target card that users can interact with or inspect.
  Widget _buildLiveTargetCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF6366F1),
                child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Interactive Host Element',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    'Zero gesture blocking during app use',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'State Value:',
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
              Text(
                '$_counter',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF818CF8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF334155)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => setState(() => _counter = 0),
                  child: const Text('Reset', style: TextStyle(color: Color(0xFF94A3B8))),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => setState(() => _counter++),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Increment'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Inspector metadata readout panel simulating what the AI agent sees.
  Widget _buildInspectorMetadataPanel() {
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
                'Agent Telemetry',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTelemetryLine('Element', 'ElevatedButton'),
          _buildTelemetryLine('File', 'example/lib/main.dart'),
          _buildTelemetryLine('Port', '4747 (SSE/JSON-RPC)'),
          _buildTelemetryLine('Draft Safe', 'Active (Unsubmitted)'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Ready for AI code synthesis',
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
              fontSize: 11,
              fontFamily: 'monospace',
              color: Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: Color(0xFFCBD5E1),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Sleek minimalist 3-card feature grid.
  Widget _buildFeatureGrid(bool isCompact) {
    final features = [
      (
        icon: Icons.search_rounded,
        title: 'Deep Widget Inspection',
        description: 'Resolves RenderBox bounds, ancestor paths, developer keys, semantics, and Dart source lines.',
      ),
      (
        icon: Icons.sync_alt_rounded,
        title: 'Multi-Platform MCP Sync',
        description: 'Seamless SSE & JSON-RPC streaming across Web (Chrome/Edge), Desktop, and Mobile devices.',
      ),
      (
        icon: Icons.shield_outlined,
        title: 'Draft Pin Protection',
        description: 'Annotations remain local drafts until submitted. Never leaks unverified code edits to agents.',
      ),
    ];

    return isCompact
        ? Column(
            children: features.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: _buildFeatureCard(entry.key, entry.value),
              );
            }).toList(),
          )
        : Row(
            children: features.asMap().entries.map((entry) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: entry.key == 0 ? 0 : 8.0,
                    right: entry.key == 2 ? 0 : 8.0,
                  ),
                  child: _buildFeatureCard(entry.key, entry.value),
                ),
              );
            }).toList(),
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

  /// Minimalist workflow strip showing the 3 agent commands.
  Widget _buildWorkflowBanner(bool isCompact) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withAlpha(160),
        borderRadius: BorderRadius.circular(16),
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
                'Spec-Kit AI Coding Workflow',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: const [
              _WorkflowStepPill(step: '1', label: 'dart run flutter_agentation:setupmcp'),
              _WorkflowStepPill(step: '2', label: '/flutter-agentation-check-mcp'),
              _WorkflowStepPill(step: '3', label: '/flutter-agentation-review-feedback'),
            ],
          ),
        ],
      ),
    );
  }

  /// Clean minimal footer.
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          'Flutter Agentation v0.1.0',
          style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
        ),
        Text(
          'Published under MIT License',
          style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
        ),
      ],
    );
  }
}

class _WorkflowStepPill extends StatelessWidget {
  const _WorkflowStepPill({required this.step, required this.label});

  final String step;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF090D16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              shape: BoxShape.circle,
            ),
            child: Text(
              step,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF818CF8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: Color(0xFFCBD5E1),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
