import 'package:flutter/material.dart';

/// EV Protocol color palette.
///
/// Pure black backgrounds, yellow highlights, muted greys for text hierarchy.
abstract final class AppColors {
  // === PRIMARY ===
  static const Color highlight = Color(0xFFFFD600); // Yellow — selected/active
  static const Color highlightDim = Color(0xFFFBC02D); // Dimmer yellow — hover
  static const Color highlightMuted = Color(0x33FFD600); // Yellow 20% — subtle bg

  // === BACKGROUNDS ===
  static const Color scaffoldBg = Color(0xFF000000); // Pure black
  static const Color cardBg = Color(0xFF0D0D0D); // Near-black card
  static const Color surfaceBg = Color(0xFF1A1A1A); // Elevated surface
  static const Color overlayBg = Color(0x80000000); // Black 50% — popouts
  static const Color dialogBg = Color(0xF2111111); // 95% opacity dark dialog

  // === TEXT ===
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF707070);
  static const Color textOnHighlight = Color(0xFF000000); // Black text on yellow

  // === BORDERS & DIVIDERS ===
  static const Color border = Color(0xFF2A2A2A);
  static const Color divider = Color(0xFF1F1F1F);

  // === STATUS ===
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF42A5F5);
}
