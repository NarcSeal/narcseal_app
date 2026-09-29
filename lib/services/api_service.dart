import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/officer.dart';
import '../models/evidence_record.dart';
import '../models/test_kit.dart';

class ApiService {
  // Use localhost for Web, 192.168.1.6 for mobile via local Wi-Fi
  static const String baseUrl = kIsWeb ? 'http://localhost:8080/api/v1' : 'http://192.168.1.6:8080/api/v1';
  static const _storage = FlutterSecureStorage();

  // Current logged in officer cache
  static Officer? _currentOfficer;
  
  static Officer get currentOfficer {
    if (_currentOfficer == null) {
      throw Exception("User is not logged in");
    }
    return _currentOfficer!;
  }

  /// Authenticate with the backend
  static Future<bool> login(String username, String password) async {
    try {
      final url = Uri.parse('$baseUrl/auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        
        await _storage.write(key: 'jwt_token', value: token);
        
        _currentOfficer = Officer(
          badgeId: data['badge_id'] ?? '',
          fullName: data['officer_name'] ?? '',
          username: username,
          rank: '',
          role: data['role'] ?? 'field_officer',
          stationCode: '',
          district: '',
          state: '',
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  /// Get the JWT Token
  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  /// Fetch recent records for the dashboard
  static Future<List<EvidenceRecord>> getRecentRecords() async {
    try {
      final token = await getToken();
      if (token == null) return [];

      final url = Uri.parse('$baseUrl/records/');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => EvidenceRecord.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching records: $e');
      return [];
    }
  }

  /// Fetch test kits and wait times from the backend
  static Future<List<TestKit>> getTestKits() async {
    try {
      final token = await getToken();
      if (token == null) return [];

      final url = Uri.parse('$baseUrl/kits/');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TestKit.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching kits: $e');
      return [];
    }
  }

  /// Upload a sealed evidence record (Sync)
  static Future<bool> uploadTestRecord(EvidenceRecord record) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final url = Uri.parse('$baseUrl/sync/upload');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(record.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      print('Upload failed: ${response.body}');
      return false;
    } catch (e) {
      print('Error uploading record: $e');
      return false;
    }
  }

  /// Fetch dashboard top-level stats
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final token = await getToken();
      if (token == null) return {};

      final url = Uri.parse('$baseUrl/analytics/stats');
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching stats: $e');
    }
    return {};
  }

  /// Fetch substance breakdown
  static Future<List<Map<String, dynamic>>> getSubstanceBreakdown() async {
    try {
      final token = await getToken();
      if (token == null) return [];

      final url = Uri.parse('$baseUrl/analytics/substance-breakdown');
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      print('Error fetching substance breakdown: $e');
    }
    return [];
  }

  /// Fetch officer specific stats
  static Future<Map<String, dynamic>> getOfficerStats(String badgeId) async {
    try {
      final token = await getToken();
      if (token == null) return {};

      final url = Uri.parse('$baseUrl/officers/$badgeId');
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching officer stats: $e');
    }
    return {};
  }

  /// Send a camera frame to the AI backend for analysis
  /// Accepts raw image bytes (works on web + mobile)
  static Future<Map<String, dynamic>> analyzeFrame(List<int> imageBytes, String kitType, {String filename = 'frame.jpg'}) async {
    try {
      final token = await getToken();
      if (token == null) return {'status': 'error', 'message': 'Not authenticated'};

      final url = Uri.parse('$baseUrl/ai/analyze-frame');
      print('[ApiService] POST $url (${imageBytes.length} bytes, kitType=$kitType)');
      final request = http.MultipartRequest('POST', url);
      if (token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.fields['kit_type'] = kitType;
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: filename,
      ));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final responseBody = await streamedResponse.stream.bytesToString();

      print('[ApiService] Response ${streamedResponse.statusCode}: $responseBody');

      if (streamedResponse.statusCode == 200) {
        return jsonDecode(responseBody) as Map<String, dynamic>;
      } else {
        return {'status': 'error', 'message': 'Server error: ${streamedResponse.statusCode} - $responseBody'};
      }
    } catch (e) {
      print('[ApiService] Error analyzing frame: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Upload a sealed evidence record with the captured image
  static Future<bool> uploadRecordWithImage(EvidenceRecord record, String? imagePath) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      // First upload the record JSON
      final url = Uri.parse('$baseUrl/sync/upload');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(record.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      print('Upload failed: ${response.body}');
      return false;
    } catch (e) {
      print('Error uploading record: $e');
      return false;
    }
  }

  /// Logout
  static Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    _currentOfficer = null;
  }
}
