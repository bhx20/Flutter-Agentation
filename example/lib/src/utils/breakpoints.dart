import 'package:flutter/material.dart';
import 'package:example/src/theme/app_dimensions.dart';


/// Screen size breakpoints and device categories.
enum ScreenDeviceType {
  mobile,
  tablet,
  desktop,
}

abstract final class Breakpoints {
  static const double mobileMax = AppDimensions.d640;
  static const double tabletMax = AppDimensions.d1024;
  static const double maxContentWidth = AppDimensions.maxContentWidth;

  static ScreenDeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < mobileMax) {
      return ScreenDeviceType.mobile;
    } else if (width < tabletMax) {
      return ScreenDeviceType.tablet;
    } else {
      return ScreenDeviceType.desktop;
    }
  }

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileMax;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileMax && width < tabletMax;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletMax;
}

