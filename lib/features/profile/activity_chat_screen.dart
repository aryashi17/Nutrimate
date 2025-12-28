import 'package:flutter/material.dart';

class ActivityChatScreen extends StatefulWidget {
  final Function(String level) onLevelSelected;
  const ActivityChatScreen({super.key, required this.onLevelSelected});

  @override
  State<ActivityChatScreen> createState() => _ActivityChatScreenState();
}

class _ActivityChatScreenState extends State<ActivityChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {"role": "bot", "text": "Hi! Describe your typical day. Do you sit a lot? Do you exercise? How often?"}
  ];
  bool _isAnalyzing = false;

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;
    
    setState(() {
      _messages.add({"role": "user", "text": _controller.text});
      _isAnalyzing = true;
    });

    String userText = _controller.text.toLowerCase();
    _controller.clear();

    // --- SIMULATED AI ANALYSIS (Replace with Real API later) ---
    await Future.delayed(const Duration(seconds: 2)); // Fake thinking time
    
    String detectedLevel = "Moderate";
    String botReply = "Got it. Based on that, I'd say you are Moderately Active.";

    if (userText.contains("desk") || userText.contains("sit") || userText.contains("office")) {
      detectedLevel = "Sedentary";
      botReply = "It sounds like you have a Sedentary lifestyle (mostly sitting). Let's start there.";
    } else if (userText.contains("run") || userText.contains("gym") || userText.contains("sport")) {
      detectedLevel = "Active";
      botReply = "Impressive! You are definitely Active. We'll set your calorie target higher.";
    }

    setState(() {
      _messages.add({"role": "bot", "text": botReply});
      _isAnalyzing = false;
    });

    // Send result back to previous screen after a slight delay
    Future.delayed(const Duration(seconds: 2), () {
      widget.onLevelSelected(detectedLevel);
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("AI Activity Analyzer"), 
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isBot = msg['role'] == 'bot';
                return Align(
                  alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isBot ? const Color(0xFF1E1E1E) : const Color(0xFFAAF0D1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(color: isBot ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isAnalyzing) const LinearProgressIndicator(color: Color(0xFFAAF0D1)),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "I walk to class and play cricket...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFAAF0D1)),
                  onPressed: _sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}