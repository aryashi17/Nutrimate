import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/medicine_log.dart';

class MedicineLogService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('users').doc(_uid).collection('medicine_logs');

  // ───────── CREATE LOG ─────────

  Future<void> createLog(MedicineLog log) async {
    await _collection.add(log.toMap());
  }

  // ───────── UPDATE STATUS ─────────

  Future<void> updateStatus({
    required String logId,
    required MedicineLogStatus status,
  }) async {
    await _collection.doc(logId).update({
      'status': status.name,
      'takenTime':
          status == MedicineLogStatus.taken ? Timestamp.now() : null,
    });
  }

  // ───────── QUERY BY DAY ─────────

  Future<List<MedicineLog>> getLogsByDate(String dateKey) async {
    final snap = await _collection
        .where('dateKey', isEqualTo: dateKey)
        .orderBy('scheduledTime')
        .get();

    return snap.docs
        .map((d) => MedicineLog.fromMap(d.id, d.data()))
        .toList();
  }

  // ───────── QUERY BY MEDICINE ─────────

  Future<List<MedicineLog>> getLogsByMedicine(String medicineId) async {
    final snap = await _collection
        .where('medicineId', isEqualTo: medicineId)
        .orderBy('scheduledTime', descending: true)
        .get();

    return snap.docs
        .map((d) => MedicineLog.fromMap(d.id, d.data()))
        .toList();
  }

 Future<bool> logExists({
  required String medicineId,
  required String dateKey,
  required String scheduledKey,
}) async {
  final snap = await _collection
      .where('medicineId', isEqualTo: medicineId)
      .where('dateKey', isEqualTo: dateKey)
      .where('scheduledKey', isEqualTo: scheduledKey)
      .limit(1)
      .get();

  return snap.docs.isNotEmpty;
}



}
