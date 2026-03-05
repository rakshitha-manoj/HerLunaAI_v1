import 'dart:convert';
import 'package:http/http.dart' as http;

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

  // ── Auth ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    String ageRange = '19-25',
    String activityLevel = 'moderate',
    String storageMode = 'cloud',
    bool isYoungGirlMode = false,
    int? averageCycleLength,
    bool cycleVariabilityKnown = false,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
        'full_name': fullName,
        'age_range': ageRange,
        'activity_level': activityLevel,
        'storage_mode': storageMode,
        'is_young_girl_mode': isYoungGirlMode,
        if (averageCycleLength != null)
          'average_cycle_length': averageCycleLength,
        'cycle_variability_known': cycleVariabilityKnown,
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

  // ── Cycle Logs ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> addCycleLog({
    required String periodStart,
    int? bleedingDays,
    String? flowIntensity,
    List<String>? symptoms,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cycle/log'),
      headers: _headers,
      body: jsonEncode({
        'period_start': periodStart,
        if (bleedingDays != null) 'bleeding_days': bleedingDays,
        if (flowIntensity != null) 'flow_intensity': flowIntensity,
        if (symptoms != null) 'symptoms': symptoms,
        if (notes != null) 'notes': notes,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to add cycle log: ${response.body}');
  }

  Future<List<Map<String, dynamic>>> getCycleLogs() async {
    final response = await http.get(
      Uri.parse('$baseUrl/cycle/logs'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to fetch cycle logs');
  }

  // ── Daily Logs (energy, stress, period, notes) ──────────────────────

  Future<Map<String, dynamic>> submitDailyLog({
    required String date,
    required bool onPeriod,
    String flowLevel = 'MEDIUM',
    required String energyLevel,
    required String stressLevel,
    String notes = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/daily/log'),
      headers: _headers,
      body: jsonEncode({
        'date': date,
        'on_period': onPeriod,
        'flow_level': flowLevel,
        'energy_level': energyLevel,
        'stress_level': stressLevel,
        'notes': notes,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to submit daily log: ${response.body}');
  }

  Future<List<Map<String, dynamic>>> getDailyLogs() async {
    final response = await http.get(
      Uri.parse('$baseUrl/daily/logs'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to fetch daily logs');
  }

  // ── Prediction / Inference ──────────────────────────────────────────

  Future<Map<String, dynamic>> predict({bool isYoungGirlMode = false}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/predict/cloud'),
      headers: _headers,
      body: jsonEncode({'is_young_girl_mode': isYoungGirlMode}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Prediction failed: ${response.body}');
  }

  // ── Feedback ────────────────────────────────────────────────────────

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

  // ── Analytics ───────────────────────────────────────────────────────

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
