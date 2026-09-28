import 'package:flutter/material.dart';
import '../models/widget_category.dart';
import '../widgets/category_header.dart';
import '../widgets/widget_card.dart';

/// Showcases:
/// Buttons (8): ElevatedButton, FilledButton, FilledButton.tonal, OutlinedButton,
/// TextButton, FloatingActionButton, FloatingActionButton.extended, SegmentedButton
/// Chips (6): Chip, ActionChip, ChoiceChip, FilterChip, InputChip, RawChip
/// Menus (5): PopupMenuButton, MenuAnchor, MenuBar, MenuItemButton, SubmenuButton
class ButtonsSection extends StatefulWidget {
  const ButtonsSection({super.key});

  @override
  State<ButtonsSection> createState() => _ButtonsSectionState();
}

class _ButtonsSectionState extends State<ButtonsSection> {
  final ValueNotifier<String> _segmentedNotifier = ValueNotifier<String>('day');
  final ValueNotifier<bool> _choiceSelectedNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _filterSelectedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _menuSelectionNotifier = ValueNotifier<String>('None');

  @override
  void dispose() {
    _segmentedNotifier.dispose();
    _choiceSelectedNotifier.dispose();
    _filterSelectedNotifier.dispose();
    _menuSelectionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CategoryHeader(
          category: WidgetCategory.buttons,
          itemCount: 19,
        ),

        // 1. ElevatedButton ('Primary Action'), OutlinedButton, FilledButton, FilledButton.tonal, TextButton
        WidgetCard(
          title: 'Standard Buttons',
          subtitle: 'ElevatedButton, FilledButton, FilledButton.tonal, OutlinedButton, TextButton',
          badgeColor: const Color(0xFF6366F1),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      key: const ValueKey('submit_button'),
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                      child: const Text('Primary Action'),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                      child: const Text('OutlinedButton'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  FilledButton(
                    onPressed: () {},
                    child: const Text('FilledButton'),
                  ),
                  FilledButton.tonal(
                    onPressed: () {},
                    child: const Text('FilledButton.tonal'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('TextButton'),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 2. Floating Action Buttons & Segmented Button
        WidgetCard(
          title: 'FAB & Segmented Button',
          subtitle: 'FloatingActionButton, FloatingActionButton.extended, SegmentedButton',
          badgeColor: const Color(0xFF10B981),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'fab_small_demo',
                    onPressed: () {},
                    child: const Icon(Icons.add),
                  ),
                  FloatingActionButton(
                    heroTag: 'fab_regular_demo',
                    onPressed: () {},
                    child: const Icon(Icons.edit),
                  ),
                  FloatingActionButton.extended(
                    heroTag: 'fab_extended_demo',
                    onPressed: () {},
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Extended FAB'),
                  ),
                ],
              ),
              const SizedBox(height: 14.0),
              ValueListenableBuilder<String>(
                valueListenable: _segmentedNotifier,
                builder: (context, currentSegment, _) {
                  return SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'day', label: Text('Day'), icon: Icon(Icons.calendar_today, size: 14)),
                      ButtonSegment(value: 'week', label: Text('Week'), icon: Icon(Icons.view_week, size: 14)),
                      ButtonSegment(value: 'month', label: Text('Month'), icon: Icon(Icons.calendar_month, size: 14)),
                    ],
                    selected: {currentSegment},
                    onSelectionChanged: (newSelection) {
                      _segmentedNotifier.value = newSelection.first;
                    },
                  );
                },
              ),
            ],
          ),
        ),

        // 3. Chips: Chip, ActionChip, ChoiceChip, FilterChip, InputChip, RawChip
        WidgetCard(
          title: 'Chips Catalog',
          subtitle: 'Chip, ActionChip, ChoiceChip, FilterChip, InputChip, RawChip',
          badgeColor: const Color(0xFFF59E0B),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              const Chip(
                avatar: Icon(Icons.label, size: 14),
                label: Text('Chip', style: TextStyle(fontSize: 11)),
              ),
              ActionChip(
                avatar: const Icon(Icons.bolt, size: 14, color: Color(0xFFF59E0B)),
                label: const Text('ActionChip', style: TextStyle(fontSize: 11)),
                onPressed: () {},
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _choiceSelectedNotifier,
                builder: (context, isSelected, _) {
                  return ChoiceChip(
                    label: const Text('ChoiceChip', style: TextStyle(fontSize: 11)),
                    selected: isSelected,
                    onSelected: (val) => _choiceSelectedNotifier.value = val,
                  );
                },
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _filterSelectedNotifier,
                builder: (context, isSelected, _) {
                  return FilterChip(
                    label: const Text('FilterChip', style: TextStyle(fontSize: 11)),
                    selected: isSelected,
                    onSelected: (val) => _filterSelectedNotifier.value = val,
                  );
                },
              ),
              InputChip(
                avatar: const CircleAvatar(child: Text('IC', style: TextStyle(fontSize: 9))),
                label: const Text('InputChip', style: TextStyle(fontSize: 11)),
                onDeleted: () {},
              ),
              RawChip(
                label: const Text('RawChip', style: TextStyle(fontSize: 11)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ],
          ),
        ),

        // 4. Menus: PopupMenuButton, MenuAnchor, MenuBar, MenuItemButton, SubmenuButton
        WidgetCard(
          title: 'Menus & Navigation Dropdowns',
          subtitle: 'PopupMenuButton, MenuAnchor, MenuBar, MenuItemButton, SubmenuButton',
          badgeColor: const Color(0xFF8B5CF6),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  PopupMenuButton<String>(
                    onSelected: (val) => _menuSelectionNotifier.value = val,
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'Copy', child: Text('Copy')),
                      const PopupMenuItem(value: 'Cut', child: Text('Cut')),
                      const PopupMenuItem(value: 'Paste', child: Text('Paste')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0x228B5CF6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.more_vert, size: 16, color: Color(0xFF8B5CF6)),
                          SizedBox(width: 4),
                          Text('PopupMenu', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  MenuAnchor(
                    menuChildren: [
                      MenuItemButton(
                        onPressed: () => _menuSelectionNotifier.value = 'Profile',
                        child: const Text('Profile'),
                      ),
                      SubmenuButton(
                        menuChildren: [
                          MenuItemButton(
                            onPressed: () => _menuSelectionNotifier.value = 'Notifications',
                            child: const Text('Notifications'),
                          ),
                          MenuItemButton(
                            onPressed: () => _menuSelectionNotifier.value = 'Privacy',
                            child: const Text('Privacy'),
                          ),
                        ],
                        child: const Text('Preferences'),
                      ),
                    ],
                    builder: (context, controller, child) {
                      return OutlinedButton.icon(
                        icon: const Icon(Icons.menu, size: 14),
                        label: const Text('MenuAnchor', style: TextStyle(fontSize: 11)),
                        onPressed: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              MenuBar(
                children: [
                  SubmenuButton(
                    menuChildren: [
                      MenuItemButton(
                        onPressed: () => _menuSelectionNotifier.value = 'New File',
                        child: const Text('New File'),
                      ),
                      MenuItemButton(
                        onPressed: () => _menuSelectionNotifier.value = 'Save File',
                        child: const Text('Save File'),
                      ),
                    ],
                    child: const Text('File'),
                  ),
                  SubmenuButton(
                    menuChildren: [
                      MenuItemButton(
                        onPressed: () => _menuSelectionNotifier.value = 'Undo',
                        child: const Text('Undo'),
                      ),
                      MenuItemButton(
                        onPressed: () => _menuSelectionNotifier.value = 'Redo',
                        child: const Text('Redo'),
                      ),
                    ],
                    child: const Text('Edit'),
                  ),
                ],
              ),
              const SizedBox(height: 6.0),
              ValueListenableBuilder<String>(
                valueListenable: _menuSelectionNotifier,
                builder: (context, selection, _) {
                  return Text('Selected: $selection', style: const TextStyle(fontSize: 10, color: Colors.grey));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
