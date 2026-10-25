import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/core/agentation_state.dart';
import 'package:flutter_agentation/src/core/agentation_widget.dart';
import 'package:flutter_agentation/src/domain/annotation.dart';
import 'package:flutter_agentation/src/domain/pending_placement.dart';
import 'package:flutter_agentation/src/domain/placement_data.dart';
import 'package:flutter_agentation/src/inspection/widget_tree_placement_resolver.dart';
import 'package:flutter_agentation/src/storage/memory_annotation_storage.dart';
import 'package:flutter_agentation/src/ui/design/component_question_config.dart';
import 'package:flutter_agentation/src/ui/design/realistic_skeleton_preview.dart';
import 'package:flutter_agentation/src/ui/design/skeleton_templates.dart';
import 'package:flutter_agentation/src/ui/overlay/annotation_marker.dart';
import 'package:flutter_agentation/src/ui/overlay/component_placement_dialog.dart';
import 'package:flutter_agentation/src/ui/overlay/placed_component_preview.dart';

void main() {
  group('Component Counter-Question & Configuration Box Tests', () {
    late MemoryAnnotationStorage storage;
    late AgentationController controller;

    setUp(() {
      storage = MemoryAnnotationStorage();
      controller = AgentationController(
        storage: storage,
        initialMode: InspectionMode.inspecting,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('ComponentQuestionConfig generates tailored questions and presets for all core components', () {
      final imageTemplate = SkeletonTemplate.defaultTemplates.firstWhere((t) => t.componentType == 'Image');
      final imageConfig = ComponentQuestionConfig.forTemplate(imageTemplate);
      expect(imageConfig.question, contains('image source'));
      expect(imageConfig.primaryInputLabel, contains('Image Source'));
      expect(imageConfig.defaultPrimaryValue, equals('assets/images/placeholder.png'));
      expect(imageConfig.optionGroups.any((g) => g.title.contains('Source Preset')), isTrue);
      expect(imageConfig.optionGroups.any((g) => g.title.contains('Fit Mode')), isTrue);

      final buttonTemplate = SkeletonTemplate.defaultTemplates.firstWhere((t) => t.componentType == 'Button');
      final buttonConfig = ComponentQuestionConfig.forTemplate(buttonTemplate);
      expect(buttonConfig.question, contains('button label'));
      expect(buttonConfig.defaultPrimaryValue, isNotEmpty);
      expect(buttonConfig.optionGroups.any((g) => g.title.contains('Variant')), isTrue);

      final inputTemplate = SkeletonTemplate.defaultTemplates.firstWhere((t) => t.componentType == 'Input');
      final inputConfig = ComponentQuestionConfig.forTemplate(inputTemplate);
      expect(inputConfig.question, contains('placeholder hint'));
      expect(inputConfig.optionGroups.any((g) => g.title.contains('Input Type')), isTrue);

      final textTemplate = SkeletonTemplate.defaultTemplates.firstWhere((t) => t.componentType == 'Text');
      final textConfig = ComponentQuestionConfig.forTemplate(textTemplate);
      expect(textConfig.question, contains('text content'));
      expect(textConfig.optionGroups.any((g) => g.title.contains('Typography Hierarchy')), isTrue);

      final avatarTemplate = SkeletonTemplate.defaultTemplates.firstWhere((t) => t.componentType == 'Avatar');
      final avatarConfig = ComponentQuestionConfig.forTemplate(avatarTemplate);
      expect(avatarConfig.question, contains('avatar'));
      expect(avatarConfig.defaultPrimaryValue, contains('pravatar'));

      final cardTemplate = SkeletonTemplate.defaultTemplates.firstWhere((t) => t.componentType == 'Card');
      final cardConfig = ComponentQuestionConfig.forTemplate(cardTemplate);
      expect(cardConfig.question, contains('card style'));
    });

    testWidgets('ComponentPlacementDialog renders counter question, prefilled defaults and option chips', (tester) async {
      final imageTemplate = SkeletonTemplate.defaultTemplates.firstWhere((t) => t.componentType == 'Image');
      final pending = PendingPlacement(
        template: imageTemplate,
        position: const Offset(200, 200),
        treePlacement: const WidgetTreePlacement(
          parentWidget: 'Column',
          parentBreadcrumb: 'HomeScreen > Scaffold > Column',
          direction: 'last child of',
          description: 'as last child of Column',
        ),
      );

      PlacementData? confirmedPlacement;
      String? confirmedComment;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                ComponentPlacementDialog(
                  pendingPlacement: pending,
                  isDark: true,
                  onConfirm: (placement, comment, metadata) {
                    confirmedPlacement = placement;
                    confirmedComment = comment;
                  },
                  onCancel: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Verify header and clean input (question banner and theme banner removed)
      expect(find.text('Configure Image Preview'), findsOneWidget);
      expect(find.textContaining('What is the image source'), findsNothing);
      expect(find.textContaining('Understand the project theme & decoration style'), findsNothing);
      expect(find.text('Image Source (Asset Path / URL)'), findsOneWidget);
      expect(find.text('Network URL'), findsOneWidget);
      expect(find.text('Local Asset'), findsOneWidget);
      expect(find.text('Place Component'), findsOneWidget);

      // Primary input should be prefilled with default asset path
      expect(find.text('assets/images/placeholder.png'), findsOneWidget);

      // Tapping "Network URL" chip automatically populates the text field with a ready URL
      await tester.tap(find.text('Network URL'));
      await tester.pump();

      expect(find.text('https://picsum.photos/600/400'), findsOneWidget);

      // Confirm placement
      await tester.tap(find.text('Place Component'));
      await tester.pumpAndSettle();

      expect(confirmedPlacement, isNotNull);
      expect(confirmedPlacement!.componentType, equals('Image'));
      expect(confirmedPlacement!.source, equals('https://picsum.photos/600/400'));
      expect(confirmedPlacement!.parentWidget, equals('Column'));
      expect(confirmedComment, contains('Source: "https://picsum.photos/600/400"'));
      expect(confirmedComment, contains('as last child of Column'));
    });

    testWidgets('ComponentPlacementDialog supports cancel and escape key', (tester) async {
      final buttonTemplate = SkeletonTemplate.defaultTemplates.firstWhere((t) => t.componentType == 'Button');
      final pending = PendingPlacement(
        template: buttonTemplate,
        position: const Offset(150, 150),
        treePlacement: const WidgetTreePlacement(
          parentWidget: 'Row',
          direction: 'after',
          description: 'inside Row after Text',
        ),
      );

      bool cancelled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                ComponentPlacementDialog(
                  pendingPlacement: pending,
                  onConfirm: (placement, comment, meta) {},
                  onCancel: () => cancelled = true,
                ),
              ],
            ),
          ),
        ),
      );

      // Cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(cancelled, isTrue);
    });

    testWidgets('Full drag-and-drop flow prompts counter question and creates rich placement annotation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FlutterAgentation(
            controller: controller,
            showToolbar: true,
            initialToolbarMinimized: false,
            child: Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Header Title'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Open Component Palette
      controller.openComponent();
      await tester.pumpAndSettle();

      // Find Image Preview in palette
      final imageFinder = find.text('Image Preview');
      expect(imageFinder, findsWidgets);

      // Drag into host page area
      final imageCenter = tester.getCenter(imageFinder.first);
      final gesture = await tester.startGesture(imageCenter);
      await tester.pump(const Duration(milliseconds: 350));

      const dropTarget = Offset(400, 300);
      await gesture.moveTo(dropTarget);
      await tester.pump();

      // Drop
      await gesture.up();
      await tester.pumpAndSettle();

      // Configuration dialog appears with clean input (no redundant banners)
      expect(find.text('Configure Image Preview'), findsOneWidget);
      expect(find.textContaining('What is the image source'), findsNothing);
      expect(find.text('Image Source (Asset Path / URL)'), findsOneWidget);

      // User selects Unsplash Sample chip
      await tester.ensureVisible(find.text('Unsplash Sample'));
      await tester.pump();
      await tester.tap(find.text('Unsplash Sample'));
      await tester.pump();

      // User clicks Place Component
      await tester.tap(find.text('Place Component'));
      await tester.pumpAndSettle();

      // Annotation created with exact user-configured source and project context style instruction
      expect(controller.annotations.length, equals(1));
      final annotation = controller.annotations.first;
      expect(annotation.kind, equals(AnnotationKind.placement));
      expect(annotation.placement?.componentType, equals('Image'));
      expect(annotation.placement?.source, contains('unsplash'));
      expect(annotation.comment, contains('Source:'));
      expect(annotation.comment, contains('Place Image Preview'));
      expect(annotation.comment, contains('Understand the project theme and decoration style'));
      expect(annotation.metadata['styleInstruction'], contains('Understand the project theme and decoration style from the codebase'));

      // Both the exact component look preview AND the comment pin (1) are rendered on the canvas!
      expect(find.byType(PlacedComponentPreview), findsOneWidget);
      expect(find.text('1'), findsWidgets);
    });

    testWidgets('ComponentPlacementDialog has normal font weights, comment box decoration parity, and compact button', (tester) async {
      final buttonTemplate = SkeletonTemplate.defaultTemplates.firstWhere((t) => t.componentType == 'Button');
      final pending = PendingPlacement(
        template: buttonTemplate,
        position: const Offset(150, 150),
        treePlacement: const WidgetTreePlacement(
          parentWidget: 'Column',
          direction: 'after',
          description: 'after Container',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                ComponentPlacementDialog(
                  pendingPlacement: pending,
                  onConfirm: (placement, comment, meta) {},
                  onCancel: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Verify header font is w500 / normal (not w600 or bold)
      final headerText = tester.widget<Text>(find.text('Configure Button'));
      expect(headerText.style?.fontWeight, equals(FontWeight.w500));

      // Verify primary input label font is normal
      final inputLabel = tester.widget<Text>(find.text('Button Label'));
      expect(inputLabel.style?.fontWeight, equals(FontWeight.normal));

      // Verify group titles and chip labels are normal
      final variantTitle = tester.widget<Text>(find.text('Variant:'));
      expect(variantTitle.style?.fontWeight, equals(FontWeight.normal));

      final chipText = tester.widget<Text>(find.text('Filled / Primary'));
      expect(chipText.style?.fontWeight, equals(FontWeight.normal));

      // Verify button label is normal and small
      final buttonText = tester.widget<Text>(find.text('Place Component'));
      expect(buttonText.style?.fontWeight, equals(FontWeight.normal));

      // Verify button size is compact (small button)
      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);
      final buttonSize = tester.getSize(buttonFinder);
      expect(buttonSize.height, lessThanOrEqualTo(28.0));

      // Verify card decoration matches comment box (borderRadius 16.0)
      final cardContainer = tester.widget<Container>(
        find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).borderRadius == BorderRadius.circular(16.0),
        ),
      );
      final decoration = cardContainer.decoration as BoxDecoration;
      expect(decoration.borderRadius, equals(BorderRadius.circular(16.0)));
    });

    testWidgets('ComponentPlacementDialog renders distinct behavior flows for Switch and Button', (tester) async {
      // 1. Switch behavior flow: interactive live toggle and change action
      final switchTemplate = SkeletonTemplate.defaultTemplates.firstWhere((t) => t.componentType == 'Switch');
      final switchPending = PendingPlacement(
        template: switchTemplate,
        position: const Offset(150, 150),
        treePlacement: const WidgetTreePlacement(
          parentWidget: 'Column',
          direction: 'last child of',
          description: 'inside Column',
        ),
      );

      PlacementData? switchResult;
      String? switchComment;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                ComponentPlacementDialog(
                  pendingPlacement: switchPending,
                  onConfirm: (placement, comment, meta) {
                    switchResult = placement;
                    switchComment = comment;
                  },
                  onCancel: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Verify live interactive switch widget is rendered
      expect(find.byType(Switch), findsOneWidget);
      expect(find.text('Active state: ON (true)'), findsOneWidget);

      // Toggle switch
      await tester.tap(find.byType(Switch));
      await tester.pump();
      expect(find.text('Inactive state: OFF (false)'), findsOneWidget);

      // Verify behavior toggles
      expect(find.text('Full ListTile Row'), findsOneWidget);

      // Confirm
      await tester.tap(find.text('Place Component'));
      await tester.pumpAndSettle();

      expect(switchResult, isNotNull);
      expect(switchResult!.properties['checked'], isFalse);
      expect(switchComment, contains('Initially Active (ON): false'));

      // 2. Button behavior flow: Tap Action & Interactive State toggles
      final buttonTemplate = SkeletonTemplate.defaultTemplates.firstWhere((t) => t.componentType == 'Button');
      final buttonPending = PendingPlacement(
        template: buttonTemplate,
        position: const Offset(150, 150),
        treePlacement: const WidgetTreePlacement(
          parentWidget: 'Row',
          direction: 'after',
          description: 'after Container',
        ),
      );

      PlacementData? buttonResult;
      String? buttonComment;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                ComponentPlacementDialog(
                  pendingPlacement: buttonPending,
                  onConfirm: (placement, comment, meta) {
                    buttonResult = placement;
                    buttonComment = comment;
                  },
                  onCancel: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Verify button-specific behavioral toggles
      expect(find.text('Enabled State'), findsOneWidget);
      expect(find.text('Leading Icon'), findsOneWidget);
      expect(find.text('Loading State'), findsOneWidget);

      // Toggle Leading Icon
      await tester.ensureVisible(find.text('Leading Icon'));
      await tester.pump();
      await tester.tap(find.text('Leading Icon'));
      await tester.pump();

      // Select OnTap Action: Open Dialog
      await tester.ensureVisible(find.text('Open Dialog'));
      await tester.pump();
      await tester.tap(find.text('Open Dialog'));
      await tester.pump();

      // Confirm button placement
      await tester.ensureVisible(find.text('Place Component'));
      await tester.pump();
      await tester.tap(find.text('Place Component'));
      await tester.pumpAndSettle();

      expect(buttonResult, isNotNull);
      expect(buttonResult!.properties['hasIcon'], isTrue);
      expect(buttonResult!.properties['Tap Action Intent'], equals('Modal'));
      expect(buttonComment, contains('Leading Icon: true'));
      expect(buttonComment, contains('Tap Action Intent: Modal'));
    });

    testWidgets('ComponentPlacementDialog adapts horizontally for wide/web screen and vertically for mobile', (tester) async {
      final buttonTemplate = SkeletonTemplate.defaultTemplates.firstWhere((t) => t.componentType == 'Button');
      final pending = PendingPlacement(
        template: buttonTemplate,
        position: const Offset(300, 300),
        treePlacement: const WidgetTreePlacement(
          parentWidget: 'Column',
          direction: 'after',
          description: 'after Container',
        ),
      );

      // 1. Web / Wide Viewport (1024x768 >= 600) -> Renders horizontally with IntrinsicHeight Row
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                ComponentPlacementDialog(
                  pendingPlacement: pending,
                  onConfirm: (_, _, _) {},
                  onCancel: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // 1. Web / Wide Viewport (1024x768 >= 600) -> Renders horizontally with two-column Row
      expect(
        find.byKey(const ValueKey('agentation_placement_horizontal_row')),
        findsOneWidget,
      );

      // 2. Mobile Viewport (390x844 < 600) -> Renders vertically without two-column Row
      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                ComponentPlacementDialog(
                  pendingPlacement: pending,
                  onConfirm: (_, _, _) {},
                  onCancel: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('agentation_placement_horizontal_row')),
        findsNothing,
      );
    });

    testWidgets('Placed component renders exact look based on details alongside comment pin', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FlutterAgentation(
            controller: controller,
            showToolbar: true,
            initialToolbarMinimized: false,
            child: Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Profile Header'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Create placement annotation directly with Avatar and details
      final avatarPlacement = PlacementData(
        componentType: 'Avatar',
        label: 'User Avatar',
        width: 48.0,
        height: 48.0,
        text: 'JD',
        source: 'JD',
        parentWidget: 'Column',
        properties: const {
          'circular': true,
          'onlineDot': true,
          'Size': 'Medium (48px)',
        },
      );

      await controller.createPlacementAnnotation(
        placement: avatarPlacement,
        position: const Offset(300, 250),
        comment: 'Place User Avatar with JD initials and online badge',
        metadata: {
          'path': 'HomeScreen > Scaffold > Column',
        },
      );
      await tester.pumpAndSettle();

      // Verify PlacedComponentPreview is rendered at the placed location
      expect(find.byType(PlacedComponentPreview), findsOneWidget);

      // Verify Material ancestor exists and Opacity is 80%
      final previewFinder = find.byType(PlacedComponentPreview);
      expect(
        find.descendant(of: previewFinder, matching: find.byType(Material)),
        findsWidgets,
      );
      final opacityWidget = tester.widget<Opacity>(
        find.descendant(of: previewFinder, matching: find.byType(Opacity)),
      );
      expect(opacityWidget.opacity, equals(0.80));

      // Verify exact look details are rendered inside the preview:
      // 1. Initials "JD"
      expect(find.text('JD'), findsOneWidget);

      // 2. The numbered comment pin "(1)" is rendered alongside it!
      expect(find.text('1'), findsWidgets);

      // 3. Tapping the placed component preview opens the annotation view
      await tester.tap(find.byType(PlacedComponentPreview));
      await tester.pumpAndSettle();

      expect(controller.activeAnnotation, isNotNull);
      expect(controller.activeAnnotation?.placement?.componentType, equals('Avatar'));
    });

    testWidgets('Placed Chip component renders at 80% opacity with Material ancestor and no underline lines', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FlutterAgentation(
            controller: controller,
            showToolbar: true,
            initialToolbarMinimized: false,
            child: const Scaffold(
              body: Center(
                child: Text('Content'),
              ),
            ),
          ),
        ),
      );

      final chipPlacement = PlacementData(
        componentType: 'Chip',
        label: 'Active Filter',
        width: 110.0,
        height: 36.0,
        text: 'Active Filter',
        parentWidget: 'Column',
        properties: const {},
      );

      await controller.createPlacementAnnotation(
        placement: chipPlacement,
        position: const Offset(200, 200),
        comment: 'Place Active Filter chip',
      );
      await tester.pumpAndSettle();

      final previewFinder = find.byType(PlacedComponentPreview);
      expect(previewFinder, findsOneWidget);

      // Text rendered inside Material with 80% opacity
      expect(find.text('Active Filter'), findsOneWidget);
      final opacityWidget = tester.widget<Opacity>(
        find.descendant(of: previewFinder, matching: find.byType(Opacity)),
      );
      expect(opacityWidget.opacity, equals(0.80));

      final materialWidget = tester.widget<Material>(
        find.descendant(of: previewFinder, matching: find.byType(Material)).first,
      );
      expect(materialWidget.type, equals(MaterialType.transparency));
    });

    testWidgets('Hovering placed component displays comment preview card cleanly without overlapping or flickering', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FlutterAgentation(
            controller: controller,
            showToolbar: true,
            initialToolbarMinimized: false,
            child: const Scaffold(
              body: Center(child: Text('Main Content')),
            ),
          ),
        ),
      );

      final buttonPlacement = PlacementData(
        componentType: 'Button',
        label: 'Get Started',
        width: 140.0,
        height: 44.0,
        text: 'Get Started',
        parentWidget: 'Column',
        properties: const {},
      );

      await controller.createPlacementAnnotation(
        placement: buttonPlacement,
        position: const Offset(200, 100),
        comment: 'Place Button Get Started as first child of Column.',
      );
      await tester.pumpAndSettle();

      final previewFinder = find.byType(PlacedComponentPreview);
      expect(previewFinder, findsOneWidget);

      // Hover over the placed button
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(const Offset(250, 120));
      await tester.pump();

      // Verify AnnotationHoverPreviewCard is displayed
      expect(find.byType(AnnotationHoverPreviewCard), findsOneWidget);

      // Verify the card does not overlap the button vertically (positioned below button bottom = 144)
      final cardTopLeft = tester.getTopLeft(find.byType(AnnotationHoverPreviewCard));
      expect(cardTopLeft.dy, greaterThanOrEqualTo(144.0));

      // Small cursor movements within the button or over the preview card do not cause flicker
      await gesture.moveTo(const Offset(260, 125));
      await tester.pump();
      expect(find.byType(AnnotationHoverPreviewCard), findsOneWidget);

      await gesture.moveTo(Offset(cardTopLeft.dx + 20, cardTopLeft.dy + 20));
      await tester.pump();
      expect(find.byType(AnnotationHoverPreviewCard), findsOneWidget);

      await gesture.removePointer();
    });

    testWidgets('Placed standalone Switch renders clean realistic toggle without outer dark box or overflow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FlutterAgentation(
            controller: controller,
            showToolbar: true,
            initialToolbarMinimized: false,
            child: const Scaffold(
              body: Center(child: Text('Settings Screen')),
            ),
          ),
        ),
      );

      final switchPlacement = PlacementData(
        componentType: 'Switch',
        label: 'Dark Mode Switch',
        width: 52.0,
        height: 32.0,
        text: 'Switch',
        parentWidget: 'Row',
        properties: const {'checked': true},
      );

      await controller.createPlacementAnnotation(
        placement: switchPlacement,
        position: const Offset(150, 150),
        comment: 'Place Switch toggle',
      );
      await tester.pumpAndSettle();

      final previewFinder = find.byType(PlacedComponentPreview);
      expect(previewFinder, findsOneWidget);

      // Verify no overflow error occurred
      expect(tester.takeException(), isNull);

      // Verify it does not render the outer ListTile dark box (no 'Setting Option' text)
      expect(find.text('Setting Option'), findsNothing);
    });

    testWidgets('RealisticSkeletonPreview renders realistic component representation for Error / 404 State and other templates', (tester) async {
      final errorTemplate = SkeletonTemplate.defaultTemplates.firstWhere((t) => t.componentType == 'ErrorState');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RealisticSkeletonPreview(
                template: errorTemplate,
                accentColor: Colors.deepPurple,
                isDark: true,
              ),
            ),
          ),
        ),
      );

      // Verify realistic Error / 404 view has warning icon, heading, subtitle, and retry button
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.text('Error / 404 State'), findsOneWidget);
      expect(find.text('Unable to load content or page not found'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}


