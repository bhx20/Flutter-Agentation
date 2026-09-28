import 'package:flutter/material.dart';
import '../models/widget_category.dart';
import '../widgets/category_header.dart';
import '../widgets/widget_card.dart';

/// Comprehensive showcase of Typography scales, RichText spans, Badges, and Chips.
class TypographySection extends StatefulWidget {
  const TypographySection({super.key});

  @override
  State<TypographySection> createState() => _TypographySectionState();
}

class _TypographySectionState extends State<TypographySection> {
  final Set<String> _selectedFilters = {'Flutter', 'Inspector'};
  int _selectedChoice = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CategoryHeader(
          category: WidgetCategory.typography,
          itemCount: 8,
        ),

        // 1. Material 3 Typography Scale
        WidgetCard(
          title: 'Material 3 Typography Hierarchy',
          subtitle: 'Display, headline, title, body, and label text styles',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Display Small (36sp)',
                style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6.0),
              Text(
                'Headline Medium (28sp)',
                style: theme.textTheme.headlineMedium?.copyWith(color: const Color(0xFF6366F1)),
              ),
              const SizedBox(height: 6.0),
              Text(
                'Title Medium (16sp, w600)',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4.0),
              Text(
                'Body Medium: Production-grade visual inspection and annotation engine for Flutter applications.',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black87),
              ),
              const SizedBox(height: 4.0),
              Text(
                'LABEL LARGE: BADGE TEXT OR BUTTON CAPTION',
                style: theme.textTheme.labelLarge?.copyWith(
                  letterSpacing: 1.1,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // 2. RichText with Multiple Styled Spans
        WidgetCard(
          title: 'RichText & TextSpan Tree',
          subtitle: 'Nested text spans with individual styles, colors, and font weights',
          child: Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: RichText(
              text: const TextSpan(
                text: 'Inspecting with ',
                style: TextStyle(color: Color(0xFF334155), fontSize: 14.5),
                children: [
                  TextSpan(
                    text: 'FlutterAgentation',
                    style: TextStyle(
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: ' allows deep exploration of '),
                  TextSpan(
                    text: 'Ancestry Breadcrumbs',
                    style: TextStyle(
                      color: Color(0xFF059669),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(text: ', '),
                  TextSpan(
                    text: 'Bounding Geometry',
                    style: TextStyle(
                      color: Color(0xFFD97706),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  TextSpan(text: ', and direct IDE source linking!'),
                ],
              ),
            ),
          ),
        ),

        // 3. Badges on Icons & Avatars
        WidgetCard(
          title: 'Badges',
          subtitle: 'Notification counts and status indicator dots',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Badge(
                label: Text('5'),
                backgroundColor: Color(0xFF6366F1),
                child: Icon(Icons.notifications_outlined, size: 28.0),
              ),
              Badge(
                label: Text('99+'),
                backgroundColor: Color(0xFFEF4444),
                child: Icon(Icons.mail_outline, size: 28.0),
              ),
              Badge(
                smallSize: 10.0,
                backgroundColor: Color(0xFF10B981),
                child: CircleAvatar(
                  radius: 18.0,
                  backgroundColor: Color(0xFFCBD5E1),
                  child: Icon(Icons.person, color: Colors.white, size: 22.0),
                ),
              ),
              Badge(
                label: Text('PRO'),
                backgroundColor: Color(0xFF8B5CF6),
                child: Icon(Icons.verified_outlined, size: 28.0),
              ),
            ],
          ),
        ),

        // 4. Interactive Material 3 Chips
        WidgetCard(
          title: 'Chips (Filter, Choice, Action, Input)',
          subtitle: 'Categorization and filtering tags with select/unselect states',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FilterChips
              const Text(
                'FilterChips (Multi-Select):',
                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 6.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 6.0,
                children: ['Flutter', 'Inspector', 'DevTools', 'Hot Reload'].map((tag) {
                  final isSelected = _selectedFilters.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    selectedColor: const Color(0xFF6366F1).withValues(alpha: 0.2),
                    checkmarkColor: const Color(0xFF6366F1),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedFilters.add(tag);
                        } else {
                          _selectedFilters.remove(tag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12.0),

              // ChoiceChips & ActionChips
              const Text(
                'ChoiceChips & ActionChips:',
                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 6.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 6.0,
                children: [
                  ChoiceChip(
                    label: const Text('Light Theme'),
                    selected: _selectedChoice == 0,
                    onSelected: (sel) => setState(() => _selectedChoice = 0),
                  ),
                  ChoiceChip(
                    label: const Text('Dark Theme'),
                    selected: _selectedChoice == 1,
                    onSelected: (sel) => setState(() => _selectedChoice = 1),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.share, size: 16.0),
                    label: const Text('Export Report'),
                    onPressed: () {},
                  ),
                  InputChip(
                    avatar: const CircleAvatar(
                      backgroundColor: Color(0xFF6366F1),
                      child: Text('AG', style: TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                    label: const Text('Agentation v3.1'),
                    onDeleted: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
