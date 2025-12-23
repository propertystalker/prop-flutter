import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:myapp/controllers/financial_controller.dart';
import 'package:myapp/screens/property/widgets/property_header.dart';

import 'property_header_test.mocks.dart';

// Generate a mock for FinancialController
@GenerateMocks([FinancialController])
void main() {
  late MockFinancialController mockFinancialController;
  const priceTextFieldKey = ValueKey('priceTextField');

  setUp(() {
    mockFinancialController = MockFinancialController();
    when(mockFinancialController.currentPrice).thenReturn(375000.0);
  });

  Future<void> pumpWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<FinancialController>.value(
            value: mockFinancialController,
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: PropertyHeader(
              address: '28, Chatburn Road',
              postcode: 'M21 0XW',
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('tapping on the price text should make it editable', (WidgetTester tester) async {
    await pumpWidget(tester);
    await tester.pumpAndSettle();

    // Initially, find the non-editable text and ensure the specific price field is not there.
    expect(find.text('£375K'), findsOneWidget);
    expect(find.byKey(priceTextFieldKey), findsNothing);

    // Tap the price text to enter edit mode
    await tester.tap(find.text('£375K'));
    await tester.pump();

    // Now, find the specific price TextField using its key
    final textFieldFinder = find.byKey(priceTextFieldKey);
    expect(textFieldFinder, findsOneWidget);
    final textField = tester.widget<TextField>(textFieldFinder);
    expect(textField.controller?.text, '375000');

    // The original compact currency text should be gone
    expect(find.text('£375K'), findsNothing);
  });

  testWidgets('price input stays editable while typing', (WidgetTester tester) async {
    await pumpWidget(tester);
    await tester.pumpAndSettle();

    // Tap the price to enter edit mode
    await tester.tap(find.text('£375K'));
    await tester.pump();

    // Find the specific price TextField
    final textFieldFinder = find.byKey(priceTextFieldKey);
    expect(textFieldFinder, findsOneWidget);

    // Simulate the user typing a new value
    await tester.enterText(textFieldFinder, '400000');
    await tester.pump();

    // Verify the specific TextField is still present and its value has updated
    expect(textFieldFinder, findsOneWidget);
    final textField = tester.widget<TextField>(textFieldFinder);
    expect(textField.controller?.text, '400000');
  });
}
