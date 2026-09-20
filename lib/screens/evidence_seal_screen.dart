import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:uuid/uuid.dart';

import '../services/api_service.dart';
import '../models/evidence_record.dart';
import '../models/test_result.dart';

class EvidenceSealScreen extends StatefulWidget {
  const EvidenceSealScreen({super.key});

  @override
  State<EvidenceSealScreen> createState() => _EvidenceSealScreenState();
}

class _EvidenceSealScreenState extends State<EvidenceSealScreen> {
  late VideoPlayerController _videoController;
  bool _animationFinished = false;
  String _resultType = 'POSITIVE';
  bool _initialized = false;
  bool _isSyncing = false;
  bool _syncSuccess = false;
  String _recordId = const Uuid().v4();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null && args['result'] != null) {
        _resultType = args['result'] as String;
      }
      _initVideo();
      _initialized = true;
    }
  }

  void _initVideo() {
    _videoController = VideoPlayerController.asset('assets/videos/tamper_proof.mp4')
      ..initialize().then((_) {
        _videoController.setLooping(false);
        _videoController.play();
        if (mounted) setState(() {});

        _videoController.addListener(() {
          if (!_videoController.value.isInitialized) return;

          final duration = _videoController.value.duration;
          final position = _videoController.value.position;

          // Ensure duration is actually loaded and position has reached it
          if (duration > Duration.zero && position >= duration) {
            if (!_animationFinished && mounted) {
              setState(() {
                _animationFinished = true;
              });
              _syncRecord();
            }
          }
        });
      });
  }

  Future<void> _syncRecord() async {
    setState(() => _isSyncing = true);
    final officer = ApiService.currentOfficer;
    final record = EvidenceRecord(
      recordId: _recordId,
      officerBadgeId: officer.badgeId,
      officerName: officer.fullName,
      timestamp: DateTime.now(),
      latitude: 28.6139, // mock gps
      longitude: 77.2090, // mock gps
      address: 'Connaught Place, New Delhi',
      testResult: _resultType == 'POSITIVE' ? TestResult.positive : (_resultType == 'NEGATIVE' ? TestResult.negative : TestResult.inconclusive),
      substance: _resultType == 'POSITIVE' ? 'Cocaine Hydrochloride' : (_resultType == 'NEGATIVE' ? 'No Narcotics Detected' : 'Unknown Substance'),
      confidence: 0.98,
      imageHash: '8f4b0292193b092a101b0f92223a9109',
      previousHash: '2c99a0928bb019f2a991b11b',
      recordHash: '2c99a0928bb019f2a991b11b',
      deviceId: 'DEVICE-1029',
      isSynced: false,
      isSealed: true,
      createdAt: DateTime.now(),
    );

    final success = await ApiService.uploadTestRecord(record);
    if (mounted) {
      setState(() {
        _isSyncing = false;
        _syncSuccess = success;
      });
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Sealing Animation
          if (_videoController.value.isInitialized && !_animationFinished)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            ),

          // Certificate Screen (Fades in after animation)
          IgnorePointer(
            ignoring: !_animationFinished,
            child: AnimatedOpacity(
              opacity: _animationFinished ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 800),
              child: _buildCertificate(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificate() {
    Color themeColor = _resultType == 'POSITIVE' 
        ? Colors.redAccent 
        : (_resultType == 'NEGATIVE' ? Colors.greenAccent : Colors.amber);

    return SafeArea(
      child: Column(
        children: [
          // App Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                ),
                Text(
                  'EVIDENCE CERTIFICATE',
                  style: GoogleFonts.orbitron(
                    color: const Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 48), // Balance
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5), width: 2),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'RECORD ID',
                          style: GoogleFonts.inter(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _isSyncing ? Colors.blue.withValues(alpha: 0.2) : (_syncSuccess ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2)),
                            border: Border.all(color: _isSyncing ? Colors.blueAccent : (_syncSuccess ? Colors.greenAccent : Colors.orangeAccent)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _isSyncing ? 'SYNCING...' : (_syncSuccess ? 'SYNCED & VERIFIED' : 'LOCAL ONLY'),
                            style: GoogleFonts.inter(
                              color: _isSyncing ? Colors.blueAccent : (_syncSuccess ? Colors.greenAccent : Colors.orangeAccent), 
                              fontSize: 10, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _recordId.split('-').first.toUpperCase(),
                      style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(color: Colors.white24, height: 32),
                    
                    _buildDetailRow('OFFICER', 'Insp. Sharma (NCB-4421)'),
                    const SizedBox(height: 16),
                    _buildDetailRow('DATE / TIME', 'Oct 24, 2026 - 14:32:05'),
                    const SizedBox(height: 16),
                    _buildDetailRow('LOCATION', '28.6139° N, 77.2090° E\nConnaught Place, New Delhi'),
                    
                    const Divider(color: Colors.white24, height: 32),
                    
                    Text(
                      'TEST RESULT',
                      style: GoogleFonts.inter(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: themeColor.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _resultType,
                            style: GoogleFonts.orbitron(color: themeColor, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _resultType == 'POSITIVE' ? 'Cocaine Hydrochloride' : (_resultType == 'NEGATIVE' ? 'No Narcotics Detected' : 'Unknown Substance'),
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),

                    const Divider(color: Colors.white24, height: 32),

                    _buildHashRow('IMAGE HASH (SHA-256)', '0x8f4b...3a91'),
                    const SizedBox(height: 16),
                    _buildHashRow('MERKLE CHAIN HASH', '0x2c99...f11b'),
                  ],
                ),
              ),
            ),
          ),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(Icons.share, 'Share', () { HapticFeedback.lightImpact(); }),
                _buildActionButton(Icons.picture_as_pdf, 'PDF', () { HapticFeedback.lightImpact(); }),
                _buildActionButton(Icons.qr_code_2, 'QR', () { HapticFeedback.lightImpact(); }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildHashRow(String label, String hash) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: Text(
            hash,
            style: GoogleFonts.jetBrainsMono(color: const Color(0xFF00B4D8), fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A1A1A),
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
