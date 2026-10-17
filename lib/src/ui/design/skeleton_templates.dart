import 'package:flutter/material.dart';
import '../../domain/placement_data.dart';

/// Pre-built wireframe skeleton template for Visual Design Mode, matching Screenshot 4.
@immutable
class SkeletonTemplate {
  const SkeletonTemplate({
    required this.componentType,
    required this.label,
    required this.icon,
    required this.defaultWidth,
    required this.defaultHeight,
    this.category = 'Elements',
    this.defaultPrompt = '',
    this.description = '',
  });

  /// Converts this template into a [PlacementData] instance.
  PlacementData toPlacementData({double? width, double? height}) {
    return PlacementData(
      componentType: componentType,
      prompt: defaultPrompt,
      width: width ?? defaultWidth,
      height: height ?? defaultHeight,
    );
  }

  /// The widget class or component kind (e.g. 'Pricing', 'Product Card', 'Icon', 'Spinner').
  final String componentType;

  /// User-facing display title.
  final String label;

  /// Category section: 'Elements' or 'Blocks'.
  final String category;

  /// Descriptive subtitle.
  final String description;

  /// Icon representing this component in the palette.
  final IconData icon;

  /// Default bounding box width in logical pixels.
  final double defaultWidth;

  /// Default bounding box height in logical pixels.
  final double defaultHeight;

  /// Suggested prompt text for AI coding agents.
  final String defaultPrompt;

