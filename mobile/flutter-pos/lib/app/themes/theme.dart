import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/colors.dart';
import '../constants/dimensions.dart';

/// Clean sans-serif type scale. Prices get their own bold/oversized style
/// so the number a cashier cares about most is always the loudest thing
/// on screen.
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Inter';

  static TextTheme get textTheme => TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 44.sp,
          fontWeight: FontWeight.w800,
          height: 1.1,
          letterSpacing: -0.5,
          color: AppColors.ink,
        ),
        headlineLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 30.sp,
          fontWeight: FontWeight.w700,
          height: 1.2,
          letterSpacing: -0.3,
          color: AppColors.ink,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 22.sp,
          fontWeight: FontWeight.w700,
          height: 1.25,
          letterSpacing: -0.2,
          color: AppColors.ink,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 17.sp,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: AppColors.ink,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 15.sp,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: AppColors.inkMuted,
        ),
        labelLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          height: 1.3,
          letterSpacing: 0.3,
          color: AppColors.inkMuted,
        ),
        labelSmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 11.5.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          color: AppColors.inkMuted,
        ),
      );

  /// Big bold price/quantity numerals — the loudest text on the screen.
  static TextStyle price = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30.sp,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: AppColors.ink,
  );

  static TextStyle priceCompact = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.sp,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.2,
    color: AppColors.ink,
  );
}

class AppTheme {
  AppTheme._();

  /// A single light theme — calm slate canvas, white floating cards, one
  /// warm orange-salmon accent.
  static ThemeData get light => _build();

  static const _shadow = Color(0x1A0F172A);

  static ThemeData _build() {
    final scheme = AppColors.scheme;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.surface,
      fontFamily: AppTypography.fontFamily,
      textTheme: AppTypography.textTheme,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,

      // Cards: white surface, soft radius, whisper hairline. The floating
      // shadow comes from AppCard / AppDecorations rather than Material
      // elevation, so it stays soft and high-blur.
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg.r),
          side: const BorderSide(color: AppColors.hairline, width: 1),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.textTheme.headlineMedium,
        iconTheme: const IconThemeData(color: AppColors.ink),
        shadowColor: _shadow,
      ),

      // Primary CTA — solid orange-salmon, the one loud color on screen,
      // lifted with a soft shadow.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.salmon,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.salmon.withValues(alpha: 0.35),
          disabledForegroundColor: Colors.white,
          elevation: 3,
          shadowColor: _shadow,
          minimumSize: Size(double.infinity, AppDimensions.buttonHeight.h),
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
          ),
          textStyle: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
            letterSpacing: -0.1,
          ),
        ),
      ),

      // Secondary action — quiet ink outline, no fill.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          disabledForegroundColor: AppColors.inkFaint,
          minimumSize: Size(double.infinity, AppDimensions.buttonHeight.h),
          side: const BorderSide(color: AppColors.hairline, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
          ),
          textStyle: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.inkMuted,
          textStyle: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 15.sp,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
        hintStyle: TextStyle(color: AppColors.inkFaint, fontSize: 15.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
          borderSide: const BorderSide(color: AppColors.hairline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
          borderSide: const BorderSide(color: AppColors.hairline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
          borderSide: const BorderSide(color: AppColors.ink, width: 1.6),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceAlt,
        selectedColor: AppColors.ink,
        labelStyle: const TextStyle(color: AppColors.ink),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        side: const BorderSide(color: AppColors.hairline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.salmon,
        foregroundColor: Colors.white,
        elevation: 4,
        extendedTextStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 15.sp,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.hairline,
        thickness: 1,
        space: 1,
      ),

      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.ink,
        selectionColor: Color(0x33FF7A59),
        selectionHandleColor: AppColors.salmon,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.salmon,
      ),

      iconTheme: const IconThemeData(color: AppColors.ink),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl.r),
        ),
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        contentTextStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 15.sp,
          color: AppColors.inkMuted,
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        elevation: 12,
        shadowColor: _shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXl.r),
          ),
        ),
      ),
    );
  }
}
