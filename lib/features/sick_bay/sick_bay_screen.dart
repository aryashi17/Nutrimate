import 'package:flutter/material.dart';
import '../../core/services/sick_bay_service_mock.dart';
import '../../core/models/sick_bay_result.dart';

class SickBayScreen extends StatefulWidget {
  const SickBayScreen({super.key});

  @override
  State<SickBayScreen> createState() => _SickBayScreenState();
}

class _SickBayScreenState extends State<SickBayScreen> {
  final SickBayServiceMock _service = SickBayServiceMock();
  SickBayResult? result;
  bool isLoading = false;

  final TextEditingController _issueController = TextEditingController();

  final List<String> commonAilments = [
    "Fever",
    "Cold",
    "Cough",
    "Headache",
    "Stomach Pain",
    "Sore Throat",
    "Weakness",
  ];

  final Set<String> selectedAilments = {};

  @override
  void dispose() {
    _issueController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Sick Bay"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIntro(),
              const SizedBox(height: 24),
              _buildIssueInput(),
              const SizedBox(height: 24),
              _buildAilmentSelector(),
              const SizedBox(height: 32),
              _buildAnalyzeButton(),
              const SizedBox(height: 32),
              if (isLoading)
               const Center(child: CircularProgressIndicator())
              else if (result != null)
                _buildResultSection(result!),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "How are you feeling?",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Describe your symptoms or select common issues below.",
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildIssueInput() {
    return TextField(
      controller: _issueController,
      maxLines: 4,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "e.g. Fever since morning, feeling weak...",
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildAilmentSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Common Ailments",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: commonAilments.map((ailment) {
            final isSelected = selectedAilments.contains(ailment);
            return ChoiceChip(
              label: Text(ailment),
              selected: isSelected,
              selectedColor: const Color(0xFFAAF0D1),
              backgroundColor: const Color(0xFF1E1E1E),
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
              ),
              onSelected: (value) {
                setState(() {
                  value
                      ? selectedAilments.add(ailment)
                      : selectedAilments.remove(ailment);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

 Widget _buildAnalyzeButton() {
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
      onPressed: isLoading
          ? null
          : () async {
            if (_issueController.text.trim().isEmpty &&
                selectedAilments.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please describe symptoms or select an ailment"),
                ),
              );
              return; // ⛔ stop here
            }
        setState(() {
          isLoading = true;
          result = null;
        });

        final menu = await _service.getTodaysMenu();

        final analysis = await _service.analyzeSickness(
          description: _issueController.text,
          selectedAilments: selectedAilments.toList(),
          todaysMenu: menu,
        );

        setState(() {
          result = analysis;
          isLoading = false;
        });
      },
      child: const Text(
        "Analyze",
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

  Widget _buildResultSection(SickBayResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _resultCard(
          title: "Eat",
          icon: Icons.check_circle_outline,
          items: result.eat,
        ),
        const SizedBox(height: 16),
        _resultCard(
          title: "Avoid",
          icon: Icons.cancel_outlined,
          items: result.avoid,
        ),
        const SizedBox(height: 16),
        _resultCard(
          title: "Care",
          icon: Icons.favorite_outline,
          items: result.care,
        ),
      ],
    );
  }

  Widget _resultCard({
    required String title,
    required IconData icon,
    required List<String> items,
  }) {
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
          Row(
            children: [
              Icon(icon, color: const Color(0xFFAAF0D1)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                "• $e",
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
