import 'package:flutter/widgets.dart';

/// Design tokens for spacing/scale used across the app.
///
/// Best practices:
/// - Centralize spacing values in one place.
/// - Provide semantic accessors and raw scale where needed.
/// - Keep increments consistent and easy to reason about.
class AppSpacing {
  // ============================
  /// Primitives — Spacing Scale
  // ============================
  // Raw scale (in logical pixels). Values 0–80.
  static const double s0 = 0;
  static const double s1 = 1;
  static const double s2 = 2;
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s28 = 28;
  static const double s32 = 32;
  static const double s36 = 36;
  static const double s40 = 40;
  static const double s48 = 48;
  static const double s56 = 56;
  static const double s64 = 64;
  static const double s72 = 72;
  static const double s80 = 80;

  // ============================
  /// Semantic — Spacing
  // ============================
  // Aliases for common spacings.
  static const double none = s0;
  static const double xxxs = s4;
  static const double xxs = s8;
  static const double xs = s12;
  static const double sm = s16;
  static const double md = s24;
  static const double lg = s32;
  static const double xl = s40;
  static const double xxl = s56;
  static const double xxxl = s80;


  // ============================
  /// Helpers — Insets
  // ============================
  // EdgeInsets helpers for common patterns.

  // Component semantics
  static const double stackedButtons = s12; // standard gap between stacked buttons
  static const double fullWidthButtonsHorizontal = s16; // side padding for full-width buttons
  static const double textBoxHorizontal = s20; // side padding for generic text boxes
  static const double paragraphSpacing = s4; // spacing between paragraph and subsequent content
  
  // Bottom navigation bar padding: 16 top/left/right, 20 bottom
  static const EdgeInsets bottomBarPadding = EdgeInsets.fromLTRB(s16, s16, s16, s20);


  // EdgeInsets helpers for common patterns.
  static EdgeInsets all(double value) => EdgeInsets.all(value);
  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);
}

/// Radius tokens (combined into spacing file for centralization).
class AppRadius {
  // ============================
  /// Primitives — Radius
  // ============================
  // Raw radius values (logical pixels)
  static const double xs = 8;    // 8px
  static const double sm = 12;   // 12px
  static const double smOuter = 14; // 14px
  static const double md = 20;   // 20px
  static const double lg = 40;   // 40px

  // ============================
  /// Semantic — Radius
  // ============================
  // BorderRadius presets for convenience
  static const BorderRadius brXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius brSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius brSmOuter = BorderRadius.all(Radius.circular(smOuter));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(lg));

  // ============================
  /// Helpers — Radius
  // ============================
  // Convenience constructors
  static BorderRadius circular(double radius) => BorderRadius.all(Radius.circular(radius));
  static BorderRadius only({
    double topLeft = 0,
    double topRight = 0,
    double bottomRight = 0,
    double bottomLeft = 0,
  }) => BorderRadius.only(
        topLeft: Radius.circular(topLeft),
        topRight: Radius.circular(topRight),
        bottomRight: Radius.circular(bottomRight),
        bottomLeft: Radius.circular(bottomLeft),
      );
}