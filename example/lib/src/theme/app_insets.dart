import 'package:flutter/material.dart';

/// Centralized margins, paddings, and edge insets for the Flutter Agentation design system.
/// All layout spacing, margins, and paddings used across the application are centralized here.
abstract final class AppInsets {
  // Empty
  static const EdgeInsets none = EdgeInsets.zero;

  // Uniform Insets (EdgeInsets.all)
  static const EdgeInsets all2 = EdgeInsets.all(2.0);
  static const EdgeInsets all4 = EdgeInsets.all(4.0);
  static const EdgeInsets all6 = EdgeInsets.all(6.0);
  static const EdgeInsets all8 = EdgeInsets.all(8.0);
  static const EdgeInsets all10 = EdgeInsets.all(10.0);
  static const EdgeInsets all12 = EdgeInsets.all(12.0);
  static const EdgeInsets all14 = EdgeInsets.all(14.0);
  static const EdgeInsets all16 = EdgeInsets.all(16.0);
  static const EdgeInsets all18 = EdgeInsets.all(18.0);
  static const EdgeInsets all20 = EdgeInsets.all(20.0);
  static const EdgeInsets all24 = EdgeInsets.all(24.0);
  static const EdgeInsets all32 = EdgeInsets.all(32.0);

  // Horizontal Insets
  static const EdgeInsets h2 = EdgeInsets.symmetric(horizontal: 2.0);
  static const EdgeInsets h4 = EdgeInsets.symmetric(horizontal: 4.0);
  static const EdgeInsets h6 = EdgeInsets.symmetric(horizontal: 6.0);
  static const EdgeInsets h8 = EdgeInsets.symmetric(horizontal: 8.0);
  static const EdgeInsets h12 = EdgeInsets.symmetric(horizontal: 12.0);
  static const EdgeInsets h14 = EdgeInsets.symmetric(horizontal: 14.0);
  static const EdgeInsets h16 = EdgeInsets.symmetric(horizontal: 16.0);
  static const EdgeInsets h20 = EdgeInsets.symmetric(horizontal: 20.0);
  static const EdgeInsets h24 = EdgeInsets.symmetric(horizontal: 24.0);
  static const EdgeInsets h32 = EdgeInsets.symmetric(horizontal: 32.0);

  // Vertical Insets
  static const EdgeInsets v2 = EdgeInsets.symmetric(vertical: 2.0);
  static const EdgeInsets v4 = EdgeInsets.symmetric(vertical: 4.0);
  static const EdgeInsets v6 = EdgeInsets.symmetric(vertical: 6.0);
  static const EdgeInsets v8 = EdgeInsets.symmetric(vertical: 8.0);
  static const EdgeInsets v10 = EdgeInsets.symmetric(vertical: 10.0);
  static const EdgeInsets v12 = EdgeInsets.symmetric(vertical: 12.0);
  static const EdgeInsets v16 = EdgeInsets.symmetric(vertical: 16.0);
  static const EdgeInsets v18 = EdgeInsets.symmetric(vertical: 18.0);
  static const EdgeInsets v20 = EdgeInsets.symmetric(vertical: 20.0);
  static const EdgeInsets v22 = EdgeInsets.symmetric(vertical: 22.0);
  static const EdgeInsets v24 = EdgeInsets.symmetric(vertical: 24.0);
  static const EdgeInsets v28 = EdgeInsets.symmetric(vertical: 28.0);
  static const EdgeInsets v32 = EdgeInsets.symmetric(vertical: 32.0);
  static const EdgeInsets v40 = EdgeInsets.symmetric(vertical: 40.0);

