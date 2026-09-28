import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/widget_category.dart';
import '../widgets/category_header.dart';
import '../widgets/widget_card.dart';

final Uint8List _kTransparentPng = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Showcases:
/// Text (4): Text, RichText, SelectableText, EditableText
/// Image (3): Image, RawImage, FadeInImage
/// Icons (2): Icon, IconButton
/// Painting (1): CustomPaint
/// Hero (1): Hero
class TextMediaIconsSection extends StatefulWidget {
  const TextMediaIconsSection({super.key});

  @override
  State<TextMediaIconsSection> createState() => _TextMediaIconsSectionState();
}

class _TextMediaIconsSectionState extends State<TextMediaIconsSection> {
  late final TextEditingController _editableController;
  late final FocusNode _editableFocusNode;

  @override
  void initState() {
    super.initState();
    _editableController = TextEditingController(text: 'EditableText content');
    _editableFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _editableController.dispose();
    _editableFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CategoryHeader(
          category: WidgetCategory.textMedia,
          itemCount: 11,
        ),

        // 1. Text, RichText, SelectableText, EditableText
        WidgetCard(
          title: 'Text & Typography',
          subtitle: 'Text, RichText, SelectableText, EditableText',
          badgeColor: const Color(0xFF6366F1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Standard Text widget with bold weight', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6.0),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                  children: [
                    TextSpan(text: 'RichText: '),
                    TextSpan(text: 'Colored ', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                    TextSpan(text: 'and '),
                    TextSpan(text: 'Underlined ', style: TextStyle(decoration: TextDecoration.underline, color: Color(0xFFEC4899))),
                    TextSpan(text: 'Spans'),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
              const SelectableText(
                'SelectableText: highlight and copy this paragraph on screen.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: EditableText(
                  controller: _editableController,
                  focusNode: _editableFocusNode,
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.white : Colors.black87),
                  cursorColor: const Color(0xFF6366F1),
                  backgroundCursorColor: Colors.grey,
                ),
              ),
            ],
          ),
        ),

        // 2. Image, RawImage, FadeInImage
        WidgetCard(
          title: 'Image & Media',
          subtitle: 'Image, RawImage, FadeInImage',
          badgeColor: const Color(0xFF10B981),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.memory(
                      _kTransparentPng,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Image.memory', style: TextStyle(fontSize: 10)),
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0x2210B981),
                      border: Border.all(color: const Color(0x4410B981)),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    alignment: Alignment.center,
                    child: const RawImage(
                      width: 32,
                      height: 32,
                      debugImageLabel: 'RawImage placeholder',
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('RawImage', style: TextStyle(fontSize: 10)),
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: FadeInImage.memoryNetwork(
                      placeholder: _kTransparentPng,
                      image: 'https://placeholder.test/image.png',
                      imageErrorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.image, size: 24, color: Color(0xFF10B981)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('FadeInImage', style: TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),
        ),

        // 3. Icon, IconButton, Hero, CustomPaint
        WidgetCard(
          title: 'Icons, Hero & Custom Painting',
          subtitle: 'Icon, IconButton, Hero, CustomPaint',
          badgeColor: const Color(0xFFF59E0B),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: const [
                  Icon(Icons.star_rounded, size: 32, color: Color(0xFFF59E0B)),
                  SizedBox(height: 4),
                  Text('Icon', style: TextStyle(fontSize: 10)),
                ],
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.thumb_up_rounded, color: Color(0xFF3B82F6)),
                    onPressed: () {},
                  ),
                  const Text('IconButton', style: TextStyle(fontSize: 10)),
                ],
              ),
              Column(
                children: const [
                  Hero(
                    tag: 'demo_hero_badge',
                    child: Chip(
                      avatar: Icon(Icons.bolt, size: 14, color: Colors.white),
                      label: Text('Hero', style: TextStyle(color: Colors.white, fontSize: 10)),
                      backgroundColor: Color(0xFF6366F1),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text('Hero', style: TextStyle(fontSize: 10)),
                ],
              ),
              Column(
                children: [
                  CustomPaint(
                    size: const Size(36, 36),
                    painter: _RingPainter(),
                  ),
                  const SizedBox(height: 4),
                  const Text('CustomPaint', style: TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
