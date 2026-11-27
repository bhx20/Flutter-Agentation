import 'package:flutter/material.dart';

/// Centralized border radii tokens for the Flutter Agentation design system.
/// All border radius and corner radius values used across the application are centralized here.
abstract final class AppRadii {
  // Base Corner Radii
  static const Radius r2 = Radius.circular(2);
  static const Radius r3 = Radius.circular(3);
  static const Radius r4 = Radius.circular(4);
  static const Radius r5 = Radius.circular(5);
  static const Radius r6 = Radius.circular(6);
  static const Radius r8 = Radius.circular(8);
  static const Radius r10 = Radius.circular(10);
  static const Radius r12 = Radius.circular(12);
  static const Radius r16 = Radius.circular(16);
  static const Radius rFull = Radius.circular(100);

  // Base Border Radii (Uniform)
  static const BorderRadius zero = BorderRadius.zero;
  static const BorderRadius rounded2 = BorderRadius.all(r2);
  static const BorderRadius rounded3 = BorderRadius.all(r3);
  static const BorderRadius rounded4 = BorderRadius.all(r4);
  static const BorderRadius rounded5 = BorderRadius.all(r5);
  static const BorderRadius rounded6 = BorderRadius.all(r6);
  static const BorderRadius rounded8 = BorderRadius.all(r8);
  static const BorderRadius rounded10 = BorderRadius.all(r10);
  static const BorderRadius rounded12 = BorderRadius.all(r12);
  static const BorderRadius rounded16 = BorderRadius.all(r16);
  static const BorderRadius roundedFull = BorderRadius.all(rFull);

  // Semantic Component Tokens
  static const BorderRadius button = rounded4;
  static const BorderRadius buttonLarge = rounded6;
  static const BorderRadius buttonPill = roundedFull;

  static const BorderRadius badge = rounded4;
  static const BorderRadius badgeSmall = rounded3;
  static const BorderRadius badgePill = roundedFull;

  static const BorderRadius tag = rounded4;
  static const BorderRadius chip = rounded4;
  static const BorderRadius pill = rounded6;

  static const BorderRadius card = rounded8;
  static const BorderRadius cardLarge = rounded12;

  static const BorderRadius dialog = rounded8;
  static const BorderRadius browserWindow = rounded12;
  static const BorderRadius codeBlock = rounded8;
  static const BorderRadius input = rounded6;
  static const BorderRadius scrollbar = rounded5;

  // Directional Radii
  static const BorderRadius cardLeft = BorderRadius.only(topLeft: r8, bottomLeft: r8);
  static const BorderRadius cardRight = BorderRadius.only(topRight: r8, bottomRight: r8);
  static const BorderRadius cardTop = BorderRadius.vertical(top: r8);
  static const BorderRadius cardBottom = BorderRadius.vertical(bottom: r8);

  static const BorderRadius windowTop = BorderRadius.vertical(top: r12);
  static const BorderRadius windowBottom = BorderRadius.vertical(bottom: r12);

  static const BorderRadius codeTop = BorderRadius.vertical(top: r8);
  static const BorderRadius codeBottom = BorderRadius.vertical(bottom: r8);
}
