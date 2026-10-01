import 'package:flutter/widgets.dart';

import '../core/agentation_logger.dart';
import '../models/hierarchical_inspection_result.dart';
import '../models/widget_bounds.dart';
import '../models/widget_context.dart';
import '../models/widget_identity.dart';
import '../models/widget_inspection_result.dart';
import '../source_location/source_location_resolver.dart';
import '../source_location/widget_source_location.dart';
import 'bounds_resolver.dart';
import 'element_inspector.dart';
import 'hit_test_engine.dart';
import 'route_resolver.dart';
import 'semantics_resolver.dart';
import 'text_resolver.dart';
import 'widget_identity_resolver.dart';
import 'widget_path_resolver.dart';

/// The core Flutter Inspection Engine coordinating hit-testing, element resolution,
/// coordinate bounding, and context extraction.
///
/// Designed as the non-negotiable foundation of FlutterAgentation per Constitution Principle I.
class FlutterInspectionEngine {
  final HitTestEngine hitTestEngine;
  final ElementInspector elementInspector;
  final WidgetIdentityResolver identityResolver;
  final WidgetPathResolver pathResolver;
  final BoundsResolver boundsResolver;
  final TextResolver textResolver;
  final SemanticsResolver semanticsResolver;
  final RouteResolver routeResolver;
  final SourceLocationResolver sourceLocationResolver;

  /// Optional set of render objects to ignore during hit testing (e.g. inspector overlay canvas).
  Set<RenderObject>? ignoredRenderObjects;

  FlutterInspectionEngine({
    HitTestEngine? hitTestEngine,
    ElementInspector? elementInspector,
    WidgetIdentityResolver? identityResolver,
    WidgetPathResolver? pathResolver,
    BoundsResolver? boundsResolver,
    TextResolver? textResolver,
    SemanticsResolver? semanticsResolver,
    RouteResolver? routeResolver,
    SourceLocationResolver? sourceLocationResolver,
    this.ignoredRenderObjects,
  })  : hitTestEngine = hitTestEngine ?? HitTestEngine(),
        elementInspector = elementInspector ?? ElementInspector(),
        identityResolver = identityResolver ?? WidgetIdentityResolver(),
        pathResolver = pathResolver ?? WidgetPathResolver(),
        boundsResolver = boundsResolver ?? BoundsResolver(),
        textResolver = textResolver ?? TextResolver(),
        semanticsResolver = semanticsResolver ?? SemanticsResolver(),
        routeResolver = routeResolver ?? RouteResolver(),
        sourceLocationResolver = sourceLocationResolver ?? FlutterSourceLocationResolver();

  /// Inspects the visual Flutter widget under [globalPosition].
  ///
  /// Guaranteed never to throw; returns [WidgetInspectionResult.unavailable()]
  /// if no hittable widget is resolved or an error occurs (Constitution Principle VI).
  WidgetInspectionResult inspectAt(
    Offset globalPosition, {
    RenderObject? rootRenderObject,
    Element? rootElement,
    bool resolveSourceLocation = true,
    bool lightweight = false,
  }) {
    try {
      final targetBox = hitTestEngine.findTargetRenderBox(
        globalPosition,
        rootRenderObject: rootRenderObject,
        ignoredRenderObjects: ignoredRenderObjects,
      );

      if (targetBox == null) {
        AgentationLogger.debug('No RenderBox resolved at $globalPosition');
        return const WidgetInspectionResult.unavailable();
      }

      return inspectRenderObject(
        targetBox,
        rootElement: rootElement,
        resolveSourceLocation: resolveSourceLocation,
        lightweight: lightweight,
      );
    } catch (e, st) {
      AgentationLogger.error('Inspection failed at $globalPosition', e, st);
      return const WidgetInspectionResult.unavailable();
    }
  }

  /// Inspects all candidate layers under [globalPosition], useful for stacked or overlapping widgets.
  List<WidgetInspectionResult> inspectAllAt(
    Offset globalPosition, {
    RenderObject? rootRenderObject,
    Element? rootElement,
    bool resolveSourceLocation = false,
  }) {
    try {
      final candidates = hitTestEngine.hitTest(
        globalPosition,
        rootRenderObject: rootRenderObject,
        ignoredRenderObjects: ignoredRenderObjects,
      );

      final results = <WidgetInspectionResult>[];
      final seenElements = <Element>{};

      for (final box in candidates) {
        final element = elementInspector.findElementForRenderObject(box, rootElement: rootElement);
        if (element != null && seenElements.add(element)) {
          final res = inspectElement(
            element,
            renderObject: box,
            rootElement: rootElement,
            resolveSourceLocation: resolveSourceLocation,
          );
          if (res.isAvailable) {
            results.add(res);
          }
        }
      }

      return results;
    } catch (e, st) {
      AgentationLogger.error('Multi-layer inspection failed at $globalPosition', e, st);
      return const [];
    }
  }

