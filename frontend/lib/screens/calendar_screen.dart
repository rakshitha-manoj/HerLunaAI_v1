import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

// Import your respective screen files here for the BottomNav
import 'home_screen.dart';
import 'insights_screen.dart';
import 'planner_screen.dart';
import 'settings_screen.dart';

// --- THEME CONSTANTS FOR EXACT VISUAL MATCH ---
const Color _bgWhite = Color(0xFFF7F6F2);
const Color _primaryDark = Color(0xFF45384D);
const Color _primaryMuted = Color(0xFF6E5C77);
const Color _textGray = Color(0xFF8A8290);
const Color _lightGray = Color(0xFFE4DFE5);
const Color _cardBg = Color(0xFFFFFFFF);

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Navigation Index
  final int _currentIndex = 1;

  // Calendar State
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  // Mock Database for Logs: Maps a Date (ignoring time) to a Log Map
  final Map<DateTime, Map<String, dynamic>> _dailyLogs = {};

  // Helper to normalize dates for map keys
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void _openLogModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DailyLogModal(
        date: _selectedDay,
        existingLog: _dailyLogs[_normalizeDate(_selectedDay)],
        onSave: (logData) {
          setState(() {
            _dailyLogs[_normalizeDate(_selectedDay)] = logData;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;
  bool _showLogSheet = false;

  // Mock logging state
  bool _isPeriod = false;
  double _flowLevel = 1;
  double _energyLevel = 3;
  double _stressLevel = 2;

  @override
  Widget build(BuildContext context) {
    final normalizedSelected = _normalizeDate(_selectedDay);
    final hasLog = _dailyLogs.containsKey(normalizedSelected);
    final logData = _dailyLogs[normalizedSelected];

    return Scaffold(
      backgroundColor: _bgWhite,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildCalendarHeader(),
                  const SizedBox(height: 16),
                  _buildCalendar(),
                  const SizedBox(height: 24),
                  _buildCycleIntelligenceCard(),
                  const SizedBox(height: 32),

                  // Dynamic Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEEE, MMM d').format(_selectedDay),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _primaryDark,
                        ),
                      ),
                      if (hasLog)
                        GestureDetector(
                          onTap: _openLogModal,
                          child: const Text(
                            "EDIT LOG",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: _primaryMuted,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Show either the Empty State or the Logged Data Grid
                  if (hasLog)
                    _buildLoggedDataGrid(logData!)
                  else
                    _buildEmptyStateCard(),

                  const SizedBox(height: 80), // Padding for FAB
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openLogModal,
        backgroundColor: _primaryMuted,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // ==========================================
  // WIDGETS
  // ==========================================
  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('MMMM yyyy').format(_focusedDay),
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: _primaryDark,
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(
                () => _focusedDay = DateTime(
                  _focusedDay.year,
                  _focusedDay.month - 1,
                  1,
                ),
              ),
              child: const Icon(Icons.chevron_left, color: _textGray, size: 28),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => setState(
                () => _focusedDay = DateTime(
                  _focusedDay.year,
                  _focusedDay.month + 1,
                  1,
                ),
              ),
              child: const Icon(
                Icons.chevron_right,
                color: _textGray,
                size: 28,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        headerVisible: false,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) => setState(() => _focusedDay = focusedDay),
        daysOfWeekHeight: 40,
        daysOfWeekStyle: DaysOfWeekStyle(
          dowTextFormatter: (date, locale) =>
              DateFormat.E(locale).format(date)[0],
          weekdayStyle: const TextStyle(
            color: _lightGray,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          weekendStyle: const TextStyle(
            color: _lightGray,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        calendarStyle: CalendarStyle(
          defaultTextStyle: const TextStyle(color: _primaryDark, fontSize: 16),
          weekendTextStyle: const TextStyle(color: _primaryDark, fontSize: 16),
          outsideDaysVisible: false,
          selectedDecoration: const BoxDecoration(
            color: _primaryMuted,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          todayDecoration: BoxDecoration(
            color: _lightGray.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(
            color: _primaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCycleIntelligenceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _bgWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.show_chart, size: 18, color: _primaryMuted),
                  const SizedBox(width: 8),
                  Text(
                    "CYCLE INTELLIGENCE",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: _primaryDark.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              Text(
                "DAY 2",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: _primaryDark.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Menstrual Phase",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _primaryDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Your body is preparing for its next peak. Focus on nutrient-dense foods and moderate movement.",
            style: TextStyle(fontSize: 14, height: 1.4, color: _textGray),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: _bgWhite, shape: BoxShape.circle),
            child: const Icon(Icons.add, color: _lightGray, size: 32),
          ),
          const SizedBox(height: 20),
          const Text(
            "No data for this day",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Track your symptoms to get better insights.",
            style: TextStyle(fontSize: 14, color: _textGray),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _openLogModal,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryMuted.withOpacity(0.3),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              "Log Today",
              style: TextStyle(
                color: _primaryMuted,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedDataGrid(Map<String, dynamic> data) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildLogTile(
                "PERIOD",
                data['onPeriod'] ? 'Active' : 'Inactive',
                data['onPeriod'] ? "${data['flow']} Flow" : null,
                Icons.water_drop_outlined,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildLogTile(
                "ENERGY",
                data['energy'],
                _getEnergyIcons(data['energy']),
                Icons.bolt,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment
              .start, // Align to top because notes can be tall
          children: [
            Expanded(
              child: _buildLogTile(
                "STRESS",
                data['stress'],
                _getStressEmoji(data['stress']),
                Icons.show_chart,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildLogTile(
                "NOTES",
                data['notes'].toString().isNotEmpty
                    ? data['notes']
                    : 'No notes',
                null,
                Icons.chat_bubble_outline,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogTile(
    String label,
    String value,
    String? subtitle,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: _lightGray),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: _textGray,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: _primaryDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(color: _textGray, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  String _getEnergyIcons(String energy) {
    switch (energy) {
      case 'Very Low':
        return '🔋';
      case 'Low':
        return '🔋🔋';
      case 'Moderate':
        return '🔋🔋🔋';
      case 'High':
        return '🔋🔋🔋🔋';
      case 'Very High':
        return '🔋🔋🔋🔋🔋';
      default:
        return '';
    }
  }

  String _getStressEmoji(String stress) {
    switch (stress) {
      case 'Calm':
        return '😀';
      case 'Mild':
        return '😐';
      case 'Moderate':
        return '😥';
      case 'High':
        return '😫';
      case 'Overwhelmed':
        return '🤬';
      default:
        return '';
    }
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: _primaryDark,
          unselectedItemColor: const Color(0xFFC4BCC8),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 11,
            height: 1.8,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11,
            height: 1.8,
          ),
          elevation: 0,
          onTap: (index) {
            if (index == _currentIndex) return;
            Widget nextScreen;
            switch (index) {
              case 0:
                nextScreen = const HomeScreen();
                break;
              case 1:
                nextScreen = const CalendarScreen();
                break;
              case 2:
                nextScreen = const InsightsScreen();
                break;
              case 3:
                nextScreen = const PlannerScreen();
                break;
              case 4:
                nextScreen = const SettingsScreen();
                break;
              default:
                return;
            }
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => nextScreen,
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled, size: 28),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined, size: 26),
              label: "Calendar",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_outlined, size: 28),
              label: "Insights",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border_rounded, size: 28),
              label: "Planner",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined, size: 28),
              label: "Settings",
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// MODAL BOTTOM SHEET
// ==========================================
class _DailyLogModal extends StatefulWidget {
  final DateTime date;
  final Map<String, dynamic>? existingLog;
  final Function(Map<String, dynamic>) onSave;

  const _DailyLogModal({
    required this.date,
    this.existingLog,
    required this.onSave,
  });

  @override
  State<_DailyLogModal> createState() => _DailyLogModalState();
}

class _DailyLogModalState extends State<_DailyLogModal> {
  bool _onPeriod = false;
  String _flowLevel = 'MEDIUM';
  String _energyLevel = 'Moderate';
  String _stressLevel = 'Mild';
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingLog != null) {
      _onPeriod = widget.existingLog!['onPeriod'] ?? false;
      _flowLevel = widget.existingLog!['flow'] ?? 'MEDIUM';
      _energyLevel = widget.existingLog!['energy'] ?? 'Moderate';
      _stressLevel = widget.existingLog!['stress'] ?? 'Mild';
      _notesController.text = widget.existingLog!['notes'] ?? '';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      // Padding handles the keyboard pushing the modal up
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _lightGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Log Daily Data",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _primaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMMM d, yyyy').format(widget.date),
                          style: const TextStyle(
                            fontSize: 14,
                            color: _textGray,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: _textGray),
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(backgroundColor: _bgWhite),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Scrollable Content
                Expanded(
                  child: ListView(
                    controller: controller,
                    children: [
                      // Period Toggle
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _bgWhite,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.water_drop_outlined,
                                  color: _primaryMuted,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "On Period",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _primaryDark,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: _onPeriod,
                              onChanged: (val) =>
                                  setState(() => _onPeriod = val),
                              activeColor: _primaryMuted,
                              inactiveTrackColor: Colors.white,
                            ),
                          ],
                        ),
                      ),

                      // Flow Level (Only visible if On Period is true)
                      if (_onPeriod) ...[
                        const SizedBox(height: 24),
                        const Text(
                          "FLOW LEVEL",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: _textGray,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildFlowButton("LIGHT")),
                            const SizedBox(width: 12),
                            Expanded(child: _buildFlowButton("MEDIUM")),
                            const SizedBox(width: 12),
                            Expanded(child: _buildFlowButton("HEAVY")),
                          ],
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Energy Level
                      Row(
                        children: [
                          const Icon(
                            Icons.bolt,
                            color: _primaryMuted,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Energy Level",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _primaryDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSelectionTile(
                        "Very Low",
                        "🔋",
                        _energyLevel,
                        (val) => setState(() => _energyLevel = val),
                      ),
                      _buildSelectionTile(
                        "Low",
                        "🔋🔋",
                        _energyLevel,
                        (val) => setState(() => _energyLevel = val),
                      ),
                      _buildSelectionTile(
                        "Moderate",
                        "🔋🔋🔋",
                        _energyLevel,
                        (val) => setState(() => _energyLevel = val),
                      ),
                      _buildSelectionTile(
                        "High",
                        "🔋🔋🔋🔋",
                        _energyLevel,
                        (val) => setState(() => _energyLevel = val),
                      ),
                      _buildSelectionTile(
                        "Very High",
                        "🔋🔋🔋🔋🔋",
                        _energyLevel,
                        (val) => setState(() => _energyLevel = val),
                      ),

                      const SizedBox(height: 32),

                      // Stress Level
                      Row(
                        children: [
                          const Icon(
                            Icons.show_chart,
                            color: _primaryMuted,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Stress Level",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _primaryDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSelectionTile(
                        "Calm",
                        "😀",
                        _stressLevel,
                        (val) => setState(() => _stressLevel = val),
                      ),
                      _buildSelectionTile(
                        "Mild",
                        "😐",
                        _stressLevel,
                        (val) => setState(() => _stressLevel = val),
                      ),
                      _buildSelectionTile(
                        "Moderate",
                        "😥",
                        _stressLevel,
                        (val) => setState(() => _stressLevel = val),
                      ),
                      _buildSelectionTile(
                        "High",
                        "😫",
                        _stressLevel,
                        (val) => setState(() => _stressLevel = val),
                      ),
                      _buildSelectionTile(
                        "Overwhelmed",
                        "🤬",
                        _stressLevel,
                        (val) => setState(() => _stressLevel = val),
                      ),

                      const SizedBox(height: 32),

                      // Notes
                      Row(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            color: _primaryMuted,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Notes",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _primaryDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "How are you feeling today?",
                          hintStyle: TextStyle(
                            color: _textGray.withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: _bgWhite,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),

                // Save Button
                Container(
                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSave({
                        'onPeriod': _onPeriod,
                        'flow': _flowLevel,
                        'energy': _energyLevel,
                        'stress': _stressLevel,
                        'notes': _notesController.text.trim(),
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryMuted,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Save Daily Log",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFlowButton(String label) {
    bool isSelected = _flowLevel == label;
    return GestureDetector(
      onTap: () => setState(() => _flowLevel = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? _primaryMuted.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _primaryMuted : _lightGray,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? _primaryMuted : _textGray,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionTile(
    String label,
    String icon,
    String groupValue,
    Function(String) onSelect,
  ) {
    bool isSelected = label == groupValue;
    return GestureDetector(
      onTap: () => onSelect(label),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _primaryDark : _lightGray,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? _primaryDark : _textGray,
              ),
            ),
            Text(icon, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
