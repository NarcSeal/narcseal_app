import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../navigation/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to login after 2 seconds
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NarcSealColors.warmOffWhite,
      body: Stack(
        children: [
          // Subtle wave background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/images/backgrounds/wave_pattern.png', // Assuming this asset exists or will be added
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/images/branding/narcseal_logo.png', // Main shield logo
                  width: 160,
                  height: 160,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.security,
                      size: 160,
                      color: NarcSealColors.titaniumGray,
                    );
                  },
                ),
                const SizedBox(height: 24),
                
                // Brand Name
                Text(
                  'NarcSeal',
                  style: NarcSealTypography.appTitle.copyWith(
                    fontSize: 40,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Tagline
                Text(
                  'Capture · Verify · Preserve',
                  style: NarcSealTypography.body.copyWith(
                    color: NarcSealColors.graphite,
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Loading indicator (optional, matching reference "keep it restrained")
                const SizedBox(
                  width: 40,
                  child: LinearProgressIndicator(
                    color: NarcSealColors.olive,
                    backgroundColor: NarcSealColors.lightBeige,
                    minHeight: 2,
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Text
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'TRUST',
                  style: NarcSealTypography.navLabel.copyWith(
                    color: NarcSealColors.graphite,
                    letterSpacing: 2,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('|', style: TextStyle(color: NarcSealColors.paleOlive)),
                ),
                Text(
                  'EVIDENCE',
                  style: NarcSealTypography.navLabel.copyWith(
                    color: NarcSealColors.graphite,
                    letterSpacing: 2,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('|', style: TextStyle(color: NarcSealColors.paleOlive)),
                ),
                Text(
                  'JUSTICE',
                  style: NarcSealTypography.navLabel.copyWith(
                    color: NarcSealColors.graphite,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
