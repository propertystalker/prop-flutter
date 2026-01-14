enum RefurbBand { light, medium, heavy }

enum PropertyForm { terraced, semiDetached, detached, flat, unknown }

class BuildCostConfig {
  const BuildCostConfig({
    required this.epcBandMap,
    required this.refurbRatesByBand,
    required this.singleStoreyRate,
    required this.twoStoreyRate,
    required this.loftRates,
    required this.garageConversionRate,
    required this.houseWidthByType,
    required this.assumedStoreysByType,
    required this.rearDepthByType,
    required this.sideExtensionWidthRatio,
    required this.loftVolumesByType,
    required this.loftAverageHeight,
    required this.assumedGarageArea,
    required this.assumedFrontAreas,
    required this.defaultFootprintArea,
    required this.planningRequiredScenarios,
    required this.frontExtensionDepth,
  });

  final Map<String, RefurbBand> epcBandMap;
  final Map<RefurbBand, double> refurbRatesByBand;
  final double singleStoreyRate;
  final double twoStoreyRate;
  final Map<String, double> loftRates;
  final double garageConversionRate;
  final Map<PropertyForm, double> houseWidthByType;
  final Map<PropertyForm, double> assumedStoreysByType;
  final Map<PropertyForm, double> rearDepthByType;
  final double sideExtensionWidthRatio;
  final Map<PropertyForm, double> loftVolumesByType;
  final double loftAverageHeight;
  final double assumedGarageArea;
  final Map<String, double> assumedFrontAreas;
  final double defaultFootprintArea;
  final Set<String> planningRequiredScenarios;
  final double frontExtensionDepth;

  static const BuildCostConfig defaults = BuildCostConfig(
    epcBandMap: {
      'A': RefurbBand.light,
      'B': RefurbBand.light,
      'C': RefurbBand.medium,
      'D': RefurbBand.medium,
      'E': RefurbBand.heavy,
      'F': RefurbBand.heavy,
      'G': RefurbBand.heavy,
    },
    refurbRatesByBand: {
      RefurbBand.light: 350,
      RefurbBand.medium: 550,
      RefurbBand.heavy: 800,
    },
    singleStoreyRate: 1800,
    twoStoreyRate: 2100,
    loftRates: {
      'Basic loft conversion (Velux)': 1400,
      'Dormer loft conversion': 1650,
      'Loft conversion with dormer': 1650,
      'Dormer loft with ensuite': 1750,
    },
    garageConversionRate: 900,
    houseWidthByType: {
      PropertyForm.terraced: 5.0,
      PropertyForm.semiDetached: 7.0,
      PropertyForm.detached: 9.0,
      PropertyForm.flat: 6.0,
      PropertyForm.unknown: 6.0,
    },
    assumedStoreysByType: {
      PropertyForm.terraced: 2.0,
      PropertyForm.semiDetached: 2.0,
      PropertyForm.detached: 2.0,
      PropertyForm.flat: 1.0,
      PropertyForm.unknown: 2.0,
    },
    rearDepthByType: {
      PropertyForm.terraced: 6.0,
      PropertyForm.semiDetached: 8.0,
      PropertyForm.detached: 8.0,
      PropertyForm.flat: 6.0,
      PropertyForm.unknown: 6.0,
    },
    sideExtensionWidthRatio: 0.5,
    loftVolumesByType: {
      PropertyForm.terraced: 40.0,
      PropertyForm.semiDetached: 50.0,
      PropertyForm.detached: 50.0,
      PropertyForm.flat: 40.0,
      PropertyForm.unknown: 40.0,
    },
    loftAverageHeight: 2.4,
    assumedGarageArea: 18.0,
    assumedFrontAreas: {
      'Porch / small front single-storey extension': 6.0,
    },
    defaultFootprintArea: 50.0,
    planningRequiredScenarios: {
      'Rear two-storey extension',
      'Side two-storey extension',
      'Porch / small front single-storey extension',
      'Full-width front single-storey extension',
      'Full-width front two-storey front extension',
    },
    frontExtensionDepth: 3.0,
  );
}

class BuildCostEngine {
  BuildCostEngine({
    required this.config,
    required this.totalInternalArea,
    required this.epcRating,
    required this.propertyType,
    required this.builtForm,
  });

  final BuildCostConfig config;
  final double totalInternalArea;
  final String epcRating;
  final String propertyType;
  final String builtForm;

