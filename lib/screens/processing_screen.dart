import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  final List<String> _steps = [
    'Reference Card Detected',
    '6/6 Color Patches Found',
    'ChromaLock Calibrating...',
    'AI Analysis Complete',
    'Evidence Compiled'
  ];
  
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _startProcessing();
  }

  void _startProcessing() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      HapticFeedback.lightImpact();
      setState(() {
        _currentStep = i + 1;
      });
    }

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    
    // Navigate to Result screen (Mocking a Positive result for the dramatic demo)
    Navigator.pushReplacementNamed(context, '/result', arguments: {'result': 'POSITIVE'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.memory,
                color: Color(0xFF00B4D8),
                size: 64,
              ),
              const SizedBox(height: 32),
              Text(
                'PROCESSING EVIDENCE',
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              LinearProgressIndicator(
                value: _currentStep / _steps.length,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00B4D8)),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 48),
              ...List.generate(_steps.length, (index) {
                final isCompleted = _currentStep > index;
                final isCurrent = _currentStep == index;
                
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isCompleted ? 1.0 : (isCurrent ? 0.7 : 0.2),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      children: [
                        Icon(
                          isCompleted ? Icons.check_circle : (isCurrent ? Icons.sync : Icons.circle_outlined),
                          color: isCompleted ? Colors.greenAccent : (isCurrent ? const Color(0xFF00B4D8) : Colors.white38),
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _steps[index],
                            style: GoogleFonts.jetBrainsMono(
                              color: isCompleted ? Colors.white : Colors.white70,
                              fontSize: 16,
                              fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
