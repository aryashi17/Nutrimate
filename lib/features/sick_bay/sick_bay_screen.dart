import 'package:flutter/material.dart';
import '../../core/services/sick_bay_service.dart';
import '../../core/models/sick_bay_result.dart';

class SickBayScreen extends StatefulWidget {
  const SickBayScreen({super.key});

  @override
  State<SickBayScreen> createState() => _SickBayScreenState();
}

class _SickBayScreenState extends State<SickBayScreen> {
  final SickBayService _service = SickBayService();
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
              else if (result != null) ...[
                _buildResultSection(result!),
                const SizedBox(height: 20),
                _buildResetButton(),
              ],
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
          "Select Illness",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return commonAilments;
            }
            return commonAilments.where(
              (ailment) => ailment.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              ),
            );
          },
          onSelected: (value) {
            setState(() {
              if (!selectedAilments.contains(value)) {
                selectedAilments.add(value);
              }
            });
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search illness (e.g. Fever)",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedAilments.map((ailment) {
            return Chip(
              label: Text(ailment),
              backgroundColor: const Color(0xFFAAF0D1),
              labelStyle: const TextStyle(color: Colors.black),
              onDeleted: () {
                setState(() {
                  selectedAilments.remove(ailment);
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
                      content: Text(
                        "Please describe symptoms or select an ailment",
                      ),
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

  Widget _buildResetButton() {
    return Center(
      child: TextButton(
        onPressed: () {
          setState(() {
            result = null;
            selectedAilments.clear();
            _issueController.clear();
          });
        },
        child: const Text(
          "Reset",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ),
    );
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case "severe":
        return Colors.redAccent;
      case "moderate":
        return Colors.orangeAccent;
      case "mild":
        return Colors.yellowAccent;
      default:
        return const Color(0xFFAAF0D1); // low
    }
  }

  String _severityMessage(String severity) {
    switch (severity) {
      case "severe":
        return "⚠️ Symptoms appear serious. Please consult a doctor immediately.";
      case "moderate":
        return "⚠️ Monitor closely. Medical attention may be needed.";
      case "mild":
        return "🙂 Mild symptoms. Rest and care should help.";
      default:
        return "✅ No major concerns detected.";
    }
  }

  Widget _buildSeverityBanner(String severity) {
    final color = _severityColor(severity);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _severityMessage(severity),
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection(SickBayResult result) {
    final color = _severityColor(result.severity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSeverityBanner(result.severity),

        _resultCard(
          title: "Eat",
          icon: Icons.check_circle_outline,
          items: result.eat,
          accentColor: color,
        ),
        const SizedBox(height: 16),

        _resultCard(
          title: "Avoid",
          icon: Icons.cancel_outlined,
          items: result.avoid,
          accentColor: color,
        ),
        const SizedBox(height: 16),

        _resultCard(
          title: "Care",
          icon: Icons.favorite_outline,
          items: result.care,
          accentColor: color,
        ),
      ],
    );
  }

  Widget _resultCard({
    required String title,
    required IconData icon,
    required List<String> items,
    required Color accentColor,
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
              Icon(
                icon,
                color: accentColor,
              ),
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
