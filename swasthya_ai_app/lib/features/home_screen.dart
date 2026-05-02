// lib/features/home_screen.dart
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/triage_model.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  // Removed const to allow rebuilding when tab switches
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _symptomController = TextEditingController();
  
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _selectedLocaleId = 'en_US'; 
  bool _isLoading = false;

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
              _symptomController.text = result.recognizedWords;
            });
          },
          localeId: _selectedLocaleId,
          pauseFor: const Duration(seconds: 3), 
        );
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
    }
  }

  Future<void> _analyzeSymptoms() async {
    if (_symptomController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_selectedLocaleId == 'hi_IN' ? 'कृपया पहले अपने लक्षण बताएं।' : 'Please describe your symptoms first.')),
      );
      return;
    }

    FocusScope.of(context).unfocus(); 
    setState(() => _isLoading = true);

    try {
      String requestedLanguage = _selectedLocaleId == 'hi_IN' ? 'Hindi' : 'English';
      
      // Global Profile Data Backend Ko Bheja Ja Raha Hai
      TriageModel result = await _apiService.getTriageResult(
        _symptomController.text, 
        requestedLanguage,
        patientHistory: ApiService.currentPatientProfile, 
      );
      
      setState(() => _isLoading = false);

      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(triageResult: result),
          ),
        );
        setState(() {
          _symptomController.clear();
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error connecting to AI. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if profile is linked
    bool isProfileLinked = ApiService.currentPatientProfile != null;

    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: Color(0xFF0F766E),
                          child: Icon(Icons.person, color: Colors.white), 
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // DYNAMIC NAME LOGIC
                            Text(
                              _selectedLocaleId == 'hi_IN' 
                                  ? "नमस्ते, ${isProfileLinked ? ApiService.currentPatientProfile!['name'].split(' ')[0] : 'उपयोगकर्ता'}" 
                                  : "Namaste, ${isProfileLinked ? ApiService.currentPatientProfile!['name'].split(' ')[0] : 'User'}",
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87),
                            ),
                            Text(
                              "Greeting, your home dashboard",
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
                      onPressed: () {},
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),

                // DYNAMIC BADGE LOGIC
                if (isProfileLinked)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_user, color: Colors.green, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "Linked: ${ApiService.currentPatientProfile!['name']}",
                          style: TextStyle(
                            color: Colors.green.shade800, 
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 30),

                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
                    ]
                  ),
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
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: _isListening 
                                    ? [Colors.redAccent, Colors.red] 
                                    : [const Color(0xFF14B8A6), const Color(0xFF0F766E)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _isListening ? Colors.red.withOpacity(0.4) : const Color(0xFF0F766E).withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                )
                              ]
                            ),
                            child: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: Colors.white,
                              size: 45,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _selectedLocaleId == 'hi_IN' ? 'बोलने के लिए माइक टैप करें' : 'Tap to Speak Symptoms',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isListening 
                            ? (_selectedLocaleId == 'hi_IN' ? 'सुन रहा हूँ...' : 'Listening...') 
                            : (_selectedLocaleId == 'hi_IN' ? 'मुझे बुखार और खांसी है' : 'e.g. I have a fever and cough'),
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLanguageTab('Hindi', 'hi_IN'),
                      _buildLanguageTab('English', 'en_US'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4).withOpacity(0.5), 
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF14B8A6).withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Chat transcript",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _symptomController,
                        maxLines: 3, 
                        style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: _selectedLocaleId == 'hi_IN' ? "यहाँ अपने लक्षण टाइप करें..." : "Or type your symptoms here...", 
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 100), 
              ],
            ),
          ),

          Positioned(
            bottom: 20,
            left: 24,
            right: 24,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _analyzeSymptoms,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                  shadowColor: const Color(0xFF0F766E).withOpacity(0.5),
                ),
                child: _isLoading 
                    ? const SizedBox(
                        height: 24, width: 24, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : Text(
                        _selectedLocaleId == 'hi_IN' ? "लक्षणों का विश्लेषण करें" : "Analyze Symptoms", 
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTab(String title, String localeId) {
    bool isSelected = _selectedLocaleId == localeId;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLocaleId = localeId;
          _symptomController.clear();
          if (_isListening) {
            _isListening = false;
            _speechToText.stop();
          }
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