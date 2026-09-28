import 'package:flutter/material.dart';
import '../models/widget_category.dart';
import '../widgets/category_header.dart';
import '../widgets/widget_card.dart';

/// Comprehensive showcase of ListTiles, ExpansionTiles, DataTables, and Grids.
class ListsTablesSection extends StatefulWidget {
  const ListsTablesSection({super.key});

  @override
  State<ListsTablesSection> createState() => _ListsTablesSectionState();
}

class _ListsTablesSectionState extends State<ListsTablesSection> {
  bool _switchTileVal = true;
  bool _checkTileVal = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CategoryHeader(
          category: WidgetCategory.lists,
          itemCount: 6,
        ),

        // 1. Nested ListTiles & Interactive Tile Variants
        WidgetCard(
          title: 'ListTile, SwitchListTile & CheckboxListTile',
          subtitle: 'Single-line and multi-line list rows with leading and trailing widgets',
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.help_outline, color: Color(0xFF6366F1)),
                title: const Text('Frequently Asked Questions'),
                subtitle: const Text('Inspect this tile or its individual text/icon children'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(height: 1.0),
              SwitchListTile(
                secondary: const Icon(Icons.notifications_active_outlined, color: Color(0xFF10B981)),
                title: const Text('Realtime Agent Webhook Sync'),
                subtitle: const Text('Stream DOM node mutations to MCP server'),
                value: _switchTileVal,
                activeThumbColor: const Color(0xFF10B981),
                onChanged: (val) => setState(() => _switchTileVal = val),
              ),
              const Divider(height: 1.0),
              CheckboxListTile(
                secondary: const Icon(Icons.security_outlined, color: Color(0xFFF59E0B)),
                title: const Text('Source Location Redaction'),
                subtitle: const Text('Mask proprietary internal file paths in export'),
                value: _checkTileVal,
                activeColor: const Color(0xFFF59E0B),
                onChanged: (val) => setState(() => _checkTileVal = val ?? false),
              ),
            ],
          ),
        ),

        // 2. ExpansionTile
        WidgetCard(
          title: 'ExpansionTile',
          subtitle: 'Collapsible accordion component showing nested child trees',
          padding: EdgeInsets.zero,
          child: ExpansionTile(
            leading: const Icon(Icons.account_tree_outlined, color: Color(0xFF6366F1)),
            title: const Text('Widget Ancestry Inspector'),
            subtitle: const Text('Tap to expand nested children hierarchy'),
            initiallyExpanded: false,
            children: [
              Container(
                color: const Color(0xFFF8FAFC),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: const [
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.subdirectory_arrow_right, size: 18.0),
                      title: Text('RenderParagraph -> TextPainter'),
                    ),
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.subdirectory_arrow_right, size: 18.0),
                      title: Text('RenderPadding -> BoxConstraints'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 3. DataTable
        WidgetCard(
          title: 'DataTable & DataColumns',
          subtitle: 'Structured tabular data with columns and rows',
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Widget', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Inspectable', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('ElevatedButton')),
                  DataCell(Text('Buttons')),
                  DataCell(Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18.0)),
                  DataCell(Text('Ready')),
                ]),
                DataRow(cells: [
                  DataCell(Text('TextFormField')),
                  DataCell(Text('Inputs')),
                  DataCell(Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18.0)),
                  DataCell(Text('Validated')),
                ]),
                DataRow(cells: [
                  DataCell(Text('CustomPaint')),
                  DataCell(Text('Visuals')),
                  DataCell(Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18.0)),
                  DataCell(Text('Active')),
                ]),
              ],
            ),
          ),
        ),

        // 4. Responsive GridView
        WidgetCard(
          title: 'GridView Layout',
          subtitle: 'Multi-column grid items for dashboards and cards',
          child: SizedBox(
            height: 140.0,
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildGridTile('Colors', Icons.palette_outlined, const Color(0xFF6366F1)),
                _buildGridTile('Layers', Icons.layers_outlined, const Color(0xFF10B981)),
                _buildGridTile('Geometry', Icons.aspect_ratio_outlined, const Color(0xFFF59E0B)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridTile(String label, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28.0),
          const SizedBox(height: 6.0),
          Text(
            label,
            style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
