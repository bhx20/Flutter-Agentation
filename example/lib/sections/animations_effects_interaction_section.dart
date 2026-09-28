import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/widget_category.dart';
import '../widgets/category_header.dart';
import '../widgets/widget_card.dart';

/// Showcases:
/// Animation (26): AnimatedContainer, AnimatedAlign, AnimatedOpacity, AnimatedPadding,
/// AnimatedPositioned, AnimatedPositionedDirectional, AnimatedDefaultTextStyle,
/// AnimatedPhysicalModel, AnimatedPhysicalShape, AnimatedSize, AnimatedScale,
/// AnimatedRotation, AnimatedSlide, AnimatedFractionallySizedBox, AnimatedCrossFade,
/// AnimatedSwitcher, FadeTransition, ScaleTransition, SizeTransition, RotationTransition,
/// SlideTransition, AlignTransition, PositionedTransition, DecoratedBoxTransition,
/// DefaultTextStyleTransition, MatrixTransition
/// Effects (4): BackdropFilter, ImageFiltered, ColorFiltered, ShaderMask
/// Interaction (8): GestureDetector, MouseRegion, Listener, IgnorePointer, AbsorbPointer,
/// Draggable, LongPressDraggable, DragTarget
/// Overlay (2): Overlay, OverlayPortal
/// Accessibility (3): Semantics, MergeSemantics, ExcludeSemantics
/// Custom implicit animation for PhysicalShape to complete the catalog
class AnimatedPhysicalShape extends ImplicitlyAnimatedWidget {
  const AnimatedPhysicalShape({
    super.key,
    required this.child,
    required this.clipper,
    required this.color,
    required this.elevation,
    this.shadowColor = const Color(0xFF000000),
    super.curve,
    required super.duration,
  });

  final Widget child;
  final CustomClipper<Path> clipper;
  final Color color;
  final double elevation;
  final Color shadowColor;

  @override
  AnimatedWidgetBaseState<AnimatedPhysicalShape> createState() => _AnimatedPhysicalShapeState();
}

class _AnimatedPhysicalShapeState extends AnimatedWidgetBaseState<AnimatedPhysicalShape> {
  ColorTween? _color;
  Tween<double>? _elevation;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _color = visitor(_color, widget.color, (dynamic val) => ColorTween(begin: val as Color)) as ColorTween?;
    _elevation = visitor(_elevation, widget.elevation, (dynamic val) => Tween<double>(begin: val as double)) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return PhysicalShape(
      clipper: widget.clipper,
      color: _color?.evaluate(animation) ?? widget.color,
      elevation: _elevation?.evaluate(animation) ?? widget.elevation,
      shadowColor: widget.shadowColor,
      child: widget.child,
    );
  }
}

class AnimationsEffectsInteractionSection extends StatefulWidget {
  const AnimationsEffectsInteractionSection({
    super.key,
    required this.animController,
  });

  final AnimationController animController;

  @override
  State<AnimationsEffectsInteractionSection> createState() =>
      _AnimationsEffectsInteractionSectionState();
}

