import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> with TickerProviderStateMixin {
  late AnimationController _bracketController;
  late AnimationController _flashController;
  bool _isLocked = false;
  bool _showFlash = false;
  bool _flashlightOn = false;

  @override
  void initState() {
    super.initState();
    _bracketController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _startSimulatedCapture();
  }

  void _startSimulatedCapture() async {
    // Simulate searching for 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Lock on to card
    HapticFeedback.lightImpact();
    setState(() {
      _isLocked = true;
    });
    _bracketController.stop();

    // Hold steady for 1.5 seconds
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;

    // FLASH and Capture
    HapticFeedback.heavyImpact();
    setState(() {
      _showFlash = true;
    });
    
    await _flashController.forward();
    await _flashController.reverse();

    if (!mounted) return;
    
    // Navigate to processing
    Navigator.pushReplacementNamed(context, '/processing');
  }

  @override
  void dispose() {
    _bracketController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated Camera Feed
          Positioned.fill(
            child: Image.asset(
              'assets/images/camera_feed.png',
              fit: BoxFit.cover,
            ),
          ),
          
          // Flashlight dimming overlay
          if (!_flashlightOn && !_isLocked)
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.3)),
            ),

          // CN Targeting Brackets
          Center(
            child: AnimatedBuilder(
              animation: _bracketController,
              builder: (context, child) {
                final scale = _isLocked ? 1.0 : 1.0 + (_bracketController.value * 0.1);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 280,
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _isLocked ? Colors.greenAccent : const Color(0xFF00B4D8),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        // Crosshairs
                        Center(
                          child: Icon(
                            Icons.add,
                            color: _isLocked ? Colors.greenAccent : const Color(0xFF00B4D8).withValues(alpha: 0.5),
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Top UI Bar
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _isLocked ? 'LOCKED' : 'SEARCHING FOR CARD',
                    style: GoogleFonts.orbitron(
                      color: _isLocked ? Colors.greenAccent : const Color(0xFF00B4D8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _flashlightOn ? Icons.flash_on : Icons.flash_off,
                    color: _flashlightOn ? Colors.yellow : Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() => _flashlightOn = !_flashlightOn);
                  },
                ),
              ],
            ),
          ),

          // Flashlight Hint
          if (!_flashlightOn && !_isLocked)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.yellow.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lightbulb_outline, color: Colors.yellow, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Enable flashlight',
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Status Bar
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Text(
                  _isLocked ? 'HOLD STEADY' : 'Align reference card + test kit within brackets',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: _isLocked ? 1.0 : null,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isLocked ? Colors.greenAccent : const Color(0xFF00B4D8),
                  ),
                ),
              ],
            ),
          ),

          // White Flash Overlay
          if (_showFlash)
            Positioned.fill(
              child: Container(color: Colors.white),
            ),
        ],
      ),
    );
  }
}
