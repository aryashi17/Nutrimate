import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine {
  final String id;
  final String name;
  final String dosage;
  final List<String> times; // ["08:00", "14:00"]
  final DateTime startDate;
  final DateTime? endDate;
  final String instructions;
  final bool isActive;

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.times,
    required this.startDate,
    this.endDate,
    required this.instructions,
    required this.isActive,
  });

  // 🔹 Firestore → Dart
  factory Medicine.fromMap(String id, Map<String, dynamic> data) {
    return Medicine(
      id: id,
      name: data['name'],
      dosage: data['dosage'],
      times: List<String>.from(data['times']),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate:
          data['endDate'] != null
              ? (data['endDate'] as Timestamp).toDate()
              : null,
      instructions: data['instructions'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }

  // 🔹 Dart → Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'times': times,
      'startDate': Timestamp.fromDate(startDate),
      'endDate':
          endDate != null ? Timestamp.fromDate(endDate!) : null,
      'instructions': instructions,
      'isActive': isActive,
    };
  }
}
