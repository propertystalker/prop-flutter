import 'package:flutter/foundation.dart';
import 'package:myapp/utils/build_cost_engine.dart';

class FinancialController with ChangeNotifier {
  // Main Financial Metrics
  double _totalCost = 0;
  double _uplift = 0;
  double _roi = 0;
  double? _currentPrice;
  double _gdv = 0;

  // Risk & Growth Metrics
  double _areaGrowth = 0;
  double _marketGrowth = 0.0;
  String _riskIndicator = 'Low';

  // Property & Scenario Data
  double _existingInternalArea = 0.0; // Correctly initialize to 0.0
  String _selectedScenario = 'Full Refurbishment';
  String _propertyType = 'Terraced';
  String _epcRating = 'D';

  // Detailed cost breakdown from the engine
  Map<String, double> _detailedCosts = {};

  // --- Scenario Definitions (Not part of cost engine) ---
  final Map<String, double> _scenarioAddedArea = {
    'Full Refurbishment': 0, 'Rear single-storey extension': 48, 'Rear two-storey extension': 96,
    'Side single-storey extension': 18, 'Side two-storey extension': 36, 'Porch / small front single-storey extension': 6,
    'Full-width front single-storey extension': 15, 'Full-width front two-storey front extension': 30,
    'Standard single garage conversion': 18, 'Basic loft conversion (Velux)': 25, 'Dormer loft conversion': 30,
    'Dormer loft with ensuite': 30,
  };

  final Map<String, bool> _scenarioPlanningRequired = {
      'Full Refurbishment': false, 'Rear single-storey extension': false,
      'Rear two-storey extension': true, 'Side single-storey extension': false,
      'Side two-storey extension': true, 'Porch / small front single-storey extension': true,
      'Full-width front single-storey extension': true, 'Full-width front two-storey front extension': true,
      'Standard single garage conversion': false, 'Basic loft conversion (Velux)': false,
      'Dormer loft conversion': false, 'Dormer loft with ensuite': false,
  };

  // --- Getters ---
  double get totalCost => _totalCost;
  double get uplift => _uplift;
  double get roi => _roi;
  double? get currentPrice => _currentPrice;
  double get gdv => _gdv;
  double get areaGrowth => _areaGrowth;
  double get marketGrowth => _marketGrowth;
  String get riskIndicator => _riskIndicator;
  String get selectedScenario => _selectedScenario;
  double get totalInternalArea => _existingInternalArea;
  Map<String, double> get detailedCosts => _detailedCosts;

  // Constructor - No longer requires initial area
  FinancialController();

  // Method to update property details when a property is selected
  void updatePropertyData({
    required double totalFloorArea,
    required String propertyType,
    required String epcRating,
  }) {
    _existingInternalArea = totalFloorArea > 0 ? totalFloorArea : 0.0; // Use 0.0 as the fallback
    _propertyType = propertyType;
    _epcRating = epcRating;
    // We don't notify listeners here, as a calculation will follow immediately
  }

  void setMarketGrowth(String? growth) {
    if (growth != null) {
      final growthValue = double.tryParse(growth.replaceAll('%', ''));
      if (growthValue != null) {
        _marketGrowth = growthValue;
        notifyListeners();
      }
    }
  }

  void calculateFinancials(String scenario, double baseGdv, double scenarioUplift) {
    _selectedScenario = scenario;
    if (_currentPrice == null) return;

    final costEngine = BuildCostEngine(
      scenario: scenario,
      totalFloorArea: _existingInternalArea,
      propertyType: _propertyType,
      epcRating: _epcRating,
    );

    _detailedCosts = costEngine.calculateBuildCosts();
    final developmentCost = _detailedCosts['Total Development Cost'] ?? 0;

    _gdv = baseGdv + scenarioUplift;
    _totalCost = (_currentPrice ?? 0) + developmentCost;
    _uplift = _gdv - _totalCost;
    _roi = (_totalCost > 0) ? (_uplift / _totalCost) * 100 : 0;

    final addedArea = _scenarioAddedArea[scenario] ?? 0;
    _areaGrowth = (_existingInternalArea > 0) ? (addedArea / _existingInternalArea) * 100 : 0;
    final needsPlanning = _scenarioPlanningRequired[scenario] ?? false;
    _riskIndicator = _calculateRisk(needsPlanning, _areaGrowth);

    notifyListeners();
  }

  String _calculateRisk(bool planningRequired, double areaGrowth) {
    if (planningRequired && areaGrowth > 50) return 'Higher';
    if (planningRequired || (areaGrowth >= 25 && areaGrowth <= 50)) return 'Medium';
    return 'Low';
  }

  void setCurrentPrice(double price, double gdv) {
    _currentPrice = price;
    calculateFinancials(_selectedScenario, gdv, 0);
  }
}
