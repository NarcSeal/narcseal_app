import 'package:flutter/material.dart';

/// Defines the completely monochromatic color palette for the NarcSeal application
/// as dictated by Image Prompts V2.
class NarcSealColors {
  // Pure Black Void Background
  static const Color bgAbyss = Color(0xFF000000); 
  
  // Metallic surfaces (dark gunmetal)
  static const Color bgSurface = Color(0xFF111111);
  static const Color bgElevated = Color(0xFF1A1A1A);
  static const Color bgGunmetal = Color(0xFF2A2A2A);
  
  // Chrome / Brushed steel accents
  static const Color borderSubtle = Color(0xFF333333);
  static const Color chromeHighlight = Color(0xFFE0E0E0);
  
  // Monochromatic typography
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF666666);
  
  // Replaced cyan with pure chrome/silver
  static const Color accentCyan = Color(0xFFCCCCCC);
  static const Color accentCyanGlow = Color(0x33CCCCCC); // 20% opacity
  
  // Results (Only colors allowed, but extremely subtle 5% tint as per V2 Prompts)
  // POSITIVE: Faint red tint
  static const Color resultPositive = Color(0xFF331111); // dark steel with red tint
  static const Color resultPositiveText = Color(0xFFFF5555);
  
  // NEGATIVE: Cool white/greenish tint
  static const Color resultNegative = Color(0xFF112211);
  static const Color resultNegativeText = Color(0xFF55FF55);
  
  // INCONCLUSIVE: Dim amber/tungsten tint
  static const Color resultInconclusive = Color(0xFF221A11);
  static const Color resultInconclusiveText = Color(0xFFFFB347);
  
  // Legacy colors stripped, mapped to silver/chrome
  static const Color sealGold = Color(0xFFCCCCCC);
  static const Color chainPurple = Color(0xFF999999);
  
  // Night Ops Palette (Even darker, near invisible)
  static const Color nightBg = Color(0xFF000000);
  static const Color nightAccent = Color(0xFF1A1A1A);
  static const Color nightText = Color(0x40FFFFFF); // 25% opacity

  /// Returns the semantic color for a given test result text.
  static Color resultColor(String result) {
    switch (result.toUpperCase()) {
      case 'POSITIVE':
        return resultPositiveText;
      case 'NEGATIVE':
        return resultNegativeText;
      case 'INCONCLUSIVE':
        return resultInconclusiveText;
      default:
        return textSecondary;
    }
  }

  /// Returns the subtle background tint for a result screen.
  static Color resultBg(String result) {
    switch (result.toUpperCase()) {
      case 'POSITIVE':
        return resultPositive;
      case 'NEGATIVE':
        return resultNegative;
      case 'INCONCLUSIVE':
        return resultInconclusive;
      default:
        return bgAbyss;
    }
  }

  /// Returns a glow color (20% opacity) for a given test result.
  static Color resultGlow(String result) {
    return resultColor(result).withOpacity(0.20);
  }
}
