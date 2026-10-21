import 'package:flutter/material.dart';
import 'skeleton_templates.dart';

/// Single selectable option chip for component configuration.
@immutable
class ComponentOptionChoice {
  const ComponentOptionChoice({
    required this.label,
    this.value,
    this.presetText,
    this.tooltip,
    this.icon,
  });

  /// User-facing label displayed on the chip.
  final String label;

  /// Identifier value; defaults to [label] if omitted.
  final String? value;

  /// If provided, clicking this option automatically populates or updates
  /// the primary input field (e.g. setting an image URL or preset path).
  final String? presetText;

  /// Optional tooltip hint.
  final String? tooltip;

  /// Optional icon displayed alongside the label.
  final IconData? icon;

  String get effectiveValue => value ?? label;
}

/// A grouped set of related option choices (e.g. Variant, Fit Mode, Source Type).
@immutable
class ComponentOptionGroup {
  const ComponentOptionGroup({
    required this.title,
    required this.choices,
    this.defaultSelectedIndex = 0,
    this.isMultiSelect = false,
  });

  /// Category heading (e.g. "Source Type:", "Variant:", "Fit Mode:").
  final String title;

  /// Selectable choices within this group.
  final List<ComponentOptionChoice> choices;

  /// Default choice selected initially.
  final int defaultSelectedIndex;

  /// Whether multiple choices in this group can be selected simultaneously.
  final bool isMultiSelect;
}

/// The behavioral category that dictates the interaction model and configuration flow for a component.
enum ComponentBehaviorCategory {
  button,
  toggle,
  input,
  image,
  text,
  slider,
  listTile,
  card,
  picker,
  indicator,
  block,
  generic,
}

/// A boolean behavioral toggle specific to the component's runtime behavior
/// (e.g. Loading State, With Leading Icon, Required, Clearable, Interactive).
@immutable
class ComponentBehaviorToggle {
  const ComponentBehaviorToggle({
    required this.key,
    required this.label,
    this.defaultValue = false,
    this.icon,
    this.activeIcon,
    this.tooltip,
  });

  /// The unique property key stored in placement properties (e.g. 'isLoading', 'hasIcon', 'isRequired').
  final String key;

  /// Display title on the toggle chip.
  final String label;

  /// Default active state.
  final bool defaultValue;

  /// Inactive icon.
  final IconData? icon;

  /// Active icon.
  final IconData? activeIcon;

  /// Informational tooltip.
  final String? tooltip;
}

/// Curated counter-question and options configuration tailored for each skeleton component.
@immutable
class ComponentQuestionConfig {
  const ComponentQuestionConfig({
    required this.componentType,
    required this.question,
    required this.primaryInputLabel,
    required this.primaryInputPlaceholder,
    required this.defaultPrimaryValue,
    this.behaviorCategory = ComponentBehaviorCategory.generic,
    this.behaviorToggles = const [],
    this.optionGroups = const [],
    this.secondaryInputLabel,
    this.secondaryInputPlaceholder,
    this.defaultSecondaryValue,
    this.notesPlaceholder = 'Optional instructions or requirements for AI coding agent...',
  });

  /// The component or block type (e.g. 'Image', 'Button', 'Input', 'Text', 'Avatar').
  final String componentType;

  /// The behavioral category that shapes the specific UI flow for this component.
  final ComponentBehaviorCategory behaviorCategory;

  /// Clear counter-question presented prominently to the user in the configuration box.
  final String question;

  /// Label for the primary input field.
  final String primaryInputLabel;

  /// Placeholder hint inside the primary text field.
  final String primaryInputPlaceholder;

  /// Ready-to-use default value pre-filled so the user can immediately place without typing.
  final String defaultPrimaryValue;

  /// Specific behavioral toggle flags (e.g. Loading State, Clearable, Required).
  final List<ComponentBehaviorToggle> behaviorToggles;

  /// Interactive option groups (chips/buttons) allowing quick selection of variants and settings.
  final List<ComponentOptionGroup> optionGroups;

  /// Optional label for a secondary input field (e.g. Tooltip, Subtitle, Action).
  final String? secondaryInputLabel;

  /// Optional placeholder for secondary input.
  final String? secondaryInputPlaceholder;

  /// Optional default value for secondary input.
  final String? defaultSecondaryValue;

  /// Placeholder text for the optional AI agent notes field.
  final String notesPlaceholder;

