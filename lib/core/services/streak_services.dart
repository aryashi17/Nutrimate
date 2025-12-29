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
    if (uid == null) {
      print('StreakService: User not authenticated, skipping streak update');
      return;
    }

    try {
      final userDoc = _db.collection('users').doc(uid);
      final snapshot = await userDoc.get();
      
      if (!snapshot.exists) {
        print('StreakService: Creating new user document');
        await userDoc.set({'streak': 1, 'lastLogDate': DateTime.now().toIso8601String()});
        return;
      }

      final data = snapshot.data();
      if (data == null) {
        print('StreakService: User document exists but data is null, creating new streak');
        await userDoc.set({'streak': 1, 'lastLogDate': DateTime.now().toIso8601String()});
        return;
      }

      final lastLogDateStr = data['lastLogDate'];
      if (lastLogDateStr == null) {
        print('StreakService: No lastLogDate found, setting initial streak');
        await userDoc.update({
          'streak': 1,
          'lastLogDate': DateTime.now().toIso8601String(),
        });
        return;
      }

      DateTime lastLog = DateTime.parse(lastLogDateStr);
      DateTime now = DateTime.now();
      int currentStreak = data['streak'] ?? 0;

      // Check if the last log was yesterday
      final difference = now.difference(lastLog).inDays;

      if (difference == 1) {
        // Logged yesterday, increment streak
        print('StreakService: Incrementing streak to ${currentStreak + 1}');
        await userDoc.update({
          'streak': currentStreak + 1,
          'lastLogDate': now.toIso8601String(),
        });
      } else if (difference > 1) {
        // Missed a day, reset streak
        print('StreakService: Resetting streak (missed $difference days)');
        await userDoc.update({
          'streak': 1,
          'lastLogDate': now.toIso8601String(),
        });
      } else {
        // Same day or future date, just update the timestamp
        print('StreakService: Same day log, updating timestamp only');
        await userDoc.update({
          'lastLogDate': now.toIso8601String(),
        });
      }
    } catch (e) {
      print('StreakService: Error updating streak: $e');
      // Don't rethrow - we don't want food logging to fail because of streak issues
    }
  }
}