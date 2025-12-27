import 'package:flutter/material.dart';

class PlateMapperScreen extends StatefulWidget {
  final String? foodName;
  const PlateMapperScreen({super.key, this.foodName});

  @override
  State<PlateMapperScreen> createState() => _PlateMapperScreenState();
}

class _PlateMapperScreenState extends State<PlateMapperScreen> {
  String selectedSection = "Rice Area"; 
  double fillLevel = 0.5;

  final Color accentMint = const Color(0xFFAAF0D1);
  final Color bgDark = const Color(0xFF121212);
  final Color cardGray = const Color(0xFF1E1E1E);

  @override
  Widget build(BuildContext context) {
    // Get screen width to make the plate size relative but controlled
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Map Your Plate", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center( 
        child: SingleChildScrollView( // Added safety for small phones, but mainAxisSize: min keeps it tight
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.foodName != null) ...[
                  Text(
                    widget.foodName!.toUpperCase(),
                    style: TextStyle(color: accentMint, letterSpacing: 3, fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 30),
                ],

                // 1. THE PLATE - Optimized for clickability and size
                SizedBox(
                  width: screenWidth * 0.85, // Use 85% of screen width
                  height: 280, // Increased height for better "tappable" bowls
                  child: _buildInteractiveTray(),
                ),
                
                const SizedBox(height: 40),
                
                // 2. Information Section
                _buildSelectionDetails(),
                
                const SizedBox(height: 40),
                
                // 3. The Slider
                _buildFillSlider(),
                
                const SizedBox(height: 50),
                
                // 4. Save Button
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveTray() {
    return Container(
      padding: const EdgeInsets.all(16), // Slightly more padding for a premium look
      decoration: BoxDecoration(
        color: cardGray,
        borderRadius: BorderRadius.circular(35), // Rounded for a modern feel
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          // Top Row: Small Bowls (Taller for easier clicking)
          Expanded(
            flex: 2, // Gave more vertical weight to the bowls
            child: Row(
              children: [
                _plateSection("Bowl 1"),
                const SizedBox(width: 12),
                _plateSection("Bowl 2"),
                const SizedBox(width: 12),
                _plateSection("Curd/Sweet"),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Bottom Row: Main Areas
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _plateSection("Rice Area", isLarge: true),
                const SizedBox(width: 12),
                _plateSection("Roti Area"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _plateSection(String name, {bool isLarge = false}) {
    bool isSelected = selectedSection == name;
    return Expanded(
      flex: isLarge ? 2 : 1,
      child: GestureDetector(
        onTap: () => setState(() => selectedSection = name),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isSelected ? accentMint.withValues(alpha: 0.15) : Colors.black38,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? accentMint : Colors.white.withValues(alpha: 0.05),
              width: isSelected ? 2.5 : 1,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white24,
                  fontSize: 11, // Slightly larger font for readability
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionDetails() {
    return Column(
      children: [
        Text(
          selectedSection.toUpperCase(),
          style: const TextStyle(
            color: Colors.white, 
            fontSize: 22, 
            fontWeight: FontWeight.w900, 
            letterSpacing: 1.5
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: accentMint.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "${(fillLevel * 100).toInt()}% FULL",
            style: TextStyle(color: accentMint, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildFillSlider() {
    return SizedBox(
      width: 300,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: accentMint,
          inactiveTrackColor: Colors.white10,
          thumbColor: Colors.white,
          trackHeight: 6,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
        ),
        child: Slider(
          value: fillLevel,
          onChanged: (val) => setState(() => fillLevel = val),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: 220,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentMint,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
          elevation: 8,
          shadowColor: accentMint.withValues(alpha: 0.3),
        ),
        onPressed: () => Navigator.pop(context),
        child: const Text("CONFIRM PORTION", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
      ),
    );
  }
}