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
}
