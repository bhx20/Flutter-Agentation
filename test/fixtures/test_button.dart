import 'package:flutter/material.dart';

Widget buildTestButton() {
  return ElevatedButton(
    onPressed: () {},
    child: const Text('Primary Action'),
  );
}

class WidgetCard extends StatelessWidget {
  const WidgetCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.badgeColor,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Color badgeColor;
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

Widget buildTestCard() {
  return const WidgetCard(
    title: 'Row, Expanded, Flexible & Spacer',
    subtitle: 'Horizontal linear layout distribution',
    badgeColor: Color(0xFF3B82F6),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text('A'),
        ),
        Flexible(
          child: Text('B'),
        ),
        Spacer(flex: 1),
      ],
    ),
  );
}
