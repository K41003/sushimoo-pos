/// Single source of truth for spacing, radius and sizing tokens.
///
/// CLEANUP: the previous version had two overlapping spacing scales
/// (`gap/gapMd/gapLg` AND `xs/sm/md/lg/xl/xxl/xxxl`) that mapped to
/// almost-but-not-quite the same values (`gap=16` vs `md=16`, `gapLg=24`
/// vs `xl=24`, etc). Screens ended up mixing both scales inconsistently
/// (e.g. `SizedBox(height: 16.h)` next to `AppDimensions.md`), which is
/// exactly the kind of drift that makes spacing look "almost right but
/// not quite" across pages.
///
/// This file keeps ONLY the `xs..xxxl` 8px-rhythm scale as the canonical
/// one. `gap`, `gapMd`, `gapLg` are kept as deprecated aliases pointing
/// at the same underlying values so any old call site still compiles
/// without behavior change, but new code should use `sm/md/lg/xl` etc.
class AppDimensions {
  AppDimensions._();

  /// 8px baseline rhythm.
  static const double unit = 8.0;

  /// Canonical spacing scale — use these everywhere.
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;

  // ---- Deprecated aliases (kept for backward compatibility only) -------
  @Deprecated('Use AppDimensions.xl instead')
  static const double gutter = 20.0;
  @Deprecated('Use AppDimensions.xl instead')
  static const double cardPadding = 22.0;
  @Deprecated('Use AppDimensions.md instead')
  static const double gap = 16.0;
  @Deprecated('Use AppDimensions.lg instead')
  static const double gapMd = 20.0;
  @Deprecated('Use AppDimensions.xl instead')
  static const double gapLg = 24.0;

  /// Minimum touch target, sized up for cashier-friendly big tap areas.
  static const double touchTarget = 52.0;

  static const double railWidth = 88.0;
  static const double sidebarWidth = 320.0;

  /// Page-level horizontal/vertical margins, per device tier. Devices
  /// are now locked to exactly one orientation each (phones: portrait,
  /// tablets: landscape — see main.dart), so this app only ever needs
  /// these 2 tiers.
  static const double marginMobile = 18.0;
  static const double marginTablet = 28.0;

  /// Soft rounded-corner tokens. 14–32 reads as "premium" once blur is
  /// applied; anything under 14dp looks flat on a glass surface.
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
