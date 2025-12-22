import 'package:flutter/foundation.dart';
import 'package:myapp/models/report_model.dart';

class ReportController with ChangeNotifier {
  PropertyReport? _report;

  PropertyReport? get report => _report;

  Future<void> generateReport(String propertyId) async {
    // In a real app, you'd fetch data from your services here
    // For now, we'll create some dummy data

    _report = PropertyReport(
      propertyAddress: '123 Main Street, Anytown, AN1 2BC',
      dateGenerated: DateTime.now(),
      investmentSignal: InvestmentSignal.green,
      estimatedProfit: 50000,
      returnOnInvestment: 15.0,
      gdvConfidence: GdvConfidence.high,
      selectedScenarios: ['REFURB_FULL', 'REAR_SINGLE'],
      keyConstraints: ['Planning required for rear extension'],
    );

    notifyListeners();
  }
}
