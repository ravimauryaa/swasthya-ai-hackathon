// lib/features/abha_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AbhaScreen extends StatefulWidget {
  const AbhaScreen({super.key});

  @override
  State<AbhaScreen> createState() => _AbhaScreenState();
}

class _AbhaScreenState extends State<AbhaScreen> {
  bool _isScanning = false;
  final ApiService _apiService = ApiService();

  Future<void> _startMockScan() async {
    setState(() => _isScanning = true);
    
    // Fake camera delay for hackathon presentation
    await Future.delayed(const Duration(seconds: 2)); 
    
    // Fetch from backend using the dummy ID
    final profile = await _apiService.fetchPatientHistory("14-1111-2222-3333");
    
    setState(() {
      ApiService.currentPatientProfile = profile; // Save to Global State
      _isScanning = false;
    });

    if (mounted && profile != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ABHA Profile Linked! Go to Triage tab.'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.health_and_safety, size: 80, color: Color(0xFF0F766E)),
            const SizedBox(height: 20),
            const Text(
              "ABHA Health Identity",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Scan patient's ABHA QR code to fetch medical history securely before triage.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            if (ApiService.currentPatientProfile == null) ...[
              _isScanning 
                ? const CircularProgressIndicator(color: Color(0xFF0F766E))
                : ElevatedButton.icon(
                    onPressed: _startMockScan,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text("Scan ABHA QR Code"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
            ] else ...[
              // Fetched Profile Details
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade300, width: 2),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      ApiService.currentPatientProfile!['name'],
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text("Age: ${ApiService.currentPatientProfile!['age']} | ${ApiService.currentPatientProfile!['gender']}"),
                    const Divider(),
                    Text("Conditions: ${ApiService.currentPatientProfile!['chronic_conditions'].join(', ')}", style: const TextStyle(color: Colors.redAccent)),
                    Text("Allergies: ${ApiService.currentPatientProfile!['allergies'].join(', ')}", style: const TextStyle(color: Colors.orange)),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () => setState(() => ApiService.currentPatientProfile = null),
                      child: const Text("Unlink Profile", style: TextStyle(color: Colors.red)),
                    )
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}