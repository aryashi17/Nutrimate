import 'package:flutter/material.dart';

import '../../../core/models/medicine_log.dart';
import '../../../core/services/medicine_log_service.dart';

class CalendarHistoryScreen extends StatefulWidget {
  const CalendarHistoryScreen({super.key});

  @override
  State<CalendarHistoryScreen> createState() =>
      _CalendarHistoryScreenState();
}

class _CalendarHistoryScreenState
    extends State<CalendarHistoryScreen> {
  final MedicineLogService _logService = MedicineLogService();

  DateTime _selectedDate = DateTime.now();
  List<MedicineLog> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  // ─────────────────────────────────────

  String _dateKey(DateTime date) {
    return "${date.year}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _loadLogs() async {
    setState(() => _loading = true);

    final logs =
        await _logService.getLogsByDate(_dateKey(_selectedDate));

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
        title: const Text("Daily History"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? _emptyState()
              : _logsList(),
    );
  }

  // ─────────────────────────────────────

  Widget _emptyState() {
    return const Center(
      child: Text(
        "No medicines for this day",
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

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
          child: Row(
            children: [
              _statusIcon(log.status),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "${log.medicineName} • ${_formatTime(log.scheduledTime)}",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
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
      },
    );
  }

  // ─────────────────────────────────────

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() => _selectedDate = date);
      await _loadLogs();
    }
  }

  // ─────────────────────────────────────

  Widget _statusIcon(MedicineLogStatus status) {
    switch (status) {
      case MedicineLogStatus.taken:
        return const Icon(Icons.check_circle,
            color: Colors.greenAccent);
      case MedicineLogStatus.skipped:
        return const Icon(Icons.cancel,
            color: Colors.orangeAccent);
      case MedicineLogStatus.missed:
        return const Icon(Icons.warning,
            color: Colors.redAccent);
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

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }
}
