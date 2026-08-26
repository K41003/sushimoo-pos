import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../constants/dimensions.dart';

/// Typography hierarchy for "Glassmorphic Zen" Pro Max.
///
/// REPLACES the old flat-theme typography file 1:1 — `AppTypography.price`
/// and `AppTypography.textTheme` keep the same names/types so nothing
/// referencing them elsewhere breaks. Internally it now uses Google Fonts.
///
/// Font pairing:
///  - Display / Headline -> Plus Jakarta Sans (geometric, warm, reads
///    premium on translucent glass backgrounds)
///  - Body / Label       -> Manrope (stays crisp at small sizes over
///    blurred surfaces — important for legibility)
///
/// Rule of thumb on glass: bump font-weight one notch heavier than you
/// would on a flat white card, since blur softens edge contrast.
class AppTypography {
  AppTypography._();

  static TextStyle get _display => GoogleFonts.plusJakartaSans();
  static TextStyle get _body => GoogleFonts.manrope();

  static String get fontFamily => GoogleFonts.manrope().fontFamily!;

  static TextTheme get textTheme => TextTheme(
        displayLarge: _display.copyWith(
          fontSize: 40.sp,
          fontWeight: FontWeight.w800,
          height: 1.1,
          letterSpacing: -0.8,
          color: AppColors.ink,
        ),
        headlineLarge: _display.copyWith(
          fontSize: 30.sp,
          fontWeight: FontWeight.w700,
          height: 1.2,
          letterSpacing: -0.4,
          color: AppColors.ink,
        ),
        headlineMedium: _display.copyWith(
          fontSize: 22.sp,
          fontWeight: FontWeight.w700,
          height: 1.25,
          letterSpacing: -0.3,
          color: AppColors.ink,
        ),
        headlineSmall: _display.copyWith(
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
          height: 1.3,
          letterSpacing: -0.2,
          color: AppColors.ink,
        ),
        bodyLarge: _body.copyWith(
          fontSize: 17.sp,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: AppColors.ink,
        ),
        bodyMedium: _body.copyWith(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: AppColors.inkMuted,
        ),
        bodySmall: _body.copyWith(
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: AppColors.inkMuted,
        ),
        labelLarge: _body.copyWith(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          height: 1.3,
          letterSpacing: 0.3,
          color: AppColors.inkMuted,
        ),
        labelSmall: _body.copyWith(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: AppColors.inkMuted,
        ),
      );

  /// Big bold price/quantity numerals — the loudest text on the screen.
  static TextStyle get price => _display.copyWith(
        fontSize: 30.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: AppColors.ink,
      );

  static TextStyle get priceCompact => _display.copyWith(
        fontSize: 18.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
        color: AppColors.ink,
      );

  static TextStyle get priceHero => _display.copyWith(
        fontSize: 44.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        color: AppColors.ink,
      );
}

class AppTheme {
  AppTheme._();

  /// A single light theme — gradient glass canvas, frosted floating
  /// panels, one warm orange-salmon accent gradient.
  static ThemeData get light => _build();

  static const _shadow = Color(0x1A10182B);

  static ThemeData _build() {
    final scheme = AppColors.scheme;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bgBase,
      fontFamily: AppTypography.fontFamily,
      textTheme: AppTypography.textTheme,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,

      // Cards default to a soft translucent surface; screens that want
      // the full frosted-blur effect should use GlassPanel instead of
      // relying on CardTheme alone (BackdropFilter can't be expressed
      // as a static theme).
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.65),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg.r),
          side: BorderSide(color: AppColors.glassBorder(opacity: 0.7), width: 1.2),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.textTheme.headlineMedium,
        iconTheme: const IconThemeData(color: AppColors.ink),
        shadowColor: _shadow,
      ),

      // Primary CTA fallback (prefer GlassPrimaryButton for the gradient
      // + press micro-interaction; this theme covers any stock
      // ElevatedButton left in un-migrated screens).
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.salmon,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.salmon.withValues(alpha: 0.35),
          disabledForegroundColor: Colors.white,
          elevation: 3,
          shadowColor: AppColors.salmon.withValues(alpha: 0.35),
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

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          disabledForegroundColor: AppColors.inkFaint,
          backgroundColor: Colors.white.withValues(alpha: 0.4),
          minimumSize: Size(double.infinity, AppDimensions.buttonHeight.h),
          side: BorderSide(color: AppColors.glassBorder(opacity: 0.7), width: 1.4),
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
        fillColor: Colors.white.withValues(alpha: 0.5),
        hintStyle: TextStyle(color: AppColors.inkFaint, fontSize: 15.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
          borderSide: BorderSide(color: AppColors.glassBorder(opacity: 0.7), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
          borderSide: BorderSide(color: AppColors.glassBorder(opacity: 0.7), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
          borderSide: const BorderSide(color: AppColors.salmon, width: 1.6),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.45),
        selectedColor: AppColors.salmon,
        labelStyle: const TextStyle(color: AppColors.ink),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        side: BorderSide(color: AppColors.glassBorder(opacity: 0.7)),
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

      dividerTheme: DividerThemeData(
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
        backgroundColor: Colors.white.withValues(alpha: 0.85),
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
        backgroundColor: AppColors.bgBase,
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
