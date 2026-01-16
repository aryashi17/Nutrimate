import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class CrosswordScreen extends StatefulWidget {
  const CrosswordScreen({super.key});

  @override
  State<CrosswordScreen> createState() => _CrosswordScreenState();
}

class _CrosswordScreenState extends State<CrosswordScreen> {
  bool w1Completed = false;
bool w2Completed = false;
  static const int gridSize = 8;
  late List<List<CrosswordCell>> grid;
  int? selectedX;
  int? selectedY;
  String clue1 = "";
  String clue2 = "";
  Map<String, dynamic>? currentPuzzleData;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _generateNewWordSet();
  }

  void _generateNewWordSet() {
    // 🧩 Curated word sets where intersections are guaranteed to match
    var puzzles = [
      {
        'w1': 'VITALITY', 'w2': 'PROTEIN', 
        'r1': 4, 'c1': 0, 'r2': 1, 'c2': 2, // Join at 'T'
        'clue1': 'State of being strong and active', 
        'clue2': 'Muscle builders'
      },
      {
        'w1': 'HEALTHY', 'w2': 'ENERGY', 
        'r1': 3, 'c1': 1, 'r2': 1, 'c2': 2, // Join at 'E'
        'clue1': 'In good physical condition', 
        'clue2': 'Strength for activity'
      },
      {
        'w1': 'CALORIES', 'w2': 'FIBER', 
        'r1': 4, 'c1': 0, 'r2': 2, 'c2': 4, // Join at 'R'
        'clue1': 'Units of energy in food', 
        'clue2': 'Aids digestion'
      },
    ];
    currentPuzzleData = puzzles[Random().nextInt(puzzles.length)];
    _loadGridFromData();
  }

  void _loadGridFromData() {
    setState(() {
      w1Completed = false;
      w2Completed = false;

      grid = List.generate(gridSize, (y) => List.generate(gridSize, (x) => CrosswordCell(x: x, y: y, isBlocked: true)));
      clue1 = currentPuzzleData!['clue1']!;
      clue2 = currentPuzzleData!['clue2']!;
      
      _fillWord(currentPuzzleData!['w1']!, currentPuzzleData!['r1'], currentPuzzleData!['c1'], true, 1);
      _fillWord(currentPuzzleData!['w2']!, currentPuzzleData!['r2'], currentPuzzleData!['c2'], false, 2);
      
      _provideSmartHint(currentPuzzleData!['w1']!, currentPuzzleData!['r1'], currentPuzzleData!['c1'], true);
      _provideSmartHint(currentPuzzleData!['w2']!, currentPuzzleData!['r2'], currentPuzzleData!['c2'], false);
    });
  }

  void _fillWord(String w, int r, int c, bool horizontal, int num) {
    for (int i = 0; i < w.length; i++) {
      int nx = horizontal ? c + i : c;
      int ny = horizontal ? r : r + i;
      if (nx < gridSize && ny < gridSize) {
        bool alreadyExists = !grid[ny][nx].isBlocked;
      int? existingNumber = grid[ny][nx].number;
      String existingGuess = grid[ny][nx].currentGuess;

        grid[ny][nx] = CrosswordCell(
          x: nx, y: ny, 
          answer: w[i], 
          isBlocked: false, 
          number: i == 0 ? num : existingNumber,
          isIntersection: alreadyExists, // Mark if words cross here
          currentGuess: existingGuess,
        );
      }
    }
  }

  void _provideSmartHint(String word, int r, int c, bool horizontal) {
    List<Point> validHintPoints = [];
    for (int i = 0; i < word.length; i++) {
      int nx = horizontal ? c + i : c;
      int ny = horizontal ? r : r + i;
      // ONLY reveal letters that are NOT at intersections to avoid confusion
      if (!grid[ny][nx].isIntersection) {
        validHintPoints.add(Point(nx, ny));
      }
    }
    if (validHintPoints.isNotEmpty) {
      Point p = validHintPoints[Random().nextInt(validHintPoints.length)];
      grid[p.y.toInt()][p.x.toInt()].currentGuess = grid[p.y.toInt()][p.x.toInt()].answer;
    }
  }

  // ⌨️ KEYBOARD & INPUT LOGIC
  void _handleInput(String key) {
    if (selectedX == null || selectedY == null) return;
    setState(() {
      var cell = grid[selectedY!][selectedX!];
      if (key == "BACKSPACE") {
        if (cell.currentGuess.isEmpty) {
          _moveBackward();
        } else {
          cell.currentGuess = "";
        }
      } else {
        cell.currentGuess = key.toUpperCase();
        _checkWordCompletion(); 
        _autoAdvance();
      }
    });
  }

  void _autoAdvance() {
    // Moves right if there's a cell, otherwise moves down
    if (selectedX! < gridSize - 1 && !grid[selectedY!][selectedX! + 1].isBlocked) {
      selectedX = selectedX! + 1;
    } else if (selectedY! < gridSize - 1 && !grid[selectedY! + 1][selectedX!].isBlocked) {
      selectedY = selectedY! + 1;
    }
  }

  void _moveBackward() {
    if (selectedX! > 0 && !grid[selectedY!][selectedX! - 1].isBlocked) {
      selectedX = selectedX! - 1;
    } else if (selectedY! > 0 && !grid[selectedY! - 1][selectedX!].isBlocked) {
      selectedY = selectedY! - 1;
    }
  }

  void _checkWordCompletion() {
   bool w1Now = _isWordFinished(currentPuzzleData!['w1'], currentPuzzleData!['r1'], currentPuzzleData!['c1'], true);
    bool w2Now = _isWordFinished(currentPuzzleData!['w2'], currentPuzzleData!['r2'], currentPuzzleData!['c2'], false);
   if ((w1Now && !w1Completed) || (w2Now && !w2Completed)) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Clear old ones
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Word Complete! 🍏"), 
          duration: Duration(milliseconds: 1000),
          backgroundColor: Colors.green,
        )
      );
    }
    setState(() {
      w1Completed = w1Now;
      w2Completed = w2Now;
    });

    if (w1Completed && w2Completed) {
      // Logic for entire puzzle finished
      print("Puzzle Finished!");
    }
  }

  bool _isWordFinished(String word, int r, int c, bool horizontal) {
    for (int i = 0; i < word.length; i++) {
      int nx = horizontal ? c + i : c;
      int ny = horizontal ? r : r + i;
      if (grid[ny][nx].currentGuess != grid[ny][nx].answer) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: const Text("Nutri-Cross Daily"),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadGridFromData)],
      ),
      body: RawKeyboardListener( // ⌨️ LISTENS FOR HARDWARE KEYBOARD (Physical/Laptop)
        focusNode: _focusNode,
        autofocus: true,
        onKey: (event) {
          if (event is RawKeyDownEvent) {
            final key = event.logicalKey;
            setState(() {
              if (key == LogicalKeyboardKey.arrowUp) selectedY = (selectedY! - 1).clamp(0, 7);
              if (key == LogicalKeyboardKey.arrowDown) selectedY = (selectedY! + 1).clamp(0, 7);
              if (key == LogicalKeyboardKey.arrowLeft) selectedX = (selectedX! - 1).clamp(0, 7);
              if (key == LogicalKeyboardKey.arrowRight) selectedX = (selectedX! + 1).clamp(0, 7);
            });
            if (key == LogicalKeyboardKey.backspace) _handleInput("BACKSPACE");
            if (event.character != null && RegExp(r'^[a-zA-Z]$').hasMatch(event.character!)) _handleInput(event.character!);
          }
        },
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GridView.builder(
                      itemCount: 64,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8, mainAxisSpacing: 2, crossAxisSpacing: 2),
                      itemBuilder: (context, index) {
                        int x = index % 8; int y = index ~/ 8;
                        var cell = grid[y][x];
                        if (cell.isBlocked) return Container(color: Colors.white.withOpacity(0.01));
                        bool isSelected = selectedX == x && selectedY == y;
                        return GestureDetector(
                          onTap: () { setState(() { selectedX = x; selectedY = y; }); _focusNode.requestFocus(); },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.cyan.withOpacity(0.3) : Colors.white.withOpacity(0.05),
                              border: Border.all(color: isSelected ? Colors.cyan : Colors.white12),
                            ),
                            child: Stack(
                              children: [
                                if (cell.number != null) Positioned(left: 2, top: 0, child: Text("${cell.number}", style: const TextStyle(color: Colors.white60, fontSize: 10))),
                                Center(child: Text(cell.currentGuess, 
                                    style: TextStyle(
                                      // 📍 POINT 3: Change color based on correctness
                                      color: cell.currentGuess == "" || cell.currentGuess == cell.answer 
                                          ? Colors.white 
                                          : Colors.redAccent, 
                                      fontSize: 18, 
                                      fontWeight: FontWeight.bold
                                    ))),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            _buildClueSection(),
            _buildOnScreenKeyboard(),
          ],
        ),
      ),
    );
  }

  Widget _buildClueSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black26,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("CLUES", style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          Text("1 ACROSS: $clue1", style: const TextStyle(color: Colors.white, fontSize: 13)),
          Text("2 DOWN: $clue2", style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildOnScreenKeyboard() {
    final rows = [["Q","W","E","R","T","Y","U","I","O","P"], ["A","S","D","F","G","H","J","K","L"], ["Z","X","C","V","B","N","M","⌫"]];
    return Container(
      padding: const EdgeInsets.only(bottom: 25, top: 10),
      child: Column(
        children: rows.map((row) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) => GestureDetector(
            onTap: () => _handleInput(key == "⌫" ? "BACKSPACE" : key),
            child: Container(
              margin: const EdgeInsets.all(3),
              width: key == "⌫" ? 50 : 32, height: 45,
              decoration: BoxDecoration(color: const Color(0xFF23395B), borderRadius: BorderRadius.circular(6)),
              child: Center(child: Text(key, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ),
          )).toList(),
        )).toList(),
      ),
    );
  }
}

class CrosswordCell {
  final int x; final int y; final String answer; String currentGuess; final int? number; final bool isBlocked; final bool isIntersection;
  CrosswordCell({required this.x, required this.y, this.answer = "", this.currentGuess = "", this.number, this.isBlocked = false, this.isIntersection = false});
}