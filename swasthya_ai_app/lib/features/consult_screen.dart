// lib/features/consult_screen.dart
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/api_service.dart'; // 👈 API Service import kar li

class ConsultScreen extends StatefulWidget {
  const ConsultScreen({super.key});

  @override
  State<ConsultScreen> createState() => _ConsultScreenState();
}

class _ConsultScreenState extends State<ConsultScreen> {
  final TextEditingController _transcriptController = TextEditingController();
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  bool _isGenerating = false; // 👈 Loading state ke liye
  String _selectedLocaleId = 'en_US'; 

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (errorNotification) => debugPrint('Error: $errorNotification'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (result) {
            setState(() {
              _transcriptController.text = result.recognizedWords; 
            });
          },
          localeId: _selectedLocaleId,
          pauseFor: const Duration(seconds: 10), 
        );
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
    }
  }

  // ==========================================
  // PHASE 6: API CALL & DOCTOR HANDOVER
  // ==========================================
  Future<void> _generateMedicalScribe() async {
    if (_transcriptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your complete problem first.')),
      );
      return;
    }

    setState(() {
      _isGenerating = true; // Button par loader ghumayenge
    });

    String language = _selectedLocaleId == 'hi_IN' ? 'Hindi' : 'English';
    
    // API Call to Local Backend
    String? report = await ApiService().generateScribeReport(
      _transcriptController.text,
      language,
    );

    setState(() {
      _isGenerating = false;
    });

    if (report != null) {
      _showDoctorHandoverSheet(report);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate summary. Check server connection.')),
        );
      }
    }
  }

  // Bottom Sheet for Doctor (Premium UX)
  void _showDoctorHandoverSheet(String report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85, // Screen ka 85% cover karega
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Handlebar
            Center(
              child: Container(
                width: 50, height: 5, 
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))
              ),
            ),
            const SizedBox(height: 20),
            
            // Header
            const Row(
              children: [
                Icon(Icons.medical_information, color: Color(0xFF0F766E), size: 28),
                SizedBox(width: 10),
                Text("Doctor Handover Summary", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F766E))),
              ],
            ),
            const Divider(height: 30),
            
            // The AI Generated HPI Report
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  report,
                  style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Export Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                   Navigator.pop(context);
                   // Future integration: use url_launcher to open WhatsApp here
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Format copied! Ready to share.")));
                },
                icon: const Icon(Icons.share, color: Colors.white),
                label: const Text("Share to Doctor", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            const Text(
              "Smart Patient Intake",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
            ),
            const SizedBox(height: 8),
            const Text(
              "Tell us everything. Our AI will create a professional medical summary for your doctor.",
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
            ),
            const SizedBox(height: 40),

            // The "Rant Room" Mic Section
            Center(
              child: Column(
                children: [
                  AvatarGlow(
                    animate: _isListening,
                    glowColor: const Color(0xFF0F766E),
                    duration: const Duration(milliseconds: 2000),
                    repeat: true,
                    child: GestureDetector(
                      onTap: _listen,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: _isListening 
                                ? [Colors.blueAccent, Colors.blue] 
                                : [const Color(0xFF14B8A6), const Color(0xFF0F766E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _isListening ? Colors.blue.withOpacity(0.4) : const Color(0xFF0F766E).withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            )
                          ]
                        ),
                        child: Icon(
                          _isListening ? Icons.graphic_eq : Icons.mic_rounded,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isListening ? "Listening to your story..." : "Tap to start telling your problem",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _isListening ? Colors.blue : Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Language Toggle
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLanguageTab('Hindi', 'hi_IN'),
                    _buildLanguageTab('English', 'en_US'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Transcript Box 
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.edit_note, color: Colors.grey),
                      SizedBox(width: 8),
                      Text("Your Story (Edit if needed)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    ],
                  ),
                  const Divider(height: 25),
                  TextField(
                    controller: _transcriptController,
                    maxLines: 8, 
                    style: const TextStyle(fontSize: 16, height: 1.5),
                    decoration: const InputDecoration(
                      hintText: "E.g., I have been having severe stomach pain since last night. I also vomited twice in the morning...", 
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Generate Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateMedicalScribe,
                icon: _isGenerating 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.auto_awesome, color: Colors.white),
                label: Text(
                  _isGenerating ? "Analyzing Medical Data..." : "Generate Doctor Summary", 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  disabledBackgroundColor: const Color(0xFF0F766E).withOpacity(0.7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                  shadowColor: const Color(0xFF0F766E).withOpacity(0.5),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTab(String title, String localeId) {
    bool isSelected = _selectedLocaleId == localeId;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLocaleId = localeId;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F766E) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}