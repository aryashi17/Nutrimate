class PlateSection {
  final String id; // Matches SVG ID (e.g., 'largest_compartment')
  final String label;
  final double volumeFactor; // How big is this section relative to others?

  PlateSection({
    required this.id, 
    required this.label, 
    required this.volumeFactor
  });
}

class PlateModel {
  final String plateType; // 'A' or 'B'
  final List<PlateSection> sections;

  PlateModel({required this.plateType, required this.sections});
}