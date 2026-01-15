import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import '../../../core/models/medicine_log.dart';
import '../../../core/services/medicine_log_service.dart';

class TodayMedicinesScreen extends StatefulWidget {
  const TodayMedicinesScreen({super.key});

  @override
  State<TodayMedicinesScreen> createState() => _TodayMedicinesScreenState();
}

class _TodayMedicinesScreenState extends State<TodayMedicinesScreen> {

  int get _takenCount =>
    _logs.where((l) => l.status == MedicineLogStatus.taken).length;

  int get _totalCount => _logs.length;

  double get _progress =>
      _totalCount == 0 ? 0 : _takenCount / _totalCount;

  final MedicineLogService _logService = MedicineLogService();

  List<MedicineLog> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayLogs();
  }

  // ─────────────────────────────────────

  String _todayKey() {
    final now = DateTime.now();
    return "${now.year}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.day.toString().padLeft(2, '0')}";
  }

  Future<void> _loadTodayLogs() async {
    try {
      final logs = await _logService.getLogsByDate(_todayKey());

      setState(() {
        _logs = logs;
        _loading = false;
      });
    } catch (e) {
      debugPrint("Error loading today's logs: $e");

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load today's medicines")),
      );
    }
  }

  // ─────────────────────────────────────

  Future<void> _updateStatus(MedicineLog log, MedicineLogStatus status) async {
    final index = _logs.indexWhere((l) => l.id == log.id);
    if (index == -1) return;

    HapticFeedback.selectionClick;
    // 1️⃣ Optimistically update UI
    setState(() {
      _logs[index] = MedicineLog(
        id: log.id,
        medicineId: log.medicineId,
        medicineName: log.medicineName,
        scheduledTime: log.scheduledTime,
        scheduledKey: log.scheduledKey,
        takenTime: status == MedicineLogStatus.taken ? DateTime.now() : null,
        status: status,
        dateKey: log.dateKey,
      );
    });

    // 2️⃣ Persist in background
    try {
      await _logService.updateStatus(logId: log.id, status: status);
    } catch (e) {
      debugPrint("Failed to update log: $e");

      // (Optional) rollback on failure
      setState(() {
        _logs[index] = log;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to update status")));
    }
  }

  // ─────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Today's Medicines"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
     body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _logs.isEmpty
            ? _emptyState()
            : Column(
                children: [
                  _progressRing(),        // 👈 progress ring
                  Expanded(child: _logsList()),
                ],
              ),
    );
  }

  // ─────────────────────────────────────

  Widget _emptyState() {
    return const Center(
      child: Text(
        "No medicines scheduled today",
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  // ─────────────────────────────────────

  Widget _logsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _logs.length,
      itemBuilder: (context, index) {
        final log = _logs[index];

        return Container(
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
                log.medicineName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(log.scheduledTime),
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.95,
                      end: 1.0,
                    ).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Row(
                  key: ValueKey(log.status), // 🔥 IMPORTANT
                  children: [
                    _actionButton(
                      label: "Taken",
                      color: Colors.greenAccent,
                      active: log.status == MedicineLogStatus.taken,
                      onTap: () => _updateStatus(log, MedicineLogStatus.taken),
                    ),
                    const SizedBox(width: 12),
                    _actionButton(
                      label: "Skipped",
                      color: Colors.redAccent,
                      active: log.status == MedicineLogStatus.skipped,
                      onTap: () =>
                          _updateStatus(log, MedicineLogStatus.skipped),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────

  Widget _actionButton({
    required String label,
    required Color color,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: active ? null : onTap, // 👈 prevents repeat taps
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  Widget _progressRing() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: _progress),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, _) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 6,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFFAAF0D1),
                      ),
                    );
                  },
                ),
                Text(
                  "${(_progress * 100).round()}%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "$_takenCount / $_totalCount doses taken today",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

}

