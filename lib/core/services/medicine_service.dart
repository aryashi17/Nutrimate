import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/medicine.dart';

class MedicineService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('users').doc(_uid).collection('medicines');

  // ─────────────── CRUD ───────────────

  Future<List<Medicine>> getMedicines() async {
    final snap = await _collection.orderBy('startDate').get();

    return snap.docs
        .map((doc) => Medicine.fromMap(doc.id, doc.data()))
        .toList();
  }

    Future<void> addMedicine(Medicine medicine) async {
      final doc = await _collection.add(medicine.toMap());
      await doc.update({'id': doc.id}); // optional but useful
    }


  Future<void> updateMedicine(Medicine medicine) async {
    await _collection.doc(medicine.id).update(medicine.toMap());
  }

  Future<void> deleteMedicine(String id) async {
    await _collection.doc(id).delete();
  }
}
