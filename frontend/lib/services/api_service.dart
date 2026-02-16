import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.1.6:8000";

  static Future<Map<String, dynamic>> createProfile({
    required String email,
    required String name,
    required String ageRange,
    required String condition,
    required List<String> goals,
    double? height,
    double? weight,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/profile/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "name": name,
        "age_range": ageRange,
        "condition": condition,
        "goals": goals, // ✅ FIXED
        "height": height, // ✅ FIXED
        "weight": weight, // ✅ FIXED
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create profile: ${response.body}");
    }
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>?> getProfile(String userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/profile/$userId"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  static Future<Map<String, dynamic>> loginWithEmail(String email) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/email"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Login failed");
    }
  }

  static Map<String, dynamic> formatLogsForBackend(dynamic logs) {
    return {};
  }

  static Future<Map<String, dynamic>> analyzeUser(
    Map<String, dynamic> payload,
  ) async {
    return {
      "deviation_type": "none",
      "confidence": "generic",
      "insights": ["Module B not implemented yet"],
    };
  }

  static Future<List<dynamic>> getLogs(String userId) async {
    final response = await http.get(Uri.parse("$baseUrl/logs/$userId"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch logs");
    }
  }

  static Future<void> createLog({
    required String userId,
    required DateTime logDate,
    required bool isPeriodActive,
    String? flowEncoded,
    required List<String> selectedSymptoms,
    required String extraSymptoms,
    required String note,
  }) async {
    final url = Uri.parse("$baseUrl/logs/");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "log_date": logDate.toIso8601String().split("T")[0],
        "is_period_active": isPeriodActive,
        "flow_encoded": flowEncoded,
        "selected_symptoms": selectedSymptoms,
        "extra_symptoms": extraSymptoms,
        "note": note,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to create log: ${response.body}");
    }
  }
}
