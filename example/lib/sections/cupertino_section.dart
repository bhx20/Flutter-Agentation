// ignore_for_file: deprecated_member_use
import 'package:flutter/cupertino.dart';
import '../models/widget_category.dart';
import '../widgets/category_header.dart';
import '../widgets/widget_card.dart';

/// Showcases all Cupertino (iOS) widgets:
/// Navigation (3): CupertinoNavigationBar, CupertinoSliverNavigationBar, CupertinoPageScaffold
/// Buttons (2): CupertinoButton, CupertinoButton.filled
/// Input (2): CupertinoTextField, CupertinoSearchTextField
/// Controls (4): CupertinoSwitch, CupertinoCheckbox, CupertinoRadio, CupertinoSlider
/// Pickers (3): CupertinoPicker, CupertinoDatePicker, CupertinoTimerPicker
/// Dialogs (2): CupertinoAlertDialog, CupertinoActionSheet
/// Lists (4): CupertinoListTile, CupertinoListSection, CupertinoFormRow, CupertinoFormSection
/// Tabs (3): CupertinoTabBar, CupertinoTabScaffold, CupertinoTabView
/// Progress (2): CupertinoActivityIndicator, CupertinoLinearActivityIndicator
/// Scroll (2): CupertinoScrollbar, CupertinoSliverRefreshControl
/// Other (2): CupertinoContextMenu, CupertinoMagnifier
class CupertinoSection extends StatefulWidget {
  const CupertinoSection({super.key});

  @override
  State<CupertinoSection> createState() => _CupertinoSectionState();
}

class _CupertinoSectionState extends State<CupertinoSection> {
  final ValueNotifier<bool> _switchNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _checkboxNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<int> _radioNotifier = ValueNotifier<int>(1);
  final ValueNotifier<double> _sliderNotifier = ValueNotifier<double>(50.0);
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _switchNotifier.dispose();
    _checkboxNotifier.dispose();
    _radioNotifier.dispose();
    _sliderNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CategoryHeader(
          category: WidgetCategory.cupertino,
          itemCount: 29,
        ),

