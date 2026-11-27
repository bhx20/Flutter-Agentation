import 'package:flutter/material.dart';

/// Centralized dimensions, sizing tokens, gaps, and spacers for the Flutter Agentation design system.
/// All dimension tokens, icon sizes, component heights/widths, layout constraints,
/// and reusable spacing boxes are centralized here.
abstract final class AppDimensions {
  // Base Dimension Scale (d0 through d1280)
  static const double d0 = 0.0;
  static const double d1 = 1.0;
  static const double d1_5 = 1.5;
  static const double d2 = 2.0;
  static const double d3 = 3.0;
  static const double d4 = 4.0;
  static const double d5 = 5.0;
  static const double d6 = 6.0;
  static const double d7 = 7.0;
  static const double d8 = 8.0;
  static const double d10 = 10.0;
  static const double d11 = 11.0;
  static const double d12 = 12.0;
  static const double d13 = 13.0;
  static const double d14 = 14.0;
  static const double d15 = 15.0;
  static const double d16 = 16.0;
  static const double d18 = 18.0;
  static const double d20 = 20.0;
  static const double d22 = 22.0;
  static const double d24 = 24.0;
  static const double d25 = 25.0;
  static const double d28 = 28.0;
  static const double d30 = 30.0;
  static const double d32 = 32.0;
  static const double d36 = 36.0;
  static const double d38 = 38.0;
  static const double d40 = 40.0;
  static const double d44 = 44.0;
  static const double d48 = 48.0;
  static const double d50 = 50.0;
  static const double d60 = 60.0;
  static const double d64 = 64.0;
  static const double d65 = 65.0;
  static const double d70 = 70.0;
  static const double d80 = 80.0;
  static const double d90 = 90.0;
  static const double d100 = 100.0;
  static const double d110 = 110.0;
  static const double d125 = 125.0;
  static const double d140 = 140.0;
  static const double d160 = 160.0;
  static const double d170 = 170.0;
  static const double d176 = 176.0;
  static const double d180 = 180.0;
  static const double d190 = 190.0;
  static const double d220 = 220.0;
  static const double d230 = 230.0;
  static const double d240 = 240.0;
  static const double d260 = 260.0;
  static const double d310 = 310.0;
  static const double d340 = 340.0;
  static const double d440 = 440.0;
  static const double d480 = 480.0;
  static const double d640 = 640.0;
  static const double d680 = 680.0;
  static const double d720 = 720.0;
  static const double d860 = 860.0;
  static const double d896 = 896.0;
  static const double d1024 = 1024.0;
  static const double d1280 = 1280.0;

  // Semantic Spacing / Gaps
  static const double gap2 = d2;
  static const double gap4 = d4;
  static const double gap6 = d6;
  static const double gap8 = d8;
  static const double gap10 = d10;
  static const double gap12 = d12;
  static const double gap14 = d14;
  static const double gap16 = d16;
  static const double gap18 = d18;
  static const double gap20 = d20;
  static const double gap24 = d24;
  static const double gap28 = d28;
  static const double gap32 = d32;
  static const double gap36 = d36;
  static const double gap40 = d40;
  static const double gap48 = d48;
  static const double gap64 = d64;

  // Semantic Icon Sizes
  static const double iconNano = d11;
  static const double iconXs = d12;
  static const double iconSm = d13;
  static const double iconBase = d14;
  static const double iconMedium = d16;
  static const double iconLg = d18;
  static const double iconXl = d20;
  static const double icon2Xl = d24;
  static const double icon3Xl = d32;

  // Semantic Component Dimensions
  static const double strokeThin = d1;
  static const double strokeActive = d1_5;
  static const double strokeMedium = d2;
  static const double dividerThickness = d1;
  static const double statusIndicatorDot = d8;
  static const double indicatorBadgeHeight = d22;
  static const double buttonHeightSm = d28;
  static const double buttonHeight = d36;
  static const double buttonHeightLg = d44;
  static const double inputHeight = d40;
  static const double searchBarHeight = d44;
  static const double navbarHeight = d64;
  static const double sidebarWidth = d260;
  static const double maxContentWidth = d1280;
  static const double maxHeroWidth = d896;
  static const double maxTextWidth = d680;
  static const double maxCardWidth = d480;
  static const double modalMaxWidth = d640;

  // Predefined Horizontal & Vertical Spacers (SizedBox)
  static const SizedBox none = SizedBox.shrink();

  // Horizontal Spacers
  static const SizedBox w2 = SizedBox(width: d2);
  static const SizedBox w4 = SizedBox(width: d4);
  static const SizedBox w5 = SizedBox(width: d5);
  static const SizedBox w6 = SizedBox(width: d6);
  static const SizedBox w7 = SizedBox(width: d7);
  static const SizedBox w8 = SizedBox(width: d8);
  static const SizedBox w10 = SizedBox(width: d10);
  static const SizedBox w12 = SizedBox(width: d12);
  static const SizedBox w14 = SizedBox(width: d14);
  static const SizedBox w16 = SizedBox(width: d16);
  static const SizedBox w20 = SizedBox(width: d20);
  static const SizedBox w24 = SizedBox(width: d24);
  static const SizedBox w28 = SizedBox(width: d28);
  static const SizedBox w32 = SizedBox(width: d32);

  // Vertical Spacers
  static const SizedBox h2 = SizedBox(height: d2);
  static const SizedBox h4 = SizedBox(height: d4);
  static const SizedBox h5 = SizedBox(height: d5);
  static const SizedBox h6 = SizedBox(height: d6);
  static const SizedBox h7 = SizedBox(height: d7);
  static const SizedBox h8 = SizedBox(height: d8);
  static const SizedBox h10 = SizedBox(height: d10);
  static const SizedBox h12 = SizedBox(height: d12);
  static const SizedBox h14 = SizedBox(height: d14);
  static const SizedBox h16 = SizedBox(height: d16);
  static const SizedBox h18 = SizedBox(height: d18);
  static const SizedBox h20 = SizedBox(height: d20);
  static const SizedBox h22 = SizedBox(height: d22);
  static const SizedBox h24 = SizedBox(height: d24);
  static const SizedBox h28 = SizedBox(height: d28);
  static const SizedBox h32 = SizedBox(height: d32);
  static const SizedBox h36 = SizedBox(height: d36);
  static const SizedBox h40 = SizedBox(height: d40);
  static const SizedBox h48 = SizedBox(height: d48);
  static const SizedBox h64 = SizedBox(height: d64);
}
