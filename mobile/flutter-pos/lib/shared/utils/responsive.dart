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

  /// Below this shortest-side width, a device is a phone. Matches
  /// Material Design's standard tablet threshold, and the threshold
  /// `main.dart` uses to decide which orientation to lock the app to.
  static const double tabletBreakpoint = 600;

  /// Width above which a tablet gets a 5th product-grid column instead
  /// of 4 (large tablets / small desktops in a split view).
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
    } else if (width >= 900) {
      cols = 4;
    } else if (width >= tabletBreakpoint) {
      cols = 3;
    } else if (width >= 420) {
      cols = 2;
    } else {
      cols = 1;
    }
    return cols > max ? max : cols;
  }
}
