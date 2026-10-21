import 'package:flutter/widgets.dart';
import '../inspection/widget_tree_placement_resolver.dart';
import '../ui/design/skeleton_templates.dart';

/// Represents a pending component drop or tap awaiting user configuration in the counter-question dialog.
@immutable
class PendingPlacement {
  const PendingPlacement({
    required this.template,
    required this.position,
    required this.treePlacement,
    this.scrollPos,
  });

  /// The wireframe template selected from the palette.
  final SkeletonTemplate template;

  /// Viewport drop/tap position coordinates.
  final Offset position;

  /// Resolved hierarchical tree placement relative to adjacent widgets.
  final WidgetTreePlacement treePlacement;

  /// Active scroll position if the drop occurred inside a scrollable view.
  final ScrollPosition? scrollPos;
}
