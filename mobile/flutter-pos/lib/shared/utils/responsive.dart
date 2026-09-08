import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app/constants/dimensions.dart';

/// Single source of truth for responsive/device-tier decisions across
/// the whole app. Every screen-size decision (padding, grid columns,
/// rail vs drawer) should read from here instead of hardcoding its own
/// `constraints.maxWidth > 900` style check.
///
/// SIMPLIFIED (this pass): the app now locks orientation per device at
/// startup (see `main.dart`) — phones are portrait-only, tablets are
/// landscape-only. There is no more "tablet held upright" state to
/// design for, so the previous 3-tier system (mobile /
/// tabletPortrait / tabletLandscape) collapses back down to 2: a device
/// is either a [DeviceClass.mobile] (phone, always portrait) or a
/// [DeviceClass.tablet] (always landscape, this app's primary/reference
/// layout — side rail navigation, more grid columns, more generous
/// padding). Checking orientation is no longer necessary since it's now
/// fully determined by device size.
enum DeviceClass { mobile, tablet }

class Responsive {
  Responsive._();

  /// Below this shortest-side width, a device is a phone.
  /// Set to 580 to reliably include 7" and 8" tablets that may report
  /// shortest side ~580-600dp after system UI insets.
  static const double tabletBreakpoint = 580;

  /// Width above which a tablet gets extra grid columns.
  static const double wideBreakpoint = 1100;

  static bool isTablet(BuildContext context) {
    final shortest = MediaQuery.of(context).size.shortestSide;
    return shortest >= tabletBreakpoint;
  }

  static DeviceClass classOf(BuildContext context) =>
      isTablet(context) ? DeviceClass.tablet : DeviceClass.mobile;

  /// Page-level horizontal/vertical margin, scaled per device tier.
  static double padding(BuildContext context) {
    return isTablet(context)
        ? AppDimensions.marginTablet.w
        : AppDimensions.marginMobile.w;
  }

  /// Product/menu grid column count for a given available width.
  static int gridColumns(BuildContext context, {int max = 4}) {
    final width = MediaQuery.of(context).size.width;
    int cols;
    if (width >= wideBreakpoint) {
      cols = 5;
    } else if (width >= 880) {
      cols = 4;
    } else if (width >= 650) {
      cols = 3;
    } else if (width >= 380) {
      cols = 2;
    } else {
      cols = 1;
    }
    return cols > max ? max : cols;
  }

  /// Calculates dynamic column count based on *actual available content width*
  /// (e.g. from [LayoutBuilder] constraints), ensuring each card has at least
  /// [itemMinWidth] so elements are never squished.
  static int columnsForWidth(
    double availableWidth, {
    double itemMinWidth = 165.0,
    int min = 1,
    int max = 5,
  }) {
    if (availableWidth <= 0) return min;
    final calculated = (availableWidth / itemMinWidth).floor();
    return calculated.clamp(min, max);
  }

  /// Computes a dynamic childAspectRatio for GridView so that items have a
  /// consistent, target height regardless of screen or column width variations.
  static double aspectRatioFor({
    required double availableWidth,
    required int columns,
    required double targetHeight,
    double spacing = 12.0,
    double minRatio = 0.75,
    double maxRatio = 2.8,
  }) {
    if (columns <= 0 || targetHeight <= 0) return 1.0;
    final totalSpacing = (columns - 1) * spacing;
    final itemWidth = (availableWidth - totalSpacing) / columns;
    final ratio = itemWidth / targetHeight;
    return ratio.clamp(minRatio, maxRatio);
  }
}
