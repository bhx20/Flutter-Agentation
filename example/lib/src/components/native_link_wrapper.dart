import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
// ignore: depend_on_referenced_packages
import 'package:web/web.dart' as web;

enum LinkTarget { blank, self }

class NativeLinkWrapper extends StatelessWidget {
  const NativeLinkWrapper({
    super.key,
    required this.url,
    required this.child,
    this.target = LinkTarget.blank,
    this.tooltip,
    this.onTap,
    this.hoverNotifier,
  });

  final String url;
  final Widget child;
  final LinkTarget target;
  final String? tooltip;
  final VoidCallback? onTap;
  final ValueNotifier<bool>? hoverNotifier;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return child;

    Widget content = child;

    final isBlank = target == LinkTarget.blank;

    if (kIsWeb) {
      content = Stack(
        fit: StackFit.passthrough,
        children: [
          child,
          Positioned.fill(
            child: HtmlElementView.fromTagName(
              key: ValueKey('native-link-$url-$target'),
              tagName: 'a',
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              onElementCreated: (Object element) {
                try {
                  final anchor = element as web.HTMLAnchorElement;
                  anchor.href = url;
                  if (isBlank) {
                    anchor.target = '_blank';
                    anchor.rel = 'noopener noreferrer';
                  } else {
                    anchor.target = '_self';
                  }
                  anchor.style
                    ..display = 'block'
                    ..width = '100%'
                    ..height = '100%'
                    ..cursor = 'pointer'
                    ..opacity = '0';

                  anchor.addEventListener(
                    'click',
                    (web.MouseEvent event) {
                      if (!isBlank) {
                        event.preventDefault();
                      }
                      onTap?.call();
                    }.toJS,
                  );

                  anchor.addEventListener(
                    'mouseenter',
                    (web.MouseEvent event) {
                      hoverNotifier?.value = true;
                    }.toJS,
                  );

                  anchor.addEventListener(
                    'mouseleave',
                    (web.MouseEvent event) {
                      hoverNotifier?.value = false;
                    }.toJS,
                  );
                } catch (_) {}
              },
            ),
          ),
        ],
      );
    } else {
      content = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: child,
      );
    }

    Widget result = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        hoverNotifier?.value = true;
      },
      onExit: (_) {
        hoverNotifier?.value = false;
      },
      child: content,
    );

    if (tooltip != null) {
      result = Tooltip(
        message: tooltip!,
        waitDuration: const Duration(milliseconds: 400),
        child: result,
      );
    }

    return SelectionContainer.disabled(child: result);
  }
}
