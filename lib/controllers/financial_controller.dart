import 'package:flutter/foundation.dart';

class FinancialController with ChangeNotifier {
  // Main Financial Metrics
  double _totalCost = 0;
  double _uplift = 0;
  double _roi = 0;
  double? _currentPrice;
  double _gdv = 0;

  // New Uplift & Risk Metrics
  double _areaGrowth = 0;
  String _riskIndicator = 'Low';
  final double _existingInternalArea; // Passed in at initialization

  // --- Data for Calculations ---

  // Base costs for each category
  final Map<String, double> _baseCosts = {
    'Preliminaries': 5000, 'Demolition / Structure': 7000, 'Foundations': 10000, 'Groundworks / Drainage': 8000,
    'Structure & Shell': 15000, 'Structural Steel': 5000, 'Roofing': 8000, 'Windows / Doors': 6000,
    'Insulation + Plastering': 9000, 'Internal Finishes': 10000, 'Kitchen': 8000, 'Bathrooms': 5000,
    'Electrical': 7000, 'Plumbing / Heating': 9000, 'Waste / Skips': 2000, 'Statutory / Compliance': 3000,
    'Professional Fees': 10000, 'Contingency': 5000, 'VAT': 0,
  };

  // Added area (m²) for each scenario
  final Map<String, double> _scenarioAddedArea = {
    'Full Refurbishment': 0, 'Rear single-storey extension': 48, 'Rear two-storey extension': 96,
    'Side single-storey extension': 18, 'Side two-storey extension': 36, 'Porch / small front single-storey extension': 6,
    'Full-width front single-storey extension': 15, 'Full-width front two-storey front extension': 30,
    'Standard single garage conversion': 18, 'Basic loft conversion (Velux)': 25, 'Dormer loft conversion': 30,
    'Dormer loft with ensuite': 30,
  };

  // Planning requirements for each scenario
  final Map<String, bool> _scenarioPlanningRequired = {
    'Full Refurbishment': false, 'Rear single-storey extension': false, // Typically PD
    'Rear two-storey extension': true, 'Side single-storey extension': false, // Typically PD
    'Side two-storey extension': true, 'Porch / small front single-storey extension': true,
    'Full-width front single-storey extension': true, 'Full-width front two-storey front extension': true,
    'Standard single garage conversion': false, // Typically PD
    'Basic loft conversion (Velux)': false, // Typically PD
    'Dormer loft conversion': false, // Often PD, but can require planning
    'Dormer loft with ensuite': false, // Often PD
  };

