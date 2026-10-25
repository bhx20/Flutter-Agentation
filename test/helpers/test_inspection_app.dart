import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agentation/flutter_agentation.dart';

class InspectionDemoApp extends StatelessWidget {
  const InspectionDemoApp({
    super.key,
    this.controller,
  });

  final AgentationController? controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FlutterAgentation(
        controller: controller,
        initialToolbarMinimized: false,
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

class _InspectionDemoScreenState extends State<InspectionDemoScreen> {
  bool _isDark = false;
  bool _chipSelected = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspection Demo'),
        actions: [
          IconButton(
            icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                _isDark = !_isDark;
              });
            },
          ),
        ],
      ),
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.blue.withValues(alpha: 0.1),
              child: const Text('Visual Inspection, Toolbar & Annotation System'),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                key: const ValueKey('primary_action_btn'),
                onPressed: () {},
                child: const Text('Primary Action'),
              ),
            ),
            const SizedBox(height: 16.0),
            Wrap(
              children: [
                FilterChip(
                  label: const Text('Basic & Boxes'),
                  selected: _chipSelected,
                  onSelected: (val) {
                    setState(() {
                      _chipSelected = val;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const SizedBox(
              height: 80.0,
              child: Center(
                child: CupertinoActivityIndicator(radius: 14.0),
              ),
            ),
            ...List.generate(
              50,
              (i) => SizedBox(
                height: 50.0,
                child: Text('Content Item $i'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
