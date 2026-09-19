import '../models/officer.dart';
import '../models/evidence_record.dart';
import '../models/test_result.dart';

/// Provides hardcoded demo data for all screens during UI development.
///
/// This will be replaced by real API calls and local database queries
/// once backend integration is complete.
class MockDataService {
  MockDataService._();

  /// The currently logged-in officer (mock).
  static const Officer currentOfficer = Officer(
    badgeId: 'NCB-4421',
    fullName: 'Rajesh Sharma',
    username: 'r.sharma',
    rank: 'inspector',
    role: 'field_officer',
    stationCode: 'MUM-NCB-01',
    district: 'Mumbai',
    state: 'Maharashtra',
    phoneNumber: '+91 98765 43210',
    isActive: true,
  );

  /// Time-based greeting for the home screen.
  static String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  /// Today's test count for the stat card.
  static const int todayTestCount = 12;

  /// Pending sync count for the stat card.
  static const int pendingSyncCount = 3;

  /// Lifetime stats for the profile screen.
  static const int totalTests = 247;
  static const double accuracyRate = 94.6;
  static const int positiveFound = 186;
  static const int daysActive = 47;

  /// Mock evidence records for the field log and home screen.
  static final List<EvidenceRecord> recentRecords = [
    EvidenceRecord(
      recordId: 'a7f3-c8d2-e1b4',
      officerBadgeId: 'NCB-4421',
      officerName: 'Insp. Sharma',
      timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 13)),
      latitude: 19.076090,
      longitude: 72.877426,
      address: 'Andheri West, Mumbai',
      testResult: TestResult.positive,
      substance: 'Cannabis',
      confidence: 94.2,
      imageHash: 'a7f3c8d2e1b4f9a2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8',
      previousHash: '8e2f7a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d',
      recordHash: '9b1e42f7a8c3d2e5f6b7a9c0d1e2f3a4b5c6d7e8f9a0b1c2',
      deviceId: 'PIXEL-7A-001',
      isSynced: true,
      isSealed: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 13)),
      chainPosition: 47,
    ),
    EvidenceRecord(
      recordId: 'b8e4-d9f3-a2c5',
      officerBadgeId: 'NCB-4421',
      officerName: 'Insp. Sharma',
      timestamp: DateTime.now().subtract(const Duration(hours: 5, minutes: 38)),
      latitude: 19.054230,
      longitude: 72.840590,
      address: 'Bandra East, Mumbai',
      testResult: TestResult.negative,
      substance: null,
      confidence: 97.8,
      imageHash: 'b8e4d9f3a2c5b6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3',
      previousHash: '9b1e42f7a8c3d2e5f6b7a9c0d1e2f3a4b5c6d7e8f9a0b1c2',
      recordHash: 'c5f2a3b4d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5',
      deviceId: 'PIXEL-7A-001',
      isSynced: false,
      isSealed: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 5, minutes: 38)),
      chainPosition: 46,
    ),
    EvidenceRecord(
      recordId: 'c9d5-e0a4-b3f6',
      officerBadgeId: 'NCB-4421',
      officerName: 'Insp. Sharma',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      latitude: 19.017560,
      longitude: 72.856290,
      address: 'Dadar, Mumbai',
      testResult: TestResult.inconclusive,
      substance: 'Cocaine',
      confidence: 62.1,
      imageHash: 'c9d5e0a4b3f6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4',
      previousHash: 'c5f2a3b4d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5',
      recordHash: 'd6e3b4c5f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6',
      deviceId: 'PIXEL-7A-001',
      isSynced: true,
      isSealed: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      chainPosition: 45,
    ),
    EvidenceRecord(
      recordId: 'd0e6-f1b5-c4a7',
      officerBadgeId: 'NCB-4421',
      officerName: 'Insp. Sharma',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 7)),
      latitude: 19.113920,
      longitude: 72.870840,
      address: 'Goregaon, Mumbai',
      testResult: TestResult.positive,
      substance: 'Heroin',
      confidence: 89.7,
      imageHash: 'd0e6f1b5c4a7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5',
      previousHash: 'd6e3b4c5f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6',
      recordHash: 'e7f4c5d6a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7',
      deviceId: 'PIXEL-7A-001',
      isSynced: true,
      isSealed: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 7)),
      chainPosition: 44,
    ),
    EvidenceRecord(
      recordId: 'e1f7-a2c6-d5b8',
      officerBadgeId: 'NCB-4421',
      officerName: 'Insp. Sharma',
      timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
      latitude: 18.938470,
      longitude: 72.835620,
      address: 'Colaba, Mumbai',
      testResult: TestResult.negative,
      substance: null,
      confidence: 99.1,
      imageHash: 'e1f7a2c6d5b8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6',
      previousHash: 'e7f4c5d6a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7',
      recordHash: 'f8a5d6e7b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8',
      deviceId: 'PIXEL-7A-001',
      isSynced: true,
      isSealed: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
      chainPosition: 43,
    ),
  ];

  /// Processing steps for the processing screen animation.
  static const List<String> processingSteps = [
    'Reference Card Detected',
    '6/6 Color Patches Found',
    'ChromaLock Calibrating...',
    'Running AI Analysis...',
    'Generating Evidence Seal',
  ];

  /// Rotating technical facts for processing screen.
  static const List<String> technicalFacts = [
    'Applying 3×3 Color Correction Matrix...',
    'Computing Delta-E 2000 distances...',
    'Running MobileNetV3 inference...',
    'Analyzing under CIE LAB color space...',
    'Validating Merkle Hash Chain integrity...',
    'Generating SHA-256 evidence hash...',
  ];
}
