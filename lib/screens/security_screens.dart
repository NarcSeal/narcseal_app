import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/colors.dart';

/// Tamper Detected Screen — Full-screen security alert
///
/// Shown when hash chain verification fails, indicating evidence
/// integrity has been compromised. Uses alarming red UI with
/// pulsing hazard elements per the NarcSeal Security Architecture.
class TamperDetectedScreen extends StatefulWidget {
  final String? recordId;
  final String? officerBadge;
  final String? mismatchDetails;

  const TamperDetectedScreen({
    super.key,
    this.recordId,
    this.officerBadge,
    this.mismatchDetails,
  });

  @override
  State<TamperDetectedScreen> createState() => _TamperDetectedScreenState();
}

class _TamperDetectedScreenState extends State<TamperDetectedScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _stripesController;

  @override
  void initState() {
    super.initState();

    // Pulsing red warning
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Subtle shake
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _shakeAnimation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );

    // Animated hazard stripes
    _stripesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Trigger heavy haptic
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) HapticFeedback.heavyImpact();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    _stripesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: child,
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Red vignette
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, _) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF7F1D1D)
                            .withOpacity(_pulseAnimation.value * 0.3),
                        Colors.black,
                      ],
                      radius: 1.2,
                    ),
                  ),
                );
              },
            ),

            // Top hazard stripe
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _stripesController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _HazardStripePainter(
                      offset: _stripesController.value,
                    ),
                    size: const Size(double.infinity, 8),
                  );
                },
              ),
            ),

            // Bottom hazard stripe
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _stripesController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _HazardStripePainter(
                      offset: _stripesController.value,
                    ),
                    size: const Size(double.infinity, 8),
                  );
                },
              ),
            ),

            // Main content
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Warning triangle
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, _) {
                          return Icon(
                            Icons.warning_rounded,
                            size: 56,
                            color: NarcSealColors.resultPositive
                                .withOpacity(_pulseAnimation.value),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Broken chain icon
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, _) {
                          return Icon(
                            Icons.link_off_rounded,
                            size: 80,
                            color: NarcSealColors.resultPositive
                                .withOpacity(0.5 + _pulseAnimation.value * 0.5),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // TAMPER DETECTED
                      Text(
                        'TAMPER DETECTED',
                        style: GoogleFonts.orbitron(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: NarcSealColors.resultPositive,
                          letterSpacing: 4,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'Image integrity compromised.\nEvidence record flagged.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: NarcSealColors.textPrimary,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Details container
                      if (widget.recordId != null || widget.officerBadge != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7F1D1D).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: NarcSealColors.resultPositive
                                  .withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.recordId != null)
                                _buildDetailRow(
                                  'Record ID',
                                  widget.recordId!,
                                ),
                              if (widget.officerBadge != null)
                                _buildDetailRow(
                                  'Officer',
                                  widget.officerBadge!,
                                ),
                              if (widget.mismatchDetails != null)
                                _buildDetailRow(
                                  'Mismatch',
                                  widget.mismatchDetails!,
                                ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 48),

                      // Dismiss button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: NarcSealColors.resultPositive,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'ACKNOWLEDGE',
                            style: GoogleFonts.orbitron(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: NarcSealColors.resultPositive,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: NarcSealColors.resultPositive,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: NarcSealColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Integrity Verified Screen — Full-screen success confirmation
///
/// Shown when hash chain verification passes, confirming evidence
/// integrity. Uses green shield with checkmark per the Image Prompts.
class IntegrityVerifiedScreen extends StatefulWidget {
  final int recordsVerified;

  const IntegrityVerifiedScreen({
    super.key,
    this.recordsVerified = 0,
  });

  @override
  State<IntegrityVerifiedScreen> createState() =>
      _IntegrityVerifiedScreenState();
}

class _IntegrityVerifiedScreenState extends State<IntegrityVerifiedScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _shieldController;
  late Animation<double> _shieldScale;
  late Animation<double> _shieldOpacity;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _shieldController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _shieldScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _shieldController, curve: Curves.elasticOut),
    );
    _shieldOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _shieldController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _shieldController.forward();
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _shieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NarcSealColors.bgAbyss,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Green radial glow
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, _) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF14532D)
                          .withOpacity(_glowAnimation.value * 0.4),
                      NarcSealColors.bgAbyss,
                    ],
                    radius: 1.0,
                  ),
                ),
              );
            },
          ),

          // Gold accent lines top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    NarcSealColors.sealGold,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Gold accent lines bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    NarcSealColors.sealGold,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Shield with checkmark
                    AnimatedBuilder(
                      animation: _shieldController,
                      builder: (context, _) {
                        return Transform.scale(
                          scale: _shieldScale.value,
                          child: Opacity(
                            opacity: _shieldOpacity.value,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Glow behind shield
                                AnimatedBuilder(
                                  animation: _glowAnimation,
                                  builder: (context, _) {
                                    return Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: NarcSealColors.resultNegative
                                                .withOpacity(
                                              _glowAnimation.value * 0.5,
                                            ),
                                            blurRadius: 40,
                                            spreadRadius: 10,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                // Shield icon
                                const Icon(
                                  Icons.verified_user_rounded,
                                  size: 100,
                                  color: NarcSealColors.resultNegative,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // INTEGRITY VERIFIED
                    Text(
                      'INTEGRITY VERIFIED',
                      style: GoogleFonts.orbitron(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: NarcSealColors.resultNegative,
                        letterSpacing: 3,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'All records in the hash chain are intact.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: NarcSealColors.textPrimary,
                        height: 1.5,
                      ),
                    ),

                    if (widget.recordsVerified > 0) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: NarcSealColors.resultNegative.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                NarcSealColors.resultNegative.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '${widget.recordsVerified} records verified',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 13,
                            color: NarcSealColors.resultNegative,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 48),

                    // Done button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: NarcSealColors.resultNegative,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'CONTINUE',
                          style: GoogleFonts.orbitron(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for animated hazard stripes (red/black diagonal lines)
class _HazardStripePainter extends CustomPainter {
  final double offset;

  _HazardStripePainter({required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDC2626)
      ..strokeWidth = 4;

    const stripeWidth = 12.0;
    final totalWidth = size.width + stripeWidth * 4;
    final startX = -stripeWidth * 2 + (offset * stripeWidth * 4);

    for (double x = startX; x < totalWidth; x += stripeWidth * 2) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HazardStripePainter oldDelegate) =>
      oldDelegate.offset != offset;
}
