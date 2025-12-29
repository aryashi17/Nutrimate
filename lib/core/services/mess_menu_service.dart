import 'package:cloud_firestore/cloud_firestore.dart';

class MessMenuService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _getTodayName() {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];
    return days[DateTime.now().weekday - 1];
  }

  Future<Map<String, List<Map<String, dynamic>>>> getTodayMenu() async {
    final day = _getTodayName();

    final snap = await _db
        .collection('mess_menu')
        .doc('week_2025_01')
        .collection(day)
        .doc(day)
        .get();

    if (!snap.exists) {
      throw Exception("Menu not found for today");
    }

    final data = snap.data()!;

    return {
      'Breakfast': List<Map<String, dynamic>>.from(data['breakfast']),
      'Lunch': List<Map<String, dynamic>>.from(data['lunch']),
      'Dinner': List<Map<String, dynamic>>.from(data['dinner']),
      'Snacks': [], // keep UI happy
    };
  }
}