  /// Formats a comprehensive, AI-friendly placement comment summarizing the user's answers and choices.
  String formatPlacementComment({
    required String targetLabel,
    required String treePlacementDescription,
    required String primaryText,
    String? secondaryText,
    Map<String, dynamic> selectedOptions = const {},
    Map<String, bool> behaviorStates = const {},
    String? additionalNotes,
  }) {
    final buffer = StringBuffer('Place $targetLabel');

    final details = <String>[];
    if (primaryText.trim().isNotEmpty) {
      if (componentType == 'Image' || componentType == 'Avatar' || componentType == 'VideoPlayer' || componentType == 'AudioPlayer') {
        details.add('Source: "$primaryText"');
      } else if (componentType == 'Button' || componentType == 'OutlinedButton' || componentType == 'TextButton' || componentType == 'FAB') {
        details.add('Label: "$primaryText"');
      } else if (componentType == 'Input' || componentType == 'SearchBar' || componentType == 'PasswordField') {
        details.add('Placeholder: "$primaryText"');
      } else if (componentType == 'Text') {
        details.add('Text: "$primaryText"');
      } else {
        details.add('Content: "$primaryText"');
      }
    }

    if (secondaryText != null && secondaryText.trim().isNotEmpty) {
      details.add('Detail: "$secondaryText"');
    }

    selectedOptions.forEach((key, val) {
      if (val != null && val.toString().isNotEmpty) {
        details.add('$key: $val');
      }
    });

    behaviorStates.forEach((key, val) {
      final matchingToggle = behaviorToggles.where((t) => t.key == key).firstOrNull;
      final label = matchingToggle?.label ?? key;
      details.add('$label: $val');
    });

    if (details.isNotEmpty) {
      buffer.write(' (${details.join(', ')})');
    }

    if (treePlacementDescription.isNotEmpty) {
      buffer.write(' $treePlacementDescription');
    }

    if (additionalNotes != null && additionalNotes.trim().isNotEmpty) {
      buffer.write('. ${additionalNotes.trim()}');
    }

    buffer.write('. Understand the project theme and decoration style from the codebase, and develop this component based on existing project patterns.');

    return buffer.toString();
  }

