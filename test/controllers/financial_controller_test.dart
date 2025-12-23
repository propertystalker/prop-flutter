import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/controllers/financial_controller.dart';

void main() {
  group('FinancialController', () {
    late FinancialController controller;

    FinancialController createController({double area = 100.0}) {
      return FinancialController(existingInternalArea: area);
    }

    setUp(() {
      controller = createController();
    });

    test('Initial values are set correctly', () {
      expect(controller.totalCost, 0);
      expect(controller.uplift, 0);
      expect(controller.roi, 0);
      expect(controller.currentPrice, isNull);
      expect(controller.gdv, 0);
      expect(controller.areaGrowth, 0);
      expect(controller.riskIndicator, 'Low');
      expect(controller.selectedScenario, 'Full Refurbishment');
    });

    test('setCurrentPrice updates price and triggers recalculation for default scenario', () {
      bool listenerWasCalled = false;
      controller.addListener(() {
        listenerWasCalled = true;
      });

      controller.setCurrentPrice(300000, 500000);

      expect(controller.currentPrice, 300000);
      expect(controller.gdv, 500000);

      // Correctly calculate the expected development cost for 'Full Refurbishment'
      const expectedDevelopmentCost = 5000 + 7000 + 9000 + 10000 + 8000 + 5000 + 7000 + 9000 + 2000 + 3000 + 10000 + 5000;
      const expectedTotalCost = 300000 + expectedDevelopmentCost;
      const expectedUplift = 500000 - expectedTotalCost;
      final expectedRoi = (expectedUplift / expectedTotalCost) * 100;

      expect(controller.totalCost, expectedTotalCost);
      expect(controller.uplift, expectedUplift);
      expect(controller.roi, closeTo(expectedRoi, 0.01));
      expect(controller.areaGrowth, 0);
      expect(controller.riskIndicator, 'Low');
      expect(listenerWasCalled, isTrue);
    });

    test('calculateFinancials updates financials correctly for a new scenario', () {
      controller.setCurrentPrice(300000, 650000);

      bool listenerWasCalled = false;
      controller.addListener(() {
        listenerWasCalled = true;
      });

      controller.calculateFinancials('Rear single-storey extension', 650000);

      expect(controller.selectedScenario, 'Rear single-storey extension');
      expect(controller.gdv, 650000);

      // Correctly calculate the expected development cost for the new scenario
      const expectedDevelopmentCost = 5000 + 7000 + 10000 + 8000 + 15000 + 5000 + 8000 + 6000 + 9000 + 10000 + 7000 + 9000 + 2000 + 3000 + 10000 + 5000;
      const expectedTotalCost = 300000 + expectedDevelopmentCost;
      const expectedUplift = 650000 - expectedTotalCost;
      final expectedRoi = (expectedUplift / expectedTotalCost) * 100;

      // Assert against the precise, correct values
      expect(controller.totalCost, expectedTotalCost);
      expect(controller.uplift, expectedUplift);
      expect(controller.roi, closeTo(expectedRoi, 0.01));

      // Check area growth and risk (48m^2 added to 100m^2 existing = 48% growth)
      expect(controller.areaGrowth, closeTo(48.0, 0.01));
      expect(controller.riskIndicator, 'Medium');

      expect(listenerWasCalled, isTrue);
    });
  });
}
