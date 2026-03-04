import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/spacing.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/prediction_model.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  PredictionModel? _prediction;
  int _selectedDateIndex = 2; // "today"

  // Defaults match user's original UI
  String _forecast = 'Your energy is predicted to be high until 4 PM. Aim to finish heavy tasks early.';
  List<Map<String, dynamic>> _tasks = [
    {'time': '08:00 AM', 'title': 'Morning Workout', 'desc': 'High energy window — best time for physical activity.', 'ai': true},
    {'time': '12:00 PM', 'title': 'Focused Work', 'desc': 'Your cognitive peak aligns with this window.', 'ai': true},
    {'time': '07:00 PM', 'title': 'Wind Down', 'desc': 'Gentle movement and light reading to prep for sleep.', 'ai': false},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userId = await StorageService.getUserId();
      final storageMode = await StorageService.getStorageMode();
      if (userId != null) {
        _prediction = await ApiService().predict(userId: userId, storageMode: storageMode);
        if (mounted) setState(() {
          final phase = _prediction?.dominantPhase ?? 'Follicular';
          final fatigue = _prediction?.fatigueProbability ?? 0.0;
          if (fatigue > 0.7) {
            _forecast = 'Energy may be low today. Focus on lighter tasks and self-care.';
          } else if (phase == 'Luteal') {
            _forecast = 'Energy may dip in the afternoon. Plan demanding work for the morning.';
          }
          // Tasks stay as user's original defaults
        });
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
          "Lifestyle Planner",
          style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Date Scroller
            _buildDateSelector(),

            AppSpacing.verticalMedium,

            // 2. AI Forecast Header
            _buildForecastHeader(),

            AppSpacing.verticalLarge,

            // 3. Time-based Agenda
            const Text(
              "Today's Flow",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
            ),
            AppSpacing.verticalSmall,

            ..._tasks.map((t) => _buildPlannerTask(
              time: t['time'] as String,
              title: t['title'] as String,
              description: t['desc'] as String,
              isAIRecommended: t['ai'] as bool,
            )),

            AppSpacing.verticalLarge,

            // Add Task Button
            Center(
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, color: AppColors.primaryMuted),
                label: const Text(
                  "Add Personal Task",
                  style: TextStyle(color: AppColors.primaryMuted, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          bool isToday = index == _selectedDateIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedDateIndex = index),
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isToday ? AppColors.primaryDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.lavender.withOpacity(0.5)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    days[index],
                    style: TextStyle(
                      color: isToday ? Colors.white70 : AppColors.primaryMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${index + 9}",
                    style: TextStyle(
                      color: isToday ? Colors.white : AppColors.primaryDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForecastHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accentMint.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentMint),
      ),
      child: Row(
        children: [
          const Icon(Icons.wb_sunny_outlined, color: AppColors.primaryDark),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _forecast,
              style: const TextStyle(color: AppColors.primaryDark, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlannerTask({
    required String time,
    required String title,
    required String description,
    required bool isAIRecommended,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: const TextStyle(fontSize: 12, color: AppColors.primaryMuted, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: isAIRecommended ? Border.all(color: AppColors.lavender, width: 1.5) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                      if (isAIRecommended)
                        const Icon(Icons.auto_awesome, size: 14, color: AppColors.primaryMuted),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(fontSize: 13, color: AppColors.primaryMuted, height: 1.3)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HerLunaTheme.background,
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, _) {
            final result = provider.inferenceResult;
            final phase = _dominantPhase(result);
            final confidence = result?.meta?.confidenceScore ?? 0.0;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: HerLunaTheme.horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text('Planner', style: HerLunaTheme.heading2),
                  const SizedBox(height: 24),

                  // ── Hero Card ─────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: HerLunaTheme.heroGradient,
                      borderRadius:
                          BorderRadius.circular(HerLunaTheme.cardRadius),
                      boxShadow: [
                        BoxShadow(
                          color: HerLunaTheme.primary.withOpacity(0.2),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upcoming Phase',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _nextPhase(phase),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _phaseDate(phase),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.75),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              'Confidence',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: confidence,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.2),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                  minHeight: 4,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${(confidence * 100).round()}%',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Energy Outlook ────────────────────────────────
                  _outlookCard(
                    icon: Icons.bolt_outlined,
                    title: 'Energy Outlook',
                    description: _energyOutlook(phase),
                  ),
                  const SizedBox(height: 12),

                  // ── Stress Outlook ────────────────────────────────
                  _outlookCard(
                    icon: Icons.spa_outlined,
                    title: 'Stress Outlook',
                    description: _stressOutlook(phase),
                  ),
                  const SizedBox(height: 12),

                  // ── Guidance ──────────────────────────────────────
                  HerLunaCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lightbulb_outline,
                                color: HerLunaTheme.primary, size: 20),
                            const SizedBox(width: 10),
                            Text('Guidance',
                                style: HerLunaTheme.heading3
                                    .copyWith(fontSize: 15)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...((result?.meta?.guidance
                                    ?.map<Widget>((g) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Icon(Icons.circle,
                                                  size: 5,
                                                  color: HerLunaTheme.accent),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  g.suggestion ?? '',
                                                  style: HerLunaTheme
                                                      .bodyMedium,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList() as List<Widget>?) ??
                            [
                              Text(
                                'Run inference for personalized guidance.',
                                style: HerLunaTheme.bodySmall,
                              ),
                            ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _outlookCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return HerLunaCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: HerLunaTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: HerLunaTheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: HerLunaTheme.heading3.copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(description, style: HerLunaTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _dominantPhase(dynamic r) {
    if (r == null) return 'Unknown';
    final ps = r.physiologicalState?.phaseProbability;
    if (ps == null) return 'Unknown';
    final map = {
      'Menstrual': ps.menstrual,
      'Follicular': ps.follicular,
      'Ovulatory': ps.ovulatory,
      'Luteal': ps.luteal,
    };
    return map.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  String _nextPhase(String current) {
    const order = ['Menstrual', 'Follicular', 'Ovulatory', 'Luteal'];
    final idx = order.indexOf(current);
    return idx >= 0 ? order[(idx + 1) % 4] : 'Follicular';
  }

  String _phaseDate(String current) {
    // Estimated from current phase
    final days = current == 'Menstrual'
        ? 5
        : current == 'Follicular'
            ? 9
            : current == 'Ovulatory'
                ? 3
                : 10;
    final est = DateTime.now().add(Duration(days: days));
    return 'Estimated ~${est.day}/${est.month}';
  }

  String _energyOutlook(String phase) {
    switch (phase) {
      case 'Menstrual': return 'Energy likely increasing as menstruation ends.';
      case 'Follicular': return 'Rising energy — good window for high-effort tasks.';
      case 'Ovulatory': return 'Peak energy expected in coming days.';
      case 'Luteal': return 'Energy may gradually decrease. Plan accordingly.';
      default: return 'Gathering data for outlook.';
    }
  }

  String _stressOutlook(String phase) {
    switch (phase) {
      case 'Menstrual': return 'Stress resilience typically improves.';
      case 'Follicular': return 'Generally lower stress sensitivity.';
      case 'Ovulatory': return 'Social activities may feel easier.';
      case 'Luteal': return 'Higher sensitivity possible. Consider lighter schedule.';
      default: return 'Gathering data for outlook.';
    }
  }
}
