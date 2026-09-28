import 'package:flutter/material.dart';
import 'package:flutter_agentation/flutter_agentation.dart';

void main() {
  runApp(const InspectionDemoApp());
}

class InspectionDemoApp extends StatelessWidget {
  const InspectionDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterAgentation Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Indigo
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: FlutterAgentation(
        endpoint: 'http://localhost:4747',
        appName: 'FlutterAgentation Showcase',
        child: const InspectionDemoScreen(),
      ),
    );
  }
}

class InspectionDemoScreen extends StatefulWidget {
  const InspectionDemoScreen({super.key});

  @override
  State<InspectionDemoScreen> createState() => _InspectionDemoScreenState();
}

class _InspectionDemoScreenState extends State<InspectionDemoScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterAgentation Visual Overlay Demo'),
        backgroundColor: const Color(0xFF1E1E2E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions banner
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x334F46E5),
                    blurRadius: 12.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Visual Inspection, Toolbar & Annotation System',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '1. Tap "Inspect" on the toolbar to start inspecting.\n'
                    '2. Switch modes: Pointer, Area marquee, Multi-select, Draw canvas, or Design Mode.\n'
                    '3. Tap the snowflake (❄) to freeze in-flight animations.\n'
                    '4. Tap detail level button to cycle Compact → Standard → Detailed → Forensic.\n'
                    '5. Open Settings (⚙) to pick marker colors or configure MCP sync.',
                    style: TextStyle(color: Colors.white70, fontSize: 13.0, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),

            // Live Animation Showcase (for testing Animation Freeze)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  RotationTransition(
                    turns: _animController,
                    child: Container(
                      width: 44.0,
                      height: 44.0,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.refresh, color: Colors.white, size: 24.0),
                    ),
                  ),
                  const SizedBox(width: 14.0),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live Continuous Animation (Freeze Test)',
                          style: TextStyle(
                            color: Color(0xFF065F46),
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          'Tap the snowflake (❄) button on the toolbar to freeze this animation mid-flight and inspect it.',
                          style: TextStyle(color: Color(0xFF047857), fontSize: 12.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Standard buttons section
            const Text(
              'Interactive Buttons',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    key: const ValueKey('submit_button'),
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: const Text('Primary Action'),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: OutlinedButton.icon(
                    key: const ValueKey('secondary_button'),
                    onPressed: () {},
                    icon: const Icon(Icons.star_outline),
                    label: const Text('Starred Action'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // Card container
            const Text(
              'Container & Card Layouts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12.0),
            Card(
              key: const ValueKey('info_card_layout'),
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.dashboard_outlined, color: Color(0xFF6366F1)),
                        SizedBox(width: 8.0),
                        Text(
                          'Hierarchical Component',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      'The inspection engine accurately maps ancestry breadcrumbs and bounding dimensions across complex layouts.',
                      style: TextStyle(color: Colors.black54, fontSize: 13.0, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24.0),

            // Transformed / Rotated Element
            const Text(
              'Transformed & Rotated Element',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: Transform.rotate(
                angle: 0.15, // ~8.5 degrees
                child: Container(
                  key: const ValueKey('rotated_demo_box'),
                  width: 220,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                    ),
                    borderRadius: BorderRadius.circular(14.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26000000),
                        blurRadius: 8.0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Rotated Card (8.5°)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32.0),

            // Explicit target with AgentationTarget
            const Text(
              'Explicit AgentationTarget Identifier',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12.0),
            AgentationTarget(
              id: 'custom_annotated_target',
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.label_important_outline, color: Color(0xFF4F46E5)),
                    SizedBox(width: 8.0),
                    Text(
                      'Tagged: custom_annotated_target',
                      style: TextStyle(
                        color: Color(0xFF4F46E5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24.0),

            // Navigation Links row (matching Screenshot 5)
            const Text(
              'Navigation & Links',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                TextButton(
                  key: const ValueKey('link_blog'),
                  onPressed: () {},
                  child: const Text('Blog', style: TextStyle(color: Color(0xFF6366F1))),
                ),
                const SizedBox(width: 8.0),
                TextButton(
                  key: const ValueKey('link_faq'),
                  onPressed: () {},
                  child: const Text('FAQ', style: TextStyle(color: Color(0xFF6366F1))),
                ),
                const SizedBox(width: 8.0),
                TextButton(
                  key: const ValueKey('link_docs'),
                  onPressed: () {},
                  child: const Text('Docs', style: TextStyle(color: Color(0xFF6366F1))),
                ),
                const SizedBox(width: 8.0),
                TextButton(
                  key: const ValueKey('link_changelog'),
                  onPressed: () {},
                  child: const Text('Changelog', style: TextStyle(color: Color(0xFF6366F1))),
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // Nested ListTiles & Children Showcase
            const Text(
              'Nested ListTiles & Child Widgets Inspection',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12.0),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.help_outline, color: Color(0xFF6366F1)),
                    title: const Text('Frequently Asked Questions'),
                    subtitle: const Text('Inspect this tile or its individual text/icon children'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1.0),
                  ListTile(
                    leading: const Icon(Icons.palette_outlined, color: Color(0xFF10B981)),
                    title: const Text('Theme & Palette Configuration'),
                    subtitle: const Text('Each text span, leading icon, and trailing widget is inspectable'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14.0),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120.0), // Bottom clearance for floating toolbar
          ],
        ),
      ),
    );
  }
}
