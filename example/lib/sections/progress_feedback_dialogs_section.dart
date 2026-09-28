import 'package:flutter/material.dart';
import '../models/widget_category.dart';
import '../widgets/category_header.dart';
import '../widgets/widget_card.dart';

/// Showcases:
/// Progress (3): CircularProgressIndicator, LinearProgressIndicator, RefreshProgressIndicator
/// Feedback (4): SnackBar, MaterialBanner, Tooltip, Badge
/// Dialogs (4): AlertDialog, SimpleDialog, Dialog, AboutDialog
class ProgressFeedbackDialogsSection extends StatelessWidget {
  const ProgressFeedbackDialogsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CategoryHeader(
          category: WidgetCategory.progressFeedback,
          itemCount: 11,
        ),

        // 1. Progress: CircularProgressIndicator, LinearProgressIndicator, RefreshProgressIndicator
        const WidgetCard(
          title: 'Progress Indicators',
          subtitle: 'CircularProgressIndicator, LinearProgressIndicator, RefreshProgressIndicator',
          badgeColor: Color(0xFF6366F1),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircularProgressIndicator(value: 0.75),
                  RefreshProgressIndicator(value: 0.8),
                  SizedBox(
                    width: 120,
                    child: LinearProgressIndicator(value: 0.6),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 2. Feedback: SnackBar, MaterialBanner, Tooltip, Badge
        WidgetCard(
          title: 'Feedback, Banners & Badges',
          subtitle: 'SnackBar, MaterialBanner, Tooltip, Badge',
          badgeColor: const Color(0xFF10B981),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MaterialBanner(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                content: const Text('MaterialBanner: In-app notification', style: TextStyle(fontSize: 11)),
                leading: const Icon(Icons.info_outline, size: 18, color: Color(0xFF10B981)),
                actions: [
                  TextButton(
                    onPressed: () {},
                    child: const Text('Action', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Badge(
                    label: Text('3'),
                    child: Icon(Icons.notifications_outlined, size: 24),
                  ),
                  const Tooltip(
                    message: 'Inspectable Tooltip message',
                    child: Chip(
                      avatar: Icon(Icons.help_outline, size: 14),
                      label: Text('Hover for Tooltip', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('SnackBar feedback message'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text('Show SnackBar', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 3. Dialogs: AlertDialog, SimpleDialog, Dialog, AboutDialog
        WidgetCard(
          title: 'Modal Dialogs',
          subtitle: 'AlertDialog, SimpleDialog, Dialog, AboutDialog',
          badgeColor: const Color(0xFFEC4899),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            alignment: WrapAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('AlertDialog'),
                      content: const Text('This is a standard AlertDialog for user confirmation.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
                      ],
                    ),
                  );
                },
                child: const Text('AlertDialog', style: TextStyle(fontSize: 11)),
              ),
              OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => SimpleDialog(
                      title: const Text('SimpleDialog'),
                      children: [
                        SimpleDialogOption(onPressed: () => Navigator.pop(ctx), child: const Text('Option A')),
                        SimpleDialogOption(onPressed: () => Navigator.pop(ctx), child: const Text('Option B')),
                      ],
                    ),
                  );
                },
                child: const Text('SimpleDialog', style: TextStyle(fontSize: 11)),
              ),
              OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => Dialog(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Custom Dialog', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            const Text('Custom raw Dialog container widget.'),
                            const SizedBox(height: 12),
                            ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Dialog', style: TextStyle(fontSize: 11)),
              ),
              OutlinedButton(
                onPressed: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'FlutterAgentation Demo',
                    applicationVersion: '3.1.2',
                  );
                },
                child: const Text('AboutDialog', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
