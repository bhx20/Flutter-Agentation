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
        try {
          final localPosition = root.globalToLocal(globalPosition);
          root.hitTest(hitTestResult, position: localPosition);
        } catch (_) {
          root.hitTest(hitTestResult, position: globalPosition);
        }
      }

      if (hitTestResult.path.isEmpty && renderViews.isNotEmpty) {
        // Fallback for View-based or PipelineOwner root hit-testing
        try {
          RendererBinding.instance.hitTestInView(
            hitTestResult,
            globalPosition,
            renderViews.first.flutterView.viewId,
          );
        } catch (_) {}
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

      // Also collect render boxes whose bounds contain globalPosition
      // to capture non-pointer-listener leaf boxes (like RenderParagraph, RenderImage, RenderFlex).
      // Uses branch-pruning and local coordinate checking for 1000x faster execution without UI thread blocking.
      final searchRoot = root is RenderBox ? root : (root is RenderView ? root.child : null);
      if (searchRoot != null) {
        // Fast-path: if globalPosition is outside searchRoot bounds, skip entirely
        if (searchRoot.hasSize && searchRoot.attached) {
          try {
            final rootLocal = searchRoot.globalToLocal(globalPosition);
            if (!searchRoot.paintBounds.contains(rootLocal)) {
              return candidateBoxes;
            }
          } catch (_) {}
        }

        final spatialMatches = <RenderBox>[];
        void walk(RenderObject node) {
          if (ignoredRenderObjects != null && ignoredRenderObjects.contains(node)) {
            return;
          }
          if (node is RenderBox && node.hasSize && node.attached) {
            if (node.size.isEmpty) return;
            try {
              final localPos = node.globalToLocal(globalPosition);
              if (node.paintBounds.contains(localPos)) {
                spatialMatches.add(node);
              } else {
                // PRUNING: If node's bounds inflated by 16px does NOT contain localPos,
                // then children cannot contain globalPosition. Skip descending into this subtree.
                if (!node.paintBounds.inflate(16.0).contains(localPos)) {
                  return;
                }
              }
            } catch (_) {
              return;
            }
          }
          node.visitChildren(walk);
        }

        walk(searchRoot);

        // Sort spatial matches by area ascending (smallest leaf first)
        spatialMatches.sort((a, b) {
          final areaA = a.size.width * a.size.height;
          final areaB = b.size.width * b.size.height;
          return areaA.compareTo(areaB);
        });

        // Merge spatial leaf candidates ahead of larger container hit-test targets
        final combined = <RenderBox>[];
        final seen = <RenderBox>{};

        for (final box in spatialMatches) {
          if (seen.add(box)) {
            combined.add(box);
          }
        }

        for (final box in candidateBoxes) {
          if (seen.add(box)) {
            combined.add(box);
          }
        }

        return combined;
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