  double calculateScenarioArea(String scenario) {
    switch (scenario) {
      case 'Full Refurbishment':
        return totalInternalArea;
      case 'Rear single-storey extension':
        return _pdRearGroundFloorArea();
      case 'Rear two-storey extension':
        return _pdRearGroundFloorArea() * 2;
      case 'Side single-storey extension':
        return _pdSideGroundFloorArea();
      case 'Side two-storey extension':
        return _pdSideTwoStoreyArea();
      case 'Porch / small front single-storey extension':
        return config.assumedFrontAreas[scenario] ?? 0;
      case 'Full-width front single-storey extension':
        return _pdFullWidthFrontSingleStoreyArea();
      case 'Full-width front two-storey front extension':
        return _pdFullWidthFrontTwoStoreyArea();
      case 'Standard single garage conversion':
        return config.assumedGarageArea;
      case 'Basic loft conversion (Velux)':
      case 'Dormer loft conversion':
      case 'Loft conversion with dormer':
      case 'Dormer loft with ensuite':
        return _pdLoftArea();
      default:
        return 0;
    }
  }

  double calculateBuildCost(String scenario) {
    final area = calculateScenarioArea(scenario);
    if (area <= 0) return 0;

    if (scenario == 'Full Refurbishment') {
      final band = _refurbBandForEpc();
      final rate = config.refurbRatesByBand[band] ??
          config.refurbRatesByBand[RefurbBand.medium] ??
          0;
      return area * rate;
    }

    if (scenario == 'Rear two-storey extension' ||
        scenario == 'Side two-storey extension' ||
        scenario == 'Full-width front two-storey front extension') {
      return area * config.twoStoreyRate;
    }

    if (scenario == 'Rear single-storey extension' ||
        scenario == 'Side single-storey extension' ||
        scenario == 'Porch / small front single-storey extension' ||
        scenario == 'Full-width front single-storey extension') {
      return area * config.singleStoreyRate;
    }

    if (scenario == 'Standard single garage conversion') {
      return area * config.garageConversionRate;
    }

    final loftRate = config.loftRates[scenario];
    if (loftRate != null) {
      return area * loftRate;
    }

    return area * config.singleStoreyRate;
  }

  bool requiresPlanning(String scenario) {
    return config.planningRequiredScenarios.contains(scenario);
  }

  RefurbBand _refurbBandForEpc() {
    final rating = epcRating.trim().toUpperCase();
    return config.epcBandMap[rating] ?? RefurbBand.medium;
  }

  PropertyForm _resolvePropertyForm() {
    final combined = '$propertyType $builtForm'.toLowerCase();
    if (combined.contains('terrace')) {
      return PropertyForm.terraced;
    }
    if (combined.contains('semi')) {
      return PropertyForm.semiDetached;
    }
    if (combined.contains('detached')) {
      return PropertyForm.detached;
    }
    if (combined.contains('flat') ||
        combined.contains('maisonette') ||
        combined.contains('apartment')) {
      return PropertyForm.flat;
    }
    return PropertyForm.unknown;
  }

  double _pdRearGroundFloorArea() {
    final form = _resolvePropertyForm();
    final width = config.houseWidthByType[form] ?? 0;
    final depth = config.rearDepthByType[form] ?? 0;
    return (width * depth).clamp(0, double.infinity);
  }

  double _pdSideGroundFloorArea() {
    final form = _resolvePropertyForm();
    final footprintArea = _footprintArea(form);
    final width = config.houseWidthByType[form] ?? 0;
    if (width <= 0) return 0;
    final depth = footprintArea / width;
    final extensionWidth = width * config.sideExtensionWidthRatio;
    return (extensionWidth * depth).clamp(0, double.infinity);
  }

  double _pdSideTwoStoreyArea() {
    return _pdSideGroundFloorArea() * 2;
  }

  double _pdFullWidthFrontSingleStoreyArea() {
    final form = _resolvePropertyForm();
    final width = config.houseWidthByType[form] ?? 0;
    return (width * config.frontExtensionDepth).clamp(0, double.infinity);
  }

  double _pdFullWidthFrontTwoStoreyArea() {
    return _pdFullWidthFrontSingleStoreyArea() * 2;
  }

  double _pdLoftArea() {
    final form = _resolvePropertyForm();
    final volume = config.loftVolumesByType[form] ?? 0;
    if (config.loftAverageHeight <= 0) return 0;
    return (volume / config.loftAverageHeight).clamp(0, double.infinity);
  }

  double _footprintArea(PropertyForm form) {
    final storeys = config.assumedStoreysByType[form] ?? 2.0;
    if (storeys <= 0) return config.defaultFootprintArea;
    final footprint = totalInternalArea / storeys;
    if (footprint <= 0) return config.defaultFootprintArea;
    return footprint;
  }
}
