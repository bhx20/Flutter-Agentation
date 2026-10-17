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
          if (_isScrollbarRenderBox(target)) {
            continue;
          }
          if (target.hasSize && target.attached) {
            candidateBoxes.add(target);
          }
        }
      }

      final searchRoot = root is RenderBox ? root : (root is RenderView ? root.child : null);

      // Fast-path: if native hit testing resolved a specific child/leaf widget (not a giant full-screen container),
      // return immediately. Innermost leaf render boxes are already at the front.
      if (candidateBoxes.isNotEmpty) {
        if (searchRoot == null || !searchRoot.hasSize) {
          return candidateBoxes;
        }
        final searchArea = searchRoot.size.width * searchRoot.size.height;
        final firstArea = candidateBoxes.first.size.width * candidateBoxes.first.size.height;
        if (firstArea < searchArea * 0.8) {
          return candidateBoxes;
        }
      }

      // Fallback: collect render boxes whose bounds contain globalPosition
      // only when native hit-testing found zero candidates (e.g. empty whitespace,
      // transparent backgrounds, or non-pointer-listener leaf boxes).
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
          if (_isScrollbarRenderBox(node)) {
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

  static bool _isScrollbarRenderBox(RenderObject node) {
    final boxType = node.runtimeType.toString();
    if (boxType == '_RenderScrollSemantics' || boxType.contains('Scrollbar')) {
      return true;
    }
    final creator = node.debugCreator;
    if (creator is DebugCreator) {
      Element? el = creator.element;
      int depth = 0;
      while (el != null && depth < 6) {
        final name = el.widget.runtimeType.toString();
        if (name == 'RawScrollbar' ||
            name == 'Scrollbar' ||
            name == 'CupertinoScrollbar' ||
            name.startsWith('_Scrollbar')) {
          return true;
        }
        if (name == 'SingleChildScrollView' ||
            name == 'ListView' ||
            name == 'CustomScrollView' ||
            name == 'NestedScrollView') {
          break;
        }
        Element? parent;
        el.visitAncestorElements((a) {
          parent = a;
          return false;
        });
        el = parent;
        depth++;
      }
    }
    return false;
  }
}

