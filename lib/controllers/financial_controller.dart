import 'package:flutter/foundation.dart';

class FinancialController with ChangeNotifier {
  double _gdv = 0;
  double _totalCost = 0;
  double _uplift = 0;
  double _roi = 0;
  double? _currentPrice;

  final Map<String, double> _developmentCosts = {
    'Full Refurbishment': 50000,
    'Rear single-storey extension': 70000,
    'Rear two-storey extension': 120000,
    'Side single-storey extension': 60000,
    'Side two-storey extension': 110000,
    'Porch / small front single-storey extension': 25000,
    'Full-width front single-storey extension': 80000,
    'Full-width front two-storey front extension': 150000,
    'Standard single garage conversion': 25000,
    'Basic loft conversion (Velux)': 40000,
    'Dormer loft conversion': 60000,
    'Dormer loft with ensuite': 75000,
    'Flat Refurbishment Only (1–3 bed)': 40000, // Added for flats
  };

  double get gdv => _gdv;
  double get totalCost => _totalCost;
  double get uplift => _uplift;
  double get roi => _roi;
  double? get currentPrice => _currentPrice;

  void calculateFinancials(String scenario) {
    if (_currentPrice == null) return;

    final developmentCost = _developmentCosts[scenario] ?? 0;

    _totalCost = _currentPrice! + developmentCost;
    // Estimated GDV: for demo purposes, let's assume GDV is total cost + 25% uplift
    _gdv = _totalCost * 1.25;
    _uplift = _gdv - _totalCost;
    _roi = (_totalCost > 0) ? (_uplift / _totalCost) * 100 : 0;
    notifyListeners();
  }

  void setCurrentPrice(double price) {
    _currentPrice = price;
    calculateFinancials('Full Refurbishment'); // Default scenario
  }
}
