
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/controllers/financial_controller.dart';

void main() {
  group('FinancialController', () {
    // Test for Low Risk Scenario
    test('calculates financials correctly and assigns Low Risk', () {
      // Arrange: High existing area, no planning needed
      final controller = FinancialController(existingInternalArea: 200);
      const currentPrice = 500000.0;
      const gdv = 600000.0;
      const scenario = 'Full Refurbishment'; // No area growth, no planning

      // Act
      controller.setCurrentPrice(currentPrice, gdv);
      controller.calculateFinancials(scenario, gdv);

      // Assert
      expect(controller.riskIndicator, 'Low');
      expect(controller.areaGrowth, 0);
      expect(controller.totalCost, isNotNull);
      expect(controller.uplift, isNotNull);
      expect(controller.roi, isNotNull);
    });

    // Test for Medium Risk Scenario
    test('calculates financials correctly and assigns Medium Risk', () {
      // Arrange: Existing area makes growth < 50%, but planning is needed
      final controller = FinancialController(existingInternalArea: 200);
      const currentPrice = 500000.0;
      const gdv = 750000.0;
      // This scenario adds 96sqm and requires planning
      const scenario = 'Rear two-storey extension'; 

      // Act
      controller.setCurrentPrice(currentPrice, gdv);
      controller.calculateFinancials(scenario, gdv);

      // Assert
      // Area growth is 96/200 = 48%. Planning is true. Should be Medium risk.
      expect(controller.riskIndicator, 'Medium');
      expect(controller.areaGrowth, closeTo(48.0, 0.1));
    });

    // Test for Higher Risk Scenario
    test('calculates financials correctly and assigns Higher Risk', () {
      // Arrange: Low existing area makes growth > 50% and planning is needed
      final controller = FinancialController(existingInternalArea: 150);
      const currentPrice = 500000.0;
      const gdv = 800000.0;
       // This scenario adds 96sqm and requires planning
      const scenario = 'Rear two-storey extension';

      // Act
      controller.setCurrentPrice(currentPrice, gdv);
      controller.calculateFinancials(scenario, gdv);

      // Assert
      // Area growth is 96/150 = 64%. Planning is true. Should be Higher risk.
      expect(controller.riskIndicator, 'Higher');
      expect(controller.areaGrowth, closeTo(64.0, 0.1));
    });

    test('ROI calculation is correct', () {
      // Arrange
      final controller = FinancialController(existingInternalArea: 100);
      controller.setCurrentPrice(200000, 300000);

      // Act
      controller.calculateFinancials('Full Refurbishment', 300000);
      
      // Assert
      // Total cost = 200000 (price) + 80000 (Full Refurbishment dev cost) = 280000
      // Uplift = 300000 (GDV) - 280000 (Total Cost) = 20000
      // ROI = (20000 / 280000) * 100 = 7.1428...
      expect(controller.roi, closeTo(7.14, 0.01));
      expect(controller.uplift, 20000);
    });

  });
}
