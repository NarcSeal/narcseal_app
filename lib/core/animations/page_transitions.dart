import 'package:flutter/material.dart';

/// Custom page transitions matching the NarcSeal UI Design Bible specifications.
///
/// Transition Table:
/// | From → To              | Type                  | Duration |
/// |------------------------|-----------------------|----------|
/// | Splash → Login         | Fade                  | 400ms    |
/// | Login → Home           | SlideUp + Fade        | 500ms    |
/// | Home → Camera          | SlideUp               | 400ms    |
/// | Camera → Processing    | CrossFade             | 300ms    |
/// | Processing → Result    | Custom morph          | 800ms    |
/// | Result → Evidence Seal | Scale + Fade          | 1200ms   |
/// | Any → Field Log        | SlideRight            | 300ms    |
/// | Bottom Nav tabs        | Fade                  | 200ms    |

/// Fade transition (400ms) — used for Splash → Login.
class NarcSealFadeTransition extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  NarcSealFadeTransition({
    required this.page,
    this.duration = const Duration(milliseconds: 400),
    RouteSettings? settings,
  }) : super(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
        );
}

/// Slide up + fade transition (500ms) — used for Login → Home.
class NarcSealSlideUpFadeTransition extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  NarcSealSlideUpFadeTransition({
    required this.page,
    this.duration = const Duration(milliseconds: 500),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return FadeTransition(
              opacity: curvedAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(curvedAnimation),
                child: child,
              ),
            );
          },
        );
}

/// Slide up transition (400ms) — used for Home → Camera.
class NarcSealSlideUpTransition extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  NarcSealSlideUpTransition({
    required this.page,
    this.duration = const Duration(milliseconds: 400),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        );
}

/// Cross-fade transition (300ms) — used for Camera → Processing.
class NarcSealCrossFadeTransition extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  NarcSealCrossFadeTransition({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
        );
}

/// Scale + fade transition (1200ms) — dramatic reveal for Result → Evidence Seal.
class NarcSealScaleFadeTransition extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  NarcSealScaleFadeTransition({
    required this.page,
    this.duration = const Duration(milliseconds: 1200),
    RouteSettings? settings,
  }) : super(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            );
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeIn,
              ),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0)
                    .animate(curvedAnimation),
                child: child,
              ),
            );
          },
        );
}

/// Slide right transition (300ms) — used for Any → Field Log.
class NarcSealSlideRightTransition extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  NarcSealSlideRightTransition({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        );
}

/// Quick fade transition (200ms) — used for bottom nav tab switches.
class NarcSealTabFadeTransition extends PageRouteBuilder {
  final Widget page;

  NarcSealTabFadeTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}
