import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cycle_log_model.dart';
import '../models/prediction_model.dart';

/// Singleton API Service for communicating with HerLuna backend.
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Update this to your backend URL (ngrok / local / production)
  static const String baseUrl = 'http://localhost:8000';
  String? _token;

  void setToken(String token) => _token = token;
  void clearToken() => _token = null;
  bool get isAuthenticated => _token != null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ── Auth ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? fullName,
    String storageMode = 'cloud',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
        'full_name': fullName ?? 'User',
        'storage_mode': storageMode,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
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

  // ── Cycle Logs ────────────────────────────────────────────────────────

  Future<void> addCycleLog(CycleLogModel log) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cycle/log'),
      headers: _headers,
      body: jsonEncode(log.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add cycle log: ${response.body}');
    }
  }

  Future<List<CycleLogModel>> getCycleLogs() async {
    final response = await http.get(
      Uri.parse('$baseUrl/cycle/logs'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list.map((j) => CycleLogModel.fromJson(j)).toList();
    }
    throw Exception('Failed to fetch cycle logs');
  }

  // ── Prediction / Inference ────────────────────────────────────────────

  Future<PredictionModel> predict() async {
    final response = await http.post(
      Uri.parse('$baseUrl/predict/cloud'),
      headers: _headers,
      body: jsonEncode({'is_young_girl_mode': false}),
    );
    if (response.statusCode == 200) {
      return PredictionModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Prediction failed: ${response.body}');
  }

  // ── Feedback ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> submitFeedback({
    required double predictedFatigue,
    required double actualFatigue,
    required double predictedStress,
    required double actualStress,
    bool guidanceHelpful = true,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/feedback'),
      headers: _headers,
      body: jsonEncode({
        'predicted_fatigue': predictedFatigue,
        'actual_fatigue': actualFatigue,
        'predicted_stress': predictedStress,
        'actual_stress': actualStress,
        'guidance_helpful': guidanceHelpful,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Feedback failed: ${response.body}');
  }

  // ── Analytics ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getAnalytics() async {
    final response = await http.get(
      Uri.parse('$baseUrl/analytics/performance'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Analytics fetch failed: ${response.body}');
  }
}
