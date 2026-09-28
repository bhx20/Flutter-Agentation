import 'package:flutter/material.dart';
import '../models/placement_data.dart';

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

  /// Curated list of design mode templates matching Screenshot 4.
  static const List<SkeletonTemplate> defaultTemplates = [
    // Elements section
    SkeletonTemplate(
      componentType: 'Icon',
      label: 'Icon',
      category: 'Elements',
      description: 'Vector icon glyph or badge',
      icon: Icons.star_border,
      defaultWidth: 32.0,
      defaultHeight: 32.0,
      defaultPrompt: 'Add vector icon element',
    ),
    SkeletonTemplate(
      componentType: 'Spinner',
      label: 'Spinner',
      category: 'Elements',
      description: 'Circular progress activity indicator',
      icon: Icons.incomplete_circle_outlined,
      defaultWidth: 32.0,
      defaultHeight: 32.0,
      defaultPrompt: 'Add circular progress loading spinner',
    ),
    SkeletonTemplate(
      componentType: 'Button',
      label: 'Button',
      category: 'Elements',
      description: 'Primary or secondary action button',
      icon: Icons.smart_button_outlined,
      defaultWidth: 120.0,
      defaultHeight: 44.0,
      defaultPrompt: 'Add action button here',
    ),
    SkeletonTemplate(
      componentType: 'Input',
      label: 'Input Field',
      category: 'Elements',
      description: 'Text or search input container',
      icon: Icons.text_fields_outlined,
      defaultWidth: 240.0,
      defaultHeight: 48.0,
      defaultPrompt: 'Add text input field with placeholder',
    ),
    SkeletonTemplate(
      componentType: 'Card',
      label: 'Card Container',
      category: 'Elements',
      description: 'Elevated content or list item card',
      icon: Icons.credit_card_outlined,
      defaultWidth: 280.0,
      defaultHeight: 140.0,
      defaultPrompt: 'Add card container with padding',
    ),
    SkeletonTemplate(
      componentType: 'Text',
      label: 'Text Block',
      category: 'Elements',
      description: 'Header, paragraph, or label',
      icon: Icons.title_outlined,
      defaultWidth: 180.0,
      defaultHeight: 28.0,
      defaultPrompt: 'Add title or paragraph label',
    ),
    SkeletonTemplate(
      componentType: 'Avatar',
      label: 'User Avatar',
      category: 'Elements',
      description: 'Circular profile photo or initials badge',
      icon: Icons.account_circle_outlined,
      defaultWidth: 48.0,
      defaultHeight: 48.0,
      defaultPrompt: 'Add circular user avatar badge',
    ),
    SkeletonTemplate(
      componentType: 'Image',
      label: 'Image Preview',
      category: 'Elements',
      description: 'Responsive media or banner container',
      icon: Icons.image_outlined,
      defaultWidth: 240.0,
      defaultHeight: 160.0,
      defaultPrompt: 'Add image display with aspect ratio',
    ),

    // Blocks section (Screenshot 4)
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
  ];
}
