import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/sick_bay_result.dart';
import './mess_menu_service.dart';

class SickBayService {
  final MessMenuService _menuService = MessMenuService();

  /// Get today's menu as a flat list of food names
  Future<List<String>> getTodaysMenu() async {
    final menuMap = await _menuService.getTodayMenu();

    return menuMap.values
        .expand((mealList) => mealList)
        .map((item) => item['name'] as String)
        .toList();
  }

  /// Analyze sickness using Cloud Function
  Future<SickBayResult> analyzeSickness({
    required String description,
    required List<String> selectedAilments,
    required List<String> todaysMenu,
  }) async {
    final url = Uri.parse(
      "https://us-central1-nutimate-app.cloudfunctions.net/analyzeSickness",
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "description": description,
        "ailments": selectedAilments,
        "nextMeal": todaysMenu,
      }),
    );

    final data = jsonDecode(response.body);

    return SickBayResult(
      severity: data["severity"],
      eat: List<String>.from(data["eat"]),
      avoid: List<String>.from(data["avoid"]),
      care: List<String>.from(data["care"]),
    );
  }
}
