import 'package:flutter/material.dart';

/// Centralized standard corner radii and border radius tokens for Agentation UI elements.
abstract final class AgentationRadii {
  // ── Raw Radii (Radius) ──
  /// Micro tag or badge corner radius (3.5).
  static const Radius r3_5 = Radius.circular(3.5);

  /// Small pill, badge, or button corner radius (4.0).
  static const Radius r4 = Radius.circular(4.0);

  /// Checkbox square corner radius (4.5).
  static const Radius r4_5 = Radius.circular(4.5);

  /// Medium tag, swatch, or toolbar icon corner radius (6.0).
  static const Radius r6 = Radius.circular(6.0);

  /// Inner container clip corner radius (7.0).
  static const Radius r7 = Radius.circular(7.0);

  /// Standard input, chip, and tooltip corner radius (8.0).
  static const Radius r8 = Radius.circular(8.0);

  /// Large card element or textarea corner radius (10.0).
  static const Radius r10 = Radius.circular(10.0);

  /// Medium card or preview element corner radius (12.0).
  static const Radius r12 = Radius.circular(12.0);

  /// Dialog and floating annotation card border radius (14.0).
  static const Radius r14 = Radius.circular(14.0);

  /// Floating panel and settings panel border radius (16.0).
  static const Radius r16 = Radius.circular(16.0);

  /// Action button or save button border radius (20.0).
  static const Radius r20 = Radius.circular(20.0);

  /// Floating toolbar endcap radius (22.0).
  static const Radius r22 = Radius.circular(22.0);

  /// Full circular or pill radius (999.0).
  static const Radius rPill = Radius.circular(999.0);

  // ── Pre-composed Border Radii (BorderRadius) ──
  /// Micro tag or badge border radius (3.5).
  static const BorderRadius br3_5 = BorderRadius.all(r3_5);

  /// Small badge or micro button border radius (4.0).
  static const BorderRadius br4 = BorderRadius.all(r4);

  /// Checkbox border radius (4.5).
  static const BorderRadius br4_5 = BorderRadius.all(r4_5);

  /// Medium tag, swatch, or icon button border radius (6.0).
  static const BorderRadius br6 = BorderRadius.all(r6);

  /// Inner clip border radius (7.0).
  static const BorderRadius br7 = BorderRadius.all(r7);

  /// Standard input, tooltip, and code box border radius (8.0).
  static const BorderRadius br8 = BorderRadius.all(r8);

  /// Textarea and help tooltip bubble border radius (10.0).
  static const BorderRadius br10 = BorderRadius.all(r10);

  /// Preview container border radius (12.0).
  static const BorderRadius br12 = BorderRadius.all(r12);

  /// Floating annotation popup and detail card border radius (14.0).
  static const BorderRadius br14 = BorderRadius.all(r14);

  /// Floating settings panel border radius (16.0).
  static const BorderRadius br16 = BorderRadius.all(r16);

  /// Button border radius (20.0).
  static const BorderRadius br20 = BorderRadius.all(r20);

  /// Floating pill toolbar border radius (22.0).
  static const BorderRadius br22 = BorderRadius.all(r22);

  /// Completely circular / pill border radius (999.0).
  static const BorderRadius brPill = BorderRadius.all(rPill);

  // ── Semantic Component Aliases ──
  /// Floating toolbar container border radius.
  static const BorderRadius toolbar = br22;

  /// Floating annotation input card border radius.
  static const BorderRadius card = br14;

  /// Settings flyout panel border radius.
  static const BorderRadius panel = br16;

  /// Comment textarea border radius.
  static const BorderRadius input = br10;

  /// Toolbar action button border radius.
  static const BorderRadius button = br20;

  /// Tooltip bubble border radius.
  static const BorderRadius tooltip = br8;

  /// Tag / badge border radius.
  static const BorderRadius badge = br4;

  /// Checkbox border radius.
  static const BorderRadius checkbox = br4_5;

  /// Action icon button border radius.
  static const BorderRadius iconButton = br6;
}
