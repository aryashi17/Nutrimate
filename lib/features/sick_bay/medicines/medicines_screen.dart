import 'package:flutter/material.dart';

import '../../../core/models/medicine.dart';
import '../../../core/services/medicine_service.dart';
import 'add_medicine_screen.dart';
import '../../../core/services/medicine_log_service.dart';
import '../../../core/models/medicine_log.dart';


class MedicinesScreen extends StatefulWidget {
  const MedicinesScreen({super.key});

  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  final MedicineService _service = MedicineService();

  final List<Medicine> _medicines = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  String _todayKey() {
  final now = DateTime.now();
  return "${now.year}-"
      "${now.month.toString().padLeft(2, '0')}-"
      "${now.day.toString().padLeft(2, '0')}";
}

Future<void> _generateTodayLogs(List<Medicine> medicines) async {
  final logService = MedicineLogService();
  final today = DateTime.now();
  final dateKey = _todayKey();

  for (final med in medicines) {
    // Skip inactive medicines
    if (!med.isActive) continue;

    // Skip expired medicines
    if (med.endDate != null && med.endDate!.isBefore(today)) continue;

    for (final time in med.times) {
      final parts = time.split(':');

      final scheduledTime = DateTime(
        today.year,
        today.month,
        today.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      final log = MedicineLog(
        id: '',
        medicineId: med.id,
        medicineName: med.name,
        scheduledTime: scheduledTime,
        takenTime: null,
        status: MedicineLogStatus.missed, // default
        dateKey: dateKey,
      );

      await logService.createLog(log);
    }
  }
}

Future<void> _ensureTodayLogs(List<Medicine> medicines) async {
  final logService = MedicineLogService();
  final dateKey = _todayKey();

  final exists = await logService.logsExistForDate(dateKey);
  if (exists) return;

  await _generateTodayLogs(medicines);
}




  // ─────────────────────────────────────

  Future<void> _loadMedicines() async {
    final meds = await _service.getMedicines();

    // 🔥 STEP 13 ACTUALLY RUNS HERE
    await _ensureTodayLogs(meds);

    setState(() {
      _medicines
        ..clear()
        ..addAll(meds);
      _loading = false;
    });
  }


  // ─────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Medicines"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFAAF0D1),
        onPressed: _openAddMedicine,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _medicines.isEmpty
              ? _emptyState()
              : _medicineList(),
    );
  }

  // ─────────────────────────────────────

  Future<void> _openAddMedicine() async {
    final medicine = await Navigator.push<Medicine>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddMedicineScreen(),
      ),
    );

    if (medicine == null) return;

    await _service.addMedicine(medicine);
    await _loadMedicines();
  }

  // ─────────────────────────────────────

  Future<void> _editMedicine(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddMedicineScreen(
          medicine: _medicines[index],
        ),
      ),
    );

    if (result == null) return;

    if (result == 'delete') {
      await _service.deleteMedicine(_medicines[index].id);
    } else if (result is Medicine) {
      await _service.updateMedicine(result);
    }

    await _loadMedicines();
  }

  // ─────────────────────────────────────

  Widget _emptyState() {
    return const Center(
      child: Text(
        "No medicines added yet",
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  // ─────────────────────────────────────

  Widget _medicineList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _medicines.length,
      itemBuilder: (context, index) {
        final med = _medicines[index];

        return GestureDetector(
          onTap: () => _editMedicine(index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  med.dosage,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: med.times.map((time) {
                    return Chip(
                      label: Text(
                        time,
                        style: const TextStyle(color: Colors.black),
                      ),
                      backgroundColor: const Color(0xFFAAF0D1),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
