
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/controllers/gdv_controller.dart';

void main() {
  group('GdvController', () {
    late GdvController gdvController;

    setUp(() {
      gdvController = GdvController();
      // Initialize with a default existing internal area
    });

    test('initial values are correct', () {
      // Initial GDV values are 0 until calculateGdv is called
      expect(gdvController.gdvSold, 0);
      expect(gdvController.gdvOnMarket, 0);
      expect(gdvController.gdvArea, 0);
      
      // Check default weights
      expect(gdvController.weightSold, 0.5);
      expect(gdvController.weightOnMarket, 0.3);
      expect(gdvController.weightArea, 0.2);

      // Check initial final GDV and bands (which will be 0)
      expect(gdvController.finalGdv, 0);
      expect(gdvController.cautiousGdv, 0);
      expect(gdvController.baseGdv, 0);
      expect(gdvController.optimisticGdv, 0);
    });

    // Test with a low price
    test('recalculates uplift values correctly for a low price', () {
      const lowPrice = 150000.0;
      const totalFloorArea = 80.0;

      gdvController.updateUpliftRates(currentPrice: lowPrice, totalFloorArea: totalFloorArea);

      final pricePerSqm = lowPrice / totalFloorArea;
      // Using the actual factors from the controller
      final rearExtensionUplift = pricePerSqm * 0.55; 
      final fullRefurbishmentUplift = pricePerSqm * 0.20;

      expect(gdvController.scenarioUplifts['Rear single-storey extension']!.rate, closeTo(rearExtensionUplift, 0.01));
      expect(gdvController.scenarioUplifts['Full Refurbishment']!.rate, closeTo(fullRefurbishmentUplift, 0.01));
    });

    // Test with a medium price
    test('recalculates uplift values correctly for a medium price', () {
      const mediumPrice = 250000.0;
      const totalFloorArea = 120.0;

      gdvController.updateUpliftRates(currentPrice: mediumPrice, totalFloorArea: totalFloorArea);

      final pricePerSqm = mediumPrice / totalFloorArea;
      final rearExtensionUplift = pricePerSqm * 0.55;
      final fullRefurbishmentUplift = pricePerSqm * 0.20;

      expect(gdvController.scenarioUplifts['Rear single-storey extension']!.rate, closeTo(rearExtensionUplift, 0.01));
      expect(gdvController.scenarioUplifts['Full Refurbishment']!.rate, closeTo(fullRefurbishmentUplift, 0.01));
    });

    // Test with a high price
    test('recalculates uplift values correctly for a high price', () {
      const highPrice = 500000.0;
      const totalFloorArea = 200.0;

      gdvController.updateUpliftRates(currentPrice: highPrice, totalFloorArea: totalFloorArea);

      final pricePerSqm = highPrice / totalFloorArea;
      final rearExtensionUplift = pricePerSqm * 0.55;
      final fullRefurbishmentUplift = pricePerSqm * 0.20;

      expect(gdvController.scenarioUplifts['Rear single-storey extension']!.rate, closeTo(rearExtensionUplift, 0.01));
      expect(gdvController.scenarioUplifts['Full Refurbishment']!.rate, closeTo(fullRefurbishmentUplift, 0.01));
    });

     test('calculates final GDV values correctly after updates', () {
      gdvController.updateGdvSources(sold: 300000, onMarket: 310000, area: 305000);

      expect(gdvController.gdvSold, 300000);
      expect(gdvController.gdvOnMarket, 310000);
      expect(gdvController.gdvArea, 305000);
      
      // Weights are final and not updatable, so they remain the same
      expect(gdvController.weightSold, 0.5);
      expect(gdvController.weightOnMarket, 0.3);
      expect(gdvController.weightArea, 0.2);

      // The controller calculates finalGdv on update
      final expectedFinalGdv = (300000 * 0.5) + (310000 * 0.3) + (305000 * 0.2);
      expect(gdvController.finalGdv, expectedFinalGdv);
      expect(gdvController.baseGdv, expectedFinalGdv);

      // Downside and upside percentages are private final variables (0.07)
      final expectedCautiousGdv = expectedFinalGdv * (1 - 0.07);
      final expectedOptimisticGdv = expectedFinalGdv * (1 + 0.07);

      expect(gdvController.cautiousGdv, closeTo(expectedCautiousGdv, 0.01));
      expect(gdvController.optimisticGdv, closeTo(expectedOptimisticGdv, 0.01));
    });

    test('recalculates uplift values correctly for side extension', () {
      const price = 300000.0;
      const totalFloorArea = 150.0;

      gdvController.updateUpliftRates(currentPrice: price, totalFloorArea: totalFloorArea);

      final pricePerSqm = price / totalFloorArea;
      final sideExtensionUplift = pricePerSqm * 0.50;

      expect(gdvController.scenarioUplifts['Side single-storey extension']!.rate, closeTo(sideExtensionUplift, 0.01));
    });
  });
}
