import 'package:flutter/material.dart';

/// Categories of Flutter widgets showcased in the inspection demo.
enum WidgetCategory {
  all(
    label: 'All Widgets (217+)',
    icon: Icons.dashboard_customize_outlined,
    description: 'Comprehensive catalog of all Flutter widgets ready for inspection.',
  ),
  basic(
    label: 'Basic & Boxes',
    icon: Icons.check_box_outline_blank_rounded,
    description: 'Container, SizedBox, Clip, Transform, Opacity, and Box widgets.',
  ),
  layout(
    label: 'Layout & Flex',
    icon: Icons.view_quilt_outlined,
    description: 'Row, Column, Flex, Stack, Positioned, Wrap, Expanded, and Spacer.',
  ),
  textMedia(
    label: 'Text, Media & Icons',
    icon: Icons.text_fields_rounded,
    description: 'Text, RichText, Images, Icons, Hero, and CustomPaint.',
  ),
  buttons(
    label: 'Buttons, Chips & Menus',
    icon: Icons.smart_button_outlined,
    description: 'Material 3 Buttons, ActionChips, SegmentedButtons, and Menus.',
  ),
  inputs(
    label: 'Inputs & Stepper',
    icon: Icons.edit_note_rounded,
    description: 'TextField, Switches, Radios, Sliders, Dropdowns, and Stepper.',
  ),
  progressFeedback(
    label: 'Progress & Dialogs',
    icon: Icons.donut_large_outlined,
    description: 'Progress indicators, SnackBars, Badges, and Dialogs.',
  ),
  surfacesNav(
    label: 'Cards, Navigation & Tables',
    icon: Icons.layers_outlined,
    description: 'Cards, Navigation Bars/Rails, Drawers, Tabs, and Tables.',
  ),
  listsSlivers(
    label: 'Lists, Grids & Slivers',
    icon: Icons.table_rows_outlined,
    description: 'ListView, GridView, PageView, Slivers, and CustomScrollView.',
  ),
  animations(
    label: 'Animations & Effects',
    icon: Icons.animation_rounded,
    description: 'Implicit animations, transitions, effects, and interaction gestures.',
  ),
  cupertino(
    label: 'Cupertino (iOS)',
    icon: Icons.phone_iphone_rounded,
    description: 'Cupertino Navigation, Buttons, Controls, Pickers, and Dialogs.',
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