  /// Inspects the complete widget hierarchy under [globalPosition], returning
  /// the primary target, ancestor chain, child elements, and hit candidates.
  HierarchicalInspectionResult inspectHierarchyAt(
    Offset globalPosition, {
    RenderObject? rootRenderObject,
    Element? rootElement,
  }) {
    try {
      final candidates = hitTestEngine.hitTest(
        globalPosition,
        rootRenderObject: rootRenderObject,
        ignoredRenderObjects: ignoredRenderObjects,
      );

      final targetBox = candidates.isNotEmpty ? candidates.first : null;

      final primary = targetBox != null
          ? inspectRenderObject(
              targetBox,
              rootElement: rootElement,
              resolveSourceLocation: true,
            )
          : const WidgetInspectionResult.unavailable();

      final hitCandidates = <WidgetInspectionResult>[];
      final seenElements = <Element>{};

      for (final box in candidates.take(5)) {
        final element = elementInspector.findElementForRenderObject(box, rootElement: rootElement);
        if (element != null && seenElements.add(element)) {
          final meaningful = elementInspector.findMeaningfulElement(element, rootElement: rootElement);
          if (primary.isAvailable && meaningful.widget.runtimeType.toString() == primary.identity.widgetType) {
            hitCandidates.add(primary);
          } else {
            hitCandidates.add(_inspectLightweight(meaningful, renderObject: box));
          }
        }
      }

      // Find the element for the primary target or top candidate
      Element? targetElement;
      if (targetBox != null) {
        final el = elementInspector.findElementForRenderObject(targetBox, rootElement: rootElement);
        if (el != null) {
          targetElement = elementInspector.findMeaningfulElement(el, rootElement: rootElement);
        }
      } else if (rootElement != null || rootRenderObject != null) {
        final fallbackElement = rootElement ??
            (rootRenderObject != null
                ? elementInspector.findElementForRenderObject(rootRenderObject)
                : null);
        if (fallbackElement != null) {
          final meaningfulFallback = elementInspector.findMeaningfulElement(fallbackElement, rootElement: rootElement);
          final res = inspectElement(
            meaningfulFallback,
            renderObject: rootRenderObject,
            rootElement: rootElement,
            resolveSourceLocation: true,
          );
          if (res.isAvailable) {
            return HierarchicalInspectionResult(
              primaryTarget: res,
              ancestors: const [],
              children: inspectChildrenOf(meaningfulFallback, resolveSourceLocation: false),
              hitCandidates: [res],
              isAvailable: true,
            );
          }
        }
      }

      final ancestors = <WidgetInspectionResult>[];
      final children = <WidgetInspectionResult>[];

      if (targetElement != null) {
        // 1. Ancestors (use fast lightweight inspection)
        final ancestorElements = elementInspector.findAncestorHierarchy(targetElement, maxDepth: 40);
        for (final ae in ancestorElements) {
          final res = _inspectLightweight(ae);
          if (res.isAvailable && res.identity.widgetType != primary.identity.widgetType) {
            ancestors.add(res);
          }
        }

        // 2. Children
        final directChildren = inspectChildrenOf(targetElement, maxDepth: 50, maxChildren: 20, resolveSourceLocation: false);
        if (directChildren.isNotEmpty) {
          children.addAll(directChildren);
        } else if (ancestorElements.isNotEmpty) {
          // If the leaf widget itself has no children (e.g. Text or Icon), find the nearest
          // parent container's children so sibling widgets within a tile/card are readily selectable
          for (final ancestor in ancestorElements.reversed.take(3)) {
            final containerChildren = inspectChildrenOf(ancestor, maxDepth: 50, maxChildren: 20, resolveSourceLocation: false);
            if (containerChildren.isNotEmpty) {
              for (final child in containerChildren) {
                if (child.identity.id != primary.identity.id) {
                  children.add(child);
                }
              }
              if (children.isNotEmpty) break;
            }
          }
        }
      }

      if (!primary.isAvailable && hitCandidates.isEmpty && ancestors.isEmpty) {
        return const HierarchicalInspectionResult.unavailable();
      }

      final resolvedPrimary = primary.isAvailable
          ? primary
          : (hitCandidates.isNotEmpty
              ? hitCandidates.first
              : (ancestors.isNotEmpty
                  ? ancestors.last
                  : const WidgetInspectionResult.unavailable()));

      return HierarchicalInspectionResult(
        primaryTarget: resolvedPrimary,
        ancestors: ancestors,
        children: children,
        hitCandidates: hitCandidates,
        isAvailable: resolvedPrimary.isAvailable,
      );
    } catch (e, st) {
      AgentationLogger.error('Hierarchical inspection failed at $globalPosition', e, st);
      return const HierarchicalInspectionResult.unavailable();
    }
  }

