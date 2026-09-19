import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/colors.dart';
import '../core/widgets/scan_line.dart';
import '../models/test_result.dart';
import '../services/mock_data_service.dart';
import 'result_screen.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  int _currentStepIndex = 0;
  int _factIndex = 0;
  Timer? _factTimer;

  final List<String> _facts = [
    "Extracting morphological features...",
    "Validating color space thresholds...",
    "Computing spectral confidence interval...",
    "Matching reagent reaction signatures...",
    "Running structural anomaly detection..."
  ];
      
  final List<String> _steps = [
    "Card Detected",
    "Color Patches",
    "ChromaLock Calibrating",
    "Running AI"
  ];

  @override
  void initState() {
    super.initState();
    _startProcessing();
    _factTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _factIndex = (_factIndex + 1) % _facts.length;
        });
      }
    });
  }

  void _startProcessing() async {
    // Step 0: Card Detected
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    _completeStep(); // Moves to 1

    // Step 1: Color Patches
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    _completeStep(); // Moves to 2

    // Step 2: ChromaLock Calibrating
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    _completeStep(); // Moves to 3

    // Step 3: Running AI
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    _completeStep(); // Moves to 4 (done)

    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ResultScreen(result: TestResult.positive)),
      );
    }
  }

  void _completeStep() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentStepIndex++;
    });
  }

  @override
  void dispose() {
    _factTimer?.cancel();
    super.dispose();
  }

  Widget _buildStepItem(int index, String text) {
    Widget icon;
    if (index < _currentStepIndex) {
      icon = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: const Icon(Icons.check_circle, color: NarcSealColors.textPrimary, size: 24),
          );
        },
      );
    } else if (index == _currentStepIndex) {
      icon = const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(NarcSealColors.chromeHighlight),
        ),
      );
    } else {
      icon = const Icon(Icons.radio_button_unchecked, color: NarcSealColors.textMuted, size: 24);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 16),
          Expanded(
            child: index == _currentStepIndex
                ? TypewriterText(
                    key: ValueKey('typewriter_$_currentStepIndex'),
                    text: text,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: NarcSealColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Text(
                    text,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: index < _currentStepIndex ? NarcSealColors.textPrimary : NarcSealColors.textMuted,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progressValue = (_currentStepIndex / _steps.length).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: NarcSealColors.bgAbyss,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                "PROCESSING EVIDENCE",
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: NarcSealColors.chromeHighlight,
                ),
              ),
              const SizedBox(height: 48),

              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [NarcSealColors.bgElevated, NarcSealColors.bgSurface],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: NarcSealColors.borderSubtle),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(Icons.image, size: 64, color: NarcSealColors.borderSubtle),
                        ),
                        const ScanLine(height: 240),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 48),

              Expanded(
                child: ListView.builder(
                  itemCount: _steps.length,
                  itemBuilder: (context, index) {
                    return _buildStepItem(index, _steps[index]);
                  },
                ),
              ),

              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: NarcSealColors.bgSurface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: MediaQuery.of(context).size.width * progressValue,
                      decoration: BoxDecoration(
                        color: NarcSealColors.chromeHighlight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),

              SizedBox(
                height: 40,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    _facts[_factIndex],
                    key: ValueKey<int>(_factIndex),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: NarcSealColors.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const TypewriterText({Key? key, required this.text, required this.style}) : super(key: key);

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    int charIndex = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (charIndex < widget.text.length) {
        if (mounted) {
          setState(() {
            charIndex++;
            _displayedText = widget.text.substring(0, charIndex);
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_displayedText, style: widget.style);
  }
}