  // Symmetric Horizontal & Vertical Combinations
  static const EdgeInsets h4v1 = EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0);
  static const EdgeInsets h4v2 = EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0);
  static const EdgeInsets h4v4 = EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0);
  static const EdgeInsets h5v2 = EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0);
  static const EdgeInsets h6v2 = EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0);
  static const EdgeInsets h6v3 = EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0);
  static const EdgeInsets h8v2 = EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0);
  static const EdgeInsets h8v3 = EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0);
  static const EdgeInsets h8v4 = EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0);
  static const EdgeInsets h9v5 = EdgeInsets.symmetric(horizontal: 9.0, vertical: 5.0);
  static const EdgeInsets h10v4 = EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0);
  static const EdgeInsets h10v5 = EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0);
  static const EdgeInsets h10v6 = EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0);
  static const EdgeInsets h10v8 = EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0);
  static const EdgeInsets h12v4 = EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0);
  static const EdgeInsets h12v5 = EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0);
  static const EdgeInsets h12v6 = EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0);
  static const EdgeInsets h12v8 = EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);
  static const EdgeInsets h12v9 = EdgeInsets.symmetric(horizontal: 12.0, vertical: 9.0);
  static const EdgeInsets h14v8 = EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0);
  static const EdgeInsets h14v10 = EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0);
  static const EdgeInsets h16v8 = EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
  static const EdgeInsets h16v10 = EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0);
  static const EdgeInsets h16v12 = EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
  static const EdgeInsets h16v16 = EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0);
  static const EdgeInsets h16v20 = EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0);
  static const EdgeInsets h18v14 = EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0);
  static const EdgeInsets h20v12 = EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0);
  static const EdgeInsets h20v14 = EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0);
  static const EdgeInsets h20v16 = EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0);

  // Common Directional Insets
  static const EdgeInsets b4 = EdgeInsets.only(bottom: 4.0);
  static const EdgeInsets b6 = EdgeInsets.only(bottom: 6.0);
  static const EdgeInsets b8 = EdgeInsets.only(bottom: 8.0);
  static const EdgeInsets b12 = EdgeInsets.only(bottom: 12.0);
  static const EdgeInsets b16 = EdgeInsets.only(bottom: 16.0);
  static const EdgeInsets b24 = EdgeInsets.only(bottom: 24.0);
  static const EdgeInsets t2 = EdgeInsets.only(top: 2.0);
  static const EdgeInsets t8 = EdgeInsets.only(top: 8.0);
  static const EdgeInsets t16 = EdgeInsets.only(top: 16.0);
  static const EdgeInsets t24 = EdgeInsets.only(top: 24.0);
  static const EdgeInsets l6 = EdgeInsets.only(left: 6.0);
  static const EdgeInsets r6 = EdgeInsets.only(right: 6.0);

  // Semantic Component Padding Tokens
  static const EdgeInsets button = h16v10;
  static const EdgeInsets buttonSmall = h10v8;
  static const EdgeInsets buttonLarge = h16v12;
  static const EdgeInsets buttonAction = h14v10;

  static const EdgeInsets badge = h9v5;
  static const EdgeInsets badgeSmall = h6v2;
  static const EdgeInsets badgeMini = h4v2;
  static const EdgeInsets pill = h10v5;
  static const EdgeInsets pillLarge = h12v6;

  static const EdgeInsets card = all16;
  static const EdgeInsets cardCompact = all12;
  static const EdgeInsets cardComfortable = all20;

  static const EdgeInsets codeCardHeader = h14v8;
  static const EdgeInsets codeCardBody = all14;
  static const EdgeInsets browserBar = h16v10;
  static const EdgeInsets browserUrlPill = h12v4;

  static const EdgeInsets navbarHorizontal = h32;
  static const EdgeInsets navbarMobile = h16;
  static const EdgeInsets pagePaddingMobile = EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0);
  static const EdgeInsets pagePaddingDesktop = EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0);
  static const EdgeInsets playgroundPaddingMobile = EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0);
  static const EdgeInsets playgroundPaddingDesktop = EdgeInsets.symmetric(horizontal: 28.0, vertical: 36.0);
  static const EdgeInsets footerDesktop = v40;
  static const EdgeInsets footerMobile = v28;
  static const EdgeInsets sidebarVertical = EdgeInsets.only(left: 28.0, right: 16.0, top: 36.0, bottom: 32.0);
  static const EdgeInsets modalScroll = EdgeInsets.only(top: 36.0, bottom: 64.0, right: 16.0);
  static const EdgeInsets tagRow = EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0);
  static const EdgeInsets sectionVertical = v24;
}
