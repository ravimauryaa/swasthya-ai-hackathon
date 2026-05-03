// lib/services/api_service.dart
import 'package:dio/dio.dart';
import '../models/triage_model.dart';

class ApiService {
  // GLOBAL VARIABLE: Yeh ABHA aur Home screen ke beech data share karega
  static Map<String, dynamic>? currentPatientProfile;

  final Dio _dio = Dio();
  
  // REPLACE with your actual Laptop IP Address
final String _apiUrl = "https://unsent-yearbook-grub.ngrok-free.dev";

  // METHOD 1: Fetch ABHA Profile
  Future<Map<String, dynamic>?> fetchPatientHistory(String abhaId) async {
    try {
      final response = await _dio.get("$_apiUrl/api/v1/abha/patient/$abhaId");
      if (response.statusCode == 200) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print("ABHA Fetch Error: $e");
      return null;
    }
  }

  // METHOD 2: Triage Result (Phase 1 to 5)
  Future<TriageModel> getTriageResult(String symptoms, String language, {Map<String, dynamic>? patientHistory}) async {
    try {
      // Build dynamic payload
      Map<String, dynamic> payload = {
        "text": symptoms,
        "language": language,
      };
      
      // Inject history if available
      if (patientHistory != null) {
        payload["patient_history"] = patientHistory;
      }

      final response = await _dio.post(
        "$_apiUrl/api/triage",
        data: payload,
      );

      if (response.statusCode == 200) {
        var aiData = response.data['ai_response'];
        return TriageModel(
          severity: aiData['severity'],
          action: aiData['action'],
        );
      } else {
        throw Exception('Server Error');
      }
    } catch (e) {
      print("Local Connection Error: $e");
      return TriageModel(
        severity: "GREEN",
        action: "Check if Laptop Server is running and IP is correct.",
      );
    }
  }

  // ==========================================
  // PHASE 6: CONSULTATION SCRIBE METHOD
  // ==========================================
  Future<String?> generateScribeReport(String transcript, String language) async {
    try {
      // Build payload for scribe
      Map<String, dynamic> payload = {
        "transcript": transcript,
        "language": language,
      };

      // Inject ABHA history if available (taaki Doctor ko purani bimariyan pata chal jaye)
      if (currentPatientProfile != null) {
        payload["patient_history"] = currentPatientProfile;
      }

      final response = await _dio.post(
        "$_apiUrl/generate_scribe",
        data: payload,
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return response.data['scribe_report'];
      } else {
        print("Scribe Server Error: ${response.data}");
        return null;
      }
    } catch (e) {
      print("Scribe API Connection Error: $e");
      return null;
    }
  }
}