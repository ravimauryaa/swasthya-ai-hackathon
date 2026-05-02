class TriageModel {
  final String severity;
  final String action;

  TriageModel({required this.severity, required this.action});

  // Yeh factory function AI ke raw JSON ko clean Dart Object mein badlega
  factory TriageModel.fromJson(Map<String, dynamic> json) {
    return TriageModel(
      // Fallback Safety: Agar AI kuch galat bhej de, toh app crash nahi hogi
      severity: json['severity'] ?? 'GREEN',
      action: json['action'] ?? 'Please consult a doctor for further advice.',
    );
  }
}