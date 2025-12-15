// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/controllers/company_controller.dart';
import 'package:myapp/controllers/financial_controller.dart';
import 'package:myapp/controllers/person_controller.dart';
import 'package:myapp/controllers/user_controller.dart';
import 'package:myapp/main.dart';
import 'package:myapp/screens/opening_screen.dart';
import 'package:myapp/widgets/development_scenarios.dart';
import 'package:myapp/widgets/finance_panel.dart';
import 'package:myapp/widgets/financial_summary.dart';
import 'package:myapp/widgets/report_panel.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('OpeningScreen has a title and essential widgets', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the OpeningScreen is displayed.
    expect(find.byType(OpeningScreen), findsOneWidget);

    // Verify that our app bar has the correct title.
    expect(find.text('Property Data'), findsOneWidget);

    // Verify that the main text input field is present.
    expect(find.byType(TextFormField), findsWidgets);

    // Verify that the main buttons are present.
    expect(find.text('GET LOCATION'), findsOneWidget);
    expect(find.text('GET POSTCODE'), findsOneWidget);
    expect(find.text('GET PRICE'), findsOneWidget);
    expect(find.text('GET EPC'), findsOneWidget);
  });

  testWidgets('PropertyFloorAreaFilterScreen has essential widgets', (WidgetTester tester) async {

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => FinancialController()),
          ChangeNotifierProvider(create: (context) => CompanyController()),
          ChangeNotifierProvider(create: (context) => PersonController()),
          ChangeNotifierProvider(create: (context) => UserController()),
        ],
        
      ),
    );

    // Verify that the address is displayed
    expect(find.text('123 Main St, London'), findsOneWidget);

    // Verify that DevelopmentScenarios and FinancialSummary are present
    expect(find.byType(DevelopmentScenarios), findsOneWidget);
    expect(find.byType(FinancialSummary), findsOneWidget);

    // Verify that FinancePanel and ReportPanel are not visible initially
    expect(find.byType(FinancePanel), findsNothing);
    expect(find.byType(ReportPanel), findsNothing);

    // Tap the finance button to show the FinancePanel
    await tester.tap(find.byIcon(Icons.attach_money));
    await tester.pumpAndSettle();
    expect(find.byType(FinancePanel), findsOneWidget);

    // Tap the report button to show the ReportPanel
    await tester.tap(find.byIcon(Icons.assessment));
    await tester.pumpAndSettle();
    expect(find.byType(ReportPanel), findsOneWidget);
  });
}
