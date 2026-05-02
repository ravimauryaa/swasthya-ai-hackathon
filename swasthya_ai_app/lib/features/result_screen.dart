import 'package:flutter/material.dart';
import '../models/triage_model.dart';

class ResultScreen extends StatelessWidget {
  final TriageModel triageResult;

  const ResultScreen({super.key, required this.triageResult});

  // Helper method for UI Colors based on RAG Triage
  Color _getSeverityColor(String severity) {
    if (severity.toUpperCase() == 'RED') return Colors.red.shade600;
    if (severity.toUpperCase() == 'YELLOW') return Colors.orange.shade500;
    return Colors.green.shade600;
  }

  // Helper method for softer background colors
  Color _getSeverityBgColor(String severity) {
    if (severity.toUpperCase() == 'RED') return Colors.red.shade50;
    if (severity.toUpperCase() == 'YELLOW') return Colors.orange.shade50;
    return Colors.green.shade50;
  }

  @override
  Widget build(BuildContext context) {
    Color severityColor = _getSeverityColor(triageResult.severity);
    Color bgColor = _getSeverityBgColor(triageResult.severity);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC), // Premium Off-White Background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AI Triage Result',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            // Giant Glowing Result Circle
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: severityColor.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: severityColor.withOpacity(0.3),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: severityColor,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          triageResult.severity.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "ALERT",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),

            // AI Action Advice Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.health_and_safety_rounded, color: severityColor, size: 28),
                      const SizedBox(width: 10),
                      const Text(
                        "Medical Advice",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(),
                  ),
                  Text(
                    triageResult.action,
                    style: const TextStyle(fontSize: 18, height: 1.5, color: Colors.black87, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Disclaimer Warning
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "This is a severity assessment based on medical guidelines, NOT a definitive diagnosis. Please consult a doctor.",
                      style: TextStyle(color: Colors.orange.shade900, fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // Dynamic Bottom Button based on Severity
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // Here we will add Google Maps / SOS logic later
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: severityColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                triageResult.severity.toUpperCase() == 'RED' ? "Find Nearest Hospital" : "Acknowledge & Go Back",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}