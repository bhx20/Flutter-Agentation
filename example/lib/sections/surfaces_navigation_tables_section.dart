import 'package:flutter/material.dart';
import '../models/widget_category.dart';
import '../widgets/category_header.dart';
import '../widgets/widget_card.dart';

/// Showcases:
/// Navigation (9): AppBar, SliverAppBar, NavigationBar, NavigationRail, NavigationDrawer,
/// BottomNavigationBar, Drawer, TabBar, TabBarView
/// Cards (6): Card, ListTile, ExpansionTile, ExpansionPanelList, GridTile, GridTileBar
/// Tables (3): Table, TableRow, TableCell
/// Dividers (2): Divider, VerticalDivider
class SurfacesNavigationTablesSection extends StatefulWidget {
  const SurfacesNavigationTablesSection({super.key});

  @override
  State<SurfacesNavigationTablesSection> createState() =>
      _SurfacesNavigationTablesSectionState();
}

class _SurfacesNavigationTablesSectionState
    extends State<SurfacesNavigationTablesSection> {
  final ValueNotifier<int> _navIndexNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> _isExpandedPanelNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _navIndexNotifier.dispose();
    _isExpandedPanelNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CategoryHeader(
          category: WidgetCategory.surfacesNav,
          itemCount: 20,
        ),

        // 1. Navigation: TabBar, TabBarView, AppBar
        WidgetCard(
          title: 'Bars & Tabs Navigation',
          subtitle: 'AppBar, TabBar, TabBarView',
          badgeColor: const Color(0xFF6366F1),
          child: Column(
            children: [
              AppBar(
                title: const Text('Mini AppBar Preview', style: TextStyle(fontSize: 14)),
                automaticallyImplyLeading: false,
                elevation: 1,
                actions: [
                  IconButton(icon: const Icon(Icons.tune, size: 18), onPressed: () {}),
                ],
              ),
              const SizedBox(height: 10.0),
              DefaultTabController(
                length: 2,
                child: Column(
                  children: const [
                    TabBar(
                      tabs: [
                        Tab(text: 'Tab One', icon: Icon(Icons.view_agenda, size: 16)),
                        Tab(text: 'Tab Two', icon: Icon(Icons.dashboard, size: 16)),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                      child: TabBarView(
                        children: [
                          Center(child: Text('TabBarView Content 1', style: TextStyle(fontSize: 11))),
                          Center(child: Text('TabBarView Content 2', style: TextStyle(fontSize: 11))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 2. Navigation: NavigationBar, BottomNavigationBar, NavigationRail
        WidgetCard(
          title: 'Bottom & Rail Navigation',
          subtitle: 'NavigationBar, BottomNavigationBar, NavigationRail',
          badgeColor: const Color(0xFF10B981),
          child: ValueListenableBuilder<int>(
            valueListenable: _navIndexNotifier,
            builder: (context, idx, _) {
              return Column(
                children: [
                  NavigationBar(
                    selectedIndex: idx,
                    onDestinationSelected: (i) => _navIndexNotifier.value = i,
                    destinations: const [
                      NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
                      NavigationDestination(icon: Icon(Icons.search_outlined), label: 'Explore'),
                      NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  BottomNavigationBar(
                    currentIndex: idx,
                    onTap: (i) => _navIndexNotifier.value = i,
                    items: const [
                      BottomNavigationBarItem(icon: Icon(Icons.feed_outlined), label: 'Feed'),
                      BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: 'Saved'),
                      BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Config'),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  SizedBox(
                    height: 200,
                    child: NavigationRail(
                      selectedIndex: idx,
                      onDestinationSelected: (i) => _navIndexNotifier.value = i,
                      labelType: NavigationRailLabelType.all,
                      destinations: const [
                        NavigationRailDestination(icon: Icon(Icons.grid_view), label: Text('Rail A')),
                        NavigationRailDestination(icon: Icon(Icons.widgets), label: Text('Rail B')),
                        NavigationRailDestination(icon: Icon(Icons.layers), label: Text('Rail C')),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // 3. Drawers: Drawer, NavigationDrawer
        WidgetCard(
          title: 'Drawer & NavigationDrawer Previews',
          subtitle: 'Drawer, NavigationDrawer',
          badgeColor: const Color(0xFFF59E0B),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 140,
                  child: Drawer(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: const [
                        DrawerHeader(
                          decoration: BoxDecoration(color: Color(0xFF6366F1)),
                          child: Text('Drawer Header', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                        ListTile(dense: true, title: Text('Drawer Item 1', style: TextStyle(fontSize: 11))),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: SizedBox(
                  height: 140,
                  child: NavigationDrawer(
                    children: const [
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 12, 16, 6),
                        child: Text('NavigationDrawer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                      NavigationDrawerDestination(icon: Icon(Icons.inbox), label: Text('Inbox')),
                      NavigationDrawerDestination(icon: Icon(Icons.send), label: Text('Outbox')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 4. Cards: Card, ListTile, ExpansionTile, ExpansionPanelList
        WidgetCard(
          title: 'Surfaces & ListTiles',
          subtitle: 'Card, ListTile, ExpansionTile, ExpansionPanelList',
          badgeColor: const Color(0xFF8B5CF6),
          child: Column(
            children: [
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.layers, color: Color(0xFF8B5CF6)),
                  title: const Text('ListTile inside Card', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Interactive row structure', style: TextStyle(fontSize: 10)),
                  trailing: const Icon(Icons.chevron_right, size: 16),
                  onTap: () {},
                ),
              ),
              const ExpansionTile(
                title: Text('ExpansionTile Preview', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Expanded child items with full hierarchy inspection.', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _isExpandedPanelNotifier,
                builder: (context, isExpanded, _) {
                  return ExpansionPanelList(
                    expansionCallback: (panelIndex, isCurrentlyExpanded) {
                      _isExpandedPanelNotifier.value = isCurrentlyExpanded;
                    },
                    children: [
                      ExpansionPanel(
                        isExpanded: isExpanded,
                        headerBuilder: (context, isOpen) => const ListTile(
                          dense: true,
                          title: Text('ExpansionPanelList Header', style: TextStyle(fontSize: 11)),
                        ),
                        body: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('ExpansionPanel body contents', style: TextStyle(fontSize: 10)),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        // 5. GridTile & GridTileBar
        WidgetCard(
          title: 'GridTile & GridTileBar',
          subtitle: 'Header/Footer styled image grid tiles',
          badgeColor: const Color(0xFFEC4899),
          child: SizedBox(
            height: 90,
            child: GridTile(
              header: const GridTileBar(
                backgroundColor: Colors.black45,
                title: Text('GridTile Header', style: TextStyle(fontSize: 10)),
              ),
              footer: const GridTileBar(
                backgroundColor: Colors.black54,
                title: Text('GridTileBar Footer', style: TextStyle(fontSize: 10)),
                trailing: Icon(Icons.favorite_border, color: Colors.white, size: 14),
              ),
              child: Container(
                color: const Color(0xFFEC4899).withValues(alpha: 0.3),
                alignment: Alignment.center,
                child: const Text('GridTile Body', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ),
          ),
        ),

        // 6. Table, TableRow, TableCell, Divider, VerticalDivider
        WidgetCard(
          title: 'Tables & Dividers',
          subtitle: 'Table, TableRow, TableCell, Divider, VerticalDivider',
          badgeColor: const Color(0xFF06B6D4),
          child: Column(
            children: [
              Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                children: const [
                  TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Text('TableCell 1', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Text('TableCell 2', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Text('Row 2 Cell A', style: TextStyle(fontSize: 10)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Text('Row 2 Cell B', style: TextStyle(fontSize: 10)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              const Divider(thickness: 1.5),
              const SizedBox(height: 4.0),
              SizedBox(
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Left Item', style: TextStyle(fontSize: 10)),
                    VerticalDivider(thickness: 1.5),
                    Text('Right Item', style: TextStyle(fontSize: 10)),
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