  /// Curated list of design mode templates matching Screenshot 4 and Flutter framework components.
  static const List<SkeletonTemplate> defaultTemplates = [
    // ── Elements (Flutter Widgets) ──
    SkeletonTemplate(
      componentType: 'Text',
      label: 'Text Block',
      category: 'Elements',
      description: 'Header, paragraph, or label (Text)',
      icon: Icons.title_outlined,
      defaultWidth: 180.0,
      defaultHeight: 28.0,
      defaultPrompt: 'Add title or paragraph label',
    ),
    SkeletonTemplate(
      componentType: 'Button',
      label: 'Button',
      category: 'Elements',
      description: 'Primary or secondary action button (ElevatedButton/FilledButton)',
      icon: Icons.smart_button_outlined,
      defaultWidth: 120.0,
      defaultHeight: 44.0,
      defaultPrompt: 'Add action button here',
    ),
    SkeletonTemplate(
      componentType: 'IconButton',
      label: 'Icon Button',
      category: 'Elements',
      description: 'Compact clickable icon action (IconButton)',
      icon: Icons.touch_app_outlined,
      defaultWidth: 44.0,
      defaultHeight: 44.0,
      defaultPrompt: 'Add clickable icon button with tooltip',
    ),
    SkeletonTemplate(
      componentType: 'Avatar',
      label: 'User Avatar',
      category: 'Elements',
      description: 'Circular profile photo or initials badge (CircleAvatar)',
      icon: Icons.account_circle_outlined,
      defaultWidth: 48.0,
      defaultHeight: 48.0,
      defaultPrompt: 'Add circular user avatar badge',
    ),
    SkeletonTemplate(
      componentType: 'Image',
      label: 'Image Preview',
      category: 'Elements',
      description: 'Responsive media or banner container (Image.network)',
      icon: Icons.image_outlined,
      defaultWidth: 240.0,
      defaultHeight: 160.0,
      defaultPrompt: 'Add image display with aspect ratio',
    ),
    SkeletonTemplate(
      componentType: 'Input',
      label: 'Input Field',
      category: 'Elements',
      description: 'Text or search input container (TextField)',
      icon: Icons.text_fields_outlined,
      defaultWidth: 240.0,
      defaultHeight: 48.0,
      defaultPrompt: 'Add text input field with placeholder',
    ),
    SkeletonTemplate(
      componentType: 'Card',
      label: 'Card Container',
      category: 'Elements',
      description: 'Elevated content or list item card (Card)',
      icon: Icons.credit_card_outlined,
      defaultWidth: 280.0,
      defaultHeight: 140.0,
      defaultPrompt: 'Add card container with padding',
    ),
    SkeletonTemplate(
      componentType: 'Icon',
      label: 'Icon',
      category: 'Elements',
      description: 'Vector icon glyph or badge (Icon)',
      icon: Icons.star_border,
      defaultWidth: 32.0,
      defaultHeight: 32.0,
      defaultPrompt: 'Add vector icon element',
    ),
    SkeletonTemplate(
      componentType: 'Chip',
      label: 'Chip',
      category: 'Elements',
      description: 'Compact interactive filter or status chip (Chip/FilterChip)',
      icon: Icons.label_outline,
      defaultWidth: 90.0,
      defaultHeight: 32.0,
      defaultPrompt: 'Add filter or action chip badge',
    ),
    SkeletonTemplate(
      componentType: 'Switch',
      label: 'Switch / Toggle',
      category: 'Elements',
      description: 'Binary on/off toggle switch (Switch)',
      icon: Icons.toggle_on_outlined,
      defaultWidth: 52.0,
      defaultHeight: 32.0,
      defaultPrompt: 'Add toggle switch setting control',
    ),
    SkeletonTemplate(
      componentType: 'Checkbox',
      label: 'Checkbox',
      category: 'Elements',
      description: 'Multi-selection toggle with label (CheckboxListTile)',
      icon: Icons.check_box_outlined,
      defaultWidth: 140.0,
      defaultHeight: 32.0,
      defaultPrompt: 'Add labeled checkbox selection',
    ),
    SkeletonTemplate(
      componentType: 'Radio',
      label: 'Radio Option',
      category: 'Elements',
      description: 'Single-choice radio button option (RadioListTile)',
      icon: Icons.radio_button_checked_outlined,
      defaultWidth: 140.0,
      defaultHeight: 32.0,
      defaultPrompt: 'Add radio button group option',
    ),
    SkeletonTemplate(
      componentType: 'Slider',
      label: 'Slider',
      category: 'Elements',
      description: 'Continuous or discrete value slider (Slider)',
      icon: Icons.linear_scale_outlined,
      defaultWidth: 200.0,
      defaultHeight: 36.0,
      defaultPrompt: 'Add numeric range slider control',
    ),
    SkeletonTemplate(
      componentType: 'Spinner',
      label: 'Spinner',
      category: 'Elements',
      description: 'Circular progress activity indicator (CircularProgressIndicator)',
      icon: Icons.incomplete_circle_outlined,
      defaultWidth: 32.0,
      defaultHeight: 32.0,
      defaultPrompt: 'Add circular progress loading spinner',
    ),
    SkeletonTemplate(
      componentType: 'Progress',
      label: 'Progress Bar',
      category: 'Elements',
      description: 'Linear task progress indicator (LinearProgressIndicator)',
      icon: Icons.horizontal_distribute_outlined,
      defaultWidth: 200.0,
      defaultHeight: 12.0,
      defaultPrompt: 'Add linear progress loading bar',
    ),
    SkeletonTemplate(
      componentType: 'FAB',
      label: 'Floating Action Button',
      category: 'Elements',
      description: 'Prominent elevated circular action button (FloatingActionButton)',
      icon: Icons.add_circle_outline,
      defaultWidth: 56.0,
      defaultHeight: 56.0,
      defaultPrompt: 'Add primary floating action button (FAB)',
    ),
    SkeletonTemplate(
      componentType: 'ListTile',
      label: 'List Tile',
      category: 'Elements',
      description: 'Structured single row item with leading and trailing slots (ListTile)',
      icon: Icons.list_alt_outlined,
      defaultWidth: 320.0,
      defaultHeight: 64.0,
      defaultPrompt: 'Add standard ListTile with leading icon, title, subtitle, and trailing action',
    ),
    SkeletonTemplate(
      componentType: 'Divider',
      label: 'Divider',
      category: 'Elements',
      description: 'Visual separation line (Divider)',
      icon: Icons.horizontal_rule_outlined,
      defaultWidth: 240.0,
      defaultHeight: 16.0,
      defaultPrompt: 'Add subtle horizontal divider line',
    ),
    SkeletonTemplate(
      componentType: 'Dropdown',
      label: 'Dropdown Menu',
      category: 'Elements',
      description: 'Popup menu for selecting from a list (DropdownButtonFormField)',
      icon: Icons.arrow_drop_down_circle_outlined,
      defaultWidth: 200.0,
      defaultHeight: 48.0,
      defaultPrompt: 'Add dropdown selection picker',
    ),
    SkeletonTemplate(
      componentType: 'Badge',
      label: 'Badge',
      category: 'Elements',
      description: 'Notification or status count indicator badge (Badge)',
      icon: Icons.mark_chat_unread_outlined,
      defaultWidth: 36.0,
      defaultHeight: 24.0,
      defaultPrompt: 'Add notification count indicator badge',
    ),
    SkeletonTemplate(
      componentType: 'SegmentedButton',
      label: 'Segmented Button',
      category: 'Elements',
      description: 'Multi-option segmented toggle bar (SegmentedButton)',
      icon: Icons.view_week_outlined,
      defaultWidth: 220.0,
      defaultHeight: 40.0,
      defaultPrompt: 'Add segmented button for switching views or options',
    ),

    // ── Blocks (Composite Flutter Layout Sections) ──
    SkeletonTemplate(
      componentType: 'Pricing',
      label: 'Pricing',
      category: 'Blocks',
      description: 'Subscription pricing tier card with features list',
      icon: Icons.layers_outlined,
      defaultWidth: 280.0,
      defaultHeight: 340.0,
      defaultPrompt: 'Add pricing tier table or card with subscription CTA',
    ),
    SkeletonTemplate(
      componentType: 'Testimonial',
      label: 'Testimonial',
      category: 'Blocks',
      description: 'Customer review quote card with avatar and rating',
      icon: Icons.article_outlined,
      defaultWidth: 320.0,
      defaultHeight: 160.0,
      defaultPrompt: 'Add customer testimonial review quote block',
    ),
    SkeletonTemplate(
      componentType: 'CTA',
      label: 'CTA',
      category: 'Blocks',
      description: 'Call-to-action banner with heading and primary button',
      icon: Icons.web_asset_outlined,
      defaultWidth: 360.0,
      defaultHeight: 140.0,
      defaultPrompt: 'Add call-to-action promotional banner',
    ),
    SkeletonTemplate(
      componentType: 'Product Card',
      label: 'Product Card',
      category: 'Blocks',
      description: 'E-commerce item card with image, title, price, and cart button',
      icon: Icons.inventory_2_outlined,
      defaultWidth: 240.0,
      defaultHeight: 300.0,
      defaultPrompt: 'Add product shopping card with media preview and pricing',
    ),
    SkeletonTemplate(
      componentType: 'Profile',
      label: 'Profile',
      category: 'Blocks',
      description: 'User profile summary with bio, avatar, and stats',
      icon: Icons.account_box_outlined,
      defaultWidth: 300.0,
      defaultHeight: 180.0,
      defaultPrompt: 'Add user account profile header card',
    ),
    SkeletonTemplate(
      componentType: 'Form',
      label: 'Form / Login',
      category: 'Blocks',
      description: 'Authentication login or registration form with inputs and submit CTA',
      icon: Icons.dynamic_form_outlined,
      defaultWidth: 300.0,
      defaultHeight: 260.0,
      defaultPrompt: 'Add authentication login or registration form with inputs and submit CTA',
    ),
    SkeletonTemplate(
      componentType: 'Hero',
      label: 'Hero Section',
      category: 'Blocks',
      description: 'Landing page hero section with bold headline, tagline, and action buttons',
      icon: Icons.view_carousel_outlined,
      defaultWidth: 360.0,
      defaultHeight: 200.0,
      defaultPrompt: 'Add landing page hero section with bold headline, tagline, and action buttons',
    ),
    SkeletonTemplate(
      componentType: 'Grid',
      label: 'Feature Grid',
      category: 'Blocks',
      description: 'Responsive 2x2 or 3x3 feature highlights card grid layout',
      icon: Icons.grid_view_outlined,
      defaultWidth: 340.0,
      defaultHeight: 240.0,
      defaultPrompt: 'Add responsive 2x2 feature highlights card grid',
    ),
    SkeletonTemplate(
      componentType: 'NavigationBar',
      label: 'Navigation Bar',
      category: 'Blocks',
      description: 'App bottom navigation bar with icons and destination tabs (NavigationBar)',
      icon: Icons.dock_outlined,
      defaultWidth: 360.0,
      defaultHeight: 64.0,
      defaultPrompt: 'Add bottom NavigationBar with destination tabs',
    ),
    SkeletonTemplate(
      componentType: 'TabBar',
      label: 'Tab Bar',
      category: 'Blocks',
      description: 'Horizontal category tab bar with animated indicator (TabBar)',
      icon: Icons.tab_outlined,
      defaultWidth: 320.0,
      defaultHeight: 48.0,
      defaultPrompt: 'Add horizontal TabBar with indicator',
    ),
    SkeletonTemplate(
      componentType: 'Stats',
      label: 'Stats / Metrics',
      category: 'Blocks',
      description: 'KPI dashboard statistics metric cards',
      icon: Icons.analytics_outlined,
      defaultWidth: 300.0,
      defaultHeight: 120.0,
      defaultPrompt: 'Add KPI dashboard statistics metric cards',
    ),
    SkeletonTemplate(
      componentType: 'AppBar',
      label: 'App Bar',
      category: 'Blocks',
      description: 'Top application header bar with title, back button, and actions (AppBar)',
      icon: Icons.web_outlined,
      defaultWidth: 360.0,
      defaultHeight: 56.0,
      defaultPrompt: 'Add top AppBar with title, navigation icon, and actions',
    ),
    SkeletonTemplate(
      componentType: 'BottomSheet',
      label: 'Bottom Sheet',
      category: 'Blocks',
      description: 'Modal bottom sheet action panel with drag handle',
      icon: Icons.vertical_align_top_outlined,
      defaultWidth: 340.0,
      defaultHeight: 220.0,
      defaultPrompt: 'Add modal bottom sheet action panel',
    ),
  ];
}

