class CrosswordCell {
  final int x;
  final int y;
  final String answer;
  String currentGuess;
  final int? number; // The small number for the clue (e.g., 1, 2)
  final bool isBlocked; // True for the dark squares

  CrosswordCell({
    required this.x,
    required this.y,
    this.answer = "",
    this.currentGuess = "",
    this.number,
    this.isBlocked = false,
  });
}