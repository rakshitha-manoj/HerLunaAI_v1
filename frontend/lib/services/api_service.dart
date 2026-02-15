import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/daily_log.dart';

class ApiService {
  static const String baseUrl = "http://10.4.210.210:8000";

  static Future<Map<String, dynamic>?> analyzeUser(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/analyze"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("API Connection Error: $e");
      return null;
    }
  }

  // Logic to transform Map<DateTime, DailyLog> into backend-ready format
  static Map<String, dynamic> formatLogsForBackend(
    Map<DateTime, DailyLog> logs,
  ) {
    List<DateTime> sortedDates = logs.keys.toList()..sort();

    List<int> cycleLengths = [];
    List<int> periodDurations = [];
    List<List<String>> flowLogs = [];

    List<String> currentFlows = [];
    DateTime? periodStart;
    DateTime? lastPeriodStart;

    for (var date in sortedDates) {
      final log = logs[date]!;
      if (log.isPeriodActive) {
        if (periodStart == null) periodStart = date;
        currentFlows.add(log.encodedFlow!);
      } else if (periodStart != null) {
        // Period concluded
        periodDurations.add(date.difference(periodStart).inDays);
        flowLogs.add(List.from(currentFlows));

        if (lastPeriodStart != null) {
          cycleLengths.add(periodStart.difference(lastPeriodStart).inDays);
        }

        lastPeriodStart = periodStart;
        periodStart = null;
        currentFlows = [];
      }
    }

    return {
      "cycle_lengths": cycleLengths,
      "period_durations": periodDurations,
      "flow_logs": flowLogs,
    };
  }
}
