import 'package:flutter/material.dart';

/// Centralized standard corner radii and border radius tokens for Agentation UI elements.
abstract final class AgentationRadii {
  // ── Raw Radii (Radius) ──
  /// Subtle divider, bar or progress indicator corner radius (2.0).
  static const Radius r2 = Radius.circular(2.0);

  /// Micro indicator bar corner radius (3.0).
  static const Radius r3 = Radius.circular(3.0);

  /// Micro tag or badge corner radius (3.5).
  static const Radius r3_5 = Radius.circular(3.5);

  /// Small pill, badge, or button corner radius (4.0).
  static const Radius r4 = Radius.circular(4.0);

  /// Checkbox square corner radius (4.5).
  static const Radius r4_5 = Radius.circular(4.5);

  /// Tiny action tag corner radius (5.0).
  static const Radius r5 = Radius.circular(5.0);

  /// Medium tag, swatch, or toolbar icon corner radius (6.0).
  static const Radius r6 = Radius.circular(6.0);

  /// Inner container clip corner radius (7.0).
  static const Radius r7 = Radius.circular(7.0);

  /// Standard input, chip, and tooltip corner radius (8.0).
  static const Radius r8 = Radius.circular(8.0);

  /// Toolbar counter badge corner radius (9.0).
  static const Radius r9 = Radius.circular(9.0);

  /// Large card element or textarea corner radius (10.0).
  static const Radius r10 = Radius.circular(10.0);

  /// Avatar inner corner radius (11.0).
  static const Radius r11 = Radius.circular(11.0);

  /// Medium card or preview element corner radius (12.0).
  static const Radius r12 = Radius.circular(12.0);

  /// Rounded compact chip corner radius (13.0).
  static const Radius r13 = Radius.circular(13.0);

  /// Dialog and floating annotation card border radius (14.0).
  static const Radius r14 = Radius.circular(14.0);

  /// Floating panel and settings panel border radius (16.0).
  static const Radius r16 = Radius.circular(16.0);

  /// Large dialog container border radius (18.0).
  static const Radius r18 = Radius.circular(18.0);

  /// Action button or save button border radius (20.0).
  static const Radius r20 = Radius.circular(20.0);

  /// Floating toolbar endcap radius (22.0).
  static const Radius r22 = Radius.circular(22.0);

  /// Full circular or pill radius (999.0).
  static const Radius rPill = Radius.circular(999.0);

  // ── Pre-composed Border Radii (BorderRadius) ──
  /// Progress indicator or bar border radius (2.0).
  static const BorderRadius br2 = BorderRadius.all(r2);

  /// Micro indicator bar border radius (3.0).
  static const BorderRadius br3 = BorderRadius.all(r3);

  /// Micro tag or badge border radius (3.5).
  static const BorderRadius br3_5 = BorderRadius.all(r3_5);

  /// Small badge or micro button border radius (4.0).
  static const BorderRadius br4 = BorderRadius.all(r4);

  /// Checkbox border radius (4.5).
  static const BorderRadius br4_5 = BorderRadius.all(r4_5);

  /// Tiny action tag border radius (5.0).
  static const BorderRadius br5 = BorderRadius.all(r5);

  /// Medium tag, swatch, or icon button border radius (6.0).
  static const BorderRadius br6 = BorderRadius.all(r6);

  /// Inner clip border radius (7.0).
  static const BorderRadius br7 = BorderRadius.all(r7);

  /// Standard input, tooltip, and code box border radius (8.0).
  static const BorderRadius br8 = BorderRadius.all(r8);

  /// Toolbar counter badge border radius (9.0).
  static const BorderRadius br9 = BorderRadius.all(r9);

  /// Textarea and help tooltip bubble border radius (10.0).
  static const BorderRadius br10 = BorderRadius.all(r10);

  /// Avatar inner border radius (11.0).
  static const BorderRadius br11 = BorderRadius.all(r11);

  /// Preview container border radius (12.0).
  static const BorderRadius br12 = BorderRadius.all(r12);

  /// Compact rounded chip border radius (13.0).
  static const BorderRadius br13 = BorderRadius.all(r13);

  /// Floating annotation popup and detail card border radius (14.0).
  static const BorderRadius br14 = BorderRadius.all(r14);

  /// Floating settings panel border radius (16.0).
  static const BorderRadius br16 = BorderRadius.all(r16);

  /// Large dialog container border radius (18.0).
  static const BorderRadius br18 = BorderRadius.all(r18);

  /// Button border radius (20.0).
  static const BorderRadius br20 = BorderRadius.all(r20);

  /// Floating pill toolbar border radius (22.0).
  static const BorderRadius br22 = BorderRadius.all(r22);

  /// Completely circular / pill border radius (999.0).
  static const BorderRadius brPill = BorderRadius.all(rPill);

  // ── Directional & Top / Bottom Radii ──
  /// Card header top border radius (12.0).
  static const BorderRadius brTop12 = BorderRadius.vertical(top: r12);

  /// Card header top border radius (14.0).
  static const BorderRadius brTop14 = BorderRadius.vertical(top: r14);

  /// Card bottom border radius (12.0).
  static const BorderRadius brBottom12 = BorderRadius.vertical(bottom: r12);

  /// Card bottom border radius (14.0).
  static const BorderRadius brBottom14 = BorderRadius.vertical(bottom: r14);

  /// Sheet header top border radius (16.0).
  static const BorderRadius brTop16 = BorderRadius.vertical(top: r16);

  /// Sheet footer bottom border radius (16.0).
  static const BorderRadius brBottom16 = BorderRadius.vertical(bottom: r16);

  // ── Semantic Component Aliases ──
  /// Floating toolbar container border radius.
  static const BorderRadius toolbar = br22;

  /// Floating annotation input card border radius.
  static const BorderRadius card = br14;

  /// Settings flyout panel border radius.
  static const BorderRadius panel = br16;

  /// Comment textarea border radius.
  static const BorderRadius input = br10;

  /// Compact input field border radius.
  static const BorderRadius inputCompact = br8;

  /// Toolbar action button border radius.
  static const BorderRadius button = br20;

  /// Compact button border radius.
  static const BorderRadius buttonCompact = br6;

  /// Pill button border radius.
  static const BorderRadius buttonPill = br20;

  /// Tooltip bubble border radius.
  static const BorderRadius tooltip = br8;

  /// Help tooltip bubble border radius.
  static const BorderRadius tooltipHelp = br10;

  /// Tag / badge border radius.
  static const BorderRadius badge = br4;

  /// Small badge border radius.
  static const BorderRadius badgeSmall = br3_5;

  /// Checkbox border radius.
  static const BorderRadius checkbox = br4_5;

  /// Action icon button border radius.
  static const BorderRadius iconButton = br6;

  /// Standard selection chip border radius.
  static const BorderRadius chip = br8;

  /// Pill chip border radius.
  static const BorderRadius chipPill = br14;

  /// Rounded preview element border radius.
  static const BorderRadius previewCard = br12;

  /// Code block container border radius.
  static const BorderRadius codeBlock = br8;

  /// Color swatch button border radius.
  static const BorderRadius colorSwatch = br6;
}
