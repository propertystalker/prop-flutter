
enum PropertyForm { terraced, semiDetached, detached, flat, unknown }

class BuildCostEngine {
  final String scenario;
  final double totalFloorArea;
  final String propertyType;
  final String builtForm; 
  final String epcRating;

  BuildCostEngine({
    required this.scenario,
    required this.totalFloorArea,
    required this.propertyType,
    required this.builtForm,
    required this.epcRating,
  });

  // --- Cost Data from the more detailed engine ---
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

  static const Map<String, double> _baseFixedCosts = {
    'Preliminaries': 1500,
    'Demolition_Structure': 2500,
    'Waste_Skips': 1000,
    'Statutory_Compliance': 1500,
  };

  static const Map<String, double> _itemCosts = {
    'Kitchen_Basic': 5000,
    'Kitchen_Mid': 12000,
    'Kitchen_High': 25000,
    'Bathroom_Basic': 4000,
    'Bathroom_Mid': 8000,
    'Bathroom_High': 15000,
  };

  static const double _professionalFeesPercentage = 0.12;
  static const double _contingencyPercentage = 0.10;
  static const double _vatPercentage = 0.20;
  
  // --- Area Calculation Config from the area-focused engine ---
  static const Map<PropertyForm, double> _houseWidthByType = {
    PropertyForm.terraced: 5.0,
    PropertyForm.semiDetached: 7.0,
    PropertyForm.detached: 9.0,
    PropertyForm.flat: 6.0,
    PropertyForm.unknown: 6.0,
  };

  static const Map<PropertyForm, double> _assumedStoreysByType = {
    PropertyForm.terraced: 2.0,
    PropertyForm.semiDetached: 2.0,
    PropertyForm.detached: 2.0,
    PropertyForm.flat: 1.0,
    PropertyForm.unknown: 2.0,
  };

  static const Map<PropertyForm, double> _rearDepthByType = {
    PropertyForm.terraced: 6.0,
    PropertyForm.semiDetached: 8.0,
    PropertyForm.detached: 8.0,
    PropertyForm.flat: 6.0,
    PropertyForm.unknown: 6.0,
  };

  static const double _sideExtensionWidthRatio = 0.5;
  
  static const Map<PropertyForm, double> _loftVolumesByType = {
    PropertyForm.terraced: 40.0,
    PropertyForm.semiDetached: 50.0,
    PropertyForm.detached: 50.0,
    PropertyForm.flat: 40.0,
    PropertyForm.unknown: 40.0,
  };

  static const double _loftAverageHeight = 2.4;
  static const double _assumedGarageArea = 18.0;
  static const double _frontExtensionDepth = 3.0;
  static const double _defaultFootprintArea = 50.0;
  
  static const Map<String, List<String>> _scenarioCostMatrix = {
      'Full Refurbishment': ['Preliminaries', 'Demolition_Structure', 'Insulation_Plastering', 'Internal_Finishes_Mid', 'Kitchen_Mid', 'Bathroom_Mid', 'Electrical_FirstFix', 'Electrical_SecondFix', 'Plumbing_Heating_FirstFix', 'Plumbing_Heating_SecondFix', 'Waste_Skips', 'Statutory_Compliance'],
      'Rear single-storey extension': ['Preliminaries', 'Demolition_Structure', 'Foundations', 'Groundworks_Drainage', 'Structure_Shell', 'Structural_Steel', 'Roofing', 'Windows_Doors', 'Insulation_Plastering', 'Internal_Finishes_Basic', 'Electrical_FirstFix', 'Electrical_SecondFix', 'Plumbing_Heating_FirstFix', 'Plumbing_Heating_SecondFix', 'Waste_Skips', 'Statutory_Compliance'],
      'Side single-storey extension': ['Preliminaries', 'Demolition_Structure', 'Foundations', 'Groundworks_Drainage', 'Structure_Shell', 'Structural_Steel', 'Roofing', 'Windows_Doors', 'Insulation_Plastering', 'Internal_Finishes_Basic', 'Electrical_FirstFix', 'Plumbing_Heating_FirstFix', 'Waste_Skips', 'Statutory_Compliance'],
      'Standard single garage conversion': ['Demolition_Structure', 'Structure_Shell', 'Windows_Doors', 'Insulation_Plastering', 'Internal_Finishes_Basic', 'Electrical_FirstFix', 'Electrical_SecondFix', 'Waste_Skips'],
      'Dormer loft with ensuite': ['Preliminaries', 'Structure_Shell', 'Structural_Steel', 'Roofing', 'Windows_Doors', 'Insulation_Plastering', 'Internal_Finishes_Basic', 'Bathroom_Mid', 'Electrical_FirstFix', 'Plumbing_Heating_FirstFix', 'Waste_Skips', 'Statutory_Compliance'],
      // Add other scenarios as needed, mapping them to cost components
  };

