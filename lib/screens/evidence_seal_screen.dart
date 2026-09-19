import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../core/theme/colors.dart';

class EvidenceSealScreen extends StatefulWidget {
  const EvidenceSealScreen({super.key});

  @override
  State<EvidenceSealScreen> createState() => _EvidenceSealScreenState();
}

class _EvidenceSealScreenState extends State<EvidenceSealScreen> with TickerProviderStateMixin {
  late AnimationController _sealController;
  late AnimationController _particleController;
  late AnimationController _certController;
  late AnimationController _badgeController;
  late AnimationController _shimmerController;
  
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  bool _showVideo = false;

  late Animation<double> _sealScale;
  late Animation<double> _sealOpacity;
  late Animation<double> _certScale;
  late Animation<double> _badgeOpacity;

  int _typingStep = 0;

  @override
  void initState() {
    super.initState();

    _sealController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _particleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _certController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _badgeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _shimmerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));

    _sealScale = Tween<double>(begin: 3.0, end: 1.0).animate(
      CurvedAnimation(parent: _sealController, curve: Curves.easeInBack)
    );
    _sealOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sealController, curve: const Interval(0.0, 0.5))
    );
    
    _certScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _certController, curve: Curves.easeOutBack)
    );

    _badgeOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _badgeController, curve: Curves.easeInOut)
    );

    _initializeVideo();
  }
  
  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset('assets/videos/seal_stamp.mp4');
    await _videoController.initialize();
    _videoController.addListener(() {
      if (_videoController.value.position >= _videoController.value.duration) {
        if (mounted) {
          setState(() {
            _showVideo = false;
          });
        }
      }
    });
    setState(() {
      _isVideoInitialized = true;
    });
    _startCeremony();
  }

  void _startCeremony() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    
    setState(() {
      _showVideo = true;
    });
    _videoController.play();
    
    _sealController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    
    _particleController.forward();
    
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    _certController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    
    for (int i = 1; i <= 9; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;
      setState(() {
        _typingStep = i;
      });
      HapticFeedback.selectionClick();
    }
    
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _badgeController.forward();
    
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _shimmerController.forward();
  }

  @override
  void dispose() {
    _sealController.dispose();
    _particleController.dispose();
    _certController.dispose();
    _badgeController.dispose();
    _shimmerController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  Widget _buildField(String label, String value, int stepReq) {
    bool isVisible = _typingStep >= stepReq;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: NarcSealColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: AnimatedOpacity(
              opacity: isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                value,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  color: label.contains("Hash") ? NarcSealColors.accentCyan : NarcSealColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NarcSealColors.bgAbyss,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                
                Expanded(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _certController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _certScale.value,
                          child: child,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24.0),
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: NarcSealColors.bgGunmetal,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: NarcSealColors.borderSubtle, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.verified, color: NarcSealColors.accentCyan, size: 32),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "EVIDENCE CERTIFICATE",
                                        style: GoogleFonts.orbitron(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: NarcSealColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(color: NarcSealColors.borderSubtle, height: 32),
                                
                                _buildField("Record ID", "a7f3-c8d2-e1b4", 1),
                                _buildField("Officer", "Insp. Sharma (NCB-4421)", 2),
                                _buildField("Date/Time", "18 Sep 2026, 14:32:07", 3),
                                _buildField("Location", "19.076090°N, 72.877426°E", 4),
                                _buildField("Map", "Mumbai, Maharashtra", 5),
                                _buildField("Result", "POSITIVE — Cannabis", 6),
                                _buildField("Confidence", "94.2%", 7),
                                _buildField("Image Hash", "a7f3c8d2e1b4f9a2...", 8),
                                _buildField("Chain Hash", "9b1e42f7a8c3d2e5...", 9),
                                _buildField("Chain Pos.", "🔗 Chain: 47", 9),
                                
                                const SizedBox(height: 32),
                                
                                Center(
                                  child: AnimatedBuilder(
                                    animation: _badgeController,
                                    builder: (context, child) {
                                      return Opacity(
                                        opacity: _badgeOpacity.value,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: NarcSealColors.resultNegativeText.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: NarcSealColors.resultNegativeText),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.check_circle, color: NarcSealColors.resultNegativeText, size: 20),
                                              const SizedBox(width: 8),
                                              Text(
                                                "INTEGRITY VERIFIED",
                                                style: GoogleFonts.inter(
                                                  color: NarcSealColors.resultNegativeText,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  ),
                                ),
                              ],
                            ),
                            
                            Positioned.fill(
                              child: AnimatedBuilder(
                                animation: _shimmerController,
                                builder: (context, child) {
                                  if (_shimmerController.value == 0 || _shimmerController.value == 1) {
                                    return const SizedBox.shrink();
                                  }
                                  return ShaderMask(
                                    blendMode: BlendMode.srcATop,
                                    shaderCallback: (bounds) {
                                      return LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        stops: [
                                          _shimmerController.value - 0.2,
                                          _shimmerController.value,
                                          _shimmerController.value + 0.2,
                                        ],
                                        colors: [
                                          Colors.transparent,
                                          Colors.white.withOpacity(0.3),
                                          Colors.transparent,
                                        ],
                                      ).createShader(bounds);
                                    },
                                    child: Container(color: Colors.white.withOpacity(0.1)),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                AnimatedOpacity(
                  opacity: _typingStep >= 9 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon')));
                                },
                                icon: const Icon(Icons.share, color: NarcSealColors.textPrimary, size: 20),
                                label: const Text("Share"),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  foregroundColor: NarcSealColors.textPrimary,
                                  side: const BorderSide(color: NarcSealColors.borderSubtle),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon')));
                                },
                                icon: const Icon(Icons.picture_as_pdf, color: NarcSealColors.textPrimary, size: 20),
                                label: const Text("Export PDF"),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  foregroundColor: NarcSealColors.textPrimary,
                                  side: const BorderSide(color: NarcSealColors.borderSubtle),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: NarcSealColors.bgSurface,
                                  title: Text("Show QR", style: GoogleFonts.inter(color: Colors.white)),
                                  content: Container(
                                    width: 200, height: 200,
                                    color: Colors.white,
                                    child: const Center(child: Icon(Icons.qr_code, size: 100, color: Colors.black)),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.qr_code, color: NarcSealColors.bgAbyss),
                            label: Text(
                              "SHOW QR",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: NarcSealColors.bgAbyss,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NarcSealColors.accentCyan,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _certController,
              builder: (context, child) {
                if (_certController.value > 0) return const SizedBox.shrink();
                
                return AnimatedBuilder(
                  animation: _sealController,
                  builder: (context, child) {
                    if (_sealController.value == 0) return const SizedBox.shrink();
                    return Center(
                      child: Opacity(
                        opacity: _sealOpacity.value,
                        child: Transform.scale(
                          scale: _sealScale.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: NarcSealColors.bgSurface,
                              border: Border.all(color: NarcSealColors.sealGold, width: 4),
                              boxShadow: [
                                BoxShadow(color: NarcSealColors.sealGold.withOpacity(0.5), blurRadius: 30)
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.verified, size: 80, color: NarcSealColors.sealGold),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                if (_particleController.value == 0 || _certController.value > 0.5) return const SizedBox.shrink();
                return Center(
                  child: Transform.scale(
                    scale: 1.0 + (_particleController.value * 2),
                    child: Opacity(
                      opacity: 1.0 - _particleController.value,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: NarcSealColors.sealGold, width: 2),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          if (_showVideo && _isVideoInitialized)
            IgnorePointer(
              child: Center(
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: VideoPlayer(_videoController),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
