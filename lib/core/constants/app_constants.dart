import 'package:flutter/material.dart';

/// Core constants for the NarcSeal application.
class AppConstants {
  // Dimensions and Layout
  static const double borderRadius = 16.0;
  static const double borderRadiusLarge = 24.0;
  static const EdgeInsets screenPadding = EdgeInsets.all(16.0);
  static const double minTouchTarget = 48.0;
  static const double cardElevation = 0;
  static const double leftBorderWidth = 4.0;

  // Animation Durations
  static const Duration splashDuration = Duration(milliseconds: 2000);
  static const Duration fadeTransition = Duration(milliseconds: 400);
  static const Duration slideTransition = Duration(milliseconds: 500);
  static const Duration buttonPress = Duration(milliseconds: 150);
  static const Duration typewriterDelay = Duration(milliseconds: 50);
  static const Duration countUpDuration = Duration(milliseconds: 1000);
  static const Duration sealCeremony = Duration(milliseconds: 3000);
  static const Duration resultReveal = Duration(milliseconds: 800);
}