  // --- MAIN CALCULATION METHOD ---
  Map<String, double> calculateBuildCosts() {
    final costCategories = _scenarioCostMatrix[scenario] ?? [];
    final detailedCosts = <String, double>{};

    final addedArea = _calculateScenarioArea();
    final areaForCalc = (scenario == 'Full Refurbishment') ? totalFloorArea : addedArea;

    if (areaForCalc <= 0) return {'Total Development Cost': 0};

    detailedCosts['calculatedAreaM2'] = areaForCalc;

    double subTotal = 0;

    // Scaled Fixed Costs
    final preliminaries = _baseFixedCosts['Preliminaries']! + (totalFloorArea * 15);
    final demolition = _baseFixedCosts['Demolition_Structure']! + (addedArea * 20);
    final waste = _baseFixedCosts['Waste_Skips']! + (areaForCalc * 10);

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

  // --- DYNAMIC AREA CALCULATION LOGIC (from bulldog) ---
  double _calculateScenarioArea() {
    switch (scenario) {
      case 'Full Refurbishment':
        return totalFloorArea;
      case 'Rear single-storey extension':
        return _pdRearGroundFloorArea();
      case 'Rear two-storey extension':
        return _pdRearGroundFloorArea() * 2;
      case 'Side single-storey extension':
        return _pdSideGroundFloorArea();
      case 'Side two-storey extension':
        return _pdSideGroundFloorArea() * 2;
      case 'Porch / small front single-storey extension':
        return 6.0; // Standard small area
      case 'Full-width front single-storey extension':
        return _pdFullWidthFrontSingleStoreyArea();
      case 'Full-width front two-storey front extension':
        return _pdFullWidthFrontSingleStoreyArea() * 2;
      case 'Standard single garage conversion':
        return _assumedGarageArea;
      case 'Basic loft conversion (Velux)':
      case 'Dormer loft conversion':
      case 'Loft conversion with dormer':
      case 'Dormer loft with ensuite':
        return _pdLoftArea();
      default:
        // Fallback for scenarios not yet in the detailed matrix
        final Map<String, double> simpleAreaMap = {
          'Rear single-storey extension': 48, 'Rear two-storey extension': 96,
          'Side single-storey extension': 18, 'Side two-storey extension': 36,
          'Porch / small front single-storey extension': 6,
          'Full-width front single-storey extension': 15, 'Full-width front two-storey front extension': 30,
          'Standard single garage conversion': 18, 'Basic loft conversion (Velux)': 25,
          'Dormer loft conversion': 30, 'Dormer loft with ensuite': 30,
        };
        return simpleAreaMap[scenario] ?? 0;
    }
  }

  PropertyForm _resolvePropertyForm() {
    final combined = '$propertyType $builtForm'.toLowerCase();
    if (combined.contains('terrace')) return PropertyForm.terraced;
    if (combined.contains('semi')) return PropertyForm.semiDetached;
    if (combined.contains('detached')) return PropertyForm.detached;
    if (combined.contains('flat') || combined.contains('maisonette') || combined.contains('apartment')) return PropertyForm.flat;
    return PropertyForm.unknown;
  }

  double _footprintArea(PropertyForm form) {
    final storeys = _assumedStoreysByType[form] ?? 2.0;
    if (storeys <= 0) return _defaultFootprintArea;
    final footprint = totalFloorArea / storeys;
    return (footprint > 0) ? footprint : _defaultFootprintArea;
  }

  double _pdRearGroundFloorArea() {
    final form = _resolvePropertyForm();
    final width = _houseWidthByType[form] ?? 0;
    final depth = _rearDepthByType[form] ?? 0;
    return (width * depth).clamp(0, double.infinity);
  }

  double _pdSideGroundFloorArea() {
    final form = _resolvePropertyForm();
    final footprintArea = _footprintArea(form);
    final width = _houseWidthByType[form] ?? 0;
    if (width <= 0) return 0;
    final depth = footprintArea / width;
    final extensionWidth = width * _sideExtensionWidthRatio;
    return (extensionWidth * depth).clamp(0, double.infinity);
  }

  double _pdFullWidthFrontSingleStoreyArea() {
    final form = _resolvePropertyForm();
    final width = _houseWidthByType[form] ?? 0;
    return (width * _frontExtensionDepth).clamp(0, double.infinity);
  }

  double _pdLoftArea() {
    final form = _resolvePropertyForm();
    final volume = _loftVolumesByType[form] ?? 0;
    if (_loftAverageHeight <= 0) return 0;
    return (volume / _loftAverageHeight).clamp(0, double.infinity);
  }
}
