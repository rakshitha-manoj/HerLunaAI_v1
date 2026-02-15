import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/daily_log.dart';
import '../theme.dart';

class LogEntryModal extends StatefulWidget {
  final DateTime date;
  final DailyLog? existingLog;
  final Function(DailyLog) onUpdate;

  const LogEntryModal({
    super.key,
    required this.date,
    this.existingLog,
    required this.onUpdate,
  });

  @override
  State<LogEntryModal> createState() => _LogEntryModalState();
}

class _LogEntryModalState extends State<LogEntryModal> {
  late bool _isPeriodActive;
  String? _selectedFlow;
  late List<String> _selectedSymptoms;

  // Controllers for the text fields
  final TextEditingController _extraSymptomsController =
      TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final List<String> _allSymptoms = [
    "Headache",
    "Cramps",
    "Bloating",
    "Mood Swings",
    "Fatigue",
    "Acne",
    "Breast Tenderness",
    "Cravings",
    "Insomnia",
    "Back Pain",
  ];

  @override
  void initState() {
    super.initState();
    _isPeriodActive = widget.existingLog?.isPeriodActive ?? false;
    _selectedFlow = widget.existingLog?.flowIntensity;
    _selectedSymptoms = List.from(widget.existingLog?.selectedSymptoms ?? []);

    // Initialize controllers with existing data
    _extraSymptomsController.text = widget.existingLog?.extraSymptoms ?? "";
    _noteController.text = widget.existingLog?.note ?? "";
  }

  @override
  void dispose() {
    _extraSymptomsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildPeriodSection(),
            const SizedBox(height: 20),

            const Text(
              "Symptoms",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSymptomGrid(),
            const SizedBox(height: 20),

            // --- SECTION 1: EXTRA SYMPTOMS ---
            const Text(
              "Extra Symptoms",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _extraSymptomsController,
              decoration: InputDecoration(
                hintText: "Enter any other symptoms...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- SECTION 2: JOURNAL THOUGHTS ---
            const Text(
              "Journal Thoughts",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: "How are you feeling today?",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  widget.onUpdate(
                    DailyLog(
                      isPeriodActive: _isPeriodActive,
                      flowIntensity: _selectedFlow,
                      selectedSymptoms: _selectedSymptoms,
                      extraSymptoms: _extraSymptomsController.text, // New field
                      note: _noteController.text,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text("Update Log"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    // Basic date formatting logic
    final List<String> weekdays = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];
    final List<String> months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              weekdays[widget.date.weekday - 1],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: HerLunaTheme.primaryPlum,
              ),
            ),
            Text(
              "${months[widget.date.month - 1]} ${widget.date.day}, ${widget.date.year}",
              style: const TextStyle(color: Colors.black45),
            ),
          ],
        ),
        CircleAvatar(
          backgroundColor: Colors.black12,
          child: IconButton(
            icon: const Icon(LucideIcons.x, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Period Active",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Checkbox(
                value: _isPeriodActive,
                activeColor: HerLunaTheme.primaryPlum,
                onChanged: (v) => setState(() => _isPeriodActive = v!),
              ),
            ],
          ),
          if (_isPeriodActive)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ["Light", "Medium", "Heavy"].map((f) {
                  bool isSelected = _selectedFlow == f;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFlow = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        // Turns Plum when selected, light grey when not
                        color: isSelected
                            ? HerLunaTheme.primaryPlum
                            : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          // Text turns white on plum background
                          color: isSelected ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSymptomGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allSymptoms
          .map(
            (s) => FilterChip(
              label: Text(s),
              selected: _selectedSymptoms.contains(s),
              onSelected: (v) => setState(
                () =>
                    v ? _selectedSymptoms.add(s) : _selectedSymptoms.remove(s),
              ),
            ),
          )
          .toList(),
    );
  }
}
