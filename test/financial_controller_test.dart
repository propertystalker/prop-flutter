
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/controllers/financial_controller.dart';

void main() {
  group('FinancialController', () {
    late FinancialController financialController;

    setUp(() {
      financialController = FinancialController();
      financialController.updatePropertyData(
        totalFloorArea: 100.0,
        epcRating: 'D', 
        propertyType: 'flat', 
      );
    });

    test('Initial values are correct', () {
      expect(financialController.totalCost, 0);
      expect(financialController.uplift, 0);
      expect(financialController.roi, 0);
      expect(financialController.currentPrice, null);
      expect(financialController.gdv, 0);
      expect(financialController.selectedScenario, 'Full Refurbishment');
    });

    test('Calculates financials correctly for Full Refurbishment', () {
      // Arrange
      const currentPrice = 250000.0;
      const baseGdv = 300000.0;
      const scenarioUplift = 25000.0;
      const expectedDevelopmentCost = 80000.0; // Corrected sum of costs
      const expectedTotalCost = currentPrice + expectedDevelopmentCost;
      const expectedGdv = baseGdv + scenarioUplift;
      const expectedUplift = expectedGdv - expectedTotalCost;
      const expectedRoi = (expectedUplift / expectedTotalCost) * 100;

      // Act
      financialController.setCurrentPrice(currentPrice, baseGdv);
      financialController.calculateFinancials('Full Refurbishment', baseGdv, scenarioUplift);

      // Assert
      expect(financialController.totalCost, expectedTotalCost);
      expect(financialController.gdv, expectedGdv);
      expect(financialController.uplift, expectedUplift);
      expect(financialController.roi, closeTo(expectedRoi, 0.01));
    });

    test('Calculates financials correctly for Rear single-storey extension', () {
      // Arrange
      const currentPrice = 300000.0;
      const baseGdv = 350000.0;
      const scenarioUplift = 75000.0;
      const expectedDevelopmentCost = 119000.0; 
      const expectedTotalCost = currentPrice + expectedDevelopmentCost;
      const expectedGdv = baseGdv + scenarioUplift;
      const expectedUplift = expectedGdv - expectedTotalCost;
      const expectedRoi = (expectedUplift / expectedTotalCost) * 100;

      // Act
      financialController.setCurrentPrice(currentPrice, baseGdv);
      financialController.calculateFinancials('Rear single-storey extension', baseGdv, scenarioUplift);

      // Assert
      expect(financialController.totalCost, expectedTotalCost);
      expect(financialController.gdv, expectedGdv);
      expect(financialController.uplift, expectedUplift);
      expect(financialController.roi, closeTo(expectedRoi, 0.01));
    });

     test('Setting market growth updates the value', () {
      // Arrange
      const growthString = '5.5%';
      const expectedGrowth = 5.5;

      // Act
      financialController.setMarketGrowth(growthString);

      // Assert
      expect(financialController.marketGrowth, expectedGrowth);
    });

    test('Risk indicator is calculated correctly', () {
      // Arrange
      const currentPrice = 300000.0;
      const baseGdv = 350000.0;

      // Act & Assert

      // Low risk: No planning, < 25% area growth
      financialController.setCurrentPrice(currentPrice, baseGdv);
      financialController.calculateFinancials('Full Refurbishment', baseGdv, 0);
      expect(financialController.riskIndicator, 'Low');

      // Higher risk: Planning required and > 50% area growth
      financialController.calculateFinancials('Rear two-storey extension', baseGdv, 150000);
      expect(financialController.riskIndicator, 'Higher');

      // Medium risk: No planning, but >= 25% area growth
      financialController.calculateFinancials('Dormer loft conversion', baseGdv, 50000);
      expect(financialController.riskIndicator, 'Medium');

    });
  });
}
