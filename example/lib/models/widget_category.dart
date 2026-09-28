import 'package:flutter/material.dart';

/// Categories of Flutter widgets showcased in the inspection demo.
enum WidgetCategory {
  all(
    label: 'All Widgets',
    icon: Icons.dashboard_customize_outlined,
    description: 'Comprehensive catalog of standard Flutter widgets ready for inspection.',
  ),
  buttons(
    label: 'Buttons & Controls',
    icon: Icons.smart_button_outlined,
    description: 'Interactive buttons, segmented switches, popups, and floating action buttons.',
  ),
  inputs(
    label: 'Inputs & Forms',
    icon: Icons.edit_note_rounded,
    description: 'Text fields, search bars, switches, checkboxes, radios, and sliders.',
  ),
  surfaces(
    label: 'Cards & Surfaces',
    icon: Icons.layers_outlined,
    description: 'Material 3 cards (elevated, filled, outlined), styled containers, and surfaces.',
  ),
  typography(
    label: 'Typography & Chips',
    icon: Icons.text_fields_rounded,
    description: 'Material 3 type scale, RichText spans, badges, and interactive chips.',
  ),
  lists(
    label: 'Lists & Data Tables',
    icon: Icons.table_rows_outlined,
    description: 'ListTiles, SwitchListTiles, ExpansionTiles, DataTables, and responsive grids.',
  ),
  layouts(
    label: 'Layouts & Transforms',
    icon: Icons.view_quilt_outlined,
    description: 'Wrap layouts, overlapping Stacks, Tables, transforms, and explicit Agentation targets.',
  ),
  indicators(
    label: 'Indicators & Animations',
    icon: Icons.donut_large_outlined,
    description: 'Progress indicators, continuous freeze test animations, and animated containers.',
  ),
  feedback(
    label: 'Dialogs & Feedback',
    icon: Icons.chat_bubble_outline_rounded,
    description: 'SnackBars, Alert dialogs, Bottom sheets, and tooltips.',
  );

  const WidgetCategory({
    required this.label,
    required this.icon,
    required this.description,
  });

  final String label;
  final IconData icon;
  final String description;
}
