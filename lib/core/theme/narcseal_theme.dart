import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';
import '../constants/app_constants.dart';

/// Standard theme for the NarcSeal application based on the professional design system.
class NarcSealTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: NarcSealColors.warmOffWhite,
      colorScheme: const ColorScheme.light(
        primary: NarcSealColors.olive,
        error: NarcSealColors.positive,
        surface: NarcSealColors.white,
      ),
      cardTheme: CardThemeData(
        color: NarcSealColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          side: const BorderSide(color: NarcSealColors.lightBeige, width: 1),
        ),
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          ),
          minimumSize: const Size(double.infinity, AppConstants.minTouchTarget),
          backgroundColor: NarcSealColors.olive,
          foregroundColor: NarcSealColors.white,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          ),
          side: const BorderSide(color: NarcSealColors.titaniumGray),
          foregroundColor: NarcSealColors.titaniumGray,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NarcSealColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          borderSide: const BorderSide(color: NarcSealColors.paleOlive, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          borderSide: const BorderSide(color: NarcSealColors.olive, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          borderSide: const BorderSide(color: NarcSealColors.paleOlive, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: NarcSealColors.warmOffWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: NarcSealColors.titaniumGray),
        centerTitle: true,
        titleTextStyle: NarcSealTypography.screenTitle,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: NarcSealColors.white,
        selectedItemColor: NarcSealColors.olive,
        unselectedItemColor: NarcSealColors.graphite,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
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
        color: NarcSealColors.paleOlive,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(
        color: NarcSealColors.titaniumGray,
      ),
    );
  }
}
