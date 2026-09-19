import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Defines the typography styles for the NarcSeal application.
class NarcSealTypography {
  static TextStyle get appTitle => GoogleFonts.orbitron(
    fontWeight: FontWeight.bold,
    fontSize: 28,
    color: NarcSealColors.textPrimary,
  );

  static TextStyle get screenTitle => GoogleFonts.inter(
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 22,
    color: NarcSealColors.textPrimary,
  );

  static TextStyle get body => GoogleFonts.inter(
    fontWeight: FontWeight.w400, // Regular
    fontSize: 16,
    color: NarcSealColors.textPrimary,
  );

  static TextStyle get label => GoogleFonts.inter(
    fontWeight: FontWeight.w500, // Medium
    fontSize: 12,
    color: NarcSealColors.textSecondary,
  );

  static TextStyle get hashCode_ => GoogleFonts.jetBrainsMono(
    fontWeight: FontWeight.w400, // Regular
    fontSize: 13,
    color: NarcSealColors.chromeHighlight,
  );

  static TextStyle get resultText => GoogleFonts.orbitron(
    fontWeight: FontWeight.w900, // Black
    fontSize: 48,
    color: NarcSealColors.textPrimary,
  );

  static TextStyle get badgeId => GoogleFonts.jetBrainsMono(
    fontWeight: FontWeight.w400, // Regular
    fontSize: 14,
    color: NarcSealColors.chromeHighlight,
  );

  static TextStyle get timestamp => GoogleFonts.jetBrainsMono(
    fontWeight: FontWeight.w400, // Regular
    fontSize: 12,
    color: NarcSealColors.textSecondary,
  );

  static TextStyle get tagline => GoogleFonts.inter(
    fontWeight: FontWeight.w400, // Regular
    fontSize: 14,
    color: NarcSealColors.textMuted,
    fontStyle: FontStyle.italic,
  );

  static TextStyle get buttonText => GoogleFonts.inter(
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 16,
    color: NarcSealColors.bgAbyss, // dark text on silver buttons
  );

  static TextStyle get navLabel => GoogleFonts.inter(
    fontWeight: FontWeight.w500, // Medium
    fontSize: 10,
  );
}
