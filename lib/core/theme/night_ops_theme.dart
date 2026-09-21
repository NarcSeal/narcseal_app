import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';
import '../constants/app_constants.dart';

/// Night Ops Theme for the NarcSeal application.
class NightOpsTheme {
  static ThemeData theme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: NarcSealColors.nightBg,
      colorScheme: const ColorScheme.dark(
        primary: NarcSealColors.nightAccent,
        error: NarcSealColors.resultPositive, // keep semantic positive
        surface: NarcSealColors.nightBg,
      ),
      cardTheme: CardThemeData(
        color: NarcSealColors.nightBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          side: const BorderSide(color: NarcSealColors.nightAccent, width: 1),
        ),
        elevation: AppConstants.cardElevation,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          minimumSize: const Size(double.infinity, AppConstants.minTouchTarget),
          backgroundColor: NarcSealColors.nightAccent,
          foregroundColor: NarcSealColors.nightText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NarcSealColors.nightBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: NarcSealColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: NarcSealColors.nightAccent, width: 2),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: NarcSealColors.nightText),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: NarcSealColors.nightBg,
        selectedItemColor: NarcSealColors.nightAccent,
        unselectedItemColor: NarcSealColors.textMuted,
      ),
      textTheme: TextTheme(
        displayLarge: NarcSealTypography.resultText.copyWith(color: NarcSealColors.nightText),
        titleLarge: NarcSealTypography.screenTitle.copyWith(color: NarcSealColors.nightText),
        titleMedium: NarcSealTypography.appTitle.copyWith(color: NarcSealColors.nightText),
        bodyLarge: NarcSealTypography.body.copyWith(color: NarcSealColors.nightText),
        bodyMedium: NarcSealTypography.body.copyWith(color: NarcSealColors.nightText),
        labelLarge: NarcSealTypography.buttonText.copyWith(color: NarcSealColors.nightText),
        labelMedium: NarcSealTypography.label.copyWith(color: NarcSealColors.nightText),
        labelSmall: NarcSealTypography.navLabel.copyWith(color: NarcSealColors.nightText),
      ),
      dividerTheme: const DividerThemeData(
        color: NarcSealColors.nightAccent,
      ),
      iconTheme: const IconThemeData(
        color: NarcSealColors.nightText,
      ),
    );
  }
}
