import 'package:flutter/material.dart';
import '../models/widget_category.dart';
import '../widgets/category_header.dart';
import '../widgets/widget_card.dart';

/// Comprehensive showcase of Flutter buttons and selection controls.
class ButtonsSection extends StatefulWidget {
  const ButtonsSection({super.key});

  @override
  State<ButtonsSection> createState() => _ButtonsSectionState();
}

class _ButtonsSectionState extends State<ButtonsSection> {
  String _selectedSegment = 'week';
  String _selectedDropdown = 'Standard';
  String _popupSelection = 'None';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CategoryHeader(
          category: WidgetCategory.buttons,
          itemCount: 10,
        ),

        // 1. Primary & Secondary Action Buttons (Required by widget_test)
        WidgetCard(
          title: 'Elevated & Outlined Buttons',
          subtitle: 'Primary call-to-actions with custom styling and elevation',
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
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text('Primary Action'),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const ValueKey('secondary_button'),
                      onPressed: () {},
                      icon: const Icon(Icons.star_outline),
                      label: const Text('Starred Action'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Wrap(
                spacing: 12.0,
                runSpacing: 8.0,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.rocket_launch_outlined, size: 18.0),
                    label: const Text('Launch Mission'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  const ElevatedButton(
                    onPressed: null, // Disabled state
                    child: Text('Disabled State'),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 2. Material 3 Filled & Tonal Buttons
        WidgetCard(
          title: 'Material 3 Filled & Tonal Buttons',
          subtitle: 'FilledButton and FilledButton.tonal variants',
          child: Wrap(
            spacing: 12.0,
            runSpacing: 10.0,
            children: [
              FilledButton(
                onPressed: () {},
                child: const Text('Filled Button'),
              ),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.send_rounded, size: 16.0),
                label: const Text('Send Message'),
              ),
              FilledButton.tonal(
                onPressed: () {},
                child: const Text('Tonal Button'),
              ),
              FilledButton.tonalIcon(
                onPressed: () {},
                icon: const Icon(Icons.bookmark_border_rounded, size: 16.0),
                label: const Text('Save Bookmark'),
              ),
            ],
          ),
        ),

        // 3. Segmented Button
        WidgetCard(
          title: 'SegmentedButton',
          subtitle: 'Single or multi-select tabbed toggle switches',
          child: Center(
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'day',
                  label: Text('Day'),
                  icon: Icon(Icons.calendar_view_day),
                ),
                ButtonSegment(
                  value: 'week',
                  label: Text('Week'),
                  icon: Icon(Icons.calendar_view_week),
                ),
                ButtonSegment(
                  value: 'month',
                  label: Text('Month'),
                  icon: Icon(Icons.calendar_view_month),
                ),
                ButtonSegment(
                  value: 'year',
                  label: Text('Year'),
                  icon: Icon(Icons.calendar_today),
                ),
              ],
              selected: {_selectedSegment},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _selectedSegment = newSelection.first;
                });
              },
            ),
          ),
        ),

        // 4. Icon Buttons & Floating Action Buttons
        WidgetCard(
          title: 'IconButtons & Floating Action Buttons',
          subtitle: 'Standard, filled, tonal, and floating action button variants',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                tooltip: 'Standard IconButton',
                onPressed: () {},
              ),
              IconButton.filled(
                icon: const Icon(Icons.thumb_up_outlined),
                tooltip: 'Filled IconButton',
                onPressed: () {},
              ),
              IconButton.filledTonal(
                icon: const Icon(Icons.share_outlined),
                tooltip: 'Tonal IconButton',
                onPressed: () {},
              ),
              IconButton.outlined(
                icon: const Icon(Icons.bookmark_outline),
                tooltip: 'Outlined IconButton',
                onPressed: () {},
              ),
              FloatingActionButton.small(
                heroTag: 'fab_small_demo',
                onPressed: () {},
                tooltip: 'Small FAB',
                child: const Icon(Icons.add),
              ),
              FloatingActionButton.extended(
                heroTag: 'fab_extended_demo',
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Compose'),
              ),
            ],
          ),
        ),

        // 5. Popup & Dropdown Menus
        WidgetCard(
          title: 'PopupMenuButton & DropdownButtonFormField',
          subtitle: 'Context menus and form selection triggers',
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedDropdown,
                  decoration: InputDecoration(
                    labelText: 'Detail Mode',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Compact', child: Text('Compact View')),
                    DropdownMenuItem(value: 'Standard', child: Text('Standard View')),
                    DropdownMenuItem(value: 'Detailed', child: Text('Detailed View')),
                    DropdownMenuItem(value: 'Forensic', child: Text('Forensic View')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDropdown = val);
                  },
                ),
              ),
              const SizedBox(width: 16.0),
              PopupMenuButton<String>(
                tooltip: 'More actions',
                onSelected: (val) => setState(() => _popupSelection = val),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'Inspect', child: Text('Inspect Element')),
                  const PopupMenuItem(value: 'Duplicate', child: Text('Duplicate Widget')),
                  const PopupMenuItem(value: 'Export', child: Text('Export JSON')),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'Delete',
                    child: Text('Delete Node', style: TextStyle(color: Colors.red)),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _popupSelection == 'None' ? 'Menu Actions' : _popupSelection,
                        style: const TextStyle(
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6.0),
                      const Icon(Icons.arrow_drop_down, color: Color(0xFF6366F1)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 6. Navigation TextButtons (Matching requirements)
        WidgetCard(
          title: 'TextButton Navigation Links',
          subtitle: 'Plain text buttons for lightweight navigation and actions',
          child: Wrap(
            spacing: 12.0,
            runSpacing: 8.0,
            children: [
              TextButton(
                key: const ValueKey('link_blog'),
                onPressed: () {},
                child: const Text('Blog', style: TextStyle(color: Color(0xFF6366F1))),
              ),
              TextButton(
                key: const ValueKey('link_faq'),
                onPressed: () {},
                child: const Text('FAQ', style: TextStyle(color: Color(0xFF6366F1))),
              ),
              TextButton(
                key: const ValueKey('link_docs'),
                onPressed: () {},
                child: const Text('Docs', style: TextStyle(color: Color(0xFF6366F1))),
              ),
              TextButton(
                key: const ValueKey('link_changelog'),
                onPressed: () {},
                child: const Text('Changelog', style: TextStyle(color: Color(0xFF6366F1))),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
