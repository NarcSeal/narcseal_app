import 'test_result.dart';

/// Data model representing a sealed drug test evidence record.
class EvidenceRecord {
  final String recordId;
  final String officerBadgeId;
  final String officerName;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String? address;
  final TestResult testResult;
  final String? substance;
  final String? testKitType;
  final String? sampleId;
  final String? notes;
  final double confidence;
  final String? imageBase64;
  final String imageHash;
  final String previousHash;
  final String recordHash;
  final String deviceId;
  final bool isSynced;
  final bool isSealed;
  final DateTime createdAt;
  final int? chainPosition;

  const EvidenceRecord({
    required this.recordId,
    required this.officerBadgeId,
    required this.officerName,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.testResult,
    this.substance,
    this.testKitType,
    this.sampleId,
    this.notes,
    required this.confidence,
    this.imageBase64,
    required this.imageHash,
    required this.previousHash,
    required this.recordHash,
    required this.deviceId,
    this.isSynced = false,
    this.isSealed = true,
    required this.createdAt,
    this.chainPosition,
  });

  /// Formatted timestamp in 24h format (e.g., "14:32:07")
  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
  }

  /// Formatted date (e.g., "18 Sep 2026")
  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${timestamp.day} ${months[timestamp.month - 1]} ${timestamp.year}';
  }

  /// GPS coordinates with 6 decimal places
  String get gpsString {
    final latDir = latitude >= 0 ? 'N' : 'S';
    final lonDir = longitude >= 0 ? 'E' : 'W';
    return '${latitude.abs().toStringAsFixed(6)}°$latDir, '
        '${longitude.abs().toStringAsFixed(6)}°$lonDir';
  }

  /// Truncated hash for display (first 12 chars + ...)
  String get shortHash => recordHash.length > 12
      ? '${recordHash.substring(0, 12)}...'
      : recordHash;

  /// Truncated image hash for display
  String get shortImageHash => imageHash.length > 12
      ? '${imageHash.substring(0, 12)}...'
      : imageHash;

  factory EvidenceRecord.fromJson(Map<String, dynamic> json) {
    return EvidenceRecord(
      recordId: json['id'] as String? ?? json['record_id'] as String? ?? '',
      officerBadgeId: json['officer_badge'] as String? ?? json['officer_badge_id'] as String? ?? '',
      officerName: json['officer_name'] as String? ?? '',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
      latitude: (json['gps_lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['gps_lng'] as num?)?.toDouble() ?? 0.0,
      address: json['location_name'] as String?,
      testResult: _parseTestResult(json['result'] as String? ?? json['test_result'] as String? ?? 'NEGATIVE'),
      substance: json['substance'] as String?,
      testKitType: json['test_kit_type'] as String?,
      sampleId: json['sample_id'] as String?,
      notes: json['notes'] as String?,
      confidence: (json['confidence_score'] as num?)?.toDouble() ?? (json['confidence'] as num?)?.toDouble() ?? 0.0,
      imageHash: json['sha256_hash'] as String? ?? json['image_hash'] as String? ?? '',
      previousHash: json['prev_block_hash'] as String? ?? json['previous_hash'] as String? ?? '',
      recordHash: json['merkle_root'] as String? ?? json['record_hash'] as String? ?? '',
      deviceId: json['device_id'] as String? ?? '',
      isSynced: true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  static TestResult _parseTestResult(String resultStr) {
    switch (resultStr.toUpperCase()) {
      case 'POSITIVE': return TestResult.positive;
      case 'INCONCLUSIVE': return TestResult.inconclusive;
      default: return TestResult.negative;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'record_id': recordId,
      'officer_badge_id': officerBadgeId,
      'officer_name': officerName,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'address': address ?? '',
      'test_result': testResult.name.toUpperCase(),
      'substance': substance ?? '',
      'test_kit_type': testKitType,
      'sample_id': sampleId,
      'sample_type': 'Unknown', // Need to add field later if required
      'is_sealed': isSealed,
      'notes': notes,
      'confidence': confidence,
      'image_hash': imageHash,
      'previous_hash': previousHash,
      'record_hash': recordHash,
      'device_id': deviceId,
    };
  }
}
