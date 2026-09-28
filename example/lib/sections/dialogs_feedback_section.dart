import 'package:flutter/material.dart';
import '../models/widget_category.dart';
import '../widgets/category_header.dart';
import '../widgets/widget_card.dart';

/// Comprehensive showcase of Dialogs, SnackBars, Bottom Sheets, and Tooltips.
class DialogsFeedbackSection extends StatelessWidget {
  const DialogsFeedbackSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CategoryHeader(
          category: WidgetCategory.feedback,
          itemCount: 4,
        ),

        // 1. Interactive Dialog & Sheet Triggers
        WidgetCard(
          title: 'Dialogs & Modal Overlays',
          subtitle: 'Triggers for AlertDialog, Modal BottomSheet, and contextual prompts',
          child: Wrap(
            spacing: 12.0,
            runSpacing: 10.0,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.info_outline, size: 18.0),
                label: const Text('Show AlertDialog'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: Color(0xFF10B981)),
                          SizedBox(width: 8.0),
                          Text('Component Inspection'),
                        ],
                      ),
                      content: const Text(
                        'This dialog is rendered in Flutter’s overlay stack and can be inspected just like root widgets.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Dismiss'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Confirm'),
                        ),
                      ],
                    ),
                  );
                },
              ),

              OutlinedButton.icon(
                icon: const Icon(Icons.vertical_align_bottom, size: 18.0),
                label: const Text('Open BottomSheet'),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                    ),
                    builder: (ctx) => Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Modal BottomSheet',
                                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.of(ctx).pop(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          const Text('Inspect bottom sheet contents, buttons, and animations.'),
                          const SizedBox(height: 16.0),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(44.0),
                            ),
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Apply Selection'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              OutlinedButton.icon(
                icon: const Icon(Icons.notifications_active_outlined, size: 18.0),
                label: const Text('Trigger SnackBar'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Component snapshot captured for Agentation!'),
                      action: SnackBarAction(
                        label: 'View',
                        onPressed: () {},
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // 2. Tooltips
        WidgetCard(
          title: 'Tooltips & Help Badges',
          subtitle: 'Contextual tooltips appearing on hover or long-press',
          child: Wrap(
            spacing: 12.0,
            runSpacing: 8.0,
            children: const [
              Tooltip(
                message: 'Inspect layout constraints & padding',
                child: Chip(
                  avatar: Icon(Icons.info_outline, size: 16.0),
                  label: Text('Hover for Info'),
                ),
              ),
              Tooltip(
                message: 'Copy source code location',
                child: Chip(
                  avatar: Icon(Icons.code, size: 16.0),
                  label: Text('Hover for Code'),
                ),
              ),
              Tooltip(
                message: 'Freeze animations mid-flight',
                child: Chip(
                  avatar: Icon(Icons.ac_unit, size: 16.0),
                  label: Text('Hover for Freeze'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
