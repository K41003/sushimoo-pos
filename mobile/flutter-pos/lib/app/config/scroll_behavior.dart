import 'package:flutter/material.dart';

/// Fixes the "stretch / rubber-band" overscroll effect seen on Android
/// simulators and devices (Android 12+ defaults to
/// [StretchingOverscrollIndicator], which visibly squashes/stretches the
/// whole page when you scroll past the edge).
///
/// We standardize on [ClampingScrollPhysics] (no bounce, no stretch) across
/// every platform so POS grids, lists, and sheets scroll the same way on
/// Android, iOS, and desktop, and never distort the page.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // No glow, no stretch — just clamp at the edge.
    return child;
  }
}
