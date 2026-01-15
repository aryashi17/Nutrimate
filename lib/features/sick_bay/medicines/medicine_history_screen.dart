import 'package:flutter/material.dart';

import '../../../core/models/medicine.dart';
import '../../../core/models/medicine_log.dart';
import '../../../core/services/medicine_log_service.dart';

class MedicineHistoryScreen extends StatefulWidget {
  final Medicine medicine;

  const MedicineHistoryScreen({
    super.key,
    required this.medicine,
  });

  @override
  State<MedicineHistoryScreen> createState() =>
      _MedicineHistoryScreenState();
}

class _MedicineHistoryScreenState extends State<MedicineHistoryScreen> {
  final MedicineLogService _logService = MedicineLogService();

  List<MedicineLog> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // ─────────────────────────────────────

  Future<void> _loadHistory() async {
    final logs =
        await _logService.getLogsByMedicine(widget.medicine.id);

    setState(() {
      _logs = logs;
      _loading = false;
    });
  }

  // ─────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(widget.medicine.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? _emptyState()
              : _historyList(),
    );
  }

  // ─────────────────────────────────────

  Widget _emptyState() {
    return const Center(
      child: Text(
        "No history yet",
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  // ─────────────────────────────────────

  Widget _historyList() {
    final grouped = _groupByDate(_logs);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: grouped.entries.map((entry) {
        return _dateSection(entry.key, entry.value);
      }).toList(),
    );
  }

  // ─────────────────────────────────────

  Widget _dateSection(String date, List<MedicineLog> logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            date,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...logs.map(_historyTile),
        const SizedBox(height: 16),
      ],
    );
  }

  // ─────────────────────────────────────

  Widget _historyTile(MedicineLog log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _statusIcon(log.status),
          const SizedBox(width: 12),
          Text(
            _formatTime(log.scheduledTime),
            style: const TextStyle(color: Colors.white),
          ),
          const Spacer(),
          Text(
            _statusLabel(log.status),
            style: TextStyle(
              color: _statusColor(log.status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────

  Widget _statusIcon(MedicineLogStatus status) {
    switch (status) {
      case MedicineLogStatus.taken:
        return const Icon(Icons.check_circle, color: Colors.greenAccent);
      case MedicineLogStatus.skipped:
        return const Icon(Icons.cancel, color: Colors.orangeAccent);
      case MedicineLogStatus.missed:
        return const Icon(Icons.warning, color: Colors.redAccent);
    }
  }

  Color _statusColor(MedicineLogStatus status) {
    switch (status) {
      case MedicineLogStatus.taken:
        return Colors.greenAccent;
      case MedicineLogStatus.skipped:
        return Colors.orangeAccent;
      case MedicineLogStatus.missed:
        return Colors.redAccent;
    }
  }

  String _statusLabel(MedicineLogStatus status) {
    switch (status) {
      case MedicineLogStatus.taken:
        return "Taken";
      case MedicineLogStatus.skipped:
        return "Skipped";
      case MedicineLogStatus.missed:
        return "Missed";
    }
  }

  // ─────────────────────────────────────

  Map<String, List<MedicineLog>> _groupByDate(List<MedicineLog> logs) {
    final map = <String, List<MedicineLog>>{};

    for (final log in logs) {
      final key = _formatDate(log.scheduledTime);
      map.putIfAbsent(key, () => []).add(log);
    }

    return map;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today =
        DateTime(now.year, now.month, now.day);
    final logDate =
        DateTime(date.year, date.month, date.day);

    if (logDate == today) return "Today";
    if (logDate ==
        today.subtract(const Duration(days: 1))) {
      return "Yesterday";
    }

    return "${date.day}/${date.month}/${date.year}";
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }
}
