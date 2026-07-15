class AppDimensions {
  AppDimensions._();

  /// 8px baseline rhythm — kept generous (whitespace-forward layout).
  static const double unit = 8.0;
  static const double gutter = 20.0;
  static const double cardPadding = 22.0;

  /// Minimum touch target, sized up for cashier-friendly big tap areas.
  static const double touchTarget = 52.0;

  static const double railWidth = 84.0;
  static const double sidebarWidth = 316.0;
  static const double marginMobile = 18.0;
  static const double marginTablet = 28.0;

  /// Soft rounded-corner tokens (12–16 per brief). No sharp corners.
  static const double radiusSm = 12.0;
  static const double radiusMd = 14.0;
  static const double radiusLg = 18.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 9999.0;

  /// Big, thumb-friendly button heights.
  static const double buttonHeight = 58.0;
  static const double stepperWidth = 64.0;

  /// Hairline border width used everywhere instead of shadows.
  static const double hairline = 1.0;
}