  /// Discovers meaningful child widgets directly contained within [element].
  List<WidgetInspectionResult> inspectChildrenOf(
    Element element, {
    int maxDepth = 50,
    int maxChildren = 20,
    bool resolveSourceLocation = false,
  }) {
    try {
      final childElements = elementInspector.findMeaningfulChildren(
        element,
        maxDepth: maxDepth,
        maxCount: maxChildren,
      );
      final results = <WidgetInspectionResult>[];
      for (final ce in childElements) {
        final res = _inspectLightweight(ce);
        if (res.isAvailable) {
          results.add(res);
        }
      }
      return results;
    } catch (e, st) {
      AgentationLogger.error('Child widget inspection failed', e, st);
      return const [];
    }
  }

  /// Fast, lightweight inspection for non-primary hierarchy candidates and ancestors,
  /// avoiding expensive tree walks, deep text scans, route resolutions, and source lookups.
  WidgetInspectionResult _inspectLightweight(Element element, {RenderObject? renderObject}) {
    try {
      final ro = element.renderObject ?? renderObject;
      final bounds = ro is RenderBox ? boundsResolver.resolveBounds(ro) : const WidgetBounds.zero();
      final identity = identityResolver.resolveIdentity(element, renderObject: ro);
      final text = textResolver.extractText(element);

      return WidgetInspectionResult(
        identity: identity,
        bounds: bounds,
        context: const WidgetContext.empty(),
        route: null,
        text: text,
        ancestors: [identity.widgetType],
        sourceLocation: const WidgetSourceLocation.unavailable(),
      );
    } catch (_) {
      return const WidgetInspectionResult.unavailable();
    }
  }

  /// Resolves an explicit [RenderObject] into an inspection result.
  WidgetInspectionResult inspectRenderObject(
    RenderObject renderObject, {
    Element? rootElement,
    bool resolveSourceLocation = true,
    bool lightweight = false,
  }) {
    try {
      final element = elementInspector.findElementForRenderObject(
        renderObject,
        rootElement: rootElement,
      );

      if (element == null) {
        // Return baseline bounds result even if Element is untracked
        final bounds = renderObject is RenderBox
            ? boundsResolver.resolveBounds(renderObject)
            : const WidgetBounds.zero();
        return WidgetInspectionResult(
          identity: WidgetIdentity(
            id: renderObject.hashCode.toString(),
            widgetType: renderObject.runtimeType.toString(),
          ),
          bounds: bounds,
          context: const WidgetContext.empty(),
          ancestors: [renderObject.runtimeType.toString()],
          sourceLocation: const WidgetSourceLocation.unavailable(),
        );
      }

      return inspectElement(
        element,
        renderObject: renderObject,
        rootElement: rootElement,
        resolveSourceLocation: resolveSourceLocation,
        lightweight: lightweight,
      );
    } catch (e, st) {
      AgentationLogger.error('RenderObject inspection failed', e, st);
      return const WidgetInspectionResult.unavailable();
    }
  }

  /// Resolves an [Element] into an immutable [WidgetInspectionResult].
  WidgetInspectionResult inspectElement(
    Element element, {
    RenderObject? renderObject,
    Element? rootElement,
    bool resolveSourceLocation = true,
    bool lightweight = false,
  }) {
    try {
      final meaningfulElement = elementInspector.findMeaningfulElement(element, rootElement: rootElement);
      final ro = meaningfulElement.renderObject ?? renderObject;

      // Resolve bounds
      final bounds = ro is RenderBox ? boundsResolver.resolveBounds(ro) : const WidgetBounds.zero();

      // Resolve identity
      final identity = identityResolver.resolveIdentity(meaningfulElement, renderObject: ro);

      if (lightweight) {
        return WidgetInspectionResult(
          identity: identity,
          bounds: bounds,
          context: const WidgetContext.empty(),
          route: null,
          text: null,
          ancestors: [identity.widgetType],
          sourceLocation: const WidgetSourceLocation.unavailable(),
        );
      }

      // Resolve ancestors
      final ancestors = pathResolver.resolveAncestors(meaningfulElement);

      // Resolve text
      final text = textResolver.extractText(meaningfulElement);

      // Resolve route
      final route = routeResolver.resolveRoute(meaningfulElement);

      // Resolve semantics
      final semantics = semanticsResolver.extractSemantics(ro, meaningfulElement);

      // Resolve source location via Flutter Inspector runtime metadata
      final sourceLocation = resolveSourceLocation
          ? (sourceLocationResolver.resolve(meaningfulElement) ??
              (meaningfulElement != element ? sourceLocationResolver.resolve(element) : null) ??
              const WidgetSourceLocation.unavailable())
          : const WidgetSourceLocation.unavailable();

      return WidgetInspectionResult(
        identity: identity,
        bounds: bounds,
        context: WidgetContext(
          route: route,
          semanticsLabel: semantics?.label,
          semanticsHint: semantics?.hint,
          depth: ancestors.length,
        ),
        route: route,
        text: text,
        ancestors: ancestors,
        sourceLocation: sourceLocation,
      );
    } catch (e, st) {
      AgentationLogger.error('Element inspection failed', e, st);
      return const WidgetInspectionResult.unavailable();
    }
  }
}
