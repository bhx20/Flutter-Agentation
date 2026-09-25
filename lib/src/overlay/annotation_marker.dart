import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/annotation.dart';

/// Numbered circular visual badge rendered on the overlay over an annotated widget.
class AnnotationMarker extends StatelessWidget {
  const AnnotationMarker({
    super.key,
    required this.index,
    required this.annotation,
    required this.onTap,
    this.isSelected = false,
  });

  /// The 1-based sequential display number (1, 2, 3...).
  final int index;

  /// The associated annotation.
  final Annotation annotation;

  /// Callback when the marker is tapped.
  final VoidCallback onTap;

  /// Whether this marker is currently selected.
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final bounds = annotation.bounds;
    final left = math.max(4.0, bounds.x - 10.0);
    final top = math.max(4.0, bounds.y - 10.0);

    final borderColor = isSelected ? Colors.white : annotation.severity.color;

    return Positioned(
      left: left,
      top: top,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 24.0,
            height: 24.0,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E), // Dark slate
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 2.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 6.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating details card displayed when an [AnnotationMarker] is tapped.
class AnnotationDetailCard extends StatelessWidget {
  const AnnotationDetailCard({
    super.key,
    required this.index,
    required this.annotation,
    required this.onClose,
    required this.onDelete,
  });

  final int index;
  final Annotation annotation;
  final VoidCallback onClose;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bounds = annotation.bounds;
    const cardWidth = 280.0;

    final left = bounds.x.clamp(8.0, math.max(8.0, screenSize.width - cardWidth - 8.0)).toDouble();
    final top = math.max(16.0, bounds.y + bounds.height + 8.0 < screenSize.height - 180.0
        ? bounds.y + bounds.height + 8.0
        : bounds.y - 170.0);

    return Positioned(
      left: left,
      top: top,
      width: cardWidth,
      child: Material(
        color: Colors.transparent,
        elevation: 16.0,
        borderRadius: BorderRadius.circular(14.0),
        child: Container(
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: const Color(0xF0181825),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: const Color(0x336366F1), width: 1.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x7F000000),
                blurRadius: 20.0,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 20.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      color: annotation.severity.color,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$index',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      annotation.targetWidget.widgetType,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.0,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16.0, color: Colors.white60),
                    onPressed: onClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),

              // Comment text
              Text(
                annotation.comment,
                style: const TextStyle(color: Colors.white, fontSize: 13.0, height: 1.3),
              ),
              const SizedBox(height: 10.0),

              // Footer: severity & delete
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: annotation.severity.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      '${annotation.intent.name.toUpperCase()} • ${annotation.severity.name.toUpperCase()}',
                      style: TextStyle(
                        color: annotation.severity.color,
                        fontSize: 9.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16.0, color: Colors.redAccent),
                    tooltip: 'Delete Note',
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
