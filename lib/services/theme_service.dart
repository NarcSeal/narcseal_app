import 'package:flutter/material.dart';

/// Service to manage theme switching between Normal Dark Mode and Night Ops Mode.
///
/// Night Ops Mode is designed for covert field operations:
/// - Pure black background to minimize screen glow
/// - Dim red accent (less visible at distance)
/// - Reduced text brightness to 60%
/// - Screen brightness forced to minimum
class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();

  factory ThemeService() {
    return _instance;
  }

  ThemeService._internal();

  bool _isNightOps = false;

  /// Whether Night Ops mode is currently active.
  bool get isNightOps => _isNightOps;

  /// Toggle between Normal Dark Mode and Night Ops Mode.
  void toggleNightOps() {
    _isNightOps = !_isNightOps;
    notifyListeners();
  }

  /// Explicitly set Night Ops mode on or off.
  void setNightOps(bool enabled) {
    if (_isNightOps != enabled) {
      _isNightOps = enabled;
      notifyListeners();
    }
  }
}