        // 1. Navigation: CupertinoPageScaffold, CupertinoNavigationBar, CupertinoSliverNavigationBar
        WidgetCard(
          title: 'Cupertino Navigation & Scaffold',
          subtitle: 'CupertinoNavigationBar, CupertinoSliverNavigationBar, CupertinoPageScaffold',
          badgeColor: const Color(0xFF007AFF),
          child: Column(
            children: [
              SizedBox(
                height: 70,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const CupertinoPageScaffold(
                    navigationBar: CupertinoNavigationBar(
                      middle: Text('CupertinoNavigationBar', style: TextStyle(fontSize: 12)),
                      automaticallyImplyLeading: false,
                    ),
                    child: Center(child: Text('CupertinoPageScaffold', style: TextStyle(fontSize: 11))),
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              SizedBox(
                height: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomScrollView(
                    slivers: const [
                      CupertinoSliverNavigationBar(
                        largeTitle: Text('SliverNavBar', style: TextStyle(fontSize: 16)),
                        automaticallyImplyLeading: false,
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 20)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. Buttons: CupertinoButton, CupertinoButton.filled
        WidgetCard(
          title: 'Cupertino Buttons',
          subtitle: 'CupertinoButton, CupertinoButton.filled',
          badgeColor: const Color(0xFF007AFF),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                onPressed: () {},
                child: const Text('CupertinoButton', style: TextStyle(fontSize: 12)),
              ),
              CupertinoButton.filled(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                onPressed: () {},
                child: const Text('CupertinoButton.filled', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),

        // 3. Input: CupertinoTextField, CupertinoSearchTextField
        WidgetCard(
          title: 'Cupertino Inputs',
          subtitle: 'CupertinoTextField, CupertinoSearchTextField',
          badgeColor: const Color(0xFF34C759),
          child: Column(
            children: const [
              CupertinoTextField(
                placeholder: 'CupertinoTextField placeholder',
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              SizedBox(height: 8.0),
              CupertinoSearchTextField(
                placeholder: 'CupertinoSearchTextField',
              ),
            ],
          ),
        ),

        // 4. Controls: CupertinoSwitch, CupertinoCheckbox, CupertinoRadio, CupertinoSlider
        WidgetCard(
          title: 'Cupertino Controls',
          subtitle: 'CupertinoSwitch, CupertinoCheckbox, CupertinoRadio, CupertinoSlider',
          badgeColor: const Color(0xFFFF9500),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: _switchNotifier,
                        builder: (context, val, _) => CupertinoSwitch(
                          value: val,
                          onChanged: (newVal) => _switchNotifier.value = newVal,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('Switch', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                  Row(
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: _checkboxNotifier,
                        builder: (context, val, _) => CupertinoCheckbox(
                          value: val,
                          onChanged: (newVal) => _checkboxNotifier.value = newVal ?? false,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('Checkbox', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                  Row(
                    children: [
                      ValueListenableBuilder<int>(
                        valueListenable: _radioNotifier,
                        builder: (context, val, _) => CupertinoRadio<int>(
                          value: 1,
                          groupValue: val,
                          onChanged: (newVal) => _radioNotifier.value = newVal ?? 1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('Radio', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ],
              ),
              ValueListenableBuilder<double>(
                valueListenable: _sliderNotifier,
                builder: (context, val, _) => CupertinoSlider(
                  value: val,
                  min: 0,
                  max: 100,
                  onChanged: (newVal) => _sliderNotifier.value = newVal,
                ),
              ),
            ],
          ),
        ),

        // 5. Pickers: CupertinoPicker, CupertinoDatePicker, CupertinoTimerPicker
        WidgetCard(
          title: 'Cupertino Pickers',
          subtitle: 'CupertinoPicker, CupertinoDatePicker, CupertinoTimerPicker',
          badgeColor: const Color(0xFFAF52DE),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 70,
                      child: CupertinoPicker(
                        itemExtent: 24,
                        onSelectedItemChanged: (_) {},
                        children: const [
                          Text('Option A', style: TextStyle(fontSize: 11)),
                          Text('Option B', style: TextStyle(fontSize: 11)),
                          Text('Option C', style: TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 70,
                      child: CupertinoTimerPicker(
                        mode: CupertinoTimerPickerMode.ms,
                        onTimerDurationChanged: (_) {},
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              SizedBox(
                height: 75,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: DateTime(2026, 9, 28),
                  onDateTimeChanged: (_) {},
                ),
              ),
            ],
          ),
        ),

        // 6. Dialogs: CupertinoAlertDialog, CupertinoActionSheet
        WidgetCard(
          title: 'Cupertino Dialogs & ActionSheet',
          subtitle: 'CupertinoAlertDialog, CupertinoActionSheet',
          badgeColor: const Color(0xFFFF2D55),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: CupertinoColors.systemGrey5,
                onPressed: () {
                  showCupertinoDialog(
                    context: context,
                    builder: (ctx) => CupertinoAlertDialog(
                      title: const Text('CupertinoAlertDialog'),
                      content: const Text('iOS-style modal alert dialog'),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                        CupertinoDialogAction(
                          isDefaultAction: true,
                          child: const Text('OK'),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Alert Dialog', style: TextStyle(color: CupertinoColors.activeBlue, fontSize: 11)),
              ),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: CupertinoColors.systemGrey5,
                onPressed: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (ctx) => CupertinoActionSheet(
                      title: const Text('CupertinoActionSheet'),
                      message: const Text('Select an action'),
                      actions: [
                        CupertinoActionSheetAction(
                          child: const Text('Option 1'),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                      cancelButton: CupertinoActionSheetAction(
                        isDestructiveAction: true,
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ),
                  );
                },
                child: const Text('Action Sheet', style: TextStyle(color: CupertinoColors.activeBlue, fontSize: 11)),
              ),
            ],
          ),
        ),

        // 7. Lists & Forms: CupertinoListTile, CupertinoListSection, CupertinoFormRow, CupertinoFormSection
        WidgetCard(
          title: 'Cupertino Lists & Form Sections',
          subtitle: 'CupertinoListTile, CupertinoListSection, CupertinoFormRow, CupertinoFormSection',
          badgeColor: const Color(0xFF5856D6),
          child: Column(
            children: [
              CupertinoListSection.insetGrouped(
                margin: EdgeInsets.zero,
                children: const [
                  CupertinoListTile(
                    title: Text('CupertinoListTile 1', style: TextStyle(fontSize: 11)),
                    trailing: CupertinoListTileChevron(),
                  ),
                  CupertinoListTile(
                    title: Text('CupertinoListTile 2', style: TextStyle(fontSize: 11)),
                    trailing: CupertinoListTileChevron(),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              CupertinoFormSection.insetGrouped(
                margin: EdgeInsets.zero,
                children: const [
                  CupertinoFormRow(
                    prefix: Text('FormRow A', style: TextStyle(fontSize: 11)),
                    child: Text('Value A', style: TextStyle(fontSize: 11, color: CupertinoColors.systemGrey)),
                  ),
                  CupertinoFormRow(
                    prefix: Text('FormRow B', style: TextStyle(fontSize: 11)),
                    child: Text('Value B', style: TextStyle(fontSize: 11, color: CupertinoColors.systemGrey)),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 8. Tabs: CupertinoTabBar, CupertinoTabScaffold, CupertinoTabView
        WidgetCard(
          title: 'Cupertino Tab Scaffold',
          subtitle: 'CupertinoTabBar, CupertinoTabScaffold, CupertinoTabView',
          badgeColor: const Color(0xFF007AFF),
          child: SizedBox(
            height: 90,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CupertinoTabScaffold(
                tabBar: CupertinoTabBar(
                  items: const [
                    BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
                    BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings), label: 'Settings'),
                  ],
                ),
                tabBuilder: (context, index) {
                  return CupertinoTabView(
                    builder: (context) => Center(
                      child: Text('CupertinoTabView #$index', style: const TextStyle(fontSize: 11)),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // 9. Progress & Scroll: CupertinoActivityIndicator, CupertinoLinearActivityIndicator, CupertinoScrollbar, CupertinoSliverRefreshControl
        WidgetCard(
          title: 'Cupertino Activity, Scroll & Refresh',
          subtitle: 'CupertinoActivityIndicator, CupertinoLinearActivityIndicator, CupertinoScrollbar, CupertinoSliverRefreshControl',
          badgeColor: const Color(0xFF34C759),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  CupertinoActivityIndicator(radius: 12),
                  SizedBox(
                    width: 100,
                    child: CupertinoLinearActivityIndicator(progress: 0.7),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              SizedBox(
                height: 70,
                child: CupertinoScrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      CupertinoSliverRefreshControl(onRefresh: () async {}),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                            child: Text('Scrollbar Item $i', style: const TextStyle(fontSize: 10)),
                          ),
                          childCount: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 10. Other: CupertinoContextMenu, CupertinoMagnifier
        WidgetCard(
          title: 'Cupertino ContextMenu & Magnifier',
          subtitle: 'CupertinoContextMenu, CupertinoMagnifier',
          badgeColor: const Color(0xFFFF9500),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CupertinoContextMenu(
                actions: [
                  CupertinoContextMenuAction(
                    child: const Text('Action A'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Long Press\nContextMenu', style: TextStyle(color: CupertinoColors.white, fontSize: 9), textAlign: TextAlign.center),
                ),
              ),
              SizedBox(
                width: 90,
                height: 45,
                child: Stack(
                  children: [
                    const Center(child: Text('Magnifier Target', style: TextStyle(fontSize: 9))),
                    CupertinoMagnifier(
                      size: const Size(60, 24),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
