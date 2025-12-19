import 'package:flutter/foundation.dart';

class UpliftData {
  final double area;
  final double rate;
  final double uplift;

  UpliftData({required this.area, required this.rate, required this.uplift});
}

class GdvController with ChangeNotifier {
  // GDV Components
  double _gdvSold = 470000;
  double _gdvOnMarket = 490000;
  double _gdvArea = 480000;

  // Weightings
  double _weightSold = 0.50; // 50%
  double _weightOnMarket = 0.30; // 30%
  double _weightArea = 0.20; // 20%

  // Final Blended GDV
  double _finalGdv = 0;

  // GDV Bands
  double _downsidePct = 0.07; // 7%
  double _upsidePct = 0.07; // 7%
  double _cautiousGdv = 0;
  double _baseGdv = 0;
  double _optimisticGdv = 0;

  // --- Uplift Calculation Properties ---
  final double _existingInternalArea = 110; // m²

  // Uplift Rates (£/m²)
  final double _refurbUpliftRate = 450;
  final double _rearExtensionUpliftRate = 1250;
  final double _sideExtensionUpliftRate = 1150;
  final double _frontExtensionUpliftRate = 900;
  final double _garageConversionUpliftRate = 800;
  final double _loftBasicUpliftRate = 1400;
  final double _loftDormerUpliftRate = 1650;
  final double _loftEnsuiteUpliftRate = 1750;
  
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
    _calculateAllScenarioUplifts();
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

  void updateGdvSources({double? sold, double? onMarket, double? area}) {
    _gdvSold = sold ?? _gdvSold;
    _gdvOnMarket = onMarket ?? _gdvOnMarket;
    _gdvArea = area ?? _gdvArea;
    calculateFinalGdv();
  }

  void _calculateAllScenarioUplifts() {
    _scenarioUplifts = {
      'Full Refurbishment': _createUpliftData(_existingInternalArea, _refurbUpliftRate),
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
