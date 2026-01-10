import 'package:flutter/foundation.dart';

class UpliftData {
  final double area;
  final double rate;
  final double uplift;

  UpliftData({required this.area, required this.rate, required this.uplift});
}

class GdvController with ChangeNotifier {
  // GDV Components
  double _gdvSold = 0;
  double _gdvOnMarket = 0;
  double _gdvArea = 0;

  // Weightings
  final double _weightSold = 0.50; // 50%
  final double _weightOnMarket = 0.30; // 30%
  final double _weightArea = 0.20; // 20%

  // Final Blended GDV
  double _finalGdv = 0;

  // GDV Bands
  final double _downsidePct = 0.07; // 7%
  final double _upsidePct = 0.07; // 7%
  double _cautiousGdv = 0;
  double _baseGdv = 0;
  double _optimisticGdv = 0;

  // --- Uplift Calculation Properties ---
  double _currentTotalFloorArea = 0;
  
  // --- Uplift Rate Factors (as a percentage of base £/m²) ---
  final double _refurbUpliftFactor = 0.20;
  final double _rearExtensionUpliftFactor = 0.55;
  final double _sideExtensionUpliftFactor = 0.50;
  final double _frontExtensionUpliftFactor = 0.40;
  final double _garageConversionUpliftFactor = 0.35;
  final double _loftBasicUpliftFactor = 0.62;
  final double _loftDormerUpliftFactor = 0.73;
  final double _loftEnsuiteUpliftFactor = 0.77;

  // --- Dynamic Uplift Rates (£/m²) ---
  double _refurbUpliftRate = 450;
  double _rearExtensionUpliftRate = 1250;
  double _sideExtensionUpliftRate = 1150;
  double _frontExtensionUpliftRate = 900;
  double _garageConversionUpliftRate = 800;
  double _loftBasicUpliftRate = 1400;
  double _loftDormerUpliftRate = 1650;
  double _loftEnsuiteUpliftRate = 1750;
  
  Map<String, UpliftData> _scenarioUplifts = {};

  // Getters
  double get gdvSold => _gdvSold;
  double get gdvOnMarket => _gdvOnMarket;
  double get gdvArea => _gdvArea;
  double get weightSold => _weightSold;
  double get weightOnMarket => _weightOnMarket;
  double get weightArea => _weightArea;
  double get finalGdv => _finalGdv;
  double get cautiousGdv => _cautiousGdv;
  double get baseGdv => _baseGdv;
  double get optimisticGdv => _optimisticGdv;
  Map<String, UpliftData> get scenarioUplifts => _scenarioUplifts;

  GdvController() {
    calculateFinalGdv();
  }

  void calculateFinalGdv() {
    _finalGdv = (_gdvSold * _weightSold) + 
                (_gdvOnMarket * _weightOnMarket) + 
                (_gdvArea * _weightArea);

    _baseGdv = _finalGdv;
    _cautiousGdv = _finalGdv * (1 - _downsidePct);
    _optimisticGdv = _finalGdv * (1 + _upsidePct);

    notifyListeners();
  }

  Future<void> calculateGdv({
    required int habitableRooms,
    required double totalFloorArea,
    required double currentPrice,
  }) async {
    _currentTotalFloorArea = totalFloorArea;

    // Use currentPrice as the core of the GDV estimation, removing randomness.
    final baseGdv = currentPrice > 0 ? currentPrice : 80000 * habitableRooms.toDouble();

    _gdvSold = baseGdv;
    _gdvOnMarket = baseGdv;
    _gdvArea = baseGdv;

    // Recalculate the blended GDV and bands
    calculateFinalGdv();
    
    // Update uplift rates based on the new, more accurate price.
    updateUpliftRates(currentPrice: _finalGdv, totalFloorArea: totalFloorArea);
  }

  void updateGdvSources({double? sold, double? onMarket, double? area}) {
    _gdvSold = sold ?? _gdvSold;
    _gdvOnMarket = onMarket ?? _gdvOnMarket;
    _gdvArea = area ?? _gdvArea;
    calculateFinalGdv();
  }

  void updateUpliftRates({required double currentPrice, required double totalFloorArea}) {
    if (totalFloorArea == 0) return; // Avoid division by zero

    _currentTotalFloorArea = totalFloorArea;
    final double baseValuePerSqM = currentPrice / totalFloorArea;

    _refurbUpliftRate = baseValuePerSqM * _refurbUpliftFactor;
    _rearExtensionUpliftRate = baseValuePerSqM * _rearExtensionUpliftFactor;
    _sideExtensionUpliftRate = baseValuePerSqM * _sideExtensionUpliftFactor;
    _frontExtensionUpliftRate = baseValuePerSqM * _frontExtensionUpliftFactor;
    _garageConversionUpliftRate = baseValuePerSqM * _garageConversionUpliftFactor;
    _loftBasicUpliftRate = baseValuePerSqM * _loftBasicUpliftFactor;
    _loftDormerUpliftRate = baseValuePerSqM * _loftDormerUpliftFactor;
    _loftEnsuiteUpliftRate = baseValuePerSqM * _loftEnsuiteUpliftFactor;

    calculateAllScenarioUplifts();
  }

  void calculateAllScenarioUplifts() {
    _scenarioUplifts = {
      'Full Refurbishment': _createUpliftData(_currentTotalFloorArea, _refurbUpliftRate),
      'Rear single-storey extension': _createUpliftData(48, _rearExtensionUpliftRate),
      'Rear two-storey extension': _createUpliftData(96, _rearExtensionUpliftRate),
      'Side single-storey extension': _createUpliftData(18, _sideExtensionUpliftRate),
      'Side two-storey extension': _createUpliftData(36, _sideExtensionUpliftRate),
      'Porch / small front single-storey extension': _createUpliftData(6, _frontExtensionUpliftRate),
      'Full-width front single-storey extension': _createUpliftData(15, _frontExtensionUpliftRate),
      'Full-width front two-storey front extension': _createUpliftData(30, _frontExtensionUpliftRate),
      'Standard single garage conversion': _createUpliftData(18, _garageConversionUpliftRate),
      'Basic loft conversion (Velux)': _createUpliftData(25, _loftBasicUpliftRate),
      'Dormer loft conversion': _createUpliftData(30, _loftDormerUpliftRate),
      'Dormer loft with ensuite': _createUpliftData(30, _loftEnsuiteUpliftRate),
    };
    notifyListeners();
  }

  UpliftData _createUpliftData(double area, double rate) {
    return UpliftData(area: area, rate: rate, uplift: area * rate);
  }
}
