import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../navigation/app_router.dart';
import '../services/api_service.dart';

/// Multi-phase camera capture screen:
///
///   Phase 1 — SCANNING:   Searching for the reference card
///   Phase 2 — CARD FOUND: Reference card detected, waiting for drug test kit
///   Phase 3 — READY:      Both card + strip detected → auto-capture + analyze
///   Phase 4 — CAPTURED:   Flash effect → navigate to result
///   TIMEOUT:              2-min limit → "Test Failed" → redirect to test setup
///
/// The test is NOT stored if the reference card is never detected.

enum _CapturePhase {
  initializing,
  scanningCard,
  cardFound,
  analyzing,
  captured,
  failed,
}

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen>
    with TickerProviderStateMixin {
  // ─── Camera ──────────────────────────────────────────────────
  CameraController? _cameraController;
  bool _cameraReady = false;

  // ─── Phase state ─────────────────────────────────────────────
  _CapturePhase _phase = _CapturePhase.initializing;

  // ─── Timers ──────────────────────────────────────────────────
  Timer? _analysisTimer;
  Timer? _countdownTimer;
  int _secondsRemaining = 120; // 2 minutes
  bool _isAnalyzing = false;

  // ─── UI state ────────────────────────────────────────────────
  String _statusText = 'Initializing camera...';
  Color _statusColor = NarcSealColors.titaniumGray;
  bool _torchOn = false;
  bool _showTorchHint = false;

  // ─── Animation ───────────────────────────────────────────────
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _flashController;
  bool _showFlash = false;

  // ─── Data from test setup ────────────────────────────────────
  String? _testKitName;
  String? _testKitId;
  String? _sampleId;
  String? _notes;

  // ─── Prevent double navigation ───────────────────────────────
  bool _navigating = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _initCamera();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null) {
      _testKitName = args['testKit'] as String?;
      _testKitId = args['testKitId'] as String?;
      _sampleId = args['sampleId'] as String?;
      _notes = args['notes'] as String?;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  CAMERA INIT
  // ═══════════════════════════════════════════════════════════════

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _setPhase(_CapturePhase.failed, 'No camera available');
        return;
      }

      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,  // Higher res = better card detection accuracy
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
      if (!mounted) return;

      setState(() {
        _cameraReady = true;
      });

      _setPhase(_CapturePhase.scanningCard, 'Searching for reference card...');
      _startCountdown();
      _startAnalysisLoop();
    } catch (e) {
      _setPhase(_CapturePhase.failed, 'Camera error: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  COUNTDOWN (2-minute timeout)
  // ═══════════════════════════════════════════════════════════════

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _phase == _CapturePhase.captured || _navigating) {
        timer.cancel();
        return;
      }

      setState(() => _secondsRemaining--);

      if (_secondsRemaining <= 0) {
        timer.cancel();
        _analysisTimer?.cancel();
        _handleTimeout();
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════
  //  ANALYSIS LOOP — sends frames every 2 seconds
  // ═══════════════════════════════════════════════════════════════

  void _startAnalysisLoop() {
    _analysisTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!mounted || _isAnalyzing || _navigating) return;
      if (_phase == _CapturePhase.captured || _phase == _CapturePhase.failed) return;
      if (_cameraController == null || !_cameraController!.value.isInitialized) return;

      _isAnalyzing = true;

      try {
        final XFile imageFile = await _cameraController!.takePicture();
        final imageBytes = await imageFile.readAsBytes();
        print('[CameraScreen] Frame captured: ${imageBytes.length} bytes, file: ${imageFile.name}');

        String kitType = _testKitId ?? _mapKitNameToType(_testKitName);
        print('[CameraScreen] Sending to API with kitType=$kitType');

        final result = await ApiService.analyzeFrame(
          imageBytes, kitType, filename: imageFile.name,
        );

        print('[CameraScreen] API response: $result');

        if (!mounted || _navigating) return;

        final status = result['status'] as String? ?? 'error';
        final lighting = result['lighting'] as String? ?? 'ok';

        print('[CameraScreen] status=$status, lighting=$lighting');

        // ── Handle lighting ─────────────────────────────────────
        if (lighting == 'too_dark') {
          _setPhase(_CapturePhase.scanningCard, 'Too dark! Turn on the torch ☀️');
          setState(() => _showTorchHint = true);
          _statusColor = const Color(0xFFFF9800);
          return;
        } else {
          setState(() => _showTorchHint = false);
        }

        // ── Handle detection status ─────────────────────────────
        switch (status) {
          case 'card_not_detected':
            _setPhase(
              _CapturePhase.scanningCard,
              'Align reference card within frame',
            );
            break;

          case 'card_detected_no_strip':
            _setPhase(
              _CapturePhase.cardFound,
              'Card detected ✓ Place the drug test kit',
            );
            break;

          case 'success':
            // Card + strip detected + analysis complete → auto-capture!
            _onAnalysisComplete(result, imageFile.path);
            return;

          default:
            _setPhase(
              _CapturePhase.scanningCard,
              'Searching for reference card...',
            );
        }
      } catch (e, stackTrace) {
        print('[CameraScreen] ERROR in analysis loop: $e');
        print('[CameraScreen] Stack trace: $stackTrace');
        if (mounted && !_navigating) {
          _setPhase(
            _CapturePhase.scanningCard,
            'Connection error. Retrying...',
          );
        }
      } finally {
        _isAnalyzing = false;
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════
  //  ON ANALYSIS COMPLETE — auto-capture + navigate to result
  // ═══════════════════════════════════════════════════════════════

  void _onAnalysisComplete(Map<String, dynamic> result, String imagePath) async {
    if (_navigating) return;

    _analysisTimer?.cancel();
    _countdownTimer?.cancel();
    _navigating = true;

    if (!mounted) return;

    HapticFeedback.heavyImpact();
    _setPhase(_CapturePhase.analyzing, 'Analyzing drug reaction...');

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    _setPhase(_CapturePhase.captured, 'CAPTURED & ANALYZED ✓');
    _pulseController.stop();

    // Flash effect
    setState(() => _showFlash = true);
    await _flashController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _flashController.reverse();
    if (mounted) setState(() => _showFlash = false);

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    // Extract AI analysis data
    final analysis = result['analysis'] as Map<String, dynamic>? ?? {};

    // Navigate to result screen with complete data
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.result,
      arguments: {
        'result': analysis['result'] ?? 'INCONCLUSIVE',
        'substance': analysis['substance'] ?? 'Unknown',
        'confidence': analysis['confidence'] ?? 0.0,
        'delta_e': analysis['delta_e'] ?? 0.0,
        'hex_code': analysis['hex_code'] ?? '#000000',
        'color_name': analysis['color_name'] ?? 'Unknown',
        'corrected_rgb': analysis['corrected_rgb'],
        'testKit': _testKitName,
        'testKitId': _testKitId,
        'sampleId': _sampleId,
        'notes': _notes,
        'imagePath': imagePath,
        'raw_reaction_rgb': result['raw_reaction_rgb'],
        'kit_type': result['kit_type'],
        'calibration': result['calibration'],
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  TIMEOUT — Reference card not detected in 2 minutes
  // ═══════════════════════════════════════════════════════════════

  void _handleTimeout() {
    if (!mounted || _navigating) return;
    _navigating = true;

    HapticFeedback.heavyImpact();
    _setPhase(_CapturePhase.failed, 'TEST FAILED — Reference card not detected');

    _cameraController?.dispose();

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: const Icon(Icons.error_outline, color: Color(0xFFE53935), size: 56),
          title: Text(
            'TEST FAILED',
            style: NarcSealTypography.sectionTitle.copyWith(
              color: const Color(0xFFE53935),
              fontSize: 22,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Reference card was not detected within the 2-minute window.',
                style: NarcSealTypography.body.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    _failInfoRow(Icons.do_not_disturb, 'No test recorded'),
                    const SizedBox(height: 8),
                    _failInfoRow(Icons.replay, 'Please retake the test'),
                    const SizedBox(height: 8),
                    _failInfoRow(Icons.credit_card, 'Ensure the reference card is clearly visible'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close dialog
                  // Navigate back to test setup — do NOT store anything
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.testSetup,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'RETAKE TEST',
                      style: NarcSealTypography.buttonText.copyWith(
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _failInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: NarcSealTypography.metadata.copyWith(color: Colors.white54),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════════════════════════

  void _setPhase(_CapturePhase phase, String statusText) {
    if (!mounted) return;
    setState(() {
      _phase = phase;
      _statusText = statusText;
      _statusColor = _colorForPhase(phase);
    });
  }

  Color _colorForPhase(_CapturePhase phase) {
    switch (phase) {
      case _CapturePhase.initializing:
        return NarcSealColors.titaniumGray;
      case _CapturePhase.scanningCard:
        return NarcSealColors.olive;
      case _CapturePhase.cardFound:
        return const Color(0xFF4CAF50); // Green accent
      case _CapturePhase.analyzing:
        return const Color(0xFF00B4D8); // Cyan
      case _CapturePhase.captured:
        return NarcSealColors.negative;
      case _CapturePhase.failed:
        return NarcSealColors.positive;
    }
  }

  String _mapKitNameToType(String? kitName) {
    if (kitName == null) return 'Marquis';
    if (kitName.contains('Marquis')) return 'Marquis';
    if (kitName.contains('Scott')) return 'Scott';
    if (kitName.contains('Mandelin')) return 'Mandelin';
    if (kitName.contains('Mecke')) return 'Mecke';
    if (kitName.contains('Ehrlich')) return 'Ehrlich';
    return 'Marquis';
  }

  void _toggleTorch() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    HapticFeedback.selectionClick();
    setState(() => _torchOn = !_torchOn);
    try {
      await _cameraController!.setFlashMode(
        _torchOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      print('Torch error: $e');
    }
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Builds 4 corner bracket decorations spanning most of the screen
  /// to show the card can be detected ANYWHERE in the frame.
  List<Widget> _buildCornerBrackets(
    BuildContext context,
    Color color,
    double pulseScale,
  ) {
    const margin = 28.0;
    const len    = 36.0;
    const thick  = 4.0;

    Widget bracket({
      required Alignment alignment,
      required bool flipX,
      required bool flipY,
    }) {
      return Positioned.fill(
        child: Align(
          alignment: alignment,
          child: Padding(
            padding: EdgeInsets.all(margin),
            child: SizedBox(
              width: len,
              height: len,
              child: CustomPaint(
                painter: _BracketPainter(
                  color: color.withValues(alpha: 0.85 * pulseScale),
                  thickness: thick,
                  flipX: flipX,
                  flipY: flipY,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return [
      bracket(alignment: Alignment.topLeft,     flipX: false, flipY: false),
      bracket(alignment: Alignment.topRight,    flipX: true,  flipY: false),
      bracket(alignment: Alignment.bottomLeft,  flipX: false, flipY: true),
      bracket(alignment: Alignment.bottomRight, flipX: true,  flipY: true),
    ];
  }

  @override
  void dispose() {
    _analysisTimer?.cancel();
    _countdownTimer?.cancel();
    _pulseController.dispose();
    _flashController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final bool isScanning = _phase == _CapturePhase.scanningCard ||
        _phase == _CapturePhase.cardFound;
    final bool isDone = _phase == _CapturePhase.captured;
    final bool isCardFound = _phase == _CapturePhase.cardFound;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ─── Camera preview ─────────────────────────────────────
          if (_cameraReady &&
              _cameraController != null &&
              _cameraController!.value.isInitialized)
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            )
          else
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(color: NarcSealColors.olive),
                ),
              ),
            ),

          // ─── Adaptive scanning overlay ─────────────────────────
          // The card is detected ANYWHERE in the full frame.
          // This overlay shows corner guides + status — NOT a restriction zone.
          if (_cameraReady && isScanning)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  final Color overlayColor = isCardFound
                      ? const Color(0xFF4CAF50)
                      : NarcSealColors.olive;
                  return Stack(
                    children: [
                      // Semi-dark vignette so card stands out
                      if (!isCardFound)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 1.2,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.35),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // Corner bracket guides (purely decorative — card detected ANYWHERE)
                      ..._buildCornerBrackets(context, overlayColor, _pulseAnimation.value),

                      // Center status badge
                      if (isCardFound)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  'CARD DETECTED',
                                  style: NarcSealTypography.metadata.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        // Instruction text when still scanning
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.18,
                          left: 32,
                          right: 32,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Point camera at the colour reference card.\nCard can be anywhere in the frame.',
                              textAlign: TextAlign.center,
                              style: NarcSealTypography.metadata.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

          // ─── Analyzing overlay ──────────────────────────────────
          if (_phase == _CapturePhase.analyzing)
            Center(
              child: Container(
                width: 280,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF00B4D8),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black26,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: Color(0xFF00B4D8),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ANALYZING...',
                      style: NarcSealTypography.metadata.copyWith(
                        color: const Color(0xFF00B4D8),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ─── Captured state — green check ───────────────────────
          if (isDone)
            Center(
              child: Container(
                width: 280,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: NarcSealColors.negative, width: 4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.check_circle, color: NarcSealColors.negative, size: 64),
                ),
              ),
            ),

          // ─── Top bar: close + timer + phase badge + torch ──────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // Close / cancel button
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),

                const Spacer(),

                // Phase badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _statusColor.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _phaseIcon(),
                      const SizedBox(width: 6),
                      Text(
                        _phaseLabel(),
                        style: NarcSealTypography.metadata.copyWith(
                          color: _statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Timer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: _secondsRemaining < 30
                            ? NarcSealColors.positive
                            : Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(_secondsRemaining),
                        style: NarcSealTypography.metadata.copyWith(
                          color: _secondsRemaining < 30
                              ? NarcSealColors.positive
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Torch toggle
                IconButton(
                  icon: Icon(
                    _torchOn ? Icons.flash_on : Icons.flash_off,
                    color: _torchOn ? Colors.amber : Colors.white,
                    size: 28,
                  ),
                  onPressed: _toggleTorch,
                ),
              ],
            ),
          ),

          // ─── Bottom status bar ──────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                24, 20, 24, MediaQuery.of(context).padding.bottom + 20,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87, Colors.black],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status text with icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isScanning)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: _statusColor,
                            strokeWidth: 2,
                          ),
                        ),
                      if (isDone)
                        Icon(Icons.check_circle, color: _statusColor, size: 18),
                      if (_phase == _CapturePhase.analyzing)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: _statusColor,
                            strokeWidth: 2,
                          ),
                        ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          _statusText,
                          style: NarcSealTypography.body.copyWith(
                            color: _statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Torch hint
                  if (_showTorchHint && isScanning)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        border: Border.all(color: Colors.amber),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lightbulb_outline,
                              color: Colors.amber, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Tap the flash icon to turn on torch',
                            style: NarcSealTypography.metadata
                                .copyWith(color: Colors.amber),
                          ),
                        ],
                      ),
                    ),

                  // Kit info
                  if (_testKitName != null)
                    Text(
                      'Kit: $_testKitName',
                      style: NarcSealTypography.metadata
                          .copyWith(color: Colors.white54),
                    ),
                ],
              ),
            ),
          ),

          // ─── Flash overlay ──────────────────────────────────────
          if (_showFlash)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _flashController,
                builder: (context, _) {
                  return Container(
                    color: Colors.white
                        .withValues(alpha: _flashController.value),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // ─── Phase badge helpers ────────────────────────────────────────

  Widget _phaseIcon() {
    switch (_phase) {
      case _CapturePhase.scanningCard:
        return Icon(Icons.search, color: _statusColor, size: 14);
      case _CapturePhase.cardFound:
        return Icon(Icons.credit_card, color: _statusColor, size: 14);
      case _CapturePhase.analyzing:
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            color: _statusColor,
            strokeWidth: 2,
          ),
        );
      case _CapturePhase.captured:
        return Icon(Icons.check_circle, color: _statusColor, size: 14);
      case _CapturePhase.failed:
        return Icon(Icons.error_outline, color: _statusColor, size: 14);
      default:
        return Icon(Icons.hourglass_empty, color: _statusColor, size: 14);
    }
  }

  String _phaseLabel() {
    switch (_phase) {
      case _CapturePhase.initializing:
        return 'INIT';
      case _CapturePhase.scanningCard:
        return 'SCANNING';
      case _CapturePhase.cardFound:
        return 'CARD FOUND';
      case _CapturePhase.analyzing:
        return 'ANALYZING';
      case _CapturePhase.captured:
        return 'CAPTURED';
      case _CapturePhase.failed:
        return 'FAILED';
    }
  }
}

/// CustomPainter for an L-shaped corner bracket.
class _BracketPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final bool flipX;
  final bool flipY;

  const _BracketPainter({
    required this.color,
    required this.thickness,
    required this.flipX,
    required this.flipY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final w = size.width;
    final h = size.height;

    // Draw in top-left orientation, then flip
    canvas.save();
    canvas.translate(flipX ? w : 0, flipY ? h : 0);
    canvas.scale(flipX ? -1 : 1, flipY ? -1 : 1);

    // Horizontal arm
    canvas.drawLine(Offset(0, 0), Offset(w, 0), paint);
    // Vertical arm
    canvas.drawLine(Offset(0, 0), Offset(0, h), paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_BracketPainter old) =>
      old.color != color || old.thickness != thickness;
}
