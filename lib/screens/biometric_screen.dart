import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({Key? key}) : super(key: key);

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _isScanning = false;
  bool _isSuccess = false;
  String _mode = 'setup';
  bool _initialized = false;
  String? _selectedBiometric;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null && args['mode'] != null) {
        _mode = args['mode'] as String;
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerScan() async {
    if (_selectedBiometric == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select Face or Fingerprint first', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    HapticFeedback.heavyImpact();
    setState(() {
      _isScanning = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    HapticFeedback.heavyImpact();
    if (mounted) {
      setState(() {
        _isScanning = false;
        _isSuccess = true;
      });
    }

    await Future.delayed(const Duration(milliseconds: 1500));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometrics_enabled', true);

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _skip() async {
    HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometrics_enabled', false);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
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
                      'assets/images/onboarding/biometric_bg.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                  
                  // Back Button
                  Positioned(
                    top: h * 0.05,
                    left: w * 0.05,
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        color: Colors.transparent, // Invisible tap zone for back arrow
                      ),
                    ),
                  ),

                  // Face ID Select Zone
                  Positioned(
                    top: h * 0.35,
                    bottom: h * 0.40,
                    left: w * 0.1,
                    right: w * 0.5,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedBiometric = 'face');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _selectedBiometric == 'face' ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Fingerprint Select Zone
                  Positioned(
                    top: h * 0.35,
                    bottom: h * 0.40,
                    left: w * 0.5,
                    right: w * 0.1,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedBiometric = 'fingerprint');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _selectedBiometric == 'fingerprint' ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // AUTHENTICATE Button Overlay (Top Blank Button)
                  Positioned(
                    top: h * 0.69,
                    height: h * 0.08,
                    left: w * 0.15,
                    right: w * 0.15,
                    child: GestureDetector(
                      onTap: _triggerScan,
                      child: Container(
                        color: Colors.transparent,
                        child: Center(
                          child: Text(
                            'AUTHENTICATE',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: const Color(0xFF1A1A1A),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // SKIP Button Overlay (Bottom Blank Button)
                  Positioned(
                    top: h * 0.795,
                    height: h * 0.08,
                    left: w * 0.15,
                    right: w * 0.15,
                    child: GestureDetector(
                      onTap: _skip,
                      child: Container(
                        color: Colors.transparent,
                        child: Center(
                          child: Text(
                            'SKIP',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Scanning Overlay
                  if (_isScanning || _isSuccess)
                    Container(
                      color: Colors.black.withValues(alpha: 0.7),
                      child: Center(
                        child: Container(
                          width: 280,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A).withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFE0E0E0).withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isScanning)
                                ScaleTransition(
                                  scale: _pulseAnimation,
                                  child: Icon(
                                    _selectedBiometric == 'face' ? Icons.face : Icons.fingerprint, 
                                    color: const Color(0xFFE0E0E0), 
                                    size: 64
                                  ),
                                ),
                              if (_isSuccess)
                                const Icon(Icons.check_circle, color: Colors.greenAccent, size: 64),
                              const SizedBox(height: 24),
                              Text(
                                _isSuccess ? 'SECURITY LINKED' : 'Scanning...',
                                style: GoogleFonts.orbitron(
                                  color: const Color(0xFFE0E0E0),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
