import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenRouterService {
 
  final String googleKey = "AIzaSyA4rVo9PHZQNFmtvpB-M03xJcoEJtWxUAs"; 
  
  final String openRouterKey = "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"; 
  final String appName = "NutriMate";
  final String siteUrl = "https://nutrimate.app";

  // 📋 LIST 1: GOOGLE MODELS (Tried first, in order)
  final List<String> googleModels = [
    "gemini-1.5-flash",          // Fast & Stable
    "gemini-1.5-flash-8b",       // Super Fast
    "gemini-1.5-pro",            // Smarter (if flash fails)
    "gemini-2.0-flash-exp",      ];

  // 📋 LIST 2: OPENROUTER MODELS (Tried if ALL Google models fail)
  final List<String> openRouterModels = [
    "meta-llama/llama-3-8b-instruct:free",
    "microsoft/phi-3-mini-128k-instruct:free",
    "google/gemini-2.0-flash-lite-preview-02-05:free",
    "mistralai/mistral-7b-instruct:free",
  ];

  Future<Map<String, dynamic>?> analyzeFood(String userInput) async {
    // ------------------------------------------------------
    // 🥇 PHASE 1: TRY DIRECT GOOGLE MODELS LOOP
    // ------------------------------------------------------
    print("🚀 PHASE 1: Trying Direct Google API Models...");
    
    for (String model in googleModels) {
      try {
        print("   👉 Trying Google Model: $model...");
        final result = await _callGoogleDirect(userInput, model);
        if (result != null) {
          print("   ✅ Success with Google ($model)!");
          return result;
        }
      } catch (e) {
        print("   ⚠️ Google ($model) failed. Trying next...");
      }
    }

    // ------------------------------------------------------
    // 🥈 PHASE 2: TRY OPENROUTER MODELS LOOP (Fallback)
    // ------------------------------------------------------
    print("🔻 PHASE 2: Google failed. Switching to OpenRouter Fallbacks...");

    for (String model in openRouterModels) {
      try {
        print("   👉 Trying OpenRouter Model: $model...");
        final result = await _callOpenRouter(userInput, model);
        if (result != null) {
          print("   ✅ Success with OpenRouter ($model)!");
          return result;
        }
      } catch (e) {
        print("   ⚠️ OpenRouter ($model) failed/busy. Trying next...");
      }
    }

    // ------------------------------------------------------
    // 💀 PHASE 3: TOTAL FAILURE
    // ------------------------------------------------------
    print("❌ FATAL: Every single AI model failed.");
    return null;
  }

  // --- HELPER: GOOGLE DIRECT LOGIC ---
  Future<Map<String, dynamic>?> _callGoogleDirect(String input, String modelName) async {
    // Dynamically insert the model name into the URL
    final url = 'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$googleKey';
    
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [{
          "parts": [{"text": _buildPrompt(input)}]
        }]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Check if candidates exist
      if (data['candidates'] == null || (data['candidates'] as List).isEmpty) {
        throw Exception("No candidates returned");
      }
      String text = data['candidates'][0]['content']['parts'][0]['text'];
      return _cleanAndParseJson(text);
    } else {
      throw Exception("Google Error ${response.statusCode}");
    }
  }

  // --- HELPER: OPENROUTER LOGIC ---
  Future<Map<String, dynamic>?> _callOpenRouter(String input, String modelName) async {
    final response = await http.post(
      Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $openRouterKey',
        'HTTP-Referer': siteUrl,
        'X-Title': appName,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": modelName,
        "messages": [
          {"role": "system", "content": "You are a nutritionist API. Return ONLY valid JSON."},
          {"role": "user", "content": _buildPrompt(input)}
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String text = data['choices'][0]['message']['content'];
      return _cleanAndParseJson(text);
    } else {
      throw Exception("OpenRouter Error ${response.statusCode}");
    }
  }

  // --- SHARED PROMPT ---
  String _buildPrompt(String input) {
    return """
    Analyze this food: "$input".
    Return ONLY a JSON object (no Markdown, no comments).
    Structure:
    {
      "meal": "Snacks",
      "food": {
        "name": "Food Name",
        "calories": 100,
        "protein": 0.0,
        "carbs": 0.0,
        "fat": 0.0
      }
    }
    Default meal to "Snacks".
    """;
  }

  // --- SHARED CLEANUP ---
  Map<String, dynamic>? _cleanAndParseJson(String rawText) {
    try {
      String clean = rawText.replaceAll('```json', '').replaceAll('```', '').trim();
      return jsonDecode(clean);
    } catch (e) {
      print("JSON Parse Error: $e");
      return null;
    }
  }
}