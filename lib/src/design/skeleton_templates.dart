import 'package:flutter/material.dart';
import '../models/placement_data.dart';

/// Pre-built wireframe skeleton template for Visual Design Mode.
@immutable
class SkeletonTemplate {
  const SkeletonTemplate({
    required this.componentType,
    required this.label,
    required this.icon,
    required this.defaultWidth,
    required this.defaultHeight,
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

  /// The widget class or component kind (e.g. 'Button', 'Input', 'Card').
  final String componentType;

  /// User-facing display title.
  final String label;

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

  /// Curated list of default design mode skeleton templates.
  static const List<SkeletonTemplate> defaultTemplates = [
    SkeletonTemplate(
      componentType: 'Button',
      label: 'Button',
      description: 'Primary or secondary action button',
      icon: Icons.smart_button_outlined,
      defaultWidth: 120.0,
      defaultHeight: 44.0,
      defaultPrompt: 'Add action button here',
    ),
    SkeletonTemplate(
      componentType: 'Input',
      label: 'Input Field',
      description: 'Text or search input container',
      icon: Icons.text_fields_outlined,
      defaultWidth: 240.0,
      defaultHeight: 48.0,
      defaultPrompt: 'Add text input field with placeholder',
    ),
    SkeletonTemplate(
      componentType: 'Card',
      label: 'Card Container',
      description: 'Elevated content or list item card',
      icon: Icons.credit_card_outlined,
      defaultWidth: 280.0,
      defaultHeight: 140.0,
      defaultPrompt: 'Add card container with padding',
    ),
    SkeletonTemplate(
      componentType: 'Text',
      label: 'Text Block',
      description: 'Header, paragraph, or label',
      icon: Icons.title_outlined,
      defaultWidth: 180.0,
      defaultHeight: 28.0,
      defaultPrompt: 'Add title or paragraph label',
    ),
    SkeletonTemplate(
      componentType: 'Avatar',
      label: 'User Avatar',
      description: 'Circular profile photo or initials badge',
      icon: Icons.account_circle_outlined,
      defaultWidth: 48.0,
      defaultHeight: 48.0,
      defaultPrompt: 'Add circular user avatar badge',
    ),
    SkeletonTemplate(
      componentType: 'Image',
      label: 'Image Preview',
      description: 'Responsive media or banner container',
      icon: Icons.image_outlined,
      defaultWidth: 240.0,
      defaultHeight: 160.0,
      defaultPrompt: 'Add image display with aspect ratio',
    ),
  ];
}
