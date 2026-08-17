class AppDimensions {
  AppDimensions._();

  /// 8px baseline rhythm — kept generous (whitespace-forward layout).
  static const double unit = 8.0;
  static const double gutter = 20.0;
  static const double cardPadding = 22.0;

  /// Consistent spacing scale (16–24 per brief) used across screens.
  static const double gap = 16.0;
  static const double gapMd = 20.0;
  static const double gapLg = 24.0;

  /// Extended spacing scale for glass-screen layouts.
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;

  /// Minimum touch target, sized up for cashier-friendly big tap areas.
  static const double touchTarget = 52.0;

  static const double railWidth = 88.0;
  static const double sidebarWidth = 320.0;
  static const double marginMobile = 18.0;
  static const double marginTablet = 28.0;

  /// Soft rounded-corner tokens. Bumped up from the old 12–24 scale to
  /// 14–32 — glassmorphic panels read as "premium" only at higher radii;
  /// anything under 14dp looks flat once blur is applied.
  static const double radiusSm = 14.0;
  static const double radiusMd = 18.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 28.0;
  static const double radiusXxl = 32.0;
  static const double radiusFull = 9999.0;

  /// Big, thumb-friendly button heights.
  static const double buttonHeight = 58.0;
  static const double buttonHeightSm = 46.0;
  static const double stepperWidth = 64.0;

  /// Hairline border width used for subtle outlines.
  static const double hairline = 1.0;

  /// Glass panel border width — thin, catches light at the edge.
  static const double glassBorderWidth = 1.2;
}
