import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../core/theme/colors.dart';
import '../core/widgets/scanner_corner.dart';
import '../core/widgets/scan_line.dart';
import '../core/widgets/pulse_dot.dart';
import '../core/widgets/breathing_background.dart';
import 'processing_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  int _currentState = 0;
  Timer? _timeTimer;
  String _currentTime = '';
  double _progress = 0.0;
  bool _flash = false;

  final List<Map<String, dynamic>> _states = [
    {'text': 'Searching', 'color': NarcSealColors.chromeHighlight},
    {'text': 'Aligning', 'color': NarcSealColors.chromeHighlight},
    {'text': 'Focus', 'color': NarcSealColors.chromeHighlight},
    {'text': 'Countdown', 'color': NarcSealColors.chromeHighlight},
    {'text': 'Captured', 'color': Colors.white},
  ];

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timeTimer = Timer.periodic(const Duration(seconds: 1), (timer) => _updateTime());
    _startSequence();
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
      });
    }
  }

  void _startSequence() async {
    // State 0 to 1
    _animateProgress(0.25, const Duration(seconds: 2));
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted || _currentState == 4) return;
    _advanceState();

    // State 1 to 2
    _animateProgress(0.5, const Duration(milliseconds: 1500));
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted || _currentState == 4) return;
    _advanceState();

    // State 2 to 3
    _animateProgress(0.75, const Duration(milliseconds: 1500));
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted || _currentState == 4) return;
    _advanceState();

    // State 3 to 4 (Capture)
    _animateProgress(1.0, const Duration(seconds: 3));
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted || _currentState == 4) return;
    _capture();
  }

  void _animateProgress(double target, Duration duration) {
    int steps = 20;
    int stepDuration = duration.inMilliseconds ~/ steps;
    double stepSize = (target - _progress) / steps;
    Timer.periodic(Duration(milliseconds: stepDuration), (timer) {
      if (!mounted || _progress >= target) {
        timer.cancel();
      } else {
        setState(() {
          _progress += stepSize;
        });
      }
    });
  }

  void _advanceState() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentState++;
    });
  }

  void _capture() async {
    HapticFeedback.heavyImpact();
    setState(() {
      _currentState = 4;
      _progress = 1.0;
      _flash = true;
    });
    
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      setState(() {
        _flash = false;
      });
    }
    
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProcessingScreen()),
      );
    }
  }

  @override
  void dispose() {
    _timeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NarcSealColors.bgAbyss,
      body: BreathingBackground(
        videoAssetPath: 'assets/videos/scan_line.mp4',
        opacity: 0.5,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    NarcSealColors.bgAbyss.withOpacity(0.8),
                    NarcSealColors.bgAbyss,
                  ],
                  radius: 1.0,
                ),
              ),
            ),
          
          CustomPaint(
            painter: _GridPainter(),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: NarcSealColors.textSecondary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Text(
                        "SCANNING MODE",
                        style: GoogleFonts.orbitron(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: NarcSealColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "19.076090°N, 72.877426°E",
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: NarcSealColors.textSecondary,
                        ),
                      ),
                      Text(
                        _currentTime,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: NarcSealColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width: 280,
                  height: 360,
                  child: Stack(
                    children: [
                      const Positioned(top: 0, left: 0, child: ScannerCorner(position: CornerPosition.topLeft, color: NarcSealColors.chromeHighlight)),
                      const Positioned(top: 0, right: 0, child: ScannerCorner(position: CornerPosition.topRight, color: NarcSealColors.chromeHighlight)),
                      const Positioned(bottom: 0, right: 0, child: ScannerCorner(position: CornerPosition.bottomRight, color: NarcSealColors.chromeHighlight)),
                      const Positioned(bottom: 0, left: 0, child: ScannerCorner(position: CornerPosition.bottomLeft, color: NarcSealColors.chromeHighlight)),
                      
                      const ScanLine(height: 360),

                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Card Detection Zone",
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: NarcSealColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Test Strip Zone",
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: NarcSealColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  decoration: BoxDecoration(
                    color: NarcSealColors.bgSurface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: NarcSealColors.borderSubtle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PulseDot(color: _states[_currentState]['color']),
                      const SizedBox(width: 12),
                      Text(
                        _states[_currentState]['text'],
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: NarcSealColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                GestureDetector(
                  onTap: () {
                    if (_currentState < 4) {
                      _capture();
                    }
                  },
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: NarcSealColors.chromeHighlight,
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: NarcSealColors.bgSurface,
                  valueColor: const AlwaysStoppedAnimation<Color>(NarcSealColors.chromeHighlight),
                  minHeight: 2,
                ),
              ],
            ),
          ),
          
          if (_flash)
            Container(
              color: Colors.white,
            ),
        ],
      ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
