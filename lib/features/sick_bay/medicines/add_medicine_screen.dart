import 'package:flutter/material.dart';
import '../../../core/models/medicine.dart';

class AddMedicineScreen extends StatefulWidget {
  final Medicine? medicine;

  const AddMedicineScreen({super.key, this.medicine});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}


class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionController = TextEditingController();

  final List<TimeOfDay> _times = [];

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return "$hour:$minute";
}


  // ─────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          widget.medicine == null ? "Add Medicine" : "Edit Medicine",
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (widget.medicine != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _input("Medicine Name", _nameController),
            const SizedBox(height: 16),

            _input("Dosage (e.g. 500mg)", _dosageController),
            const SizedBox(height: 24),

            _buildTimeSection(),
            const SizedBox(height: 24),

            _buildDateSection(),
            const SizedBox(height: 24),

            _input(
              "Instructions (optional)",
              _instructionController,
              maxLines: 2,
            ),
            const SizedBox(height: 32),

            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  @override
void initState() {
  super.initState();

  final med = widget.medicine;
  if (med != null) {
    _nameController.text = med.name;
    _dosageController.text = med.dosage;
    _instructionController.text = med.instructions;
    _startDate = med.startDate;
    _endDate = med.endDate;

    _times.addAll(
      med.times.map((t) {
        final parts = t.split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }),
    );
  }
}

void _confirmDelete() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text(
        "Delete Medicine?",
        style: TextStyle(color: Colors.white),
      ),
      content: const Text(
        "This medicine will be removed.",
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);        // close dialog
            Navigator.pop(context, 'delete'); // return result
          },
          child: const Text(
            "Delete",
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    ),
  );
}



  Widget _input(
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ─────────────────────────────────────

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Times",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          children: _times.map((time) {
            return Chip(
              label: Text(
                time.format(context),
                style: const TextStyle(color: Colors.black),
              ),
              backgroundColor: const Color(0xFFAAF0D1),
              onDeleted: () {
                setState(() {
                  _times.remove(time);
                });
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        TextButton.icon(
          onPressed: _pickTime,
          icon: const Icon(Icons.add, color: Color(0xFFAAF0D1)),
          label: const Text(
            "Add Time",
            style: TextStyle(color: Color(0xFFAAF0D1)),
          ),
        ),
      ],
    );
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null && !_times.contains(time)) {
      setState(() => _times.add(time));
    }
  }

  // ─────────────────────────────────────

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Duration",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            "Start Date: ${_formatDate(_startDate)}",
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: const Icon(Icons.calendar_today, color: Colors.white70),
          onTap: () => _pickStartDate(),
        ),

        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            _endDate == null
                ? "End Date: Not set"
                : "End Date: ${_formatDate(_endDate!)}",
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: const Icon(Icons.calendar_today, color: Colors.white70),
          onTap: () => _pickEndDate(),
        ),
      ],
    );
  }

  Future<void> _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  Future<void> _pickEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  // ─────────────────────────────────────

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFAAF0D1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: _onSave,
        child: const Text(
          "Save Medicine",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _onSave() {
  if (_nameController.text.isEmpty ||
      _dosageController.text.isEmpty ||
      _times.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill required fields")),
    );
    return;
  }

  final medicine = Medicine(
  id: widget.medicine?.id ?? '',
  name: _nameController.text.trim(),
  dosage: _dosageController.text.trim(),
  times: _times.map(_formatTime).toList(),
  startDate: _startDate,
  endDate: _endDate,
  instructions: _instructionController.text.trim(),
  isActive: true,
);

Navigator.pop(context, medicine);

}


  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
