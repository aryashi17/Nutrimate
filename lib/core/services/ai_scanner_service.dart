import 'dart:convert';
import 'package:http/http.dart' as http;

class AiScannerService {
  Future<Map<String, dynamic>> analyzeFood({
    required String input,
  }) async {
    final url = Uri.parse(
      "https://us-central1-nutimate-app.cloudfunctions.net/analyzeFood",
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "input": input,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("AI Food analysis failed");
    }

    return jsonDecode(response.body);
  }
}
