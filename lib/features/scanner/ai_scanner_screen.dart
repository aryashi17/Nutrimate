import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/services/ai_scanner_service.dart';

class AiScannerScreen extends StatefulWidget {
  const AiScannerScreen({super.key});

  @override
  State<AiScannerScreen> createState() => _AiScannerScreenState();
}

class _AiScannerScreenState extends State<AiScannerScreen> {
  final TextEditingController _textController = TextEditingController();
  final AiScannerService _service = AiScannerService();

  final MobileScannerController _scannerController =
      MobileScannerController();

  bool _isLoading = false;
  bool _isScanning = false;

  // ───────────────────────────────

  void _onBarcodeDetect(BarcodeCapture capture) async {
    if (_isLoading) return;

    final code = capture.barcodes.first.rawValue;
    if (code == null) return;

    _scannerController.stop();

    setState(() {
      _isScanning = false;
      _textController.text = code;
    });

    await _analyzeInput(code);
  }

  Future<void> _analyzeInput(String input) async {
    if (input.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final result = await _service.analyzeFood(input: input);

      if (!mounted) return;
      Navigator.pop(context, result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not identify food. Try typing it."),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ───────────────────────────────

  @override
  void dispose() {
    _scannerController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Snack / Food")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: "Describe your food",
                hintText: "e.g. Banana or 1 pack of biscuits",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fastfood),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () => _analyzeInput(_textController.text),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Add to Log"),
            ),

            const SizedBox(height: 30),

            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("OR"),
                ),
                Expanded(child: Divider()),
              ],
            ),

            const SizedBox(height: 30),

            if (_isScanning)
              SizedBox(
                height: 300,
                child: MobileScanner(
                  controller: _scannerController,
                  onDetect: _onBarcodeDetect,
                ),
              )
            else
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text("Scan Barcode"),
                onPressed: () {
                  setState(() => _isScanning = true);
                  _scannerController.start();
                },
              ),

            if (_isScanning)
              TextButton(
                onPressed: () {
                  _scannerController.stop();
                  setState(() => _isScanning = false);
                },
                child: const Text("Cancel Scan"),
              ),
          ],
        ),
      ),
    );
  }
}
