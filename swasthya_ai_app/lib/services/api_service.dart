import 'package:dio/dio.dart';
import '../models/triage_model.dart';

class ApiService {
  final Dio _dio = Dio();
  
  // REPLACE '192.168.x.x' with your actual Laptop IP Address
final String _apiUrl = "http://10.132.200.129:8000/api/triage";

  Future<TriageModel> getTriageResult(String symptoms, String language) async {
    try {
      final response = await _dio.post(
        _apiUrl,
        data: {
          "text": symptoms,
          "language": language,
        },
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
}