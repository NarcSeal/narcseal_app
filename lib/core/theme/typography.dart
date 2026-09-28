import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Defines the professional typography styles for the NarcSeal application.
class NarcSealTypography {
  static TextStyle get appTitle => GoogleFonts.inter(
    fontWeight: FontWeight.w700, // Bold
    fontSize: 28,
    color: NarcSealColors.titaniumGray,
  );

  static TextStyle get screenTitle => GoogleFonts.inter(
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 20,
    color: NarcSealColors.titaniumGray,
  );

  static TextStyle get sectionTitle => GoogleFonts.inter(
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 16,
    color: NarcSealColors.titaniumGray,
  );

  static TextStyle get body => GoogleFonts.inter(
    fontWeight: FontWeight.w400, // Regular
    fontSize: 16,
    color: NarcSealColors.graphite,
  );

  static TextStyle get label => GoogleFonts.inter(
    fontWeight: FontWeight.w400, // Regular
    fontSize: 14,
    color: NarcSealColors.titaniumGray,
  );

  static TextStyle get metadata => GoogleFonts.inter(
    fontWeight: FontWeight.w400, // Regular
    fontSize: 12,
    color: NarcSealColors.graphite,
  );

  static TextStyle get importantNumbers => GoogleFonts.inter(
    fontWeight: FontWeight.w700, // Bold
    fontSize: 24,
    color: NarcSealColors.titaniumGray,
  );

  static TextStyle get resultText => GoogleFonts.inter(
    fontWeight: FontWeight.w700, // Bold
    fontSize: 32,
    color: NarcSealColors.titaniumGray,
  );

  static TextStyle get buttonText => GoogleFonts.inter(
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 16,
    color: NarcSealColors.white,
  );

  static TextStyle get statusBadge => GoogleFonts.inter(
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 12,
  );

  static TextStyle get navLabel => GoogleFonts.inter(
    fontWeight: FontWeight.w500, // Medium
    fontSize: 10,
  );
}
