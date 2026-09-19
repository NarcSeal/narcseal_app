import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';
import '../constants/app_constants.dart';

/// Standard theme for the NarcSeal application.
class NarcSealTheme {
  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: NarcSealColors.bgAbyss,
      colorScheme: const ColorScheme.dark(
        primary: NarcSealColors.accentCyan,
        error: NarcSealColors.resultPositiveText,
        surface: NarcSealColors.bgSurface,
      ),
      cardTheme: CardTheme(
        color: NarcSealColors.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          side: const BorderSide(color: NarcSealColors.borderSubtle, width: 1),
        ),
        elevation: AppConstants.cardElevation,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          minimumSize: const Size(double.infinity, AppConstants.minTouchTarget),
          backgroundColor: NarcSealColors.accentCyan,
          foregroundColor: NarcSealColors.bgAbyss,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NarcSealColors.bgElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: NarcSealColors.borderSubtle, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: NarcSealColors.chromeHighlight, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: NarcSealColors.borderSubtle, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: NarcSealColors.textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: NarcSealColors.bgSurface,
        selectedItemColor: NarcSealColors.chromeHighlight,
        unselectedItemColor: NarcSealColors.textMuted,
      ),
      textTheme: TextTheme(
        displayLarge: NarcSealTypography.resultText,
        titleLarge: NarcSealTypography.screenTitle,
        titleMedium: NarcSealTypography.appTitle,
        bodyLarge: NarcSealTypography.body,
        bodyMedium: NarcSealTypography.body,
        labelLarge: NarcSealTypography.buttonText,
        labelMedium: NarcSealTypography.label,
        labelSmall: NarcSealTypography.navLabel,
      ),
      dividerTheme: const DividerThemeData(
        color: NarcSealColors.borderSubtle,
      ),
      iconTheme: const IconThemeData(
        color: NarcSealColors.textSecondary,
      ),
    );
  }
}
