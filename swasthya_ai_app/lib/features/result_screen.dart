// lib/features/result_screen.dart
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter_tts/flutter_tts.dart'; // 👈 Naya import
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
  final FlutterTts _flutterTts = FlutterTts(); // 👈 TTS Instance
  
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
    _flutterTts.stop(); // 👈 Screen band hote hi aawaz band
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
      
      // 🔊 AUTO-SPEAK LOGIC: Result aate hi bolna shuru karo
      _speakResult();
    } catch (e) {
      setState(() => _error = "Connection failed. Please try again.");
    }
  }

  Future<void> _speakResult() async {
    if (_result == null) return;

    // Language set karo (Hindi/English)
    await _flutterTts.setLanguage(widget.language == 'Hindi' ? "hi-IN" : "en-US");
    await _flutterTts.setPitch(1.0);
    
    // Kya bolna hai: Severity + Action
    String speechText = "${_result!.severity} Alert. ${_result!.action}";
    await _flutterTts.speak(speechText);
  }

  Color _getSeverityColor(String s) {
    if (s.toUpperCase() == 'RED') return Colors.red.shade600;
    if (s.toUpperCase() == 'YELLOW') return Colors.orange.shade500;
    return Colors.green.shade600;
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
                    
                    // 🎧 Elegant Speaker Icon
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