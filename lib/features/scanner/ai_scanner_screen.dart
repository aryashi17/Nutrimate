import '../../core/services/openrouter_service.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';


class AiScannerScreen extends StatefulWidget {
  const AiScannerScreen({super.key});

  @override
  State<AiScannerScreen> createState() => _AiScannerScreenState();
}

class _AiScannerScreenState extends State<AiScannerScreen> {
  final TextEditingController _textController = TextEditingController();
  final OpenRouterService _aiService = OpenRouterService();
  bool _isLoading = false;
  bool _isScanning = false;

  // 1. Logic to handle barcode detection
  void _onBarcodeDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && !_isLoading) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        setState(() {
          _isScanning = false; // Stop scanning UI
          _textController.text = "Product Barcode: $code"; // Temporary feedback
        });
        
        // In a real app, you would swap this for an OpenFoodFacts API call.
        // For now, we ask AI to guess/lookup the code (Note: AI is not great at raw numbers without a database, 
        // but this completes the logic flow you asked for).
        _analyzeInput("Food item with barcode $code");
      }
    }
  }

  // 2. Logic to send data to AI
  Future<void> _analyzeInput(String input) async {
    if (input.isEmpty) return;
    
    setState(() => _isLoading = true);
    
    // Call the service we made in Step 2
    final result = await _aiService.analyzeFood(input);
    
    setState(() => _isLoading = false);

    if (result != null && mounted) {
      // Success! Pass data back to the previous screen
      Navigator.pop(context, result);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not identify food. Please try typing it.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Snack / Food")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Input Field ---
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: "Describe your food",
                hintText: "e.g., '1 pack of oreos' or 'banana'",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fastfood),
              ),
            ),
            const SizedBox(height: 12),
            
            // --- Analyze Button ---
            ElevatedButton(
              onPressed: _isLoading ? null : () => _analyzeInput(_textController.text),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                : const Text("Add to Log"),
            ),

            const SizedBox(height: 30),
            const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.all(8.0), child: Text("OR")), Expanded(child: Divider())]),
            const SizedBox(height: 30),

            // --- Scanner Area ---
            if (_isScanning)
              Container(
                height: 300,
                decoration: BoxDecoration(border: Border.all(color: Colors.green, width: 2)),
                child: MobileScanner(
                  onDetect: _onBarcodeDetect,
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () => setState(() => _isScanning = true),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text("Scan Barcode"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
              ),
              
            if (_isScanning)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextButton(
                  onPressed: () => setState(() => _isScanning = false),
                  child: const Text("Cancel Scan"),
                ),
              )
          ],
        ),
      ),
    );
  }
}