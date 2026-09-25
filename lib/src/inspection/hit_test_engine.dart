import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../core/agentation_logger.dart';

/// Helper responsible for executing native hit tests against the Flutter render tree.
class HitTestEngine {
  /// Executes a hit test at [globalPosition] and returns candidate [RenderBox] objects,
  /// ordered from front-most (deepest leaf) to back-most.
  List<RenderBox> hitTest(
    Offset globalPosition, {
    RenderObject? rootRenderObject,
    Set<RenderObject>? ignoredRenderObjects,
  }) {
    try {
      final hitTestResult = BoxHitTestResult();
      final renderViews = RendererBinding.instance.renderViews;
      final root = rootRenderObject ??
          WidgetsBinding.instance.rootElement?.renderObject ??
          (renderViews.isNotEmpty ? renderViews.first : null);

      if (root is RenderBox) {
        root.hitTest(hitTestResult, position: globalPosition);
      } else if (renderViews.isNotEmpty) {
        // Fallback for View-based or PipelineOwner root hit-testing
        RendererBinding.instance.hitTestInView(
          hitTestResult,
          globalPosition,
          renderViews.first.flutterView.viewId,
        );
      }

      final candidateBoxes = <RenderBox>[];

      for (final entry in hitTestResult.path) {
        final target = entry.target;
        if (target is RenderBox) {
          if (ignoredRenderObjects != null &&
              ignoredRenderObjects.contains(target)) {
            continue;
          }
          if (target.hasSize && target.attached) {
            candidateBoxes.add(target);
          }
        }
      }

      return candidateBoxes;
    } catch (e, st) {
      AgentationLogger.error('Hit test failed at position $globalPosition', e, st);
      return const [];
    }
  }

  /// Finds the primary front-most [RenderBox] under [globalPosition].
  RenderBox? findTargetRenderBox(
    Offset globalPosition, {
    RenderObject? rootRenderObject,
    Set<RenderObject>? ignoredRenderObjects,
  }) {
    final candidates = hitTest(
      globalPosition,
      rootRenderObject: rootRenderObject,
      ignoredRenderObjects: ignoredRenderObjects,
    );
    if (candidates.isEmpty) return null;
    return candidates.first;
  }
}
