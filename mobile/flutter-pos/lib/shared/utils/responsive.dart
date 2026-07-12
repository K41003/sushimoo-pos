import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Responsive {
  Responsive._();

  static bool isTablet(BuildContext context) {
    final shortest = MediaQuery.of(context).size.shortestSide;
    return shortest >= 600;
  }

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  /// True for the POS-style landscape tablet (rail + master + detail).
  static bool isLandscapeTablet(BuildContext context) =>
      isTablet(context) && isLandscape(context);

  static double padding(BuildContext context) =>
      isTablet(context)
          ? 24.w
          : 16.w;
}
