import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../navigation/app_router.dart';
import '../models/evidence_record.dart';
import '../models/test_result.dart';
import '../services/api_service.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  // AI analysis results
  String _resultType = 'INCONCLUSIVE';
  String _substance = 'Unknown';
  double _confidence = 0.0;
  double _deltaE = 0.0;
  String _hexCode = '#000000';
  String _colorName = 'Unknown';
  List<dynamic>? _correctedRgb;
  String? _testKit;
  String? _testKitId;
  String? _sampleId;
  String? _notes;
  String? _imagePath;

  // Sealing state
  bool _isSealing = false;
  bool _isSealed = false;
  bool _isSynced = false;
  String _recordId = '';
  String _imageHash = '';
  String _recordHash = '';
  String _previousHash = 'GENESIS';

  // Location
  double _latitude = 0.0;
  double _longitude = 0.0;
  String _address = 'Unknown Location';

  // Timestamps
  late DateTime _captureTime;

  @override
  void initState() {
    super.initState();
    _captureTime = DateTime.now();
    _recordId = const Uuid().v4();
    _getLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null) {
      setState(() {
        _resultType = (args['result'] as String?) ?? 'INCONCLUSIVE';
        _substance = (args['substance'] as String?) ?? 'Unknown';
        _confidence = (args['confidence'] as num?)?.toDouble() ?? 0.0;
        _deltaE = (args['delta_e'] as num?)?.toDouble() ?? 0.0;
        _hexCode = (args['hex_code'] as String?) ?? '#000000';
        _colorName = (args['color_name'] as String?) ?? 'Unknown';
        _correctedRgb = args['corrected_rgb'] as List<dynamic>?;
        _testKit = args['testKit'] as String?;
        _testKitId = args['testKitId'] as String?;
        _sampleId = args['sampleId'] as String?;
        _notes = args['notes'] as String?;
        _imagePath = args['imagePath'] as String?;
      });

      // Compute image hash if we have the image
      if (_imagePath != null) {
        _computeImageHash();
      }
    }
  }

  Future<void> _getLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _address = '${position.latitude.toStringAsFixed(4)}°N, ${position.longitude.toStringAsFixed(4)}°E';
        });
      }
    } catch (e) {
      print('Location error: $e');
    }
  }

  Future<void> _computeImageHash() async {
    try {
      final file = File(_imagePath!);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final digest = sha256.convert(bytes);
        setState(() {
          _imageHash = digest.toString();
        });
      }
    } catch (e) {
      print('Hash error: $e');
      _imageHash = const Uuid().v4();
    }
  }

  void _computeRecordHash() {
    final orderedString = '${ApiService.currentOfficer.badgeId}|'
        '${_captureTime.toIso8601String()}|'
        '$_latitude|'
        '$_longitude|'
        '$_resultType|'
        '$_substance|'
        '$_confidence|'
        '$_imageHash|'
        '$_previousHash';

    final digest = sha256.convert(utf8.encode(orderedString));
    _recordHash = digest.toString();
  }

  Future<void> _sealAndSync() async {
    HapticFeedback.heavyImpact();
    setState(() => _isSealing = true);

    // Step 1: Compute record hash (seal the evidence)
    _computeRecordHash();

    final officer = ApiService.currentOfficer;
    final record = EvidenceRecord(
      recordId: _recordId,
      officerBadgeId: officer.badgeId,
      officerName: officer.fullName,
      timestamp: _captureTime,
      latitude: _latitude,
      longitude: _longitude,
      address: _address,
      testResult: _parseResult(_resultType),
      substance: _substance,
      testKitType: _testKit,
      sampleId: _sampleId ?? 'NS-${DateFormat('yyyy').format(_captureTime)}-${_recordId.substring(0, 6).toUpperCase()}',
      notes: _notes,
      confidence: _confidence / 100.0,
      imageHash: _imageHash,
      previousHash: _previousHash,
      recordHash: _recordHash,
      deviceId: 'NARCSEAL-APP',
      isSynced: false,
      isSealed: true,
      createdAt: _captureTime,
    );

    setState(() => _isSealed = true);

    // Step 2: Check connectivity and try to sync
    bool synced = false;
    try {
      final connectivity = await Connectivity().checkConnectivity();
      final hasInternet = connectivity.any((c) => c != ConnectivityResult.none);

      if (hasInternet) {
        synced = await ApiService.uploadRecordWithImage(record, _imagePath);
      }
    } catch (e) {
      print('Sync error: $e');
    }

    // Step 3: If sync failed, store locally
    if (!synced) {
      await _storeLocally(record);
    }

    if (mounted) {
      setState(() {
        _isSynced = synced;
        _isSealing = false;
      });

      HapticFeedback.heavyImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            synced
                ? '✓ Evidence sealed & synced to database'
                : '✓ Evidence sealed & stored locally (will sync when online)',
          ),
          backgroundColor: synced ? NarcSealColors.negative : NarcSealColors.inconclusive,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _storeLocally(EvidenceRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingRecords = prefs.getString('pending_records') ?? '[]';
      final List<dynamic> records = jsonDecode(pendingRecords);
      records.add(record.toJson());
      await prefs.setString('pending_records', jsonEncode(records));
    } catch (e) {
      print('Local storage error: $e');
    }
  }

  TestResult _parseResult(String result) {
    switch (result.toUpperCase()) {
      case 'POSITIVE':
        return TestResult.positive;
      case 'NEGATIVE':
        return TestResult.negative;
      default:
        return TestResult.inconclusive;
    }
  }

  void _goHome() {
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  void _retake() {
    HapticFeedback.lightImpact();
    Navigator.pushReplacementNamed(context, AppRoutes.camera, arguments: {
      'testKit': _testKit,
      'sampleId': _sampleId,
      'notes': _notes,
    });
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor;
    IconData statusIcon;
    String statusLabel;

    switch (_resultType.toUpperCase()) {
      case 'POSITIVE':
        themeColor = NarcSealColors.positive;
        statusIcon = Icons.warning_rounded;
        statusLabel = 'POSITIVE';
        break;
      case 'NEGATIVE':
        themeColor = NarcSealColors.negative;
        statusIcon = Icons.check_circle;
        statusLabel = 'NEGATIVE';
        break;
      default:
        themeColor = NarcSealColors.inconclusive;
        statusIcon = Icons.help_outline;
        statusLabel = 'INCONCLUSIVE';
    }

    return Scaffold(
      backgroundColor: NarcSealColors.warmOffWhite,
      appBar: AppBar(
        title: const Text('ANALYSIS REPORT'),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'assets/images/branding/narcseal_logo.png',
              height: 28,
              errorBuilder: (c, e, s) => const Icon(Icons.security, color: NarcSealColors.titaniumGray),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Result Banner ───
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.08),
                  border: Border.all(color: themeColor, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(statusIcon, color: themeColor, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      statusLabel,
                      style: NarcSealTypography.statusBadge.copyWith(
                        color: themeColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_substance != 'None' && _substance != 'Unknown')
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _substance,
                          style: NarcSealTypography.sectionTitle.copyWith(
                            color: themeColor,
                            fontSize: 18,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── Confidence Score ───
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: NarcSealColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NarcSealColors.lightBeige),
                ),
                child: Column(
                  children: [
                    Text(
                      '${_confidence.toStringAsFixed(1)}%',
                      style: NarcSealTypography.importantNumbers.copyWith(fontSize: 42),
                    ),
                    const SizedBox(height: 4),
                    Text('AI Confidence Score', style: NarcSealTypography.body),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _confidence / 100.0,
                        backgroundColor: NarcSealColors.lightBeige,
                        valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Delta-E: ${_deltaE.toStringAsFixed(2)}',
                      style: NarcSealTypography.metadata,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── Detected Reaction Color ───
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: NarcSealColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NarcSealColors.lightBeige),
                ),
                child: Column(
                  children: [
                    Text('DETECTED REACTION COLOR', style: NarcSealTypography.sectionTitle),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Color swatch
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: _parseHexColor(_hexCode),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: NarcSealColors.lightBeige, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: _parseHexColor(_hexCode).withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _colorName,
                                style: NarcSealTypography.sectionTitle.copyWith(fontSize: 18),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _hexCode,
                                style: NarcSealTypography.metadata.copyWith(
                                  fontFamily: 'monospace',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: NarcSealColors.graphite,
                                ),
                              ),
                              if (_correctedRgb != null && _correctedRgb!.length == 3)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    'RGB(${_correctedRgb![0]}, ${_correctedRgb![1]}, ${_correctedRgb![2]})',
                                    style: NarcSealTypography.metadata.copyWith(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                      color: NarcSealColors.titaniumGray,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_substance != 'None' && _substance != 'Unknown') ...[
                      const SizedBox(height: 16),
                      const Divider(color: NarcSealColors.lightBeige),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: themeColor.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Substance likely to be:',
                              style: NarcSealTypography.metadata.copyWith(color: NarcSealColors.titaniumGray),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _substance,
                              style: NarcSealTypography.sectionTitle.copyWith(
                                color: themeColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_confidence.toStringAsFixed(1)}% confidence',
                              style: NarcSealTypography.body.copyWith(
                                color: themeColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── Evidence Document Details ───
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: NarcSealColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NarcSealColors.lightBeige),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('EVIDENCE DOCUMENT', style: NarcSealTypography.sectionTitle),
                    const SizedBox(height: 16),
                    const Divider(color: NarcSealColors.lightBeige),
                    const SizedBox(height: 12),

                    // ── Officer Info ──
                    _infoRow('Officer', _getOfficerName()),
                    _infoRow('Badge ID', _getOfficerBadge()),

                    const Divider(color: NarcSealColors.lightBeige, height: 20),

                    // ── Test Info ──
                    _infoRow('Record ID', _recordId.substring(0, 8).toUpperCase()),
                    _infoRow('Sample ID', _sampleId ?? 'Auto-generated'),
                    _infoRow('Test Kit', _testKit ?? 'Not specified'),
                    if (_testKitId != null)
                      _infoRow('Kit Type', _testKitId!.toUpperCase()),
                    _infoRow('Result', _resultType),
                    _infoRow('Substance', _substance),
                    _infoRow('Confidence', '${_confidence.toStringAsFixed(1)}%'),
                    _infoRow('Delta-E', '${_deltaE.toStringAsFixed(2)} (${_deltaEInterpretation()})'),
                    _infoRow('Hex Code', _hexCode),
                    _infoRow('Color', _colorName),

                    const Divider(color: NarcSealColors.lightBeige, height: 20),

                    // ── Time & Location ──
                    _infoRow('Date', DateFormat('dd MMM yyyy').format(_captureTime)),
                    _infoRow('Time', DateFormat('HH:mm:ss').format(_captureTime)),
                    _infoRow('Location', _address),

                    if (_imageHash.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Image SHA-256:', style: NarcSealTypography.metadata),
                      const SizedBox(height: 4),
                      Text(
                        _imageHash.length > 32 ? '${_imageHash.substring(0, 32)}...' : _imageHash,
                        style: NarcSealTypography.metadata.copyWith(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: NarcSealColors.graphite,
                        ),
                      ),
                    ],

                    if (_notes != null && _notes!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text('Notes:', style: NarcSealTypography.metadata),
                      Text(_notes!, style: NarcSealTypography.body),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── Seal Status ───
              if (_isSealed)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: NarcSealColors.negative.withValues(alpha: 0.08),
                    border: Border.all(color: NarcSealColors.negative),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_outlined, color: NarcSealColors.negative, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Evidence Sealed ✓',
                              style: NarcSealTypography.body.copyWith(
                                color: NarcSealColors.negative,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _isSynced ? 'Synced to database' : 'Stored locally (pending sync)',
                              style: NarcSealTypography.metadata.copyWith(color: NarcSealColors.negative),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _isSynced ? Icons.cloud_done : Icons.cloud_off,
                        color: NarcSealColors.negative,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // ─── Actions ───
              if (!_isSealed)
                ElevatedButton(
                  onPressed: _isSealing ? null : _sealAndSync,
                  child: _isSealing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: NarcSealColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.verified_outlined, size: 20),
                            const SizedBox(width: 8),
                            Text('SEAL EVIDENCE', style: NarcSealTypography.buttonText),
                          ],
                        ),
                ),

              if (_isSealed) ...[
                ElevatedButton(
                  onPressed: _goHome,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('RETURN TO DASHBOARD', style: NarcSealTypography.buttonText),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              if (!_isSealed)
                OutlinedButton(
                  onPressed: _retake,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.refresh, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'RE-TEST',
                        style: NarcSealTypography.buttonText.copyWith(color: NarcSealColors.titaniumGray),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: NarcSealTypography.metadata.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value, style: NarcSealTypography.body.copyWith(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  String _getOfficerName() {
    try {
      return ApiService.currentOfficer.fullName;
    } catch (_) {
      return 'Unknown';
    }
  }

  String _getOfficerBadge() {
    try {
      return ApiService.currentOfficer.badgeId;
    } catch (_) {
      return 'Unknown';
    }
  }

  String _deltaEInterpretation() {
    if (_deltaE < 5.0) return 'Excellent match';
    if (_deltaE < 15.0) return 'Strong match';
    if (_deltaE < 25.0) return 'Weak match';
    return 'No match';
  }

  Color _parseHexColor(String hex) {
    try {
      hex = hex.replaceFirst('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
      return Colors.grey;
    } catch (_) {
      return Colors.grey;
    }
  }
}

/// SharedPreferencesAsync wrapper (uses shared_preferences internally)
class SharedPreferencesAsync {
  Future<String?> getString(String key) async {
    final prefs = await _getPrefs();
    return prefs.getString(key);
  }

  Future<void> setString(String key, String value) async {
    final prefs = await _getPrefs();
    await prefs.setString(key, value);
  }

  Future<dynamic> _getPrefs() async {
    // Use shared_preferences package
    return await SharedPreferencesHelper.getInstance();
  }
}

/// Simple helper to access SharedPreferences
class SharedPreferencesHelper {
  static dynamic _instance;

  static Future<dynamic> getInstance() async {
    if (_instance == null) {
      // Import shared_preferences at runtime
      final module = await Future.value(null); // Placeholder
    }
    return _instance;
  }
}
