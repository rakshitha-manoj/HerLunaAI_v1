import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/spacing.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/cycle_log_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<CycleLogModel> _cycleLogs = [];
  Set<int> _periodDays = {};

  @override
  void initState() {
    super.initState();
    _loadCycleLogs();
  }

  Future<void> _loadCycleLogs() async {
    try {
      final userId = await StorageService.getUserId();
      if (userId != null) {
        _cycleLogs = await ApiService().getCycleLogs(userId);
        // Highlight period days for October (mock month shown)
        for (final log in _cycleLogs) {
          for (int d = 0; d < 5; d++) {
            _periodDays.add(log.periodStart.day + d);
          }
        }
        if (mounted) setState(() {});
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Calendar",
          style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "October 2023",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                ),
                Row(
                  children: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
                  ],
                ),
              ],
            ),
            
            AppSpacing.verticalMedium,

            // Weekday Labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                  .map((day) => Text(day, style: const TextStyle(color: AppColors.primaryMuted, fontWeight: FontWeight.bold)))
                  .toList(),
            ),
            
            AppSpacing.verticalSmall,

            // Calendar Grid Placeholder
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 31,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                int day = index + 1;
                // Use real period data if available, fallback to mock
                bool isPhaseDay = _periodDays.isNotEmpty
                    ? _periodDays.contains(day)
                    : (day >= 10 && day <= 14);
                bool isSelected = day == 12;

                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primaryDark 
                        : (isPhaseDay ? AppColors.lavender.withOpacity(0.5) : Colors.transparent),
                    shape: BoxShape.circle,
                    border: isPhaseDay && !isSelected 
                        ? Border.all(color: AppColors.lavender) 
                        : null,
                  ),
                  child: Text(
                    "$day",
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.primaryDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),

            AppSpacing.verticalLarge,

            // Legend/Summary Section
            const Text(
              "Legend",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
            ),
            AppSpacing.verticalSmall,
            _buildLegendItem(AppColors.lavender, "Ovulation Window"),
            _buildLegendItem(AppColors.primaryDark, "Selected Day"),
            _buildLegendItem(AppColors.accentMint, "Predicted Period"),

            AppSpacing.verticalLarge,

            // Daily Detail Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("October 12th Insights", style: TextStyle(fontWeight: FontWeight.bold)),
                  AppSpacing.verticalSmall,
                  const Text(
                    "High energy levels today. Your AI suggests focusing on physical activity.",
                    style: TextStyle(color: AppColors.primaryMuted, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          CircleAvatar(radius: 6, backgroundColor: color),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.primaryMuted, fontSize: 14)),
        ],
      ),
    );
  }
}