import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/colors.dart';
import '../core/widgets/breathing_background.dart';
import '../models/test_result.dart';
import 'evidence_seal_screen.dart';
import 'camera_screen.dart';

class ResultScreen extends StatefulWidget {
  final TestResult result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _revealController;
  late AnimationController _countController;
  late AnimationController _buttonsController;

  late Animation<double> _dotScale;
  late Animation<double> _dotOpacity;
  late Animation<double> _textScale;
  late Animation<double> _glowOpacity;
  late Animation<double> _buttonsSlide;

  bool _showSubstance = false;
  double _confidence = 0.0;
  
  Color get _resultColor {
    switch (widget.result) {
      case TestResult.positive: return NarcSealColors.resultPositiveText;
      case TestResult.negative: return NarcSealColors.resultNegativeText;
      case TestResult.inconclusive: return NarcSealColors.resultInconclusiveText;
    }
  }

  String get _resultText {
    switch (widget.result) {
      case TestResult.positive: return "POSITIVE";
      case TestResult.negative: return "NEGATIVE";
      case TestResult.inconclusive: return "INCONCLUSIVE";
    }
  }

  String get _substanceText {
    switch (widget.result) {
      case TestResult.positive: return "Cannabis";
      case TestResult.negative: return "";
      case TestResult.inconclusive: return "Cocaine";
    }
  }

  double get _targetConfidence {
    switch (widget.result) {
      case TestResult.positive: return 94.2;
      case TestResult.negative: return 97.8;
      case TestResult.inconclusive: return 62.1;
    }
  }

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _revealController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _countController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _buttonsController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _dotScale = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)
    );
    _dotOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _revealController, curve: const Interval(0.0, 0.3))
    );
    _textScale = Tween<double>(begin: 5.0, end: 1.0).animate(
      CurvedAnimation(parent: _revealController, curve: const Interval(0.2, 0.8, curve: Curves.elasticOut))
    );
    _glowOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _revealController, curve: const Interval(0.5, 1.0))
    );
    _buttonsSlide = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _buttonsController, curve: Curves.easeOutBack)
    );

    _countController.addListener(() {
      setState(() {
        _confidence = _countController.value * _targetConfidence;
      });
    });

    _startSequence();
  }

  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _pulseController.repeat(reverse: true);

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    
    if (widget.result == TestResult.positive) {
      HapticFeedback.heavyImpact();
    } else if (widget.result == TestResult.negative) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      HapticFeedback.mediumImpact();
    }

    _pulseController.stop();
    _revealController.forward();
    
    if (widget.result == TestResult.positive) {
      _pulseController.duration = const Duration(milliseconds: 800);
      _pulseController.repeat(reverse: true); 
    } else if (widget.result == TestResult.inconclusive) {
      _pulseController.duration = const Duration(milliseconds: 150);
      _pulseController.repeat(reverse: true);
    }

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() { _showSubstance = true; });

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _countController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _buttonsController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _revealController.dispose();
    _countController.dispose();
    _buttonsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NarcSealColors.bgAbyss,
      body: BreathingBackground(
        videoAssetPath: 'assets/videos/result_bg.mp4',
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([_revealController, _pulseController]),
              builder: (context, child) {
                double opacity = _glowOpacity.value;
                if (widget.result == TestResult.positive) {
                  opacity *= (0.6 + 0.4 * _pulseController.value);
                } else if (widget.result == TestResult.inconclusive) {
                  opacity *= (0.7 + 0.3 * _pulseController.value);
                }
                
                return Opacity(
                  opacity: opacity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          NarcSealColors.resultBg(widget.result.name).withOpacity(0.4),
                          Colors.transparent,
                        ],
                        radius: 1.2,
                      ),
                    ),
                  ),
                );
              },
            ),

          Center(
            child: AnimatedBuilder(
              animation: _revealController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_revealController.value < 0.3)
                      Opacity(
                        opacity: _dotOpacity.value,
                        child: Transform.scale(
                          scale: _dotScale.value,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _resultColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: _resultColor.withOpacity(0.5), blurRadius: 10, spreadRadius: 5)
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                    if (_revealController.value > 0.1)
                      Transform.scale(
                        scale: _textScale.value,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _resultText,
                              style: GoogleFonts.orbitron(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: _resultColor,
                                shadows: [
                                  Shadow(
                                    color: _resultColor.withOpacity(0.8),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            AnimatedOpacity(
                              opacity: _showSubstance ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 500),
                              child: _substanceText.isNotEmpty 
                                ? Text(
                                    _substanceText,
                                    style: GoogleFonts.inter(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            ),
                            
                            const SizedBox(height: 8),

                            AnimatedOpacity(
                              opacity: _showSubstance ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 500),
                              child: Text(
                                "${_confidence.toStringAsFixed(1)}% CONFIDENCE",
                                style: GoogleFonts.orbitron(
                                  fontSize: 28,
                                  color: NarcSealColors.textSecondary,
                                ),
                              ),
                            ),
                            
                            AnimatedOpacity(
                              opacity: _showSubstance ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 500),
                              child: Container(
                                height: 120,
                                width: 280,
                                margin: const EdgeInsets.symmetric(vertical: 24),
                                decoration: BoxDecoration(
                                  color: NarcSealColors.bgSurface.withOpacity(0.5),
                                  border: Border.all(color: NarcSealColors.borderSubtle),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.auto_awesome, color: NarcSealColors.textSecondary, size: 32),
                                      SizedBox(height: 8),
                                      Text("[ Explainable AI Graphic ]", style: TextStyle(color: NarcSealColors.textMuted)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            
                            if (widget.result == TestResult.inconclusive)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: AnimatedOpacity(
                                  opacity: _showSubstance ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 500),
                                  child: Text(
                                    "Manual verification recommended",
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: NarcSealColors.resultInconclusive,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: AnimatedBuilder(
              animation: _buttonsSlide,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 100 * _buttonsSlide.value),
                  child: Opacity(
                    opacity: (1 - _buttonsSlide.value).clamp(0.0, 1.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const EvidenceSealScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.result == TestResult.inconclusive ? NarcSealColors.resultInconclusive : NarcSealColors.accentCyan,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(
                              widget.result == TestResult.inconclusive ? "SEAL AS INCONCLUSIVE" : "🔒 SEAL EVIDENCE",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: NarcSealColors.bgAbyss,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const CameraScreen()),
                              );
                            },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(color: NarcSealColors.borderSubtle),
                              ),
                            ),
                            child: Text(
                              "↩ RETAKE",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: NarcSealColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        ),
      ),
    );
  }
}

