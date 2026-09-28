import 'package:flutter/material.dart';
import 'package:flutter_agentation/flutter_agentation.dart';
import 'models/widget_category.dart';
import 'sections/animations_effects_interaction_section.dart';
import 'sections/basic_section.dart';
import 'sections/buttons_section.dart';
import 'sections/cupertino_section.dart';
import 'sections/inputs_section.dart';
import 'sections/layout_section.dart';
import 'sections/lists_slivers_section.dart';
import 'sections/progress_feedback_dialogs_section.dart';
import 'sections/surfaces_navigation_tables_section.dart';
import 'sections/text_media_icons_section.dart';

void main() {
  runApp(const InspectionDemoApp());
}

/// The root application widget showcasing all 217+ standard Flutter widgets
/// with the FlutterAgentation visual inspection engine attached.
class InspectionDemoApp extends StatefulWidget {
  const InspectionDemoApp({super.key});

  @override
  State<InspectionDemoApp> createState() => _InspectionDemoAppState();
}

class _InspectionDemoAppState extends State<InspectionDemoApp> {
  final ValueNotifier<ThemeMode> _themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  @override
  void dispose() {
    _themeModeNotifier.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    _themeModeNotifier.value = _themeModeNotifier.value == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'FlutterAgentation Demo',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6366F1), // Indigo
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            cardTheme: const CardThemeData(
              elevation: 0.5,
              color: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6366F1),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            cardTheme: const CardThemeData(
              elevation: 0.5,
              color: Color(0xFF1E293B),
            ),
          ),
          home: FlutterAgentation(
            endpoint: 'http://localhost:4747',
            appName: 'FlutterAgentation Showcase',
            child: InspectionDemoScreen(
              onToggleTheme: _toggleTheme,
              isDarkMode: themeMode == ThemeMode.dark,
            ),
          ),
        );
      },
    );
  }
}

/// The main showcase screen organizing all Flutter widgets into structured,
/// interactive categories with category navigation chips.
class InspectionDemoScreen extends StatefulWidget {
  const InspectionDemoScreen({
    super.key,
    this.onToggleTheme,
    this.isDarkMode = false,
  });

  final VoidCallback? onToggleTheme;
  final bool isDarkMode;

  @override
  State<InspectionDemoScreen> createState() => _InspectionDemoScreenState();
}

class _InspectionDemoScreenState extends State<InspectionDemoScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final ValueNotifier<WidgetCategory> _activeCategoryNotifier =
      ValueNotifier<WidgetCategory>(WidgetCategory.all);

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
    _activeCategoryNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterAgentation Visual Overlay Demo'),
        backgroundColor: const Color(0xFF1E1E2E),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: widget.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
          const SizedBox(width: 8.0),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Hero Instructions Banner ──
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
                    'Comprehensive catalog covering 217+ Flutter visual widgets across 37 categories.\n'
                    '• Tap || on the toolbar to freeze & inspect any component.\n'
                    '• Supports Pointer, Area marquee, Multi-select, Drawing canvas, and Design skeleton modes.\n'
                    '• All localized states run entirely via ValueNotifier.',
                    style: TextStyle(color: Colors.white70, fontSize: 13.0, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14.0),

            // ── Category Filter Chip Bar ──
            ValueListenableBuilder<WidgetCategory>(
              valueListenable: _activeCategoryNotifier,
              builder: (context, activeCategory, _) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: WidgetCategory.values.map((cat) {
                      final isSelected = activeCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          avatar: Icon(
                            cat.icon,
                            size: 16.0,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : const Color(0xFF4B5563)),
                          ),
                          label: Text(cat.label),
                          selected: isSelected,
                          selectedColor: const Color(0xFF6366F1),
                          labelStyle: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : const Color(0xFF374151)),
                          ),
                          checkmarkColor: Colors.white,
                          backgroundColor:
                              isDark ? const Color(0xFF262638) : const Color(0xFFF1F5F9),
                          onSelected: (_) {
                            _activeCategoryNotifier.value = cat;
                          },
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),

            // ── Categorized Widget Sections ──
            ValueListenableBuilder<WidgetCategory>(
              valueListenable: _activeCategoryNotifier,
              builder: (context, activeCategory, _) {
                bool shouldShow(WidgetCategory category) {
                  return activeCategory == WidgetCategory.all || activeCategory == category;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (shouldShow(WidgetCategory.buttons))
                      const ButtonsSection(),

                    if (shouldShow(WidgetCategory.basic))
                      const BasicSection(),

                    if (shouldShow(WidgetCategory.layout))
                      const LayoutSection(),

                    if (shouldShow(WidgetCategory.textMedia))
                      const TextMediaIconsSection(),

                    if (shouldShow(WidgetCategory.inputs))
                      const InputsSection(),

                    if (shouldShow(WidgetCategory.progressFeedback))
                      const ProgressFeedbackDialogsSection(),

                    if (shouldShow(WidgetCategory.surfacesNav))
                      const SurfacesNavigationTablesSection(),

                    if (shouldShow(WidgetCategory.listsSlivers))
                      const ListsSliversSection(),

                    if (shouldShow(WidgetCategory.animations))
                      AnimationsEffectsInteractionSection(animController: _animController),

                    if (shouldShow(WidgetCategory.cupertino))
                      const CupertinoSection(),

                    // Bottom padding clearance for the floating toolbar
                    const SizedBox(height: 120.0),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
