import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey = 'AIzaSyCQCJR1iPYDGxlWvlCA4S9bywbFgXo4P8w'; // Replace with your API key

  final String endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';


  Future<String> sendMessage(String prompt) async {
    final uri = Uri.parse('$endpoint?key=$apiKey');
    final message = "Explain '$prompt' in a short but informative way for quick understanding.";

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": message}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('Gemini API error: ${response.body}');
    }
  }
}
