/// 8-point spacing scale. Use these tokens for all padding, margins and gaps.
/// If you reach for a value that isn't here (e.g. 13), you're off-scale.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4; // icon-to-text gap
  static const double sm = 8; // inside tight elements
  static const double md = 16; // default gap between elements
  static const double lg = 24; // section padding
  static const double xl = 32; // between major sections
  static const double xxl = 48; // top/bottom of pages

  /// Standard horizontal page padding (16) and top-of-content padding (24).
  static const double pageHorizontal = 16;
  static const double pageTop = 24;
}
