import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getHistory(int days) async {
    // 1. SAFE UID CHECK: Get the ID inside the method, not at the top
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return []; // Return empty list instead of crashing

    try {
      DateTime threshold = DateTime.now().subtract(Duration(days: days));
      
      // 2. QUERY: Fetch logs for the specific user
      QuerySnapshot snapshot = await _db.collection('users')
          .doc(user.uid)
          .collection('logs')
          .where('timestamp', isGreaterThan: threshold.toIso8601String())
          .orderBy('timestamp', descending: false) // Important for chart order
          .get();

      // 3. SAFE MAPPING: Ensure data exists before returning
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Fallback values to prevent chart crashes
        return {
          'totalProtein': data['totalProtein'] ?? 0.0,
          'water': data['water'] ?? 0.0,
          'timestamp': data['timestamp'] ?? '',
          'dateLabel': data['dateLabel'] ?? '',
        };
      }).toList();
    } catch (e) {
      print("Error fetching history: $e");
      return []; // Return empty list on error to keep UI stable
    }
  }
}