  /// Factory creating component-specific question and preset configurations.
  static ComponentQuestionConfig forTemplate(SkeletonTemplate template) {
    switch (template.componentType) {
      // ── Image Preview ──
      case 'Image':
        return const ComponentQuestionConfig(
          componentType: 'Image',
          behaviorCategory: ComponentBehaviorCategory.image,
          question: 'What is the image source & scaling fit mode?',
          primaryInputLabel: 'Image Source (Asset Path / URL)',
          primaryInputPlaceholder: 'assets/images/banner.png or https://...',
          defaultPrimaryValue: 'assets/images/placeholder.png',
          behaviorToggles: [
            ComponentBehaviorToggle(
              key: 'rounded',
              label: 'Rounded Corners',
              defaultValue: true,
              icon: Icons.rounded_corner_outlined,
              tooltip: 'Apply rounded border radius',
            ),
            ComponentBehaviorToggle(
              key: 'aspectRatio',
              label: '16:9 Aspect Ratio',
              defaultValue: true,
              icon: Icons.aspect_ratio_outlined,
              tooltip: 'Lock to standard 16:9 ratio',
            ),
          ],
          optionGroups: [
            ComponentOptionGroup(
              title: 'Source Preset:',
              choices: [
                ComponentOptionChoice(
                  label: 'Local Asset',
                  presetText: 'assets/images/placeholder.png',
                  icon: Icons.folder_open_outlined,
                  tooltip: 'Load from Flutter app local pubspec assets',
                ),
                ComponentOptionChoice(
                  label: 'Network URL',
                  presetText: 'https://picsum.photos/600/400',
                  icon: Icons.link_outlined,
                  tooltip: 'Load dynamically from external HTTPS URL',
                ),
                ComponentOptionChoice(
                  label: 'Unsplash Sample',
                  presetText: 'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=800',
                  icon: Icons.camera_alt_outlined,
                  tooltip: 'High-res sample photo from Unsplash',
                ),
                ComponentOptionChoice(
                  label: 'Icon Placeholder',
                  presetText: 'Icons.image_outlined',
                  icon: Icons.image_outlined,
                  tooltip: 'Vector icon fallback container',
                ),
              ],
            ),
            ComponentOptionGroup(
              title: 'Fit Mode:',
              choices: [
                ComponentOptionChoice(label: 'Cover', value: 'BoxFit.cover', tooltip: 'Scale and crop to fill'),
                ComponentOptionChoice(label: 'Contain', value: 'BoxFit.contain', tooltip: 'Scale to fit inside without cropping'),
                ComponentOptionChoice(label: 'Fill', value: 'BoxFit.fill', tooltip: 'Stretch to fill box'),
                ComponentOptionChoice(label: 'Fit Width', value: 'BoxFit.fitWidth', tooltip: 'Match width and adjust height'),
              ],
            ),
          ],
        );

      // ── Action Buttons ──
      case 'Button':
      case 'OutlinedButton':
      case 'TextButton':
      case 'FAB':
        final isFab = template.componentType == 'FAB';
        final isOutlined = template.componentType == 'OutlinedButton';
        final isTextBtn = template.componentType == 'TextButton';
        return ComponentQuestionConfig(
          componentType: template.componentType,
          behaviorCategory: ComponentBehaviorCategory.button,
          question: isFab
              ? 'What is the Floating Action Button tooltip & action intent?'
              : 'What is the button label, variant & tap action intent?',
          primaryInputLabel: isFab ? 'FAB Action / Tooltip' : 'Button Label',
          primaryInputPlaceholder: isFab ? 'e.g. Create New Post' : 'e.g. Get Started, Submit',
          defaultPrimaryValue: isFab ? 'Add New' : (isOutlined ? 'Secondary Action' : (isTextBtn ? 'Learn More' : 'Get Started')),
          behaviorToggles: [
            const ComponentBehaviorToggle(
              key: 'enabled',
              label: 'Enabled State',
              defaultValue: true,
              icon: Icons.check_circle_outline,
              tooltip: 'Button is active and clickable',
            ),
            const ComponentBehaviorToggle(
              key: 'hasIcon',
              label: 'Leading Icon',
              defaultValue: false,
              icon: Icons.add_circle_outline,
              tooltip: 'Render button with a leading glyph',
            ),
            const ComponentBehaviorToggle(
              key: 'isLoading',
              label: 'Loading State',
              defaultValue: false,
              icon: Icons.hourglass_empty,
              tooltip: 'Show circular spinner on tap',
            ),
          ],
          optionGroups: [
            if (!isFab)
              ComponentOptionGroup(
                title: 'Variant:',
                defaultSelectedIndex: isOutlined ? 1 : (isTextBtn ? 2 : 0),
                choices: const [
                  ComponentOptionChoice(label: 'Filled / Primary', value: 'FilledButton'),
                  ComponentOptionChoice(label: 'Outlined', value: 'OutlinedButton'),
                  ComponentOptionChoice(label: 'Text Link', value: 'TextButton'),
                  ComponentOptionChoice(label: 'Elevated', value: 'ElevatedButton'),
                  ComponentOptionChoice(label: 'Icon + Text', value: 'FilledButton.icon'),
                ],
              ),
            ComponentOptionGroup(
              title: 'Tap Action Intent:',
              choices: const [
                ComponentOptionChoice(label: 'Submit Form', value: 'Submit'),
                ComponentOptionChoice(label: 'Navigate Next', value: 'Navigate'),
                ComponentOptionChoice(label: 'Open Dialog', value: 'Modal'),
                ComponentOptionChoice(label: 'Cancel / Back', value: 'Cancel'),
              ],
            ),
          ],
        );

      // ── Icon & Icon Button ──
      case 'Icon':
      case 'IconButton':
        final isIconButton = template.componentType == 'IconButton';
        return ComponentQuestionConfig(
          componentType: template.componentType,
          behaviorCategory: ComponentBehaviorCategory.button,
          question: 'Which icon and action should this element use?',
          primaryInputLabel: 'Icon Name or Tooltip',
          primaryInputPlaceholder: 'e.g. Icons.search, Close Dialog',
          defaultPrimaryValue: 'Icons.search',
          behaviorToggles: [
            ComponentBehaviorToggle(
              key: 'isButton',
              label: 'Clickable (IconButton)',
              defaultValue: isIconButton,
              icon: Icons.touch_app_outlined,
            ),
            const ComponentBehaviorToggle(
              key: 'hasTooltip',
              label: 'Show Tooltip',
              defaultValue: true,
              icon: Icons.info_outline,
            ),
          ],
          optionGroups: const [
            ComponentOptionGroup(
              title: 'Icon Preset:',
              choices: [
                ComponentOptionChoice(label: 'Search', presetText: 'Icons.search', icon: Icons.search),
                ComponentOptionChoice(label: 'Settings', presetText: 'Icons.settings', icon: Icons.settings),
                ComponentOptionChoice(label: 'Close', presetText: 'Icons.close', icon: Icons.close),
                ComponentOptionChoice(label: 'Favorite', presetText: 'Icons.favorite_border', icon: Icons.favorite_border),
                ComponentOptionChoice(label: 'Share', presetText: 'Icons.share', icon: Icons.share),
                ComponentOptionChoice(label: 'More', presetText: 'Icons.more_vert', icon: Icons.more_vert),
              ],
            ),
            ComponentOptionGroup(
              title: 'Size:',
              choices: [
                ComponentOptionChoice(label: 'Standard (24px)', value: '24'),
                ComponentOptionChoice(label: 'Compact (18px)', value: '18'),
                ComponentOptionChoice(label: 'Large (32px)', value: '32'),
              ],
            ),
          ],
        );

      // ── Input Fields ──
      case 'Input':
      case 'SearchBar':
      case 'PasswordField':
      case 'OtpInput':
        final isSearch = template.componentType == 'SearchBar';
        final isPassword = template.componentType == 'PasswordField';
        final isOtp = template.componentType == 'OtpInput';
        return ComponentQuestionConfig(
          componentType: template.componentType,
          behaviorCategory: ComponentBehaviorCategory.input,
          question: isOtp
              ? 'How many digits for the verification code input?'
              : 'What is the placeholder hint text & input type?',
          primaryInputLabel: isOtp ? 'PIN Digits & Format' : 'Placeholder Hint Text',
          primaryInputPlaceholder: isOtp ? 'e.g. 6 digits, numeric only' : 'e.g. Enter work email address...',
          defaultPrimaryValue: isOtp
              ? '6 Digits (SMS / Email Verification)'
              : (isSearch ? 'Search products, tags or categories...' : (isPassword ? 'Enter secure password' : 'Enter text here...')),
          behaviorToggles: [
            const ComponentBehaviorToggle(
              key: 'clearable',
              label: 'Clear Button (✕)',
              defaultValue: true,
              icon: Icons.cancel_outlined,
              tooltip: 'Show suffix clear button when user types',
            ),
            const ComponentBehaviorToggle(
              key: 'required',
              label: 'Required Field (*)',
              defaultValue: false,
              icon: Icons.emergency_outlined,
              tooltip: 'Mark field with required validator',
            ),
            if (isPassword)
              const ComponentBehaviorToggle(
                key: 'obscureEye',
                label: 'Show/Hide Password Eye',
                defaultValue: true,
                icon: Icons.visibility_outlined,
              ),
            if (isSearch)
              const ComponentBehaviorToggle(
                key: 'leadingSearch',
                label: 'Search Prefix Icon',
                defaultValue: true,
                icon: Icons.search,
              ),
          ],
          optionGroups: [
            if (!isOtp)
              ComponentOptionGroup(
                title: 'Keyboard / Input Type:',
                defaultSelectedIndex: isSearch ? 3 : (isPassword ? 2 : 0),
                choices: const [
                  ComponentOptionChoice(label: 'Plain Text', value: 'TextInputType.text'),
                  ComponentOptionChoice(label: 'Email', value: 'TextInputType.emailAddress'),
                  ComponentOptionChoice(label: 'Password', value: 'Obscured Password'),
                  ComponentOptionChoice(label: 'Search', value: 'Search Query'),
                  ComponentOptionChoice(label: 'Number / Phone', value: 'TextInputType.phone'),
                ],
              ),
            ComponentOptionGroup(
              title: 'Decoration:',
              choices: const [
                ComponentOptionChoice(label: 'Standard Outline', value: 'Outlined'),
                ComponentOptionChoice(label: 'Filled Tone', value: 'Filled'),
                ComponentOptionChoice(label: 'Multiline / Area', value: 'Multiline (3 lines)'),
              ],
            ),
          ],
        );

      // ── Text Block ──
      case 'Text':
        return const ComponentQuestionConfig(
          componentType: 'Text',
          behaviorCategory: ComponentBehaviorCategory.text,
          question: 'What is the text content & typography hierarchy?',
          primaryInputLabel: 'Text Content',
          primaryInputPlaceholder: 'e.g. Welcome back, Account Settings, or body copy...',
          defaultPrimaryValue: 'Section Heading Title',
          behaviorToggles: [
            ComponentBehaviorToggle(
              key: 'ellipsis',
              label: 'Single-Line Truncate (…)',
              defaultValue: false,
              icon: Icons.more_horiz,
              tooltip: 'Truncate text with ellipsis if overflowing',
            ),
            ComponentBehaviorToggle(
              key: 'selectable',
              label: 'Selectable Text',
              defaultValue: false,
              icon: Icons.select_all,
              tooltip: 'Allow user to select and copy text',
            ),
          ],
          optionGroups: [
            ComponentOptionGroup(
              title: 'Typography Hierarchy:',
              choices: [
                ComponentOptionChoice(label: 'H1 Headline (32px)', value: 'Theme.textTheme.headlineMedium', presetText: 'Main Headline'),
                ComponentOptionChoice(label: 'H2 Title (24px)', value: 'Theme.textTheme.titleLarge', presetText: 'Section Title'),
                ComponentOptionChoice(label: 'Body Text (14px)', value: 'Theme.textTheme.bodyMedium', presetText: 'Descriptive body text paragraph detailing the features.'),
                ComponentOptionChoice(label: 'Caption / Muted (12px)', value: 'Theme.textTheme.bodySmall', presetText: 'Last updated 5 minutes ago'),
              ],
            ),
            ComponentOptionGroup(
              title: 'Alignment:',
              choices: [
                ComponentOptionChoice(label: 'Left', value: 'TextAlign.start', icon: Icons.format_align_left),
                ComponentOptionChoice(label: 'Center', value: 'TextAlign.center', icon: Icons.format_align_center),
                ComponentOptionChoice(label: 'Right', value: 'TextAlign.end', icon: Icons.format_align_right),
              ],
            ),
          ],
        );

      // ── User Avatar ──
      case 'Avatar':
        return const ComponentQuestionConfig(
          componentType: 'Avatar',
          behaviorCategory: ComponentBehaviorCategory.image,
          question: 'What is the avatar image URL, local asset or initials?',
          primaryInputLabel: 'Avatar Source or Initials',
          primaryInputPlaceholder: 'e.g. https://... or assets/... or JD',
          defaultPrimaryValue: 'https://i.pravatar.cc/150?img=12',
          behaviorToggles: [
            ComponentBehaviorToggle(
              key: 'circular',
              label: 'Circle Shape',
              defaultValue: true,
              icon: Icons.circle_outlined,
            ),
            ComponentBehaviorToggle(
              key: 'onlineDot',
              label: 'Online Status Dot',
              defaultValue: false,
              icon: Icons.fiber_manual_record,
              tooltip: 'Render green online activity indicator badge',
            ),
          ],
          optionGroups: [
            ComponentOptionGroup(
              title: 'Source Preset:',
              choices: [
                ComponentOptionChoice(
                  label: 'Network Photo',
                  presetText: 'https://i.pravatar.cc/150?img=12',
                  icon: Icons.link_outlined,
                  tooltip: 'External profile photo URL',
                ),
                ComponentOptionChoice(
                  label: 'User Initials',
                  presetText: 'JD (John Doe)',
                  icon: Icons.text_fields_outlined,
                  tooltip: 'Letter initials badge',
                ),
                ComponentOptionChoice(
                  label: 'Default Person Icon',
                  presetText: 'Icons.person_outline',
                  icon: Icons.person_outline,
                  tooltip: 'Standard fallback avatar icon',
                ),
                ComponentOptionChoice(
                  label: 'Local Asset',
                  presetText: 'assets/images/user_avatar.png',
                  icon: Icons.folder_open_outlined,
                  tooltip: 'App bundled local asset image',
                ),
              ],
            ),
            ComponentOptionGroup(
              title: 'Size:',
              choices: [
                ComponentOptionChoice(label: 'Medium (48px)', value: 'Radius 24'),
                ComponentOptionChoice(label: 'Small (32px)', value: 'Radius 16'),
                ComponentOptionChoice(label: 'Large (64px)', value: 'Radius 32'),
              ],
            ),
          ],
        );

      // ── Card Container ──
      case 'Card':
        return const ComponentQuestionConfig(
          componentType: 'Card',
          behaviorCategory: ComponentBehaviorCategory.card,
          question: 'What is the card style, elevation & interaction?',
          primaryInputLabel: 'Card Title / Purpose',
          primaryInputPlaceholder: 'e.g. Feature Overview Card, Order Summary',
          defaultPrimaryValue: 'Feature Overview Card',
          behaviorToggles: [
            ComponentBehaviorToggle(
              key: 'clickable',
              label: 'Interactive (onTap)',
              defaultValue: false,
              icon: Icons.touch_app_outlined,
              tooltip: 'Wrap card in InkWell to handle taps',
            ),
          ],
          optionGroups: [
            ComponentOptionGroup(
              title: 'Card Style:',
              choices: [
                ComponentOptionChoice(label: 'Elevated (Shadow)', value: 'Card(elevation: 2)'),
                ComponentOptionChoice(label: 'Outlined (Border)', value: 'Card(border: true)'),
                ComponentOptionChoice(label: 'Filled (Flat)', value: 'Card(elevation: 0, filled: true)'),
              ],
            ),
            ComponentOptionGroup(
              title: 'Internal Padding:',
              choices: [
                ComponentOptionChoice(label: 'Standard (16px)', value: 'EdgeInsets.all(16)'),
                ComponentOptionChoice(label: 'Compact (8px)', value: 'EdgeInsets.all(8)'),
                ComponentOptionChoice(label: 'Spacious (24px)', value: 'EdgeInsets.all(24)'),
              ],
            ),
          ],
        );

      // ── Chip / Status Badge ──
      case 'Chip':
      case 'Badge':
        final isBadge = template.componentType == 'Badge';
        return ComponentQuestionConfig(
          componentType: template.componentType,
          behaviorCategory: ComponentBehaviorCategory.indicator,
          question: isBadge ? 'What is the badge text & color tone?' : 'What is the chip label & behavior?',
          primaryInputLabel: isBadge ? 'Badge Label / Count' : 'Chip Label',
          primaryInputPlaceholder: isBadge ? 'e.g. NEW, 3, PRO' : 'e.g. Active, Flutter, Category',
          defaultPrimaryValue: isBadge ? 'NEW' : 'Active Filter',
          behaviorToggles: [
            ComponentBehaviorToggle(
              key: 'hasIcon',
              label: isBadge ? 'Dot Indicator' : 'Leading Icon',
              defaultValue: false,
              icon: Icons.circle_outlined,
            ),
          ],
          optionGroups: [
            ComponentOptionGroup(
              title: isBadge ? 'Color Tone:' : 'Behavior:',
              choices: isBadge
                  ? const [
                      ComponentOptionChoice(label: 'Red / Alert', value: 'Colors.redAccent'),
                      ComponentOptionChoice(label: 'Blue / Info', value: 'Colors.blueAccent'),
                      ComponentOptionChoice(label: 'Green / Success', value: 'Colors.green'),
                      ComponentOptionChoice(label: 'Amber / Warning', value: 'Colors.amber'),
                    ]
                  : const [
                      ComponentOptionChoice(label: 'Filter Chip', value: 'FilterChip(selected: true)'),
                      ComponentOptionChoice(label: 'Action Chip', value: 'ActionChip'),
                      ComponentOptionChoice(label: 'Deletable Tag', value: 'Chip(onDeleted: ...)'),
                      ComponentOptionChoice(label: 'Status Pill', value: 'Container Pill Badge'),
                    ],
            ),
          ],
        );

      // ── Switch & Toggles ──
      case 'Switch':
      case 'SwitchListTile':
      case 'Checkbox':
      case 'CheckboxListTile':
      case 'Radio':
      case 'RadioListTile':
        final isSwitch = template.componentType.contains('Switch');
        final isCheckbox = template.componentType.contains('Checkbox');
        return ComponentQuestionConfig(
          componentType: template.componentType,
          behaviorCategory: ComponentBehaviorCategory.toggle,
          question: 'What is the toggle label, initial state & behavior?',
          primaryInputLabel: 'Setting / Option Label',
          primaryInputPlaceholder: 'e.g. Enable Push Notifications, I agree to Terms',
          defaultPrimaryValue: isSwitch
              ? 'Enable Notifications'
              : (isCheckbox ? 'I agree to the Terms of Service' : 'Option Choice A'),
          behaviorToggles: [
            ComponentBehaviorToggle(
              key: 'checked',
              label: isSwitch ? 'Initially Active (ON)' : 'Initially Checked',
              defaultValue: isSwitch,
              icon: isSwitch ? Icons.toggle_on : Icons.check_box,
              tooltip: 'Initial boolean value in component state',
            ),
            const ComponentBehaviorToggle(
              key: 'asRow',
              label: 'Full ListTile Row',
              defaultValue: true,
              icon: Icons.table_rows_outlined,
              tooltip: 'Render clickable full-width row with title',
            ),
          ],
          optionGroups: const [
            ComponentOptionGroup(
              title: 'On State Change Action:',
              choices: [
                ComponentOptionChoice(label: 'Instant Save', value: 'Save to preferences immediately'),
                ComponentOptionChoice(label: 'Form Submission', value: 'Submit with parent form'),
                ComponentOptionChoice(label: 'Theme Switch', value: 'Toggle dark / light theme'),
                ComponentOptionChoice(label: 'Permission Trigger', value: 'Request system permission'),
              ],
            ),
          ],
        );

      // ── Slider ──
      case 'Slider':
        return const ComponentQuestionConfig(
          componentType: 'Slider',
          behaviorCategory: ComponentBehaviorCategory.slider,
          question: 'What is the slider label and value range?',
          primaryInputLabel: 'Slider Label / Value',
          primaryInputPlaceholder: r'e.g. Volume: 75%, Price: $0 - $500',
          defaultPrimaryValue: 'Volume: 75%',
          behaviorToggles: [
            ComponentBehaviorToggle(
              key: 'divisions',
              label: 'Discrete Tick Steps',
              defaultValue: false,
              icon: Icons.linear_scale,
              tooltip: 'Snap slider thumb to discrete values',
            ),
            ComponentBehaviorToggle(
              key: 'showValue',
              label: 'Show Floating Bubble',
              defaultValue: true,
              icon: Icons.label_outline,
              tooltip: 'Render active value above slider thumb',
            ),
          ],
          optionGroups: [
            ComponentOptionGroup(
              title: 'Range Preset:',
              choices: [
                ComponentOptionChoice(label: 'Percentage (0 - 100%)', value: '0.0 - 100.0'),
                ComponentOptionChoice(label: 'Rating (1 - 5)', value: '1.0 - 5.0'),
                ComponentOptionChoice(label: r'Price ($0 - $1,000)', value: '0 - 1000'),
                ComponentOptionChoice(label: 'Normalized (0.0 - 1.0)', value: '0.0 - 1.0'),
              ],
            ),
          ],
        );

      // ── Dropdown & Segmented Button ──
      case 'Dropdown':
      case 'SegmentedButton':
        final isSegmented = template.componentType == 'SegmentedButton';
        return ComponentQuestionConfig(
          componentType: template.componentType,
          behaviorCategory: ComponentBehaviorCategory.picker,
          question: isSegmented
              ? 'What are the segmented button segments?'
              : 'What are the dropdown menu options?',
          primaryInputLabel: 'Comma-Separated Options',
          primaryInputPlaceholder: 'e.g. Day, Week, Month, Year',
          defaultPrimaryValue: isSegmented ? 'Daily, Weekly, Monthly, Annual' : 'All Items, Popular, Recent, Highest Rated',
          behaviorToggles: [
            const ComponentBehaviorToggle(
              key: 'fullWidth',
              label: 'Full Width Expand',
              defaultValue: true,
              icon: Icons.unfold_more,
            ),
          ],
          optionGroups: [
            ComponentOptionGroup(
              title: 'Display Mode:',
              choices: [
                ComponentOptionChoice(label: isSegmented ? 'Pill Bar' : 'Standard Dropdown', value: 'Standard'),
                ComponentOptionChoice(label: 'With Icons', value: 'With leading icons'),
              ],
            ),
          ],
        );

      // ── List Tile ──
      case 'ListTile':
        return const ComponentQuestionConfig(
          componentType: 'ListTile',
          behaviorCategory: ComponentBehaviorCategory.listTile,
          question: 'What is the list tile title, subtitle & slot behavior?',
          primaryInputLabel: 'Tile Title',
          primaryInputPlaceholder: 'e.g. Security & Privacy, Payment Methods',
          defaultPrimaryValue: 'Account Security Settings',
          secondaryInputLabel: 'Subtitle (optional)',
          secondaryInputPlaceholder: 'e.g. Manage passwords, two-factor auth',
          defaultSecondaryValue: 'Manage passwords and authentication keys',
          behaviorToggles: [
            ComponentBehaviorToggle(
              key: 'clickable',
              label: 'Tappable Navigation',
              defaultValue: true,
              icon: Icons.touch_app_outlined,
              tooltip: 'Attach onTap navigation callback',
            ),
            ComponentBehaviorToggle(
              key: 'dense',
              label: 'Compact Density',
              defaultValue: false,
              icon: Icons.density_medium,
              tooltip: 'Reduce vertical padding for compact lists',
            ),
          ],
          optionGroups: [
            ComponentOptionGroup(
              title: 'Leading Slot:',
              choices: [
                ComponentOptionChoice(label: 'Icon', value: 'Leading Icon', icon: Icons.star_border),
                ComponentOptionChoice(label: 'Avatar', value: 'CircleAvatar', icon: Icons.account_circle_outlined),
                ComponentOptionChoice(label: 'Checkbox', value: 'Checkbox', icon: Icons.check_box_outlined),
                ComponentOptionChoice(label: 'None', value: 'None'),
              ],
            ),
            ComponentOptionGroup(
              title: 'Trailing Slot:',
              choices: [
                ComponentOptionChoice(label: 'Chevron Arrow (›)', value: 'Icons.chevron_right'),
                ComponentOptionChoice(label: 'Switch Toggle', value: 'Switch()'),
                ComponentOptionChoice(label: 'Checkbox', value: 'Checkbox()'),
                ComponentOptionChoice(label: 'Text Badge', value: 'Badge(PRO)'),
              ],
            ),
          ],
        );

      // ── Progress & Spinner ──
      case 'Spinner':
      case 'Progress':
        final isProgress = template.componentType == 'Progress';
        return ComponentQuestionConfig(
          componentType: template.componentType,
          behaviorCategory: ComponentBehaviorCategory.indicator,
          question: 'What is the indicator style and status message?',
          primaryInputLabel: 'Status Label / Hint',
          primaryInputPlaceholder: 'e.g. Loading data, Uploading 75%...',
          defaultPrimaryValue: isProgress ? 'Uploading files (65%)...' : 'Loading data...',
          behaviorToggles: [
            ComponentBehaviorToggle(
              key: 'showPercentage',
              label: 'Show Percentage Text',
              defaultValue: isProgress,
              icon: Icons.percent,
            ),
          ],
          optionGroups: [
            ComponentOptionGroup(
              title: 'Indicator Mode:',
              choices: [
                ComponentOptionChoice(label: isProgress ? 'Linear Bar' : 'Circular Ring', value: 'Standard'),
                ComponentOptionChoice(label: 'Indeterminate Loop', value: 'Indeterminate'),
                ComponentOptionChoice(label: 'Determinate Progress', value: 'Value: 0.65'),
              ],
            ),
          ],
        );

      // ── Blocks (Composite Sections) ──
      case 'Pricing':
      case 'Testimonial':
      case 'CTA':
      case 'Product Card':
      case 'Profile':
      case 'Form':
        return ComponentQuestionConfig(
          componentType: template.componentType,
          behaviorCategory: ComponentBehaviorCategory.block,
          question: 'What is the block title & headline structure?',
          primaryInputLabel: '${template.label} Title / Headline',
          primaryInputPlaceholder: 'e.g. Pro Plan, Customer Review, Get Started Today',
          defaultPrimaryValue: template.componentType == 'Pricing'
              ? 'Pro Plan (\$29/month)'
              : (template.componentType == 'CTA'
                  ? 'Ready to supercharge your workflow?'
                  : (template.componentType == 'Product Card'
                      ? 'Wireless Noise-Cancelling Headphones'
                      : 'Featured Section')),
          behaviorToggles: const [
            ComponentBehaviorToggle(
              key: 'hasCta',
              label: 'Include Action Button',
              defaultValue: true,
              icon: Icons.smart_button_outlined,
            ),
          ],
          optionGroups: const [
            ComponentOptionGroup(
              title: 'Layout Style:',
              choices: [
                ComponentOptionChoice(label: 'Modern Card', value: 'Card Container with padding'),
                ComponentOptionChoice(label: 'Full-Width Section', value: 'Container(width: double.infinity)'),
                ComponentOptionChoice(label: 'Compact Block', value: 'Dense padding'),
              ],
            ),
          ],
        );

      // ── Default / Fallback for any other component ──
      default:
        return ComponentQuestionConfig(
          componentType: template.componentType,
          behaviorCategory: ComponentBehaviorCategory.generic,
          question: 'What details or properties should this ${template.label} have?',
          primaryInputLabel: '${template.label} Details / Value',
          primaryInputPlaceholder: 'Enter custom label, identifier, or properties...',
          defaultPrimaryValue: template.label,
          notesPlaceholder: template.defaultPrompt.isNotEmpty
              ? template.defaultPrompt
              : 'Optional instructions for AI coding agent...',
          optionGroups: const [
            ComponentOptionGroup(
              title: 'Preset Options:',
              choices: [
                ComponentOptionChoice(label: 'Standard', value: 'Default style'),
                ComponentOptionChoice(label: 'Compact', value: 'Compact sizing'),
                ComponentOptionChoice(label: 'Prominent', value: 'Highlighted styling'),
              ],
            ),
          ],
        );
    }
  }
}

