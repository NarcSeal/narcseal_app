import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/officer.dart';
import '../models/evidence_record.dart';
import '../models/test_kit.dart';

class ApiService {
  // Use localhost for Web, 10.0.2.2 for Android Emulator connecting to localhost
  static const String baseUrl = kIsWeb ? 'http://localhost:8000/api/v1' : 'http://10.0.2.2:8000/api/v1';
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

  /// Logout
  static Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    _currentOfficer = null;
  }
}
