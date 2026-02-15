class DailyLog {
  final bool isPeriodActive;
  final String? flowIntensity; // "Light", "Medium", "Heavy"
  final List<String> selectedSymptoms;
  final String extraSymptoms; // NEW: Stores the free-text symptoms
  final String note; // NEW: Specifically for journal/emotional thoughts

  DailyLog({
    this.isPeriodActive = false,
    this.flowIntensity,
    this.selectedSymptoms = const [],
    this.extraSymptoms = "", // Default to empty string
    this.note = "",
  });

  // Helper for Backend: Translates UI labels to module1/feature_extraction.py FLOW_MAP
  String? get encodedFlow {
    if (!isPeriodActive) return null;
    if (flowIntensity == "Light") return "L";
    if (flowIntensity == "Medium") return "M";
    if (flowIntensity == "Heavy") return "H";
    return "M"; // Default to Medium if active but not specified
  }
}
