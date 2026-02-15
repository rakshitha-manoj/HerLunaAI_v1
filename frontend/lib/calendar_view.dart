import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:table_calendar/table_calendar.dart';
import 'theme.dart';
import 'models/daily_log.dart';
import 'widgets/log_entry_modal.dart';
import 'services/api_service.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Local storage for user logs (Source of Truth for the UI)
  final Map<DateTime, DailyLog> _userLogs = {};

  // Analytics data returned from the FastAPI backend
  Map<String, dynamic>? _predictionData;

  // 1. VALIDATION: Check if a day is in the future
  bool _isFuture(DateTime day) {
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return normalizedDay.isAfter(today);
  }

  // 2. PREDICTION LOGIC: Highlight the window returned by the backend
  bool _isWithinPredictedWindow(DateTime day) {
    if (_predictionData == null || _predictionData!['cycle_window'] == null) {
      // Default placeholder highlight for demo purposes
      return day.month == 2 && day.day >= 14 && day.day <= 18;
    }

    final window = _predictionData!['cycle_window'];
    // Logic matches the backend schema: cycle_window: {earliest: int, latest: int}
    return day.day >= window['earliest'] && day.day <= window['latest'];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    // BLOCKING VALIDATION: Prevent selection or logging for future dates
    if (_isFuture(selectedDay)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Future dates are for predictions only."),
          backgroundColor: HerLunaTheme.accentPlum,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    _showLogSheet(selectedDay);
  }

  void _showLogSheet(DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LogEntryModal(
        date: date,
        existingLog: _userLogs[DateTime(date.year, date.month, date.day)],
        onUpdate: (newLog) {
          _updateLogsAndAnalyze(date, newLog);
        },
      ),
    );
  }

  void _updateLogsAndAnalyze(DateTime date, DailyLog log) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    setState(() {
      _userLogs[normalizedDate] = log;
    });

    // Translate UI logs into the payload expected by your FastAPI module1 logic
    final payload = ApiService.formatLogsForBackend(_userLogs);

    // Asynchronous call to your backend (uvicorn app:app --host 0.0.0.0)
    final result = await ApiService.analyzeUser(payload);

    if (result != null) {
      setState(() {
        _predictionData = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HerLunaTheme.backgroundBeige,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildCalendarCard(),
                  const SizedBox(height: 16),
                  _buildPredictionCard(),
                  const SizedBox(height: 16),
                  _buildSummaryCard(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Cycle Journal",
          style: GoogleFonts.quicksand(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: HerLunaTheme.primaryPlum,
          ),
        ),
        Text(
          "Log past symptoms for AI analysis",
          style: GoogleFonts.quicksand(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020),
        lastDay: DateTime.utc(2030),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: _onDaySelected,

        // VISUAL VALIDATION: Disable interaction for future days
        enabledDayPredicate: (day) => !_isFuture(day),

        calendarBuilders: CalendarBuilders(
          // Marker Logic: Show plum dots on days where user has logged data
          markerBuilder: (context, date, events) {
            final normalizedDate = DateTime(date.year, date.month, date.day);
            if (_userLogs.containsKey(normalizedDate)) {
              return Positioned(
                bottom: 4,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: HerLunaTheme.primaryPlum,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }
            return null;
          },

          // Prediction Overlay: Highlight future dates based on Backend logic
          defaultBuilder: (context, day, focusedDay) {
            if (_isWithinPredictedWindow(day)) {
              return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: HerLunaTheme.primaryPlum.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: _isFuture(day) ? HerLunaTheme.primaryPlum : null,
                      fontWeight: _isFuture(day) ? FontWeight.bold : null,
                    ),
                  ),
                ),
              );
            }
            return null;
          },
        ),

        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleTextStyle: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: HerLunaTheme.primaryPlum,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          disabledTextStyle: const TextStyle(
            color: Colors.black12,
          ), // Gray out future days
          selectedDecoration: const BoxDecoration(
            color: HerLunaTheme.primaryPlum,
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(
            color: HerLunaTheme.primaryPlum,
            fontWeight: FontWeight.bold,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: HerLunaTheme.primaryPlum, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionCard() {
    final windowStr = _predictionData != null
        ? "Predicted: ${_predictionData!['cycle_window']['earliest']} — ${_predictionData!['cycle_window']['latest']}"
        : "Feb 14 — 18";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: HerLunaTheme.primaryPlum.withOpacity(0.08),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: HerLunaTheme.primaryPlum.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.sparkles,
                size: 18,
                color: HerLunaTheme.primaryPlum,
              ),
              const SizedBox(width: 8),
              Text(
                "Cycle Intelligence",
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  color: HerLunaTheme.primaryPlum,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            windowStr,
            style: GoogleFonts.quicksand(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: HerLunaTheme.primaryPlum,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Insight: ${_predictionData?['deviation_type'] ?? 'No deviations detected yet.'}",
            style: const TextStyle(fontSize: 12, color: Colors.black45),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Cycle History",
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: HerLunaTheme.primaryPlum,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Confidence Level: ${_predictionData?['confidence'] ?? 'Early Stage'}. "
            "Continue logging to refine cycle predictions.",
            style: const TextStyle(color: Colors.black54, height: 1.4),
          ),
        ],
      ),
    );
  }
}
