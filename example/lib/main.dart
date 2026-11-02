import 'package:flutter/material.dart';
import 'package:flutter_agentation/flutter_agentation.dart';

/// Entry point for the official Flutter Agentation example application.
///
/// Demonstrates production-grade integration of visual inspection,
/// annotation draft protection, and Model Context Protocol (MCP) tooling.
void main() {
  runApp(const AgentationExampleApp());
}

/// The root application widget configured with Flutter Agentation.
///
/// Best Practice:
/// Place [FlutterAgentation.builder] at the `builder` parameter of [MaterialApp].
/// This ensures the inspection overlay and floating toolbar persist seamlessly
/// across all screens, modals, bottom sheets, and route transitions.
class AgentationExampleApp extends StatelessWidget {
  const AgentationExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Agentation Example',
      debugShowCheckedModeBanner: false,

      // Material 3 Design System with clean Seed Palette
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
      ),
      themeMode: ThemeMode.system,

      // ── FLUTTER AGENTATION INTEGRATION ──
      // Injects the visual inspection overlay and floating toolbar.
      builder: FlutterAgentation.builder(
        // Optional callback invoked when annotations are submitted to agents
        onSubmit: (sessionId, annotations) {
          debugPrint(
            '[FlutterAgentation] Session $sessionId submitted ${annotations.length} annotation(s).',
          );
        },
      ),

      home: const ExampleDashboardPage(),
    );
  }
}

/// A clean, real-world dashboard page designed for visual inspection testing.
///
/// Includes nested widgets, text fields, lists, and interactive buttons
/// allowing developers to test:
/// 1. Deep widget tree inspection and breadcrumb ancestry.
/// 2. Dart source code location resolution.
/// 3. Freeform drawing and area marquee selection.
/// 4. Draft annotation safety (submitting only when ready).
class ExampleDashboardPage extends StatefulWidget {
  const ExampleDashboardPage({super.key});

  @override
  State<ExampleDashboardPage> createState() => _ExampleDashboardPageState();
}

class _ExampleDashboardPageState extends State<ExampleDashboardPage> {
  int _counter = 0;
  bool _notificationsEnabled = true;
  String _selectedPriority = 'Normal';
  final TextEditingController _feedbackNoteController =
      TextEditingController();

  @override
  void dispose() {
    _feedbackNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Agentation Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Information',
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Tap the crosshair icon on the toolbar below to inspect any widget.',
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              // ── Header Card ──
              _buildOverviewCard(colorScheme),
              const SizedBox(height: 20),

              // ── Section 1: Nested Widget Hierarchy ──
              _buildHierarchyCard(colorScheme),
              const SizedBox(height: 20),

              // ── Section 2: Form & Input Elements ──
              _buildInteractiveFormCard(colorScheme),
              const SizedBox(height: 20),

              // ── Section 3: State & Gesture Testing ──
              _buildCounterCard(colorScheme),
              const SizedBox(height: 24),

              // ── Footer Quickstart Guide ──
              _buildQuickstartGuide(colorScheme),
              const SizedBox(height: 80), // Padding above bottom toolbar
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the top overview card introducing the tooling.
  Widget _buildOverviewCard(ColorScheme colorScheme) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.track_changes_rounded,
                color: colorScheme.onPrimaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Visual Inspection Active',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Use the floating pill toolbar below to inspect elements, leave notes, '
                    'and stream exact source code locations to your AI agent.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Demonstrates deep hierarchy resolution (Card -> ListTile -> Switch).
  Widget _buildHierarchyCard(ColorScheme colorScheme) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Hierarchical Elements',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.notifications_active_outlined,
              color: colorScheme.primary,
            ),
            title: const Text('Live Sync Notifications'),
            subtitle: const Text('Broadcasts pin updates via MCP SSE stream'),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
              },
            ),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          ListTile(
            leading: Icon(
              Icons.security_outlined,
              color: colorScheme.primary,
            ),
            title: const Text('Draft Annotation Protection'),
            subtitle: const Text('Drafts held locally until explicitly submitted'),
            trailing: const Icon(Icons.check_circle, color: Colors.green, size: 20),
          ),
        ],
      ),
    );
  }

  /// Demonstrates text input and selection chips for form testing.
  Widget _buildInteractiveFormCard(ColorScheme colorScheme) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interactive Form & Chips',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _feedbackNoteController,
              decoration: InputDecoration(
                hintText: 'Enter test note or element label...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Priority Tag:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Low', 'Normal', 'Urgent'].map((priority) {
                final isSelected = _selectedPriority == priority;
                return ChoiceChip(
                  label: Text(priority),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedPriority = priority);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Demonstrates state mutation and gesture passthrough verification.
  Widget _buildCounterCard(ColorScheme colorScheme) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gesture Passthrough',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  'Counter: $_counter',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => setState(() => _counter = 0),
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => setState(() => _counter++),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Increment'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the CLI quickstart footer guide.
  Widget _buildQuickstartGuide(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.terminal_rounded, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              const Text(
                'AI Agent Connection Quickstart',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '1. Run "dart run flutter_agentation:setupmcp" in terminal.\n'
            '2. Run "/flutter-agentation-check-mcp" in your AI agent chat.\n'
            '3. Run "/flutter-agentation-review-feedback" to apply code fixes.',
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
