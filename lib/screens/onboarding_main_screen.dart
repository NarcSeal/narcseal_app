import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OnboardingMainScreen extends StatefulWidget {
  const OnboardingMainScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingMainScreen> createState() => _OnboardingMainScreenState();
}

class _OnboardingMainScreenState extends State<OnboardingMainScreen> {
  int? _tappedZone;

  void _handleTap(int zoneId, VoidCallback action) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _tappedZone = zoneId;
    });
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (mounted) {
      setState(() {
        _tappedZone = null;
      });
      action();
    }
  }

  Widget _buildTapZone({
    required int id, 
    required double topPercent, 
    required double bottomPercent, 
    required double leftPercent,
    required double rightPercent,
    required VoidCallback action,
    required double boxWidth,
    required double boxHeight,
  }) {
    final isTapped = _tappedZone == id;
    
    return Positioned(
      top: boxHeight * topPercent,
      bottom: boxHeight * (1.0 - bottomPercent),
      left: boxWidth * leftPercent,
      right: boxWidth * rightPercent,
      child: GestureDetector(
        onTap: () => _handleTap(id, action),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            color: isTapped ? Colors.white.withValues(alpha: 0.3) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Center(
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              
              return Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/onboarding/main1.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                  
                  // Option 1
                  _buildTapZone(
                    id: 1,
                    topPercent: 0.36,
                    bottomPercent: 0.45,
                    leftPercent: 0.1,
                    rightPercent: 0.1,
                    boxWidth: w,
                    boxHeight: h,
                    action: () => Navigator.pushNamed(context, '/feature-video', arguments: {
                      'title': 'Scan Any Test Kit',
                      'videoPath': 'assets/videos/feature_scan.mp4',
                    }),
                  ),
                  
                  // Option 2
                  _buildTapZone(
                    id: 2,
                    topPercent: 0.48,
                    bottomPercent: 0.57,
                    leftPercent: 0.1,
                    rightPercent: 0.1,
                    boxWidth: w,
                    boxHeight: h,
                    action: () => Navigator.pushNamed(context, '/feature-video', arguments: {
                      'title': 'AI-Powered Classification',
                      'videoPath': 'assets/videos/feature_ai.mp4',
                    }),
                  ),
                  
                  // Option 3
                  _buildTapZone(
                    id: 3,
                    topPercent: 0.60,
                    bottomPercent: 0.69,
                    leftPercent: 0.1,
                    rightPercent: 0.1,
                    boxWidth: w,
                    boxHeight: h,
                    action: () => Navigator.pushNamed(context, '/feature-video', arguments: {
                      'title': 'Tamper-Proof Evidence',
                      'videoPath': 'assets/videos/feature_tamper.mp4',
                    }),
                  ),
                  
                  // Option 4
                  _buildTapZone(
                    id: 4,
                    topPercent: 0.72,
                    bottomPercent: 0.81,
                    leftPercent: 0.1,
                    rightPercent: 0.1,
                    boxWidth: w,
                    boxHeight: h,
                    action: () => Navigator.pushNamed(context, '/feature-video', arguments: {
                      'title': 'Works Offline',
                      'videoPath': 'assets/videos/feature_offline.mp4',
                    }),
                  ),
                  
                  // Get Started
                  _buildTapZone(
                    id: 5,
                    topPercent: 0.85,
                    bottomPercent: 0.94,
                    leftPercent: 0.15,
                    rightPercent: 0.15,
                    boxWidth: w,
                    boxHeight: h,
                    action: () => Navigator.pushReplacementNamed(context, '/login'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
