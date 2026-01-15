class BuildCostEngine {
  final String scenario;
  final double totalFloorArea;
  final String propertyType; // e.g., 'Detached', 'Semi-Detached', 'Terraced', 'Flat'
  final String epcRating;    // e.g., 'A', 'B', 'C', 'D', 'E', 'F', 'G'

  BuildCostEngine({
    required this.scenario,
    required this.totalFloorArea,
    required this.propertyType,
    required this.epcRating,
  });

  // --- Cost Data ---
  // Using more granular data to allow for better scaling.

  // 1. Costs per Square Meter (£/m²)
  static const Map<String, double> _costsPerSqM = {
    'Foundations': 210,
    'Groundworks_Drainage': 110,
    'Structure_Shell': 575,
    'Structural_Steel': 95,
    'Roofing': 160,
    'Windows_Doors': 270,
    'Insulation_Plastering': 130,
    'Internal_Finishes_Basic': 160,
    'Internal_Finishes_Mid': 260,
    'Internal_Finishes_High': 420,
    'Electrical_FirstFix': 75,
    'Electrical_SecondFix': 65,
    'Plumbing_Heating_FirstFix': 95,
    'Plumbing_Heating_SecondFix': 85,
  };

  // 2. Fixed Project-Level Costs (£) - These are base values, some will be scaled.
  static const Map<String, double> _baseFixedCosts = {
    'Preliminaries': 1500,     // Base for site setup
    'Demolition_Structure': 2500, // Base for structural work
    'Waste_Skips': 1000,       // Base for waste
    'Statutory_Compliance': 1500, // Fixed cost
  };

  // 3. Per-Item Costs (£)
  static const Map<String, double> _itemCosts = {
    'Kitchen_Basic': 5000,
    'Kitchen_Mid': 12000,
    'Kitchen_High': 25000,
    'Bathroom_Basic': 4000,
    'Bathroom_Mid': 8000,
    'Bathroom_High': 15000,
  };

  // 4. Percentage-Based Costs (%)
  static const double _professionalFeesPercentage = 0.12;
  static const double _contingencyPercentage = 0.10;
  static const double _vatPercentage = 0.20;

  // --- Scenario Definitions ---
  static const Map<String, double> _scenarioAddedArea = {
    'Full Refurbishment': 0, 'Rear single-storey extension': 48, 'Rear two-storey extension': 96,
    'Side single-storey extension': 18, 'Side two-storey extension': 36, 'Porch / small front single-storey extension': 6,
    'Full-width front single-storey extension': 15, 'Full-width front two-storey front extension': 30,
    'Standard single garage conversion': 18, 'Basic loft conversion (Velux)': 25, 'Dormer loft conversion': 30,
    'Dormer loft with ensuite': 30,
  };

  static const Map<String, List<String>> _scenarioCostMatrix = {
      'Full Refurbishment': ['Preliminaries', 'Demolition_Structure', 'Insulation_Plastering', 'Internal_Finishes_Mid', 'Kitchen_Mid', 'Bathroom_Mid', 'Electrical_FirstFix', 'Electrical_SecondFix', 'Plumbing_Heating_FirstFix', 'Plumbing_Heating_SecondFix', 'Waste_Skips', 'Statutory_Compliance'],
      'Rear single-storey extension': ['Preliminaries', 'Demolition_Structure', 'Foundations', 'Groundworks_Drainage', 'Structure_Shell', 'Structural_Steel', 'Roofing', 'Windows_Doors', 'Insulation_Plastering', 'Internal_Finishes_Basic', 'Electrical_FirstFix', 'Electrical_SecondFix', 'Plumbing_Heating_FirstFix', 'Plumbing_Heating_SecondFix', 'Waste_Skips', 'Statutory_Compliance'],
      'Side single-storey extension': ['Preliminaries', 'Demolition_Structure', 'Foundations', 'Groundworks_Drainage', 'Structure_Shell', 'Structural_Steel', 'Roofing', 'Windows_Doors', 'Insulation_Plastering', 'Internal_Finishes_Basic', 'Electrical_FirstFix', 'Plumbing_Heating_FirstFix', 'Waste_Skips', 'Statutory_Compliance'],
      'Standard single garage conversion': ['Demolition_Structure', 'Structure_Shell', 'Windows_Doors', 'Insulation_Plastering', 'Internal_Finishes_Basic', 'Electrical_FirstFix', 'Electrical_SecondFix', 'Waste_Skips'],
      'Dormer loft with ensuite': ['Preliminaries', 'Structure_Shell', 'Structural_Steel', 'Roofing', 'Windows_Doors', 'Insulation_Plastering', 'Internal_Finishes_Basic', 'Bathroom_Mid', 'Electrical_FirstFix', 'Plumbing_Heating_FirstFix', 'Waste_Skips', 'Statutory_Compliance'],
  };

  Map<String, double> calculateBuildCosts() {
    final costCategories = _scenarioCostMatrix[scenario] ?? [];
    final detailedCosts = <String, double>{};

    final addedArea = _scenarioAddedArea[scenario] ?? 0;
    final areaForCalc = (scenario == 'Full Refurbishment') ? totalFloorArea : addedArea;

    if (areaForCalc <= 0) return {};

    // Include the floor area in the output for debugging and display
    detailedCosts['total floor area'] = totalFloorArea;

    double subTotal = 0;

    // Scaled Fixed Costs
    final preliminaries = _baseFixedCosts['Preliminaries']! + (totalFloorArea * 15); // Scale with overall size
    final demolition = _baseFixedCosts['Demolition_Structure']! + (addedArea * 20); // Scale with new area
    final waste = _baseFixedCosts['Waste_Skips']! + (areaForCalc * 10); // Scale with work area

    final scaledFixedCosts = {
      'Preliminaries': preliminaries,
      'Demolition_Structure': demolition,
      'Waste_Skips': waste,
      'Statutory_Compliance': _baseFixedCosts['Statutory_Compliance']!,
    };

    for (final category in costCategories) {
      double cost = 0;
      if (_costsPerSqM.containsKey(category)) {
        cost = _costsPerSqM[category]! * areaForCalc;
      } else if (scaledFixedCosts.containsKey(category)) {
        cost = scaledFixedCosts[category]!;
      } else if (_itemCosts.containsKey(category)) {
        cost = _itemCosts[category]!;
      }
      detailedCosts[category] = cost;
      subTotal += cost;
    }

    detailedCosts['Build Cost Sub-total'] = subTotal;

    final professionalFees = subTotal * _professionalFeesPercentage;
    detailedCosts['Professional Fees (12%)'] = professionalFees;

    final contingency = (subTotal + professionalFees) * _contingencyPercentage;
    detailedCosts['Contingency (10%)'] = contingency;

    final totalBuildCost = subTotal + professionalFees + contingency;
    detailedCosts['Total Build Cost'] = totalBuildCost;
    
    double vat = 0;
    if (scenario != 'Full Refurbishment') {
      vat = totalBuildCost * _vatPercentage;
      detailedCosts['VAT (20%)'] = vat;
    }

    detailedCosts['Total Development Cost'] = totalBuildCost + vat;

    return detailedCosts;
  }
}
