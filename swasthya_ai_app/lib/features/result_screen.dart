// lib/features/result_screen.dart
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert'; // JSON ke liye
import 'package:shared_preferences/shared_preferences.dart'; // Local Memory ke liye
import '../models/triage_model.dart';
import '../services/api_service.dart';

class ResultScreen extends StatefulWidget {
  final String symptoms;
  final String language;

  const ResultScreen({super.key, required this.symptoms, required this.language});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final ApiService _apiService = ApiService();
  final FlutterTts _flutterTts = FlutterTts(); 
  
  TriageModel? _result;
  String? _error;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _fetchTriage();
  }

  // TTS Setup
  void _initTts() {
    _flutterTts.setStartHandler(() => setState(() => _isSpeaking = true));
    _flutterTts.setCompletionHandler(() => setState(() => _isSpeaking = false));
    _flutterTts.setErrorHandler((msg) => setState(() => _isSpeaking = false));
  }

  @override
  void dispose() {
    _flutterTts.stop(); 
    super.dispose();
  }

  Future<void> _fetchTriage() async {
    try {
      final data = await _apiService.getTriageResult(
        widget.symptoms, 
        widget.language,
        patientHistory: ApiService.currentPatientProfile,
      );
      setState(() => _result = data);
      
      // 💾 AUTO-SAVE LOGIC: Result aate hi phone me save karo
      _saveResultLocally(data);
      
      _speakResult();
    } catch (e) {
      setState(() => _error = "Connection failed. Please try again.");
    }
  }

  // ==========================================
  // PHASE 5: LOCAL MEDICAL LEDGER (MEMORY)
  // ==========================================
  Future<void> _saveResultLocally(TriageModel data) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('medical_history') ?? [];

    Map<String, dynamic> newEntry = {
      'date': DateTime.now().toIso8601String(),
      'symptoms': widget.symptoms,
      'severity': data.severity,
      'action': data.action,
    };

    history.insert(0, jsonEncode(newEntry));
    await prefs.setStringList('medical_history', history);
    debugPrint("✅ Medical record securely saved locally!");
  }

  Future<void> _speakResult() async {
    if (_result == null) return;

    await _flutterTts.setLanguage(widget.language == 'Hindi' ? "hi-IN" : "en-US");
    await _flutterTts.setPitch(1.0);
    
    String speechText = "${_result!.severity} Alert. ${_result!.action}";
    await _flutterTts.speak(speechText);
  }

  Color _getSeverityColor(String s) {
    if (s.toUpperCase() == 'RED') return Colors.red.shade600;
    if (s.toUpperCase() == 'YELLOW') return Colors.orange.shade500;
    return Colors.green.shade600;
  }

  // ==========================================
  // PHASE 4: EMERGENCY ACTIONS LOGIC
  // ==========================================
  Future<void> _openMaps() async {
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=hospitals+near+me');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch Maps');
    }
  }

  Future<void> _callAmbulance() async {
    final Uri url = Uri.parse('tel:108');
    if (!await launchUrl(url)) {
      debugPrint('Could not launch Dialer');
    }
  }

  Future<void> _alertFamily() async {
    String patientName = ApiService.currentPatientProfile?['name'] ?? "me";
    String severity = _result?.severity.toUpperCase() ?? "MEDICAL";
    String message = "EMERGENCY: SwasthyaAI has detected a $severity alert for $patientName. Please contact me immediately. I am heading to the nearest hospital.";
    
    final Uri url = Uri.parse('sms:?body=${Uri.encodeComponent(message)}');
    if (!await launchUrl(url)) {
      debugPrint('Could not launch SMS');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: const Text('Triage Analysis', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _result == null ? _buildLoader() : _buildContent(),
    );
  }

  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AvatarGlow(
            glowColor: const Color(0xFF0F766E),
            duration: const Duration(milliseconds: 1500),
            repeat: true,
            child: Container(
              width: 140, height: 140,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF0F766E).withOpacity(0.1)),
              child: const Icon(Icons.auto_awesome, color: Color(0xFF0F766E), size: 60),
            ),
          ),
          const SizedBox(height: 30),
          const Text("AI is analyzing your symptoms...", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 10),
          Text(_error ?? "Checking medical guidelines...", style: TextStyle(color: _error != null ? Colors.red : Colors.grey)),
          if (_error != null) TextButton(onPressed: () => setState(() { _error = null; _fetchTriage(); }), child: const Text("Retry"))
        ],
      ),
    );
  }

  Widget _buildContent() {
    Color color = _getSeverityColor(_result!.severity);
    bool isEmergency = _result!.severity.toUpperCase() == 'RED' || _result!.severity.toUpperCase() == 'YELLOW';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Severity Circle
          Container(
            width: 180, height: 180,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.1), boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 30)]),
            child: Center(
              child: Container(
                width: 140, height: 140,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_result!.severity.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    const Text("ALERT", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          
          // Advice Card with Audio Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [Icon(Icons.medical_services, color: color), const SizedBox(width: 10), const Text("Medical Advice", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
                    
                    GestureDetector(
                      onTap: _isSpeaking ? () => _flutterTts.stop() : _speakResult,
                      child: AvatarGlow(
                        animate: _isSpeaking,
                        glowColor: color,
                        duration: const Duration(milliseconds: 1000),
                        child: Icon(
                          _isSpeaking ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
                          color: color,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30),
                Text(_result!.action, style: const TextStyle(fontSize: 17, height: 1.5, fontWeight: FontWeight.w500, color: Colors.black87)),
              ],
            ),
          ),
          
          const SizedBox(height: 20),

          // EMERGENCY ACTIONS UI
          if (isEmergency) ...[
            const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                SizedBox(width: 8),
                Text("Emergency Actions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
              ],
            ),
            const SizedBox(height: 15),
            
            // Map Button
            ElevatedButton.icon(
              onPressed: _openMaps,
              icon: const Icon(Icons.local_hospital, color: Colors.white),
              label: const Text("Find Nearest Hospital", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 12),
            
            // Call & SMS Row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _callAmbulance,
                    icon: const Icon(Icons.call, color: Colors.white),
                    label: const Text("108", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _alertFamily,
                    icon: const Icon(Icons.message, color: Colors.white),
                    label: const Text("Family", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // DOCTOR HANDOVER SUMMARY CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50, 
                borderRadius: BorderRadius.circular(20), 
                border: Border.all(color: Colors.blue.shade200)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.badge, color: Colors.blue),
                      SizedBox(width: 8),
                      Text("Doctor Handover Summary", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                  const Divider(height: 25),
                  Text("AI Triage: ${_result!.severity.toUpperCase()} ALERT", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 10),
                  Text("Patient: ${ApiService.currentPatientProfile?['name'] ?? 'N/A'} (${ApiService.currentPatientProfile?['age'] ?? '-'} yrs, ${ApiService.currentPatientProfile?['gender'] ?? '-'})", style: const TextStyle(fontSize: 14)),
                  Text("Blood Group: ${ApiService.currentPatientProfile?['blood_group'] ?? 'N/A'}", style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 10),
                  const Text("Critical Info:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text("Conditions: ${(ApiService.currentPatientProfile?['chronic_conditions'] as List?)?.join(', ') ?? 'None'}", style: const TextStyle(fontSize: 14)),
                  Text("Allergies: ${(ApiService.currentPatientProfile?['allergies'] as List?)?.join(', ') ?? 'None'}", style: const TextStyle(fontSize: 14, color: Colors.redAccent, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          
          // Disclaimer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade200)),
            child: const Text("Disclaimer: This is an AI assessment based on medical protocols. Consult a doctor for definitive diagnosis.", style: TextStyle(fontSize: 12, color: Colors.orange)),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// PREMIUM TRANSITION LOGIC
// ==========================================
class PremiumPageTransition extends PageRouteBuilder {
  final Widget page;

  PremiumPageTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
}