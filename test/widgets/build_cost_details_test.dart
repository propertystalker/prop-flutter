import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/controllers/financial_controller.dart';
import 'package:myapp/widgets/build_cost_details.dart';
import 'package:provider/provider.dart';

import 'build_cost_details_test.mocks.dart';

// Generate a MockFinancialController using the mockito package.
@GenerateMocks([FinancialController])
void main() {
  group('BuildCostDetails Widget', () {
    late MockFinancialController mockFinancialController;

    setUp(() {
      mockFinancialController = MockFinancialController();
    });

    // Helper function to create the widget tree with the mock provider
    Widget createTestWidget({required String propertyType}) {
      return MaterialApp(
        home: ChangeNotifierProvider<FinancialController>.value(
          value: mockFinancialController,
          child: Scaffold(
            body: BuildCostDetails(propertyType: propertyType),
          ),
        ),
      );
    }

    testWidgets('displays title and placeholder when no costs are available',
        (WidgetTester tester) async {
      // Arrange
      // Stub the detailedCosts getter to return an empty map
      when(mockFinancialController.detailedCosts)
          .thenReturn(const <String, double>{});

      await tester.pumpWidget(createTestWidget(propertyType: 'House'));

      // Assert
      expect(find.text('Build Cost Details - House'), findsOneWidget);
      expect(find.text('Select a scenario to see the cost breakdown.'),
          findsOneWidget);
    });

    testWidgets('displays formatted cost details when costs are available',
        (WidgetTester tester) async {
      // Arrange
      final costs = {
        'total floor area': 120.0,
        'Preliminaries': 5000.0,
        'Demolition': 3000.0,
        'Sub-Total': 8000.0,
        'Contingency': 800.0,
        'Total Build Cost': 8800.0,
      };
      // Stub the detailedCosts getter to return our test data
      when(mockFinancialController.detailedCosts).thenReturn(costs);

      await tester.pumpWidget(createTestWidget(propertyType: 'Flat'));

      // Assert
      expect(find.text('Build Cost Details - Flat'), findsOneWidget);
      expect(
          find.text('Select a scenario to see the cost breakdown.'), findsNothing);

      expect(find.text('total floor area'), findsOneWidget);
      expect(find.text('120 m²'), findsOneWidget);

      expect(find.text('Preliminaries'), findsOneWidget);
      expect(find.text('£5,000'), findsOneWidget);

      expect(find.text('Demolition'), findsOneWidget);
      expect(find.text('£3,000'), findsOneWidget);

      expect(find.text('Sub-Total'), findsOneWidget);
      expect(find.text('£8,000'), findsOneWidget);

      expect(find.text('Contingency'), findsOneWidget);
      expect(find.text('£800'), findsOneWidget);

      expect(find.text('Total Build Cost'), findsOneWidget);
      expect(find.text('£8,800'), findsOneWidget);
    });

    testWidgets('ensures total and sub-total fields are bold',
        (WidgetTester tester) async {
      // Arrange
      final costs = {
        'total floor area': 100.0,
        'Normal Cost': 1000.0,
        'Sub-Total': 1000.0,
        'Total Cost': 1000.0,
      };
      when(mockFinancialController.detailedCosts).thenReturn(costs);

      await tester.pumpWidget(createTestWidget(propertyType: 'Bungalow'));

      // Assert
      final subTotalText = tester.widget<Text>(find.text('Sub-Total'));
      final totalText = tester.widget<Text>(find.text('Total Cost'));
      final floorAreaText = tester.widget<Text>(find.text('total floor area'));
      final normalText = tester.widget<Text>(find.text('Normal Cost'));

      expect(subTotalText.style?.fontWeight, FontWeight.bold);
      expect(totalText.style?.fontWeight, FontWeight.bold);
      expect(floorAreaText.style?.fontWeight, FontWeight.bold);
      expect(normalText.style?.fontWeight, FontWeight.normal);

      final subTotalValue = tester.widget<Text>(find.text('£1,000').first);
      final floorAreaValue = tester.widget<Text>(find.text('100 m²'));

      expect(subTotalValue.style?.fontWeight, FontWeight.bold);
      expect(floorAreaValue.style?.fontWeight, FontWeight.bold);
    });
  });
}