class _AnimationsEffectsInteractionSectionState
    extends State<AnimationsEffectsInteractionSection> {
  final ValueNotifier<bool> _animToggleNotifier = ValueNotifier<bool>(false);
  final OverlayPortalController _portalController = OverlayPortalController();

  late final Animation<Alignment> _alignAnimation;
  late final Animation<RelativeRect> _rectAnimation;
  late final Animation<Decoration> _decorationAnimation;
  late final Animation<TextStyle> _styleAnimation;

  @override
  void initState() {
    super.initState();
    _alignAnimation = AlignmentTween(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(widget.animController);

    _rectAnimation = RelativeRectTween(
      begin: const RelativeRect.fromLTRB(4, 4, 30, 30),
      end: const RelativeRect.fromLTRB(30, 30, 4, 4),
    ).animate(widget.animController);

    _decorationAnimation = DecorationTween(
      begin: BoxDecoration(
        color: const Color(0xFF6366F1),
        borderRadius: BorderRadius.circular(4),
      ),
      end: BoxDecoration(
        color: const Color(0xFFEC4899),
        borderRadius: BorderRadius.circular(16),
      ),
    ).animate(widget.animController);

    _styleAnimation = TextStyleTween(
      begin: const TextStyle(fontSize: 10, color: Colors.blue),
      end: const TextStyle(fontSize: 12, color: Colors.purple, fontWeight: FontWeight.bold),
    ).animate(widget.animController);
  }

  @override
  void dispose() {
    _animToggleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CategoryHeader(
          category: WidgetCategory.animations,
          itemCount: 43,
        ),

        // 1. Implicit Animations Group 1 (Container, Align, Opacity, Padding, DefaultTextStyle, Size, Scale, Rotation, Slide, FractionallySizedBox)
        WidgetCard(
          title: 'Implicit Animations',
          subtitle: 'AnimatedContainer, AnimatedAlign, AnimatedOpacity, AnimatedPadding, AnimatedDefaultTextStyle, AnimatedSize, AnimatedScale, AnimatedRotation, AnimatedSlide, AnimatedFractionallySizedBox',
          badgeColor: const Color(0xFF6366F1),
          child: ValueListenableBuilder<bool>(
            valueListenable: _animToggleNotifier,
            builder: (context, toggled, _) {
              return Column(
                children: [
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => _animToggleNotifier.value = !toggled,
                        child: Text(toggled ? 'Reset Animations' : 'Trigger Animations', style: const TextStyle(fontSize: 11)),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: toggled ? 60 : 40,
                        height: 35,
                        color: toggled ? const Color(0xFF10B981) : const Color(0xFF6366F1),
                        alignment: Alignment.center,
                        child: const Text('Container', style: TextStyle(color: Colors.white, fontSize: 8)),
                      ),
                      SizedBox(
                        width: 70,
                        height: 35,
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 400),
                          alignment: toggled ? Alignment.bottomRight : Alignment.topLeft,
                          child: const Text('Align', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 400),
                        opacity: toggled ? 0.4 : 1.0,
                        child: const Chip(label: Text('Opacity', style: TextStyle(fontSize: 9))),
                      ),
                      AnimatedPadding(
                        duration: const Duration(milliseconds: 400),
                        padding: EdgeInsets.symmetric(horizontal: toggled ? 12.0 : 4.0),
                        child: const Text('Padding', style: TextStyle(fontSize: 10)),
                      ),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 400),
                        style: TextStyle(
                          fontSize: toggled ? 13 : 10,
                          color: toggled ? Colors.deepPurple : Colors.black87,
                          fontWeight: toggled ? FontWeight.bold : FontWeight.normal,
                        ),
                        child: const Text('Style'),
                      ),
                      AnimatedScale(
                        duration: const Duration(milliseconds: 400),
                        scale: toggled ? 1.2 : 0.9,
                        child: const Chip(label: Text('Scale', style: TextStyle(fontSize: 9))),
                      ),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 400),
                        turns: toggled ? 0.25 : 0.0,
                        child: const Icon(Icons.refresh, size: 20, color: Color(0xFFF59E0B)),
                      ),
                      AnimatedSlide(
                        duration: const Duration(milliseconds: 400),
                        offset: toggled ? const Offset(0.1, 0) : Offset.zero,
                        child: const Text('Slide', style: TextStyle(fontSize: 10)),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 400),
                        child: SizedBox(
                          width: toggled ? 45 : 30,
                          height: 30,
                          child: Container(color: const Color(0x3306B6D4), alignment: Alignment.center, child: const Text('Size', style: TextStyle(fontSize: 8))),
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        height: 30,
                        child: AnimatedFractionallySizedBox(
                          duration: const Duration(milliseconds: 400),
                          widthFactor: toggled ? 0.9 : 0.5,
                          child: Container(color: const Color(0x33EC4899)),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),

        // 2. Animated Stack & Shapes & Switchers (AnimatedPositioned, AnimatedPositionedDirectional, AnimatedPhysicalModel, AnimatedPhysicalShape, AnimatedCrossFade, AnimatedSwitcher)
        WidgetCard(
          title: 'Positioned & Physical Animations',
          subtitle: 'AnimatedPositioned, AnimatedPositionedDirectional, AnimatedPhysicalModel, AnimatedPhysicalShape, AnimatedCrossFade, AnimatedSwitcher',
          badgeColor: const Color(0xFF10B981),
          child: ValueListenableBuilder<bool>(
            valueListenable: _animToggleNotifier,
            builder: (context, toggled, _) {
              return Column(
                children: [
                  SizedBox(
                    height: 60,
                    child: Stack(
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 400),
                          left: toggled ? 60 : 4,
                          top: 4,
                          child: Container(padding: const EdgeInsets.all(4), color: const Color(0x3310B981), child: const Text('AnimatedPositioned', style: TextStyle(fontSize: 9))),
                        ),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: AnimatedPositionedDirectional(
                            duration: const Duration(milliseconds: 400),
                            end: toggled ? 60 : 4,
                            bottom: 4,
                            child: Container(padding: const EdgeInsets.all(4), color: const Color(0x338B5CF6), child: const Text('AnimatedPosDirectional', style: TextStyle(fontSize: 9))),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AnimatedPhysicalModel(
                        duration: const Duration(milliseconds: 400),
                        shape: BoxShape.rectangle,
                        elevation: toggled ? 8.0 : 2.0,
                        color: Colors.white,
                        shadowColor: Colors.black45,
                        child: const Padding(padding: EdgeInsets.all(4.0), child: Text('AnimatedPhysicalModel', style: TextStyle(fontSize: 9))),
                      ),
                      AnimatedPhysicalShape(
                        duration: const Duration(milliseconds: 400),
                        clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(toggled ? 12 : 4))),
                        elevation: toggled ? 6.0 : 1.0,
                        color: const Color(0x33F59E0B),
                        shadowColor: Colors.black26,
                        child: const Padding(padding: EdgeInsets.all(4.0), child: Text('PhysicalShape', style: TextStyle(fontSize: 9))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        firstChild: const Text('CrossFade First', style: TextStyle(fontSize: 10, color: Colors.blue)),
                        secondChild: const Text('CrossFade Second', style: TextStyle(fontSize: 10, color: Colors.green)),
                        crossFadeState: toggled ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          toggled ? 'Switcher On' : 'Switcher Off',
                          key: ValueKey(toggled),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),

        // 3. Explicit Transitions (FadeTransition, ScaleTransition, SizeTransition, RotationTransition, SlideTransition, AlignTransition, PositionedTransition, DecoratedBoxTransition, DefaultTextStyleTransition, MatrixTransition)
        WidgetCard(
          title: 'Explicit Animation Transitions',
          subtitle: 'FadeTransition, ScaleTransition, SizeTransition, RotationTransition, SlideTransition, AlignTransition, PositionedTransition, DecoratedBoxTransition, DefaultTextStyleTransition, MatrixTransition',
          badgeColor: const Color(0xFFF59E0B),
          child: Column(
            children: [
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FadeTransition(
                    opacity: widget.animController,
                    child: const Chip(label: Text('FadeTrans', style: TextStyle(fontSize: 9))),
                  ),
                  ScaleTransition(
                    scale: widget.animController,
                    child: const Chip(label: Text('ScaleTrans', style: TextStyle(fontSize: 9))),
                  ),
                  SizeTransition(
                    sizeFactor: widget.animController,
                    axis: Axis.horizontal,
                    child: Container(color: const Color(0x3310B981), padding: const EdgeInsets.all(4), child: const Text('SizeTrans', style: TextStyle(fontSize: 9))),
                  ),
                  RotationTransition(
                    turns: widget.animController,
                    child: const Icon(Icons.autorenew, size: 20, color: Color(0xFF6366F1)),
                  ),
                  SlideTransition(
                    position: Tween<Offset>(begin: Offset.zero, end: const Offset(0.1, 0)).animate(widget.animController),
                    child: const Text('SlideTrans', style: TextStyle(fontSize: 9)),
                  ),
                  MatrixTransition(
                    animation: widget.animController,
                    onTransform: (val) => Matrix4.rotationZ(val * 0.1),
                    child: const Text('MatrixTrans', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  SizedBox(
                    width: 70,
                    height: 40,
                    child: AlignTransition(
                      alignment: _alignAnimation,
                      child: const Text('AlignTrans', style: TextStyle(fontSize: 9)),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    height: 40,
                    child: Stack(
                      children: [
                        PositionedTransition(
                          rect: _rectAnimation,
                          child: Container(color: const Color(0x33EC4899)),
                        ),
                      ],
                    ),
                  ),
                  DecoratedBoxTransition(
                    decoration: _decorationAnimation,
                    child: const Padding(padding: EdgeInsets.all(6.0), child: Text('DecoratedBoxTrans', style: TextStyle(color: Colors.white, fontSize: 8))),
                  ),
                  const SizedBox(width: 8.0),
                  DefaultTextStyleTransition(
                    style: _styleAnimation,
                    child: const Text('TextStyleTrans'),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 4. Effects: BackdropFilter, ImageFiltered, ColorFiltered, ShaderMask
        WidgetCard(
          title: 'Visual Effects & Shader Filters',
          subtitle: 'BackdropFilter, ImageFiltered, ColorFiltered, ShaderMask',
          badgeColor: const Color(0xFFEC4899),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ClipRect(
                child: SizedBox(
                  width: 55,
                  height: 45,
                  child: Stack(
                    children: [
                      Container(color: Colors.amber, alignment: Alignment.center, child: const Text('BG', style: TextStyle(fontSize: 9))),
                      BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                        child: Container(color: Colors.black.withValues(alpha: 0.1), child: const Center(child: Text('Backdrop', style: TextStyle(fontSize: 8)))),
                      ),
                    ],
                  ),
                ),
              ),
              ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                child: Container(padding: const EdgeInsets.all(4), color: const Color(0x333B82F6), child: const Text('ImageFiltered', style: TextStyle(fontSize: 9))),
              ),
              ColorFiltered(
                colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                child: Container(padding: const EdgeInsets.all(4), color: Colors.red, child: const Text('ColorFiltered', style: TextStyle(color: Colors.white, fontSize: 8))),
              ),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(colors: [Colors.blue, Colors.purple]).createShader(bounds),
                child: const Text('ShaderMask', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ],
          ),
        ),

        // 5. Interaction: GestureDetector, MouseRegion, Listener, IgnorePointer, AbsorbPointer, Draggable, LongPressDraggable, DragTarget
        WidgetCard(
          title: 'Interaction, Gestures & Dragging',
          subtitle: 'GestureDetector, MouseRegion, Listener, IgnorePointer, AbsorbPointer, Draggable, LongPressDraggable, DragTarget',
          badgeColor: const Color(0xFF06B6D4),
          child: Column(
            children: [
              Wrap(
                spacing: 8.0,
                runSpacing: 6.0,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: const Chip(label: Text('GestureDetector', style: TextStyle(fontSize: 9))),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: const Chip(label: Text('MouseRegion', style: TextStyle(fontSize: 9))),
                  ),
                  Listener(
                    onPointerDown: (_) {},
                    child: const Chip(label: Text('Listener', style: TextStyle(fontSize: 9))),
                  ),
                  const IgnorePointer(
                    child: Chip(label: Text('IgnorePointer', style: TextStyle(fontSize: 9, color: Colors.grey))),
                  ),
                  const AbsorbPointer(
                    child: Chip(label: Text('AbsorbPointer', style: TextStyle(fontSize: 9, color: Colors.grey))),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Draggable<String>(
                    data: 'demo_drag',
                    feedback: const Material(child: Chip(label: Text('Dragging...'))),
                    child: const Chip(label: Text('Draggable', style: TextStyle(fontSize: 10))),
                  ),
                  LongPressDraggable<String>(
                    data: 'demo_lp',
                    feedback: const Material(child: Chip(label: Text('LP Dragging...'))),
                    child: const Chip(label: Text('LongPressDraggable', style: TextStyle(fontSize: 10))),
                  ),
                  DragTarget<String>(
                    onAcceptWithDetails: (_) {},
                    builder: (context, candidate, rejected) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0x1F06B6D4),
                          border: Border.all(color: const Color(0xFF06B6D4)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('DragTarget', style: TextStyle(fontSize: 10)),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // 6. Overlay, OverlayPortal & Accessibility (Overlay, OverlayPortal, Semantics, MergeSemantics, ExcludeSemantics)
        WidgetCard(
          title: 'Overlay & Accessibility',
          subtitle: 'Overlay, OverlayPortal, Semantics, MergeSemantics, ExcludeSemantics',
          badgeColor: const Color(0xFF64748B),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 35,
                      child: Overlay(
                        initialEntries: [
                          OverlayEntry(
                            builder: (context) => const Center(
                              child: Text('OverlayEntry inside Overlay', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  OverlayPortal(
                    controller: _portalController,
                    overlayChildBuilder: (context) => Positioned(
                      top: 100,
                      left: 100,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.black87,
                        child: const Text('OverlayPortal Content', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ),
                    child: OutlinedButton(
                      onPressed: () => _portalController.toggle(),
                      child: const Text('OverlayPortal', style: TextStyle(fontSize: 10)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Semantics(
                    label: 'Inspectable Semantics element',
                    child: const Chip(label: Text('Semantics', style: TextStyle(fontSize: 9))),
                  ),
                  const MergeSemantics(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 14),
                        SizedBox(width: 2),
                        Text('MergeSemantics', style: TextStyle(fontSize: 9)),
                      ],
                    ),
                  ),
                  const ExcludeSemantics(
                    child: Chip(label: Text('ExcludeSemantics', style: TextStyle(fontSize: 9))),
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
