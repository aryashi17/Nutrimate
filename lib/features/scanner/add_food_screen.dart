import 'package:flutter/material.dart';
import '../../core/models/food_item.dart';
import '../../core/services/add_food_service_mock.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final AddFoodServiceMock _service = AddFoodServiceMock();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _calController = TextEditingController();

  bool isLoading = false;
  FoodItem? result;

  @override
  void dispose() {
    _nameController.dispose();
    _calController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Add / Scan Food"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildManualSection(),
            const SizedBox(height: 32),
            _buildScanSection(),
            const SizedBox(height: 32),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (result != null)
              _buildResultCard(result!),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Manual Add Section
  // ──────────────────────────────────────────────

  Widget _buildManualSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Add Manually",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration("Food name"),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _calController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration("Calories per 100g"),
        ),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFAAF0D1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: isLoading ? null : _addManualFood,
            child: const Text(
              "Add Food",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // Scan Section (Mock)
  // ──────────────────────────────────────────────

  Widget _buildScanSection() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.camera_alt),
        label: const Text("Scan Food (Mock)"),
        onPressed: isLoading ? null : _scanFood,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Actions
  // ──────────────────────────────────────────────

  Future<void> _addManualFood() async {
    if (_nameController.text.trim().isEmpty ||
        _calController.text.trim().isEmpty) {
      _showMessage("Please enter food name and calories");
      return;
    }

    final caloriesPer100g = double.tryParse(_calController.text);
    if (caloriesPer100g == null || caloriesPer100g <= 0) {
      _showMessage("Enter a valid calorie value");
      return;
    }

    setState(() {
      isLoading = true;
      result = null;
    });

    final food = await _service.addManualFood(
      name: _nameController.text.trim(),
      caloriesPer100g: caloriesPer100g,
    );

    setState(() {
      result = food;
      isLoading = false;
    });
  }

  Future<void> _scanFood() async {
    setState(() {
      isLoading = true;
      result = null;
    });

    final food = await _service.scanFood();

    setState(() {
      result = food;
      isLoading = false;
    });
  }

  // ──────────────────────────────────────────────
  // Result UI
  // ──────────────────────────────────────────────

  Widget _buildResultCard(FoodItem food) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            food.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${(food.calPerGram * 100).toStringAsFixed(0)} kcal / 100g",
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            "Cup: ${food.gramPerCup.toStringAsFixed(0)} g",
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          const Text(
            "Default Plate Mapping:",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          ...food.defaultSectionDensity.entries.map(
            (e) => Text(
              "• ${e.key}: ${e.value.toStringAsFixed(0)} g",
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