  // Cost categories applicable to each scenario
  final Map<String, List<String>> _scenarioCostMatrix = {
    'Full Refurbishment': ['Preliminaries', 'Demolition / Structure', 'Insulation + Plastering', 'Internal Finishes', 'Kitchen', 'Bathrooms', 'Electrical', 'Plumbing / Heating', 'Waste / Skips', 'Statutory / Compliance', 'Professional Fees', 'Contingency'],
    'Rear single-storey extension': ['Preliminaries', 'Demolition / Structure', 'Foundations', 'Groundworks / Drainage', 'Structure & Shell', 'Structural Steel', 'Roofing', 'Windows / Doors', 'Insulation + Plastering', 'Internal Finishes', 'Electrical', 'Plumbing / Heating', 'Waste / Skips', 'Statutory / Compliance', 'Professional Fees', 'Contingency'],
    'Rear two-storey extension': ['Preliminaries', 'Demolition / Structure', 'Foundations', 'Groundworks / Drainage', 'Structure & Shell', 'Structural Steel', 'Roofing', 'Windows / Doors', 'Insulation + Plastering', 'Internal Finishes', 'Electrical', 'Plumbing / Heating', 'Waste / Skips', 'Statutory / Compliance', 'Professional Fees', 'Contingency'],
    'Side single-storey extension': ['Preliminaries', 'Demolition / Structure', 'Foundations', 'Groundworks / Drainage', 'Structure & Shell', 'Structural Steel', 'Roofing', 'Windows / Doors', 'Insulation + Plastering', 'Internal Finishes', 'Electrical', 'Plumbing / Heating', 'Waste / Skips', 'Statutory / Compliance', 'Professional Fees', 'Contingency'],
    'Side two-storey extension': ['Preliminaries', 'Demolition / Structure', 'Foundations', 'Groundworks / Drainage', 'Structure & Shell', 'Structural Steel', 'Roofing', 'Windows / Doors', 'Insulation + Plastering', 'Internal Finishes', 'Electrical', 'Plumbing / Heating', 'Waste / Skips', 'Statutory / Compliance', 'Professional Fees', 'Contingency'],
    'Porch / small front single-storey extension': ['Preliminaries', 'Demolition / Structure', 'Foundations', 'Groundworks / Drainage', 'Structure & Shell', 'Structural Steel', 'Roofing', 'Windows / Doors', 'Insulation + Plastering', 'Internal Finishes', 'Electrical', 'Waste / Skips', 'Statutory / Compliance', 'Professional Fees', 'Contingency'],
    'Full-width front single-storey extension': ['Preliminaries', 'Demolition / Structure', 'Foundations', 'Groundworks / Drainage', 'Structure & Shell', 'Structural Steel', 'Roofing', 'Windows / Doors', 'Insulation + Plastering', 'Internal Finishes', 'Electrical', 'Plumbing / Heating', 'Waste / Skips', 'Statutory / Compliance', 'Professional Fees', 'Contingency'],
    'Full-width front two-storey front extension': ['Preliminaries', 'Demolition / Structure', 'Foundations', 'Groundworks / Drainage', 'Structure & Shell', 'Structural Steel', 'Roofing', 'Windows / Doors', 'Insulation + Plastering', 'Internal Finishes', 'Electrical', 'Plumbing / Heating', 'Waste / Skips', 'Statutory / Compliance', 'Professional Fees', 'Contingency'],
    'Standard single garage conversion': ['Preliminaries', 'Demolition / Structure', 'Structure & Shell', 'Windows / Doors', 'Insulation + Plastering', 'Internal Finishes', 'Electrical', 'Plumbing / Heating', 'Waste / Skips', 'Statutory / Compliance', 'Professional Fees', 'Contingency'],
    'Basic loft conversion (Velux)': ['Preliminaries', 'Structural Steel', 'Roofing', 'Insulation + Plastering', 'Internal Finishes', 'Electrical', 'Waste / Skips', 'Statutory / Compliance', 'Professional Fees', 'Contingency'],
    'Dormer loft conversion': ['Preliminaries', 'Structure & Shell', 'Structural Steel', 'Roofing', 'Windows / Doors', 'Insulation + Plastering', 'Internal Finishes', 'Electrical', 'Plumbing / Heating', 'Waste / Skips', 'Statutory / Compliance', 'Professional Fees', 'Contingency'],
    'Dormer loft with ensuite': ['Preliminaries', 'Structure & Shell', 'Structural Steel', 'Roofing', 'Windows / Doors', 'Insulation + Plastering', 'Internal Finishes', 'Bathrooms', 'Electrical', 'Plumbing / Heating', 'Waste / Skips', 'Statutory / Compliance', 'Professional Fees', 'Contingency'],
  };

  // --- Getters ---
  double get totalCost => _totalCost;
  double get uplift => _uplift;
  double get roi => _roi;
  double? get currentPrice => _currentPrice;
  double get gdv => _gdv;
  double get areaGrowth => _areaGrowth;
  String get riskIndicator => _riskIndicator;

  // Constructor
  FinancialController({required double existingInternalArea}) : _existingInternalArea = existingInternalArea;

  // --- Main Calculation Method ---
  void calculateFinancials(String scenario, double gdv) {
    if (_currentPrice == null) return;
    _gdv = gdv;

    // Standard financial calculations
    final costCategories = _scenarioCostMatrix[scenario] ?? [];
    final developmentCost = costCategories.fold<double>(0.0, (sum, category) => sum + (_baseCosts[category] ?? 0));
    _totalCost = _currentPrice! + developmentCost;
    _uplift = _gdv - _totalCost;
    _roi = (_totalCost > 0) ? (_uplift / _totalCost) * 100 : 0;

    // New Area Growth & Risk calculations
    final addedArea = _scenarioAddedArea[scenario] ?? 0;
    _areaGrowth = (_existingInternalArea > 0) ? (addedArea / _existingInternalArea) * 100 : 0;

    final needsPlanning = _scenarioPlanningRequired[scenario] ?? false;
    _riskIndicator = _calculateRisk(needsPlanning, _areaGrowth);

    notifyListeners();
  }

  String _calculateRisk(bool planningRequired, double areaGrowth) {
    final areaGrowthPct = areaGrowth; // areaGrowth is already in %

    if (planningRequired && areaGrowthPct > 50) {
      return 'Higher';
    }
    if (planningRequired || (areaGrowthPct >= 25 && areaGrowthPct <= 50)) {
      return 'Medium';
    }
    return 'Low';
  }

  void setCurrentPrice(double price, double gdv) {
    _currentPrice = price;
    // Recalculate with a default scenario when price is set
    calculateFinancials('Full Refurbishment', gdv);
  }
}
