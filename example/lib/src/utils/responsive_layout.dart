import 'package:flutter/material.dart';
import '../theme/app_insets.dart';
import 'breakpoints.dart';

/// Responsive builder widget and layout helper utilities.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < Breakpoints.mobileMax) {
          return mobile;
        } else if (constraints.maxWidth < Breakpoints.tabletMax) {
          return tablet ?? mobile;
        } else {
          return desktop;
        }
      },
    );
  }
}

/// Helper container that caps width to [Breakpoints.maxContentWidth] and centers it.
class ContentContainer extends StatelessWidget {
  const ContentContainer({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
        child: Padding(
          padding: padding ??
              (Breakpoints.isMobile(context)
                  ? AppInsets.h16
                  : AppInsets.h32),
          child: child,
        ),
      ),
    );
  }
}

