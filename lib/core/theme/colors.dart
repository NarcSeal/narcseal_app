import 'package:flutter/material.dart';

/// Defines the professional forensic and evidence management color palette.
class NarcSealColors {
  // Primary Palette
  static const Color warmOffWhite = Color(0xFFF7F7F3);
  static const Color white = Color(0xFFFFFFFF);
  static const Color titaniumGray = Color(0xFF34383A);
  static const Color graphite = Color(0xFF555A5D);
  static const Color olive = Color(0xFF596347);
  static const Color deepOlive = Color(0xFF414A32);
  static const Color paleOlive = Color(0xFFDDE0D1);
  static const Color policeKhaki = Color(0xFFB7AC8D);
  static const Color lightBeige = Color(0xFFE4E0D4);

  // Legacy Theme Aliases (for backward compatibility with un-rewritten screens)
  static const Color bgAbyss = warmOffWhite;
  static const Color bgSurface = white;
  static const Color bgElevated = lightBeige;
  static const Color borderSubtle = lightBeige;
  static const Color textPrimary = titaniumGray;
  static const Color textSecondary = graphite;
  static const Color textMuted = Colors.grey;
  static const Color accentCyan = olive;
  static const Color chromeHighlight = paleOlive;
  static const Color chainPurple = Color(0xFF9C27B0); // Colors.purple
  static const Color sealGold = Color(0xFFFFC107); // Colors.amber
  static const Color resultPositive = positive;
  static const Color resultNegative = negative;
  static const Color resultInconclusive = inconclusive;

  // Status Colors
  static const Color positive = Color(0xFFA63D32); // Muted Red
  static const Color negative = Color(0xFF3F7A4D); // Muted Green
  static const Color inconclusive = Color(0xFF777B7D); // Neutral Gray

  // Night Ops Palette (Covert Operations)
  static const Color nightBg = Color(0xFF000000); // Pure black
  static const Color nightAccent = Color(0xFF8B0000); // Dim red
  static const Color nightText = Color(0x99FFFFFF); // 60% white opacity

  /// Returns the color based on the test result string.
  static Color getResultColor(String result) {
    switch (result.toUpperCase()) {
      case 'POSITIVE':
        return positive;
      case 'NEGATIVE':
        return negative;
      case 'INCONCLUSIVE':
        return inconclusive;
      default:
        return graphite;
    }
  }

  /// Returns a faint background tint for a test result.
  static Color getResultBgColor(String result) {
    switch (result.toUpperCase()) {
      case 'POSITIVE':
        return const Color(0xFFFDECEE); // Light red tint
      case 'NEGATIVE':
        return const Color(0xFFF0F4EF); // Light green tint
      case 'INCONCLUSIVE':
        return const Color(0xFFF5F5F5); // Light gray tint
      default:
        return white;
    }
  }
}
