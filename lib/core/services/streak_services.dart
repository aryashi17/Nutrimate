import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StreakService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  // Stream to listen to streak changes in real-time
  Stream<int> get streakStream {
    if (uid == null) return Stream.value(0);
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      return snapshot.data()?['streak'] ?? 0;
    });
  }

  // Call this function whenever food is logged in MessLoggerScreen
  Future<void> updateStreak() async {
    if (uid == null) return;

    final userDoc = _db.collection('users').doc(uid);
    final snapshot = await userDoc.get();
    
    if (!snapshot.exists) {
      await userDoc.set({'streak': 1, 'lastLogDate': DateTime.now().toIso8601String()});
      return;
    }

    final data = snapshot.data()!;
    DateTime lastLog = DateTime.parse(data['lastLogDate']);
    DateTime now = DateTime.now();
    int currentStreak = data['streak'] ?? 0;

    // Check if the last log was yesterday
    final difference = now.difference(lastLog).inDays;

    if (difference == 1) {
      // Logged yesterday, increment streak
      await userDoc.update({
        'streak': currentStreak + 1,
        'lastLogDate': now.toIso8601String(),
      });
    } else if (difference > 1) {
      // Missed a day, reset streak
      await userDoc.update({
        'streak': 1,
        'lastLogDate': now.toIso8601String(),
      });
    }
  }
}