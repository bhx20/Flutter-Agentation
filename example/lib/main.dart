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
        child: const InspectionDemoScreen(),
      ),
    );
  }
}

class InspectionDemoScreen extends StatelessWidget {
  const InspectionDemoScreen({super.key});

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
                    '1. Tap the "Inspect" icon button on the floating pill toolbar.\n'
                    '2. Tap any widget below to open the Annotation Popup editor.\n'
                    '3. Write your feedback, choose intent/severity, and tap "Save Note".\n'
                    '4. Numbered markers (①, ②) appear over widgets. Tap any marker to view details.\n'
                    '5. Drag the floating toolbar anywhere across the screen.',
                    style: TextStyle(color: Colors.white70, fontSize: 13.0, height: 1.4),
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
            const SizedBox(height: 100.0), // Bottom clearance for floating toolbar
          ],
        ),
      ),
    );
  }
}
