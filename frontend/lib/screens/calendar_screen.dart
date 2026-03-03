import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
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
    return Scaffold(
      backgroundColor: HerLunaTheme.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => setState(() => _showLogSheet = true),
        backgroundColor: HerLunaTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Log Day', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Calendar', style: HerLunaTheme.heading2),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_left,
                        color: HerLunaTheme.textSecondary),
                    onPressed: () => setState(() {
                      _focusedMonth = DateTime(
                          _focusedMonth.year, _focusedMonth.month - 1);
                    }),
                  ),
                  Text(
                    _monthName(_focusedMonth),
                    style: HerLunaTheme.heading3.copyWith(fontSize: 15),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right,
                        color: HerLunaTheme.textSecondary),
                    onPressed: () => setState(() {
                      _focusedMonth = DateTime(
                          _focusedMonth.year, _focusedMonth.month + 1);
                    }),
                  ),
                ],
              ),
            ),

            // ── Calendar Grid ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildCalendarGrid(),
            ),

            const SizedBox(height: 16),

            // ── Selected Day Summary ─────────────────────────────────
            if (_selectedDay != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildDaySummary(),
              ),

            // ── Log Bottom Sheet ─────────────────────────────────────
            if (_showLogSheet) ...[
              const Spacer(),
              _buildLogSheet(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstWeekday =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday;
    final today = DateTime.now();

    return Column(
      children: [
        // Day names
        Row(
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              .map((d) => Expanded(
                    child: Center(
                      child: Text(d,
                          style: HerLunaTheme.bodySmall
                              .copyWith(fontWeight: FontWeight.w500)),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        // Days grid
        ...List.generate(6, (week) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: List.generate(7, (day) {
                final dayNum =
                    week * 7 + day + 1 - (firstWeekday == 7 ? 0 : firstWeekday);
                if (dayNum < 1 || dayNum > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 42));
                }

                final date = DateTime(
                    _focusedMonth.year, _focusedMonth.month, dayNum);
                final isToday = date.day == today.day &&
                    date.month == today.month &&
                    date.year == today.year;
                final isSelected = _selectedDay != null &&
                    date.day == _selectedDay!.day &&
                    date.month == _selectedDay!.month;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDay = date),
                    child: Container(
                      height: 42,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? HerLunaTheme.primary
                            : isToday
                                ? HerLunaTheme.accentLight
                                : null,
                        borderRadius: BorderRadius.circular(12),
                        border: isToday && !isSelected
                            ? Border.all(
                                color: HerLunaTheme.primary.withOpacity(0.4))
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '$dayNum',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isToday ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? Colors.white
                                : HerLunaTheme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDaySummary() {
    return HerLunaCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_selectedDay!.day} ${_monthName(DateTime(_selectedDay!.year, _selectedDay!.month))}',
            style: HerLunaTheme.heading3,
          ),
          const SizedBox(height: 12),
          _summaryRow('Phase', 'Follicular', Icons.nightlight_round),
          _summaryRow('Energy', 'Moderate', Icons.bolt_outlined),
          _summaryRow('Stress', 'Low', Icons.spa_outlined),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: HerLunaTheme.accent),
          const SizedBox(width: 10),
          Text(label, style: HerLunaTheme.bodyMedium),
          const Spacer(),
          Text(value,
              style: HerLunaTheme.bodyLarge
                  .copyWith(fontWeight: FontWeight.w500, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildLogSheet() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      decoration: BoxDecoration(
        color: HerLunaTheme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: HerLunaTheme.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text('Log Today', style: HerLunaTheme.heading3),
          const SizedBox(height: 20),
          // Period toggle
          Row(
            children: [
              Text('Period', style: HerLunaTheme.bodyLarge),
              const Spacer(),
              Switch(
                value: _isPeriod,
                onChanged: (v) => setState(() => _isPeriod = v),
                activeColor: HerLunaTheme.primary,
              ),
            ],
          ),
          if (_isPeriod) ...[
            const SizedBox(height: 8),
            _sliderRow('Flow Level', _flowLevel, 1, 5, (v) {
              setState(() => _flowLevel = v);
            }),
          ],
          const SizedBox(height: 8),
          _sliderRow('Energy', _energyLevel, 1, 5, (v) {
            setState(() => _energyLevel = v);
          }),
          const SizedBox(height: 8),
          _sliderRow('Stress', _stressLevel, 1, 5, (v) {
            setState(() => _stressLevel = v);
          }),
          const SizedBox(height: 20),
          HerLunaButton(
            text: 'Save',
            onPressed: () => setState(() => _showLogSheet = false),
          ),
        ],
      ),
    );
  }

  Widget _sliderRow(String label, double value, double min, double max,
      ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: HerLunaTheme.bodyMedium),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: HerLunaTheme.primary,
              inactiveTrackColor: HerLunaTheme.accentLight,
              thumbColor: HerLunaTheme.primary,
              overlayColor: HerLunaTheme.primary.withOpacity(0.1),
              trackHeight: 3,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).round(),
              onChanged: onChanged,
            ),
          ),
        ),
        Text(
          value.round().toString(),
          style: HerLunaTheme.bodyLarge
              .copyWith(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  String _monthName(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
