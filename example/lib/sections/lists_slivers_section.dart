import 'package:flutter/material.dart';
import '../models/widget_category.dart';
import '../widgets/category_header.dart';
import '../widgets/widget_card.dart';

/// Showcases:
/// Lists & Grids (7): ListView, GridView, PageView, ListWheelScrollView,
/// ReorderableListView, AnimatedList, CustomScrollView
/// Slivers (13): SliverList, SliverFixedExtentList, SliverPrototypeExtentList,
/// SliverGrid, SliverPadding, SliverToBoxAdapter, SliverFillRemaining,
/// SliverFillViewport, SliverOpacity, SliverVisibility, SliverOffstage,
/// SliverSafeArea, SliverAppBar
class ListsSliversSection extends StatefulWidget {
  const ListsSliversSection({super.key});

  @override
  State<ListsSliversSection> createState() => _ListsSliversSectionState();
}

class _ListsSliversSectionState extends State<ListsSliversSection> {
  final GlobalKey<AnimatedListState> _animListKey = GlobalKey<AnimatedListState>();
  final ValueNotifier<List<String>> _reorderListNotifier = ValueNotifier<List<String>>(['Alpha', 'Beta', 'Gamma']);

  @override
  void dispose() {
    _reorderListNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CategoryHeader(
          category: WidgetCategory.listsSlivers,
          itemCount: 20,
        ),

        // 1. ListView & GridView
        WidgetCard(
          title: 'ListView & GridView',
          subtitle: 'Standard scrolling linear and 2D grid views',
          badgeColor: const Color(0xFF6366F1),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 90,
                  child: ListView.builder(
                    itemCount: 4,
                    itemBuilder: (context, i) => Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      color: const Color(0x1F6366F1),
                      child: Text('ListView Item $i', style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: SizedBox(
                  height: 90,
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    children: List.generate(
                      4,
                      (i) => Container(
                        color: const Color(0x1F10B981),
                        alignment: Alignment.center,
                        child: Text('Grid $i', style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. PageView & ListWheelScrollView
        WidgetCard(
          title: 'PageView & ListWheelScrollView',
          subtitle: 'Horizontal swiping pages and cylindrical 3D wheel list',
          badgeColor: const Color(0xFF10B981),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 80,
                  child: PageView(
                    children: [
                      Container(color: const Color(0x333B82F6), alignment: Alignment.center, child: const Text('PageView Slide 1', style: TextStyle(fontSize: 11))),
                      Container(color: const Color(0x338B5CF6), alignment: Alignment.center, child: const Text('PageView Slide 2', style: TextStyle(fontSize: 11))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: SizedBox(
                  height: 80,
                  child: ListWheelScrollView(
                    itemExtent: 26,
                    children: List.generate(
                      5,
                      (i) => Container(
                        color: const Color(0x22F59E0B),
                        alignment: Alignment.center,
                        child: Text('Wheel Item $i', style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3. ReorderableListView & AnimatedList
        WidgetCard(
          title: 'Reorderable & Animated Lists',
          subtitle: 'ReorderableListView, AnimatedList',
          badgeColor: const Color(0xFFF59E0B),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 100,
                  child: ValueListenableBuilder<List<String>>(
                    valueListenable: _reorderListNotifier,
                    builder: (context, items, _) {
                      return ReorderableListView(
                        shrinkWrap: true,
                        // ignore: deprecated_member_use
                        onReorder: (oldIndex, newIndex) {
                          if (oldIndex < newIndex) newIndex -= 1;
                          final list = List<String>.from(items);
                          final item = list.removeAt(oldIndex);
                          list.insert(newIndex, item);
                          _reorderListNotifier.value = list;
                        },
                        children: [
                          for (int i = 0; i < items.length; i++)
                            Container(
                              key: ValueKey(items[i]),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              margin: const EdgeInsets.only(bottom: 2),
                              color: const Color(0x18F59E0B),
                              child: Text(items[i], style: const TextStyle(fontSize: 10)),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: SizedBox(
                  height: 100,
                  child: AnimatedList(
                    key: _animListKey,
                    initialItemCount: 3,
                    itemBuilder: (context, index, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          margin: const EdgeInsets.only(bottom: 2),
                          color: const Color(0x18EC4899),
                          child: Text('AnimatedList #$index', style: const TextStyle(fontSize: 10)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // 4. CustomScrollView with all 13 Slivers
        WidgetCard(
          title: 'CustomScrollView & 13 Slivers',
          subtitle: 'SliverList, SliverFixedExtentList, SliverPrototypeExtentList, SliverGrid, SliverPadding, SliverToBoxAdapter, SliverFillRemaining, SliverFillViewport, SliverOpacity, SliverVisibility, SliverOffstage, SliverSafeArea, SliverAppBar',
          badgeColor: const Color(0xFF8B5CF6),
          child: SizedBox(
            height: 220,
            child: CustomScrollView(
              slivers: [
                const SliverAppBar(
                  title: Text('SliverAppBar', style: TextStyle(fontSize: 11)),
                  automaticallyImplyLeading: false,
                  pinned: true,
                  toolbarHeight: 32,
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(4.0),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      color: const Color(0x336366F1),
                      padding: const EdgeInsets.all(4),
                      child: const Text('SliverToBoxAdapter in SliverPadding', style: TextStyle(fontSize: 10)),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Container(padding: const EdgeInsets.all(4), color: const Color(0x2210B981), child: const Text('SliverList Row 1', style: TextStyle(fontSize: 10))),
                  ]),
                ),
                SliverFixedExtentList(
                  itemExtent: 24,
                  delegate: SliverChildListDelegate([
                    Container(color: const Color(0x22F59E0B), padding: const EdgeInsets.all(4), child: const Text('SliverFixedExtentList', style: TextStyle(fontSize: 10))),
                  ]),
                ),
                SliverPrototypeExtentList(
                  prototypeItem: const SizedBox(height: 24, child: Text('Proto')),
                  delegate: SliverChildListDelegate([
                    Container(color: const Color(0x22EC4899), padding: const EdgeInsets.all(4), child: const Text('SliverPrototypeExtentList', style: TextStyle(fontSize: 10))),
                  ]),
                ),
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 24, crossAxisSpacing: 4),
                  delegate: SliverChildListDelegate([
                    Container(color: const Color(0x333B82F6), alignment: Alignment.center, child: const Text('SliverGrid 1', style: TextStyle(fontSize: 9))),
                    Container(color: const Color(0x338B5CF6), alignment: Alignment.center, child: const Text('SliverGrid 2', style: TextStyle(fontSize: 9))),
                  ]),
                ),
                SliverOpacity(
                  opacity: 0.8,
                  sliver: SliverToBoxAdapter(
                    child: Container(color: const Color(0x2206B6D4), padding: const EdgeInsets.all(4), child: const Text('SliverOpacity (0.8)', style: TextStyle(fontSize: 10))),
                  ),
                ),
                SliverVisibility(
                  visible: true,
                  sliver: SliverToBoxAdapter(
                    child: Container(color: const Color(0x228B5CF6), padding: const EdgeInsets.all(4), child: const Text('SliverVisibility (true)', style: TextStyle(fontSize: 10))),
                  ),
                ),
                const SliverOffstage(
                  offstage: false,
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text('SliverOffstage (false)', style: TextStyle(fontSize: 10)),
                    ),
                  ),
                ),
                const SliverSafeArea(
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text('SliverSafeArea Adapter', style: TextStyle(fontSize: 10)),
                    ),
                  ),
                ),
                SliverFillViewport(
                  delegate: SliverChildListDelegate([
                    Container(color: const Color(0x1810B981), alignment: Alignment.center, child: const Text('SliverFillViewport Page', style: TextStyle(fontSize: 10))),
                  ]),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(
                    color: const Color(0x186366F1),
                    alignment: Alignment.center,
                    child: const Text('SliverFillRemaining Bottom Footer', style: TextStyle(fontSize: 10)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
