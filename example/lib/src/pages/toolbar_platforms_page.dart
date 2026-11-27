import 'package:flutter/material.dart';
import 'package:example/src/theme/app_dimensions.dart';

import '../constants/app_strings.dart';
import '../theme/app_theme.dart';
import '../theme/app_insets.dart';
import '../theme/app_radii.dart';
import 'package:flutter_agentation/flutter_agentation.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/breakpoints.dart';
import '../utils/clipboard_helper.dart';

class ToolbarPlatformsPage extends StatefulWidget {
  const ToolbarPlatformsPage({super.key});

  @override
  State<ToolbarPlatformsPage> createState() => _ToolbarPlatformsPageState();
}

class _ToolbarPlatformsPageState extends State<ToolbarPlatformsPage> {
  int _selectedStyleIndex = 0;
  int _selectedStateIndex = 0;

  static const String _specJson = '''{
  "jsonrpc": "2.0",
  "method": "agentation/component_drop",
  "params": {
    "kind": "placement_spec",
    "widget": "SkeletonButton",
    "targetSource": "lib/screens/dashboard.dart:64",
    "spec": {
      "variant": "ElevatedButton",
      "intent": "Primary CTA",
      "onPressed": "onSubmitOrder()",
      "stateSource": "ref.read(orderControllerProvider.notifier)",
      "dimensions": { "width": "double.infinity", "height": 48.0 },
      "margin": "AppInsets.t24"
    },
    "spatialHints": {
      "parent": "Column",
      "slotIndex": 3,
      "ancestor": "Scaffold > SafeArea > Padding"
    }
  }
}''';

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final isTablet = Breakpoints.isTablet(context);

    final skeletons = [
      (
        widgetName: 'Widget: SkeletonButton',
        subLeft: 'Elevated Pill Skeleton',
        subRight: 'h: 48 • r: 24',
        type: 0,
      ),
      (
        widgetName: 'Widget: SkeletonInput',
        subLeft: 'Search Field Skeleton',
        subRight: 'w: 100% • h: 42',
        type: 1,
      ),
      (
        widgetName: 'Widget: SkeletonCard',
        subLeft: 'Metric / Stat Card',
        subRight: 'aspect: 16:9 • p: 16',
        type: 2,
      ),
      (
        widgetName: 'Widget: SkeletonAvatar',
        subLeft: 'Profile & Subtitle Tile',
        subRight: 'avatar: 40px • gap: 12',
        type: 3,
      ),
      (
        widgetName: 'Widget: SkeletonListTile',
        subLeft: 'Data Row / Action Tile',
        subRight: 'h: 56 • trailing: 24',
        type: 4,
      ),
      (
        widgetName: 'Widget: SkeletonTabBar',
        subLeft: 'Segmented Bar Skeleton',
        subRight: 'tabs: 3 • h: 36',
        type: 5,
      ),
    ];

    final quickActions = [
      (
        icon: AgentationIcons.pause(size: AppDimensions.d18, color: AppColors.textDark),
        badge: 'P',
        title: 'Pause / Resume',
        desc: 'Freeze running animations via TickerMode',
      ),
      (
        icon: AgentationIcons.eye(size: AppDimensions.d18, color: AppColors.textDark),
        badge: 'H / Alt+V',
        title: 'Eye Visibility',
        desc: 'Toggle comments & pin markers visibility',
      ),
      (
        icon: AgentationIcons.copy(size: AppDimensions.d18, color: AppColors.textDark),
        badge: 'C',
        title: 'Copy Markdown',
        desc: 'Copy annotations as AI-ready Markdown & JSON',
      ),
      (
        icon: AgentationIcons.send(size: AppDimensions.d18, color: AppColors.textDark),
        badge: 'S',
        title: 'Dispatch Send',
        desc: 'Post draft annotations directly to MCP transport',
      ),
      (
        icon: AgentationIcons.trash(size: AppDimensions.d18, color: AppColors.textDark),
        badge: 'X',
        title: 'Trash Markers',
        desc: 'Clear active pins and resolved feedback',
      ),
      (
        icon: AgentationIcons.gear(size: AppDimensions.d18, color: AppColors.textDark),
        badge: 'Gear',
        title: 'Settings',
        desc: 'Configure local daemon port & active webhooks',
      ),
    ];

