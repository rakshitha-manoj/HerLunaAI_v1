import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';

class CycleBaselineScreen extends StatefulWidget {
  const CycleBaselineScreen({super.key});

  @override
  State<CycleBaselineScreen> createState() => _CycleBaselineScreenState();
}

class _CycleBaselineScreenState extends State<CycleBaselineScreen> {
  double _cycleLength = 28;
  DateTime _lastPeriod = DateTime.now().subtract(const Duration(days: 14));
  bool _notSure = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HerLunaTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: HerLunaTheme.horizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Set Your Cycle\nBaseline',
                style: HerLunaTheme.heading1,
              ),
              const SizedBox(height: 36),
              // ── Average cycle length ───────────────────────────
              HerLunaCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Average cycle length',
                      style: HerLunaTheme.heading3.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_cycleLength.round()} days',
                      style: HerLunaTheme.heading2.copyWith(
                        color: HerLunaTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: HerLunaTheme.primary,
                        inactiveTrackColor: HerLunaTheme.accentLight,
                        thumbColor: HerLunaTheme.primary,
                        overlayColor: HerLunaTheme.primary.withOpacity(0.1),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: _cycleLength,
                        min: 18,
                        max: 45,
                        divisions: 27,
                        onChanged: _notSure
                            ? null
                            : (v) => setState(() => _cycleLength = v),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // ── Last period date ───────────────────────────────
              HerLunaCard(
                padding: const EdgeInsets.all(20),
                onTap: _notSure ? null : () => _pickDate(context),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: HerLunaTheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last period start',
                            style:
                                HerLunaTheme.heading3.copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_lastPeriod.day}/${_lastPeriod.month}/${_lastPeriod.year}',
                            style: HerLunaTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: HerLunaTheme.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // ── Not sure toggle ────────────────────────────────
              Row(
                children: [
                  Switch(
                    value: _notSure,
                    onChanged: (v) => setState(() => _notSure = v),
                    activeColor: HerLunaTheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "I'm not sure",
                      style: HerLunaTheme.bodyLarge.copyWith(fontSize: 15),
                    ),
                  ),
                ],
              ),
              if (_notSure)
                Padding(
                  padding: const EdgeInsets.only(left: 60, top: 4),
                  child: Text(
                    'No worries — HerLuna will learn your patterns over time.',
                    style: HerLunaTheme.bodySmall,
                  ),
                ),
              const Spacer(),
              HerLunaButton(
                text: 'Finish Setup',
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainShell()),
                    (_) => false,
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastPeriod,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: HerLunaTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _lastPeriod = picked);
    }
  }
}
