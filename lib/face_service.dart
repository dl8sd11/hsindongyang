import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class FaceRecognitionService {
  // API Key for accessing Eden AI services. Replace with your actual API key.
  static final String _apiKey =
      'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNTVjZGJiMzQtNzMyNi00MDI2LWI5ODgtZGRlYWY2MWIwN2YwIiwidHlwZSI6ImFwaV90b2tlbiJ9.FIU423RL25HWm3LMmf03W1V1iOzk6PSgoHbl-sf69VQ';

  // URL for the Eden AI "add face" endpoint
  static const String _addFaceUrl =
      'https://api.edenai.run/v2/image/face_recognition/add_face';

  // URL for the Eden AI "recognize face" endpoint
  static const String _recognizeUrl =
      'https://api.edenai.run/v2/image/face_recognition/recognize';

  // Function to add a face to the recognition service using a URL
  Future<void> addFace(String faceUrl, String provider) async {
    // Create payload for the request
    final payload = {
      'providers': provider,
      'file_url': faceUrl,
    };

    // Define headers for the request
    final headers = {
      'Authorization': _apiKey,
      'Content-Type': 'application/json',
    };

    // Send POST request to the "add face" endpoint
    final response = await http.post(
      Uri.parse(_addFaceUrl),
      headers: headers,
      body: jsonEncode(payload),
    );

    // Check if the request was successful
    if (response.statusCode != 200) {
      throw Exception('Failed to add face: ${response.body}');
    }
  }

  // Function to recognize faces in an image using a URL
  Future<Map<String, dynamic>> recognizeFaces(
      String faceUrl, String provider) async {
    // Create payload for the request
    final payload = {
      'providers': provider,
      'file_url': faceUrl,
    };

    // Define headers for the request
    final headers = {
      'Authorization': _apiKey,
      'Content-Type': 'application/json',
    };
    print(payload);

    // Send POST request to the "recognize face" endpoint
    final response = await http.post(
      Uri.parse(_recognizeUrl),
      headers: headers,
      body: jsonEncode(payload),
    );

    // Check if the request was successful
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to recognize faces: ${response.body}');
    }
  }
}