    final shortcuts = [
      (keys: ['Ctrl+Shift+A', 'Cmd+Shift+A'], desc: 'Toggle Agentation inspection mode'),
      (keys: ['S'], desc: 'Submit draft annotations to agent transport'),
      (keys: ['Ctrl+Shift+F', 'Cmd+Shift+F'], desc: 'Toggle feedback overlay'),
      (keys: ['X'], desc: 'Clear all annotations'),
      (keys: ['Alt+I'], desc: 'Toggle inspect mode'),
      (keys: ['Delete', 'Backspace'], desc: 'Delete selected feedback pin or skeleton'),
      (keys: ['L'], desc: 'Toggle layout wireframing palette'),
      (keys: ['Ctrl+Enter', 'Cmd+Enter'], desc: 'Submit active annotation modal'),
      (keys: ['P'], desc: 'Pause / freeze running animations (TickerMode)'),
      (keys: ['Escape'], desc: 'Close active dialog / clear selection'),
      (keys: ['H / Alt+V'], desc: 'Toggle comments & markers visibility'),
      (keys: ['Ctrl+Z', 'Cmd+Z'], desc: 'Undo last action'),
      (keys: ['C'], desc: 'Copy annotations as Markdown to clipboard'),
      (keys: ['Arrow Keys'], desc: 'Nudge selected marker position'),
    ];

