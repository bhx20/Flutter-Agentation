import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/widget_category.dart';
import '../widgets/category_header.dart';
import '../widgets/widget_card.dart';

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_TriangleClipper oldClipper) => false;
}

/// Showcases all 27 Flutter "Basic" widgets:
/// Container, SizedBox, Center, Align, Padding, ColoredBox, DecoratedBox,
/// ConstrainedBox, LimitedBox, FractionallySizedBox, FittedBox, AspectRatio,
/// IntrinsicWidth, IntrinsicHeight, UnconstrainedBox, OverflowBox, Offstage,
/// Visibility, Opacity, RotatedBox, Transform, ClipRect, ClipRRect, ClipOval,
/// ClipPath, PhysicalModel, PhysicalShape.
class BasicSection extends StatelessWidget {
  const BasicSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CategoryHeader(
          category: WidgetCategory.basic,
          itemCount: 27,
        ),

        // 1. Container, SizedBox, Center, Align, Padding
        WidgetCard(
          title: 'Container & Alignment Essentials',
          subtitle: 'Container, SizedBox, Center, Align, Padding',
          badgeColor: const Color(0xFF6366F1),
          child: Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                width: 90,
                height: 50,
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Color(0xFF4F46E5),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                child: Center(
                  child: Text('Container', style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ),
              SizedBox(
                width: 80,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFF10B981),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  child: Center(
                    child: Text('SizedBox', style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ),
              ),
              SizedBox(
                width: 70,
                height: 50,
                child: Center(
                  child: Text('Center', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              SizedBox(
                width: 80,
                height: 50,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text('Align BR', style: TextStyle(fontSize: 11, color: Color(0xFF6366F1))),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Padding (8)', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),

        // 2. ColoredBox & DecoratedBox
        const WidgetCard(
          title: 'Boxes: ColoredBox & DecoratedBox',
          subtitle: 'High performance paint boxes',
          badgeColor: Color(0xFF3B82F6),
          child: Row(
            children: [
              Expanded(
                child: ColoredBox(
                  color: Color(0x333B82F6),
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Center(child: Text('ColoredBox', style: TextStyle(fontWeight: FontWeight.w600))),
                  ),
                ),
              ),
              SizedBox(width: 12.0),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)]),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Center(child: Text('DecoratedBox', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3. ConstrainedBox, LimitedBox, FractionallySizedBox, FittedBox, AspectRatio
        WidgetCard(
          title: 'Constraints & Sizing',
          subtitle: 'ConstrainedBox, LimitedBox, FractionallySizedBox, FittedBox, AspectRatio',
          badgeColor: const Color(0xFFEC4899),
          child: Column(
            children: [
              Row(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 80, maxWidth: 120, minHeight: 40),
                    child: Container(
                      color: const Color(0x22EC4899),
                      alignment: Alignment.center,
                      child: const Text('ConstrainedBox', style: TextStyle(fontSize: 10)),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  LimitedBox(
                    maxHeight: 40,
                    child: Container(
                      width: 80,
                      height: 40,
                      color: const Color(0x2210B981),
                      alignment: Alignment.center,
                      child: const Text('LimitedBox', style: TextStyle(fontSize: 10)),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: FractionallySizedBox(
                        widthFactor: 0.85,
                        heightFactor: 0.9,
                        child: Container(
                          color: const Color(0x228B5CF6),
                          alignment: Alignment.center,
                          child: const Text('FractionallySizedBox (85%)', style: TextStyle(fontSize: 10)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  SizedBox(
                    width: 70,
                    height: 35,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: const Text('FittedBox ScaleDown Text', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  SizedBox(
                    height: 40,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        color: const Color(0xFF6366F1),
                        alignment: Alignment.center,
                        child: const Text('16:9 AspectRatio', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 4. IntrinsicWidth, IntrinsicHeight, UnconstrainedBox, OverflowBox
        WidgetCard(
          title: 'Intrinsics & Overflow',
          subtitle: 'IntrinsicWidth, IntrinsicHeight, UnconstrainedBox, OverflowBox',
          badgeColor: const Color(0xFFF59E0B),
          child: Row(
            children: [
              IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(color: const Color(0x33F59E0B), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: const Text('IntrinsicWidth A', style: TextStyle(fontSize: 10))),
                    const SizedBox(height: 2),
                    Container(color: const Color(0x33F59E0B), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: const Text('IntrinsicWidth Longer Row B', style: TextStyle(fontSize: 10))),
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Container(width: 25, color: const Color(0xFFF59E0B)),
                    const SizedBox(width: 4),
                    const Text('Intrinsic\nHeight', style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              ClipRect(
                child: SizedBox(
                  width: 50,
                  height: 35,
                  child: OverflowBox(
                    maxWidth: 70,
                    maxHeight: 35,
                    child: Container(
                      color: const Color(0x3310B981),
                      alignment: Alignment.center,
                      child: const Text('OverflowBox', style: TextStyle(fontSize: 9)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              UnconstrainedBox(
                child: Container(
                  width: 55,
                  height: 30,
                  color: const Color(0x336366F1),
                  alignment: Alignment.center,
                  child: const Text('Unconstrained', style: TextStyle(fontSize: 8)),
                ),
              ),
            ],
          ),
        ),

        // 5. Offstage, Visibility, Opacity
        const WidgetCard(
          title: 'Visibility & Opacity',
          subtitle: 'Offstage, Visibility, Opacity',
          badgeColor: Color(0xFF8B5CF6),
          child: Row(
            children: [
              Offstage(
                offstage: false,
                child: Chip(label: Text('Offstage: false', style: TextStyle(fontSize: 11))),
              ),
              SizedBox(width: 8.0),
              Visibility(
                visible: true,
                child: Chip(label: Text('Visibility: true', style: TextStyle(fontSize: 11))),
              ),
              SizedBox(width: 8.0),
              Opacity(
                opacity: 0.5,
                child: Chip(label: Text('Opacity: 0.5', style: TextStyle(fontSize: 11))),
              ),
            ],
          ),
        ),

        // 6. RotatedBox & Transform
        WidgetCard(
          title: 'Transforms: RotatedBox & Transform',
          subtitle: 'RotatedBox, Transform',
          badgeColor: const Color(0xFF06B6D4),
          child: Row(
            children: [
              RotatedBox(
                quarterTurns: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  color: const Color(0xFF06B6D4),
                  child: const Text('Rotated 90°', style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ),
              const SizedBox(width: 20.0),
              Transform.rotate(
                angle: math.pi / 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x3306B6D4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Transform.rotate 15°', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 20.0),
              Transform.scale(
                scale: 1.1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: const Color(0x338B5CF6),
                  child: const Text('Transform.scale 1.1x', style: TextStyle(fontSize: 11)),
                ),
              ),
            ],
          ),
        ),

        // 7. ClipRect, ClipRRect, ClipOval, ClipPath
        WidgetCard(
          title: 'Clipping Shapes',
          subtitle: 'ClipRect, ClipRRect, ClipOval, ClipPath',
          badgeColor: const Color(0xFF10B981),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ClipRect(
                child: Container(
                  width: 50,
                  height: 50,
                  color: const Color(0xFF10B981),
                  alignment: Alignment.center,
                  child: const Text('ClipRect', style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Container(
                  width: 50,
                  height: 50,
                  color: const Color(0xFF3B82F6),
                  alignment: Alignment.center,
                  child: const Text('ClipRRect', style: TextStyle(color: Colors.white, fontSize: 9)),
                ),
              ),
              ClipOval(
                child: Container(
                  width: 50,
                  height: 50,
                  color: const Color(0xFFF59E0B),
                  alignment: Alignment.center,
                  child: const Text('ClipOval', style: TextStyle(color: Colors.white, fontSize: 9)),
                ),
              ),
              ClipPath(
                clipper: _TriangleClipper(),
                child: Container(
                  width: 50,
                  height: 50,
                  color: const Color(0xFFEC4899),
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 4),
                  child: const Text('ClipPath', style: TextStyle(color: Colors.white, fontSize: 8)),
                ),
              ),
            ],
          ),
        ),

        // 8. PhysicalModel & PhysicalShape
        WidgetCard(
          title: 'Physical Surfaces & Elevation',
          subtitle: 'PhysicalModel, PhysicalShape',
          badgeColor: const Color(0xFF64748B),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PhysicalModel(
                color: Colors.white,
                shadowColor: Colors.black54,
                elevation: 6.0,
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  width: 100,
                  height: 44,
                  alignment: Alignment.center,
                  child: const Text('PhysicalModel', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87)),
                ),
              ),
              PhysicalShape(
                clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0))),
                color: const Color(0xFF6366F1),
                shadowColor: const Color(0x666366F1),
                elevation: 8.0,
                child: Container(
                  width: 100,
                  height: 44,
                  alignment: Alignment.center,
                  child: const Text('PhysicalShape', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
