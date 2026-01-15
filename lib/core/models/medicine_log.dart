import 'package:cloud_firestore/cloud_firestore.dart';

enum MedicineLogStatus { taken, skipped, missed }

class MedicineLog {
  final String scheduledKey;
  final String id;
  final String medicineId;
  final String medicineName;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final MedicineLogStatus status;
  final String dateKey; // yyyy-MM-dd

  MedicineLog({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.scheduledTime,
    this.takenTime,
    required this.status,
    required this.dateKey,
    required this.scheduledKey,
  });

  factory MedicineLog.fromMap(String id, Map<String, dynamic> data) {
    return MedicineLog(
      id: id,
      medicineId: data['medicineId'],
      medicineName: data['medicineName'],
      scheduledTime: (data['scheduledTime'] as Timestamp).toDate(),
      takenTime: data['takenTime'] != null
          ? (data['takenTime'] as Timestamp).toDate()
          : null,
      status: MedicineLogStatus.values.firstWhere(
        (e) => e.name == data['status'],
      ),
      dateKey: data['dateKey'],
      scheduledKey: data['scheduledKey'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicineId': medicineId,
      'medicineName': medicineName,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'takenTime': takenTime != null ? Timestamp.fromDate(takenTime!) : null,
      'status': status.name,
      'dateKey': dateKey,
      'scheduledKey' : scheduledKey,
    };
  }
}
