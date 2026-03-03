import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/cycle_log.dart';
import '../models/behavioral_data.dart';
import '../models/travel_data.dart';
import '../models/inference_response.dart';

/// API Service for communicating with HerLuna backend.
/// Handles both cloud and local mode request formatting.
class ApiService {
  // Change this to your backend URL (ngrok, local, or production)
  static const String baseUrl = 'http://10.0.2.2:8000';
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ── Auth ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String storageMode = 'cloud',
    bool isYoungGirlMode = false,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
        'storage_mode': storageMode,
        'is_young_girl_mode': isYoungGirlMode,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['access_token'];
      return data;
    }
    throw Exception('Registration failed: ${response.body}');
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['access_token'];
      return data;
    }
    throw Exception('Login failed: ${response.body}');
  }

  // ── Cycle Logs ──────────────────────────────────────────────────────

  Future<void> addCycleLog(CycleLog log) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cycle/log'),
      headers: _headers,
      body: jsonEncode(log.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add cycle log: ${response.body}');
    }
  }

  Future<List<CycleLog>> getCycleLogs(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/cycle/logs/$userId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list.map((j) => CycleLog.fromJson(j)).toList();
    }
    throw Exception('Failed to fetch cycle logs');
  }

  // ── Behavioral Data ──────────────────────────────────────────────────

  Future<void> addBehavioralData(BehavioralData data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/behavioral/log'),
      headers: _headers,
      body: jsonEncode(data.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add behavioral data: ${response.body}');
    }
  }

  Future<List<BehavioralData>> getBehavioralData(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/behavioral/logs/$userId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list.map((j) => BehavioralData.fromJson(j)).toList();
    }
    throw Exception('Failed to fetch behavioral data');
  }

  // ── Travel Data ──────────────────────────────────────────────────────

  Future<void> addTravelData(TravelData data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/travel/log'),
      headers: _headers,
      body: jsonEncode(data.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add travel data: ${response.body}');
    }
  }

  Future<List<TravelData>> getTravelData(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/travel/logs/$userId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list.map((j) => TravelData.fromJson(j)).toList();
    }
    throw Exception('Failed to fetch travel data');
  }

  // ── Prediction / Inference ────────────────────────────────────────────

  /// Cloud mode: predict using user_id (data fetched from DB).
  Future<InferenceResponse> predictCloud({
    required int userId,
    bool isYoungGirlMode = false,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/predict'),
      headers: _headers,
      body: jsonEncode({
        'user_id': userId,
        'storage_mode': 'cloud',
        'is_young_girl_mode': isYoungGirlMode,
      }),
    );
    if (response.statusCode == 200) {
      return InferenceResponse.fromJson(jsonDecode(response.body));
    }
    throw Exception('Prediction failed: ${response.body}');
  }

  /// Local mode: send data snapshot, backend does NOT store.
  Future<InferenceResponse> predictLocal({
    required List<CycleLog> cycleLogs,
    required List<BehavioralData> behavioralData,
    required List<TravelData> travelData,
    bool isYoungGirlMode = false,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/predict'),
      headers: _headers,
      body: jsonEncode({
        'storage_mode': 'local',
        'is_young_girl_mode': isYoungGirlMode,
        'cycle_logs': cycleLogs.map((c) => c.toJson()).toList(),
        'behavioral_data': behavioralData.map((b) => b.toJson()).toList(),
        'travel_data': travelData.map((t) => t.toJson()).toList(),
      }),
    );
    if (response.statusCode == 200) {
      return InferenceResponse.fromJson(jsonDecode(response.body));
    }
    throw Exception('Prediction failed: ${response.body}');
  }

  // ── Healthcare Locator ────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> findNearbyHealthcare({
    required double latitude,
    required double longitude,
    int radius = 5000,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/healthcare/nearby'),
      headers: _headers,
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['locations'] ?? []);
    }
    throw Exception('Healthcare search failed: ${response.body}');
  }
}