    final platforms = [
      (
        icon: AgentationIcons.layout(size: AppDimensions.d18, color: AppColors.textDark),
        title: 'Desktop',
        sub: 'Windows & macOS',
        desc: 'Direct localhost socket listening on 127.0.0.1:4747 with zero config or bridge dependencies.',
        badge: 'http://127.0.0.1:4747/sse',
        isGreen: true,
      ),
      (
        icon: AgentationIcons.wireframe(size: AppDimensions.d18, color: AppColors.textDark),
        title: 'Linux',
        sub: 'Native Desktop Socket',
        desc: 'Native desktop direct socket on 127.0.0.1:4747 for local engine communication.',
        badge: 'flutter run -d linux',
        isGreen: true,
      ),
      (
        icon: AgentationIcons.component(size: AppDimensions.d18, color: AppColors.textDark),
        title: 'Android',
        sub: 'Device & Emulator',
        desc: 'Automated ADB reverse port forwarding syncing device requests back to workstation daemon.',
        badge: 'adb forward tcp:4747 tcp:4747',
        isGreen: false,
      ),
      (
        icon: AgentationIcons.listSparkle(size: AppDimensions.d18, color: AppColors.textDark),
        title: 'iOS',
        sub: 'Simulator & Device',
        desc: 'Localhost loopback on simulator or local Wi-Fi LAN IP on device with automatic handshake.',
        badge: 'http://<device-ip>:4747/sse',
        isGreen: true,
      ),
      (
        icon: AgentationIcons.eye(size: AppDimensions.d18, color: AppColors.textDark),
        title: 'Web',
        sub: 'Chrome, Edge, Safari',
        desc: 'Background synchronization bridge connecting browser WebSocket/SSE to host terminal daemon.',
        badge: 'dart run flutter_agentation:mcp --port 4747',
        isGreen: false,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: AppDimensions.d16,
          runSpacing: AppDimensions.d8,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.toolbarPlatformsOverline,
                  style: AppTypography.overline,
                ),
                AppDimensions.h6,
                Text(
                  AppStrings.toolbarSubheader,
                  style: isMobile ? AppTypography.h3 : AppTypography.h2,
                ),
              ],
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppDimensions.d480),
              child: const Text(
                '5 interactive inspection modes, rapid action shortcuts, and zero-config local sockets across all 6 Flutter runtime targets.',
                style: AppTypography.bodyMedium,
              ),
            ),
          ],
        ),
        AppDimensions.h28,
        const Divider(color: AppColors.borderSubtle, height: AppDimensions.d1),
        AppDimensions.h28,

        // 1. Flutter Skeleton Wireframe Palette
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: AppDimensions.d7,
                  height: AppDimensions.d7,
                  decoration: const BoxDecoration(color: AppColors.accentBlue, shape: BoxShape.circle),
                ),
                AppDimensions.w8,
                const Flexible(
                  child: Text(
                    'Layout Mode Active • Press L',
                    style: AppTypography.badgeSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            AppDimensions.h8,
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppDimensions.d12,
              runSpacing: AppDimensions.d4,
              children: [
                const Text('Flutter Skeleton Wireframe Palette', style: AppTypography.h3),
                if (!isMobile)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AgentationIcons.layout(size: AppDimensions.d16, color: AppColors.textTertiary),
                      AppDimensions.w4,
                      const Text(
                        'Drag to live screen canvas',
                        style: AppTypography.bodySmallTertiary,
                      ),
                    ],
                  ),
              ],
            ),
            AppDimensions.h6,
            const Text(
              'Component palette with 65+ skeleton types. Drag high-fidelity wireframe structures directly onto live Flutter screens to compose interfaces or communicate design specs to AI agents.',
              style: AppTypography.bodySmallSecondary,
            ),
            AppDimensions.h20,

            // 6 Skeleton Cards Grid (dynamic columns based on viewport)
            isMobile
                ? Column(
                    children: skeletons.map((s) => Padding(padding: AppInsets.b12, child: _buildSkeletonCard(s))).toList(),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = constraints.maxWidth < 640 ? 1 : (constraints.maxWidth < 900 ? 2 : 3);
                      final cardWidth = (constraints.maxWidth - (cols - 1) * 14) / cols;
                      return Wrap(
                        spacing: AppDimensions.d14,
                        runSpacing: AppDimensions.d14,
                        children: skeletons.map((s) {
                          return SizedBox(
                            width: cardWidth,
                            child: _buildSkeletonCard(s),
                          );
                        }).toList(),
                      );
                    },
                  ),
          ],
        ),
        AppDimensions.h48,
        const Divider(color: AppColors.borderSubtle, height: AppDimensions.d1),
        AppDimensions.h28,

        // 2. Counter-Question Dialog Preview on Component Drop
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: AppDimensions.d7,
                  height: AppDimensions.d7,
                  decoration: const BoxDecoration(color: AppColors.accentBlue, shape: BoxShape.circle),
                ),
                AppDimensions.w8,
                const Text(
                  'Canvas Drop Interceptor',
                  style: AppTypography.badgeSmall,
                ),
              ],
            ),
            AppDimensions.h8,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Counter-Question Dialog Preview on Component Drop',
                    style: isMobile ? AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w500) : AppTypography.h3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: AppInsets.h8v4,
                  decoration: BoxDecoration(
                    color: AppColors.pageBackground,
                    borderRadius: AppRadii.rounded6,
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      AgentationIcons.eye(size: AppDimensions.d14, color: AppColors.textDark),
                      AppDimensions.w6,
                      const Text('Zero prompt ambiguity', style: AppTypography.captionDark),
                    ],
                  ),
                ),
              ],
            ),
            AppDimensions.h6,
            const Text(
              'When dragging a skeleton onto the Flutter canvas, Flutter Agentation automatically launches an in-situ specification dialog to clarify widget intent, architecture bindings, and callbacks before piping to the MCP agent.',
              style: AppTypography.bodySmallSecondary,
            ),
            AppDimensions.h20,

            // Two columns: Left dialog mockup, Right JSON envelope
            if (isMobile)
              Column(
                children: [
                  _buildDialogMockup(context),
                  AppDimensions.h16,
                  _buildJsonEnvelope(),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: _buildDialogMockup(context)),
                  AppDimensions.w16,
                  Expanded(flex: 5, child: _buildJsonEnvelope()),
                ],
              ),
          ],
        ),
        AppDimensions.h48,
        const Divider(color: AppColors.borderSubtle, height: AppDimensions.d1),
        AppDimensions.h28,

        // 3. Quick Action Bar Shortcuts (6 in a row)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppDimensions.d12,
              runSpacing: AppDimensions.d4,
              children: const [
                Text(
                  'QUICK ACTION BAR SHORTCUTS',
                  style: AppTypography.overline,
                ),
                Text('Global keyboard shortcuts', style: AppTypography.captionMuted),
              ],
            ),
            AppDimensions.h12,
            if (isMobile)
              Column(
                children: quickActions.map((a) => Padding(padding: AppInsets.b8, child: _buildQuickActionCard(a))).toList(),
              )
            else
              Wrap(
                spacing: AppDimensions.d8,
                runSpacing: AppDimensions.d8,
                children: quickActions.map((a) {
                  return SizedBox(
                    width: isTablet ? AppDimensions.d230 : AppDimensions.d176,
                    child: _buildQuickActionCard(a),
                  );
                }).toList(),
              ),
          ],
        ),
        AppDimensions.h36,

        // 4. Keyboard Shortcuts Reference Table (14 hotkeys in 2 columns)
        Container(
          decoration: BoxDecoration(
            color: AppColors.textWhite,
            borderRadius: AppRadii.rounded8,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: AppInsets.h20v12,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppDimensions.d12,
                  runSpacing: AppDimensions.d4,
                  children: const [
                    Text(
                      'KEYBOARD SHORTCUTS REFERENCE',
                      style: AppTypography.overline,
                    ),
                    Text('14 global hotkeys', style: AppTypography.captionMuted),
                  ],
                ),
              ),
              const Divider(color: AppColors.borderSubtle, height: AppDimensions.d1),
              Padding(
                padding: AppInsets.all16,
                child: isMobile
                    ? Column(
                        children: shortcuts.map((s) => _buildShortcutRow(s)).toList(),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: shortcuts.sublist(0, 7).map((s) => _buildShortcutRow(s)).toList(),
                            ),
                          ),
                          AppDimensions.w20,
                          Expanded(
                            child: Column(
                              children: shortcuts.sublist(7).map((s) => _buildShortcutRow(s)).toList(),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
        AppDimensions.h48,

        // 5. Multi-Platform Transport Matrix
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: AppDimensions.d16,
          runSpacing: AppDimensions.d8,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'TRANSPORT RUNTIME TARGETS',
                  style: AppTypography.overline,
                ),
                AppDimensions.h6,
                Text('Multi-Platform Transport Matrix', style: AppTypography.h3),
              ],
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppDimensions.d440),
              child: const Text(
                'Seamless IPC connection strategies across native desktop, mobile sandboxes, and browser runtimes.',
                style: AppTypography.bodySmallSecondary,
              ),
            ),
          ],
        ),
        AppDimensions.h16,

        Container(
          decoration: BoxDecoration(
            color: AppColors.textWhite,
            borderRadius: AppRadii.rounded8,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            children: platforms.map((p) {
              return Container(
                padding: AppInsets.h20v16,
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
                ),
                child: (isMobile || isTablet)
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: AppDimensions.d6,
                            runSpacing: AppDimensions.d2,
                            children: [
                              p.icon,
                              Text(p.title, style: AppTypography.sectionItemTitlePrimaryBold),
                              Text(p.sub, style: AppTypography.captionMuted),
                            ],
                          ),
                          AppDimensions.h6,
                          Text(p.desc, style: AppTypography.bodySmallSecondary),
                          AppDimensions.h10,
                          _buildTransportBadge(p.badge, p.isGreen),
                        ],
                      )
                    : Row(
                        children: [
                          p.icon,
                          AppDimensions.w12,
                          SizedBox(
                            width: AppDimensions.d160,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.title, style: AppTypography.sectionItemTitlePrimaryBold),
                                Text(p.sub, style: AppTypography.captionMuted),
                              ],
                            ),
                          ),
                          AppDimensions.w12,
                          Expanded(
                            child: Text(p.desc, style: AppTypography.bodySmallSecondary),
                          ),
                          AppDimensions.w16,
                          _buildTransportBadge(p.badge, p.isGreen),
                        ],
                      ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonCard(({String widgetName, String subLeft, String subRight, int type}) s) {
    return Container(
      padding: AppInsets.all14,
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: AppRadii.rounded8,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppDimensions.d4,
            runSpacing: AppDimensions.d4,
            children: [
              Container(
                padding: AppInsets.h6v3,
                decoration: BoxDecoration(
                  color: AppColors.cardBackgroundAlt,
                  borderRadius: AppRadii.rounded4,
                ),
                child: Text(
                  s.widgetName,
                  style: AppTypography.codeMicroBold,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AgentationIcons.layout(size: AppDimensions.d14, color: AppColors.textMuted),
                  AppDimensions.w2,
                  const Text('DRAG', style: AppTypography.badgeTagMuted),
                ],
              ),
            ],
          ),
          AppDimensions.h14,

          // Skeleton visual preview
          Container(
            height: AppDimensions.d64,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.pageBackground,
              borderRadius: AppRadii.rounded6,
              border: Border.all(color: AppColors.cardBackgroundAlt),
            ),
            child: Center(
              child: _buildSkeletonVisual(s.type),
            ),
          ),
          AppDimensions.h12,

          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppDimensions.d4,
            runSpacing: AppDimensions.d4,
            children: [
              Text(s.subLeft, style: AppTypography.captionTertiary),
              Text(s.subRight, style: AppTypography.codeSmallMuted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonVisual(int type) {
    switch (type) {
      case 0: // Button
        return Container(
          padding: AppInsets.h14v8,
          decoration: BoxDecoration(
            color: AppColors.borderSubtle,
            borderRadius: AppRadii.roundedFull,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: AppDimensions.d8, height: AppDimensions.d8, decoration: const BoxDecoration(color: AppColors.textMuted, shape: BoxShape.circle)),
              AppDimensions.w6,
              Container(width: AppDimensions.d44, height: AppDimensions.d6, decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: AppRadii.rounded3)),
            ],
          ),
        );
      case 1: // Input
        return Container(
          width: AppDimensions.d180,
          padding: AppInsets.h10v8,
          decoration: BoxDecoration(
            color: AppColors.textWhite,
            borderRadius: AppRadii.rounded6,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              Container(width: AppDimensions.d8, height: AppDimensions.d8, decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: AppRadii.rounded2)),
              AppDimensions.w8,
              Container(width: AppDimensions.d60, height: AppDimensions.d6, decoration: BoxDecoration(color: AppColors.borderSubtle, borderRadius: AppRadii.rounded3)),
              const Spacer(),
              Container(width: AppDimensions.d6, height: AppDimensions.d6, decoration: const BoxDecoration(color: AppColors.borderLight, shape: BoxShape.circle)),
            ],
          ),
        );
      case 2: // Card
        return Container(
          width: AppDimensions.d180,
          padding: AppInsets.all8,
          decoration: BoxDecoration(
            color: AppColors.textWhite,
            borderRadius: AppRadii.rounded6,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: AppDimensions.d60, height: AppDimensions.d6, decoration: BoxDecoration(color: AppColors.borderSubtle, borderRadius: AppRadii.rounded2)),
              AppDimensions.h6,
              Container(width: AppDimensions.d100, height: AppDimensions.d8, decoration: BoxDecoration(color: AppColors.cardBackgroundAlt, borderRadius: AppRadii.rounded2)),
            ],
          ),
        );
      case 3: // Avatar
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: AppDimensions.d28, height: AppDimensions.d28, decoration: const BoxDecoration(color: AppColors.borderLight, shape: BoxShape.circle)),
            AppDimensions.w8,
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: AppDimensions.d60, height: AppDimensions.d6, decoration: BoxDecoration(color: AppColors.borderSubtle, borderRadius: AppRadii.rounded2)),
                AppDimensions.h4,
                Container(width: AppDimensions.d40, height: AppDimensions.d5, decoration: BoxDecoration(color: AppColors.cardBackgroundAlt, borderRadius: AppRadii.rounded2)),
              ],
            ),
          ],
        );
      case 4: // ListTile
        return Container(
          width: AppDimensions.d190,
          padding: AppInsets.all8,
          decoration: BoxDecoration(
            color: AppColors.textWhite,
            borderRadius: AppRadii.rounded6,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              Container(width: AppDimensions.d20, height: AppDimensions.d20, decoration: BoxDecoration(color: AppColors.borderSubtle, borderRadius: AppRadii.rounded4)),
              AppDimensions.w8,
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: AppDimensions.d50, height: AppDimensions.d5, decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: AppRadii.rounded2)),
                  AppDimensions.h4,
                  Container(width: AppDimensions.d70, height: AppDimensions.d4, decoration: BoxDecoration(color: AppColors.cardBackgroundAlt, borderRadius: AppRadii.rounded2)),
                ],
              ),
              const Spacer(),
              Container(width: AppDimensions.d12, height: AppDimensions.d12, decoration: BoxDecoration(color: AppColors.cardBackgroundAlt, borderRadius: AppRadii.rounded3)),
            ],
          ),
        );
      default: // TabBar
        return Container(
          width: AppDimensions.d180,
          padding: AppInsets.all4,
          decoration: BoxDecoration(
            color: AppColors.borderSubtle,
            borderRadius: AppRadii.rounded6,
          ),
          child: Row(
            children: List.generate(3, (i) {
              return Expanded(
                child: Container(
                  height: AppDimensions.d18,
                  margin: AppInsets.h2,
                  decoration: BoxDecoration(
                    color: i == 0 ? AppColors.cardBackground : Colors.transparent,
                    borderRadius: AppRadii.rounded4,
                  ),
                ),
              );
            }),
          ),
        );
    }
  }

  Widget _buildDialogMockup(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: AppRadii.rounded8,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      padding: AppInsets.all18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppDimensions.d8,
            runSpacing: AppDimensions.d4,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppDimensions.d8,
                children: [
                  AgentationIcons.gear(size: AppDimensions.d16, color: AppColors.textDark),
                  const Text('Component Specification Dialog', style: AppTypography.itemTitleSmall),
                ],
              ),
              Container(
                padding: AppInsets.h6v2,
                decoration: BoxDecoration(
                  color: AppColors.cardBackgroundAlt,
                  borderRadius: AppRadii.rounded4,
                ),
                child: const Text('SkeletonButton • lib/screens/dashboard.dart:64', style: AppTypography.codeMicro),
              ),
            ],
          ),
          AppDimensions.h16,

          // 1. BUTTON INTENT & STYLE VARIANT
          const Text('1. BUTTON INTENT & STYLE VARIANT', style: AppTypography.overlineMini),
          AppDimensions.h8,
          Wrap(
            spacing: AppDimensions.d6,
            runSpacing: AppDimensions.d6,
            children: [
              _buildDialogOption('Elevated Primary', _selectedStyleIndex == 0, () => setState(() => _selectedStyleIndex = 0), isBlack: true),
              _buildDialogOption('Outlined Secondary', _selectedStyleIndex == 1, () => setState(() => _selectedStyleIndex = 1)),
              _buildDialogOption('Filled Tonal', _selectedStyleIndex == 2, () => setState(() => _selectedStyleIndex = 2)),
              _buildDialogOption('Text Only', _selectedStyleIndex == 3, () => setState(() => _selectedStyleIndex = 3)),
            ],
          ),
          AppDimensions.h14,

          // 2. ACTION CALLBACK / ONPRESSED
          const Text('2. ACTION CALLBACK / ONPRESSED', style: AppTypography.overlineMini),
          AppDimensions.h6,
          Container(
            width: double.infinity,
            padding: AppInsets.h10v8,
            decoration: BoxDecoration(
              color: AppColors.pageBackground,
              borderRadius: AppRadii.rounded4,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: const Text(
              'Submit order and trigger payment validation state',
              style: AppTypography.captionCodeDark,
            ),
          ),
          AppDimensions.h14,

          // 3. STATE MANAGEMENT BINDING
          const Text('3. STATE MANAGEMENT BINDING', style: AppTypography.overlineMini),
          AppDimensions.h8,
          Wrap(
            spacing: AppDimensions.d6,
            runSpacing: AppDimensions.d6,
            children: [
              _buildDialogOption('Riverpod Notifier', _selectedStateIndex == 0, () => setState(() => _selectedStateIndex = 0), isBlue: true),
              _buildDialogOption('Bloc / Cubit', _selectedStateIndex == 1, () => setState(() => _selectedStateIndex = 1)),
              _buildDialogOption('ValueNotifier', _selectedStateIndex == 2, () => setState(() => _selectedStateIndex = 2)),
              _buildDialogOption('Ephemeral setState', _selectedStateIndex == 3, () => setState(() => _selectedStateIndex = 3)),
            ],
          ),
          AppDimensions.h14,

          // 4. LAYOUT CONSTRAINTS & PADDING
          const Text('4. LAYOUT CONSTRAINTS & PADDING', style: AppTypography.overlineMini),
          AppDimensions.h6,
          Wrap(
            spacing: AppDimensions.d8,
            runSpacing: AppDimensions.d6,
            children: [
              _buildMiniParam('width: AppDimensions.d100%'),
              _buildMiniParam('height: AppDimensions.d48'),
              _buildMiniParam('margin: AppInsets.t24'),
            ],
          ),
          AppDimensions.h20,

          // Footer
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppDimensions.d12,
            runSpacing: AppDimensions.d8,
            children: [
              const Text('Cancel Placement', style: AppTypography.captionTertiary),
              FilledButton.icon(
                style: AppTheme.actionPrimaryButton,
                onPressed: () {
                  ClipboardHelper.copy(context, _specJson, successMessage: 'Dispatched placement spec to agent');
                },
                icon: AgentationIcons.send(size: AppDimensions.d12, color: AppColors.textWhite),
                label: const Text('Confirm & Dispatch to Agent (Ctrl+Enter)', style: AppTypography.captionBold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDialogOption(String label, bool isSelected, VoidCallback onTap, {bool isBlack = false, bool isBlue = false}) {
    Color bg = AppColors.cardBackground;
    Color fg = AppColors.textCodeDark;
    Color border = AppColors.borderSubtle;

    if (isSelected) {
      if (isBlack) {
        bg = AppColors.textPrimary;
        fg = AppColors.textWhite;
        border = AppColors.textPrimary;
      } else if (isBlue) {
        bg = AppColors.accentBlueSubtle;
        fg = AppColors.accentBlue;
        border = AppColors.accentBlueBorder;
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.rounded4,
      child: Container(
        padding: AppInsets.h10v6,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadii.rounded4,
          border: Border.all(color: border),
        ),
        child: Text(label, style: AppTypography.caption.copyWith(fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400, color: fg)),
      ),
    );
  }

  Widget _buildMiniParam(String text) {
    return Container(
      padding: AppInsets.h8v4,
      decoration: BoxDecoration(
        color: AppColors.pageBackground,
        borderRadius: AppRadii.rounded4,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Text(text, style: AppTypography.codeMicro),
    );
  }

  Widget _buildJsonEnvelope() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: AppRadii.rounded8,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: AppInsets.h14v10,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppDimensions.d8,
              runSpacing: AppDimensions.d4,
              children: [
                const Text('AI AGENT SPEC ENVELOPE', style: AppTypography.overline),
                Container(
                  padding: AppInsets.h6v2,
                  decoration: BoxDecoration(
                    color: AppColors.accentBlueSubtle,
                    borderRadius: AppRadii.rounded4,
                  ),
                  child: const Text('Spec Payload: JSON-RPC 2.0', style: AppTypography.badgeTagBoldBlue),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.borderSubtle, height: AppDimensions.d1),
          Padding(
            padding: AppInsets.all12,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(
                _specJson,
                style: AppTypography.codeSmallDark,
              ),
            ),
          ),
          const Divider(color: AppColors.borderSubtle, height: AppDimensions.d1),
          Padding(
            padding: AppInsets.all12,
            child: Row(
              children: [
                AgentationIcons.listSparkle(size: AppDimensions.d16, color: AppColors.accentBlue),
                AppDimensions.w8,
                const Expanded(
                  child: Text(
                    'Coding agents receive complete architectural context without round-trip ambiguity.',
                    style: AppTypography.captionTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(({Widget icon, String badge, String title, String desc}) a) {
    return Container(
      padding: AppInsets.all14,
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: AppRadii.rounded8,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              a.icon,
              Container(
                padding: AppInsets.h5v2,
                decoration: BoxDecoration(
                  color: AppColors.cardBackgroundAlt,
                  borderRadius: AppRadii.rounded4,
                ),
                child: Text(a.badge, style: AppTypography.codeMicroSecondaryBold),
              ),
            ],
          ),
          AppDimensions.h12,
          Text(a.title, style: AppTypography.itemTitleSmall),
          AppDimensions.h4,
          Text(a.desc, style: AppTypography.captionTertiaryTight),
        ],
      ),
    );
  }

  Widget _buildShortcutRow(({List<String> keys, String desc}) s) {
    return Padding(
      padding: AppInsets.v6,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppDimensions.d8,
        runSpacing: AppDimensions.d4,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: s.keys.map((k) {
              return Container(
                margin: AppInsets.r6,
                padding: AppInsets.h6v3,
                decoration: BoxDecoration(
                  color: AppColors.pageBackground,
                  borderRadius: AppRadii.rounded4,
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Text(
                  k,
                  style: AppTypography.codeMicroCodeDark,
                ),
              );
            }).toList(),
          ),
          Text(
            s.desc,
            style: AppTypography.captionSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildTransportBadge(String badge, bool isGreen) {
    return Container(
      padding: AppInsets.h8v4,
      decoration: BoxDecoration(
        color: AppColors.pageBackground,
        borderRadius: AppRadii.rounded6,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppDimensions.d6,
            height: AppDimensions.d6,
            decoration: BoxDecoration(
              color: isGreen ? AppColors.accentGreen : AppColors.accentBlue,
              shape: BoxShape.circle,
            ),
          ),
          AppDimensions.w6,
          Flexible(
            child: Text(
              badge,
              style: AppTypography.codeSmallCodeDark,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

typedef ToolbarPlatformsSection = ToolbarPlatformsPage;
