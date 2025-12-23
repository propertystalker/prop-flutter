import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:myapp/controllers/gdv_controller.dart';
import 'package:myapp/widgets/uplift_analysis_widget.dart';

import 'uplift_analysis_widget_test.mocks.dart';

@GenerateMocks([GdvController])
void main() {
  final mockUpliftData = <String, UpliftData>{
    'Full Refurbishment': UpliftData(area: 94, rate: 798, uplift: 75000),
    'Rear single-storey extension': UpliftData(area: 48, rate: 2194, uplift: 105319),
    'Rear two-storey extension': UpliftData(area: 96, rate: 2194, uplift: 210638),
    'Side single-storey extension': UpliftData(area: 18, rate: 1995, uplift: 35904),
    'Side two-storey extension': UpliftData(area: 36, rate: 1995, uplift: 71809),
    'Porch / small front single-storey extension': UpliftData(area: 6, rate: 1596, uplift: 9574),
    'Full-width front single-storey extension': UpliftData(area: 15, rate: 1596, uplift: 23936),
    'Full-width front two-storey front extension': UpliftData(area: 30, rate: 1596, uplift: 47872),
    'Standard single garage conversion': UpliftData(area: 18, rate: 1396, uplift: 25133),
    'Basic loft conversion (Velux)': UpliftData(area: 25, rate: 2473, uplift: 61835),
    'Dormer loft conversion': UpliftData(area: 30, rate: 2912, uplift: 87367),
    'Dormer loft with ensuite': UpliftData(area: 30, rate: 3072, uplift: 92154),
  };

  late MockGdvController mockGdvController;

  setUp(() {
    mockGdvController = MockGdvController();
    when(mockGdvController.scenarioUplifts).thenReturn(mockUpliftData);
  });

  Future<void> pumpWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<GdvController>.value(
        value: mockGdvController,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: UpliftAnalysisWidget(),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Uplift Analysis widget displays all table data correctly', (WidgetTester tester) async {
    await pumpWidget(tester);
    await tester.pumpAndSettle();

    final currencyFormat = NumberFormat.simpleCurrency(locale: 'en_GB', decimalDigits: 0);
    final numberFormatter = NumberFormat.decimalPattern('en_GB');

    // Find the Table widget itself
    final tableFinder = find.byType(Table);
    expect(tableFinder, findsOneWidget);

    // Get the instance of the Table widget
    final tableWidget = tester.widget<Table>(tableFinder);
    
    // Get the list of TableRow objects from the widget's children property
    final tableRows = tableWidget.children;

    // Verify the number of rows
    expect(tableRows.length, mockUpliftData.length + 2); // Data rows + Header + Spacer

    // 1. Verify Header Row
    final headerRow = tableRows[0];
    expect((headerRow.children[0] as Text).data, 'Scenario');
    expect((headerRow.children[1] as Text).data, 'Area (m²)');
    expect((headerRow.children[2] as Text).data, 'Uplift £/m²');
    expect((headerRow.children[3] as Text).data, 'Uplift (£)');

    // 2. Verify Data Rows (skipping spacer at index 1)
    final mockEntries = mockUpliftData.entries.toList();
    for (int i = 0; i < mockEntries.length; i++) {
      final dataRow = tableRows[i + 2]; // +2 to skip header and spacer
      final entry = mockEntries[i];
      final scenario = entry.key;
      final data = entry.value;

      // Extract text from widgets in the row
      final scenarioText = ((dataRow.children[0] as Padding).child as Text).data;
      final areaText = (dataRow.children[1] as Text).data;
      final rateText = (dataRow.children[2] as Text).data;
      final upliftText = (dataRow.children[3] as Text).data;

      // Verify the data for this row
      expect(scenarioText, scenario);
      expect(areaText, numberFormatter.format(data.area));
      expect(rateText, currencyFormat.format(data.rate));
      expect(upliftText, currencyFormat.format(data.uplift));
    }

    // 3. Verify Total Uplift Section
    final total = mockUpliftData.values.fold(0.0, (sum, item) => sum + item.uplift);
    expect(find.text('Total Potential Uplift'), findsOneWidget);
    expect(find.text(currencyFormat.format(total)), findsOneWidget);
  });
}
