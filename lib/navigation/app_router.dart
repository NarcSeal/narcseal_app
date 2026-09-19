import 'package:flutter/material.dart';
import '../core/animations/page_transitions.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/camera_screen.dart';
import '../screens/processing_screen.dart';
import '../screens/result_screen.dart';
import '../screens/evidence_seal_screen.dart';
import '../screens/field_log_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/security_screens.dart';
import '../models/test_result.dart';

/// Centralized route names for the NarcSeal app.
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String home = '/home';
  static const String camera = '/camera';
  static const String processing = '/processing';
  static const String result = '/result';
  static const String evidenceSeal = '/evidence-seal';
  static const String fieldLog = '/field-log';
  static const String profile = '/profile';
  static const String tamperDetected = '/tamper-detected';
  static const String integrityVerified = '/integrity-verified';
}

/// Route generator with custom transitions per the UI Design Bible spec.
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.onboarding:
        return NarcSealFadeTransition(page: const OnboardingScreen());

      case AppRoutes.login:
        return NarcSealFadeTransition(page: const LoginScreen());

      case AppRoutes.home:
        return NarcSealSlideUpFadeTransition(page: const HomeScreen());

      case AppRoutes.camera:
        return NarcSealSlideUpTransition(page: const CameraScreen());

      case AppRoutes.processing:
        return NarcSealCrossFadeTransition(page: const ProcessingScreen());

      case AppRoutes.result:
        final result = settings.arguments as TestResult? ?? TestResult.positive;
        return NarcSealFadeTransition(
          page: ResultScreen(result: result),
          duration: const Duration(milliseconds: 800),
        );

      case AppRoutes.evidenceSeal:
        return NarcSealScaleFadeTransition(
          page: const EvidenceSealScreen(),
        );

      case AppRoutes.fieldLog:
        return NarcSealSlideRightTransition(page: const FieldLogScreen());

      case AppRoutes.profile:
        return NarcSealSlideRightTransition(page: const ProfileScreen());

      case AppRoutes.tamperDetected:
        final args = settings.arguments as Map<String, String?>?;
        return NarcSealFadeTransition(
          page: TamperDetectedScreen(
            recordId: args?['recordId'],
            officerBadge: args?['officerBadge'],
            mismatchDetails: args?['mismatchDetails'],
          ),
          duration: const Duration(milliseconds: 300),
        );

      case AppRoutes.integrityVerified:
        final count = settings.arguments as int? ?? 0;
        return NarcSealScaleFadeTransition(
          page: IntegrityVerifiedScreen(recordsVerified: count),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text(
                'Route not found: ${settings.name}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
    }
  }
}
