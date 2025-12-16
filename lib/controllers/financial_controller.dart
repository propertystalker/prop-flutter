import 'package:flutter/foundation.dart';

class FinancialController with ChangeNotifier {
  double _gdv = 0;
  double _totalCost = 0;
  double _uplift = 0;
  double _roi = 0;
  double? _currentPrice;

  int _selectedScenarioIndex = 0;
  final List<String> _houseScenarios = [
    'Full Refurbishment',
    'Extensions (Rear / Side / Front)',
    'Loft Conversion',
    'Garage Conversion',
  ];

  final Map<String, double> _developmentCosts = {
    'Full Refurbishment': 50000,
    'Extensions (Rear / Side / Front)': 100000,
    'Loft Conversion': 75000,
    'Garage Conversion': 25000,
    'Flat Refurbishment Only (1–3 bed)': 40000, // Added for flats
  };

  double get gdv => _gdv;
  double get totalCost => _totalCost;
  double get uplift => _uplift;
  double get roi => _roi;
  double? get currentPrice => _currentPrice;
  int get selectedScenarioIndex => _selectedScenarioIndex;
  List<String> get houseScenarios => _houseScenarios;

  void calculateFinancials(bool isFlat) {
    if (_currentPrice == null) return;

    final selectedScenario = isFlat
        ? 'Flat Refurbishment Only (1–3 bed)'
        : _houseScenarios[_selectedScenarioIndex];
    final developmentCost = _developmentCosts[selectedScenario] ?? 0;

    _totalCost = _currentPrice! + developmentCost;
    // Estimated GDV: for demo purposes, let's assume GDV is total cost + 25% uplift
    _gdv = _totalCost * 1.25;
    _uplift = _gdv - _totalCost;
    _roi = (_totalCost > 0) ? (_uplift / _totalCost) * 100 : 0;
    notifyListeners();
  }

  void setCurrentPrice(double price) {
    _currentPrice = price;
    calculateFinancials(false); // You might need a way to determine if it's a flat here
  }

  void nextScenario(bool isFlat) {
    _selectedScenarioIndex = (_selectedScenarioIndex + 1) % _houseScenarios.length;
    calculateFinancials(isFlat);
  }

  void previousScenario(bool isFlat) {
    _selectedScenarioIndex = (_selectedScenarioIndex - 1 + _houseScenarios.length) % _houseScenarios.length;
    calculateFinancials(isFlat);
  }
}
