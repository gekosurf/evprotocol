import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sailor/core/theme/app_colors.dart';
import 'package:sailor/core/theme/app_text_styles.dart';

/// Builds the dark theme for the Sailor app.
///
/// Pure black backgrounds, yellow highlight for active/selected state,
/// condensed typography for data-dense iOS layouts.
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Inter',

    // === COLORS ===
    colorScheme: const ColorScheme.dark(
      primary: AppColors.highlight,
      onPrimary: AppColors.textOnHighlight,
      secondary: AppColors.highlightDim,
      onSecondary: AppColors.textOnHighlight,
      surface: AppColors.surfaceBg,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: AppColors.textPrimary,
    ),
    scaffoldBackgroundColor: AppColors.scaffoldBg,
    canvasColor: AppColors.scaffoldBg,
    dividerColor: AppColors.divider,

    // === APP BAR ===
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.scaffoldBg,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.h3,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),

    // === BUTTONS ===
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.highlight,
        foregroundColor: AppColors.textOnHighlight,
        textStyle: AppTextStyles.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        textStyle: AppTextStyles.buttonSecondary,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.highlight,
        textStyle: AppTextStyles.buttonSecondary.copyWith(
          color: AppColors.highlight,
        ),
      ),
    ),

    // === TEXT FIELDS ===
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.highlight, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      hintStyle: AppTextStyles.bodySecondary,
      labelStyle: AppTextStyles.label,
    ),

    // === CARDS ===
    cardTheme: CardThemeData(
      color: AppColors.cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 0.5),
      ),
      margin: EdgeInsets.zero,
    ),

    // === BOTTOM SHEET ===
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.dialogBg,
      modalBarrierColor: AppColors.overlayBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    // === DIALOG ===
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.dialogBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      barrierColor: AppColors.overlayBg,
    ),

    // === DIVIDER ===
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 0.5,
      space: 0,
    ),

    // === ICON ===
    iconTheme: const IconThemeData(
      color: AppColors.textSecondary,
      size: 22,
    ),

    // === PROGRESS ===
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.highlight,
    ),
  );
}
