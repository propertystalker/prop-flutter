import 'package:flutter/foundation.dart';
import 'package:myapp/models/report_model.dart';

class ReportController with ChangeNotifier {
  PropertyReport? _report;

  PropertyReport? get report => _report;

  Future<void> generateReport(String propertyId, {List<String> scenarios = const []}) async {
    // In a real app, you'd fetch data from your services here
    // and filter/calculate based on the selected scenarios.
    // For now, we'll create some dummy data and pass the scenarios through.

    _report = PropertyReport(
      propertyAddress: '123 Main Street, Anytown, AN1 2BC',
      dateGenerated: DateTime.now(),
      investmentSignal: InvestmentSignal.green, // This would be calculated based on scenarios
      estimatedProfit: 50000, // This would be calculated based on scenarios
      returnOnInvestment: 15.0, // This would be calculated based on scenarios
      gdvConfidence: GdvConfidence.high,
      selectedScenarios: scenarios, // Pass the selected scenarios to the report model
      keyConstraints: ['Planning required for rear extension'], // This could also be scenario-dependent
    );

    notifyListeners();
  }
}
