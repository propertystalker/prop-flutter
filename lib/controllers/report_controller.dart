import 'package:flutter/foundation.dart';
import 'package:myapp/models/report_model.dart';
import 'package:myapp/services/planning_service.dart';

class ReportController with ChangeNotifier {
  PropertyReport? _report;
  final PlanningService _planningService = PlanningService();

  PropertyReport? get report => _report;

  Future<void> generateReport(
    String propertyId, {
    List<String> scenarios = const [],
    double gdv = 0,
    double totalCost = 0,
    double uplift = 0,
  }) async {
    // In a real app, you'd fetch data from your services here
    // and filter/calculate based on the selected scenarios.
    // For now, we'll create some dummy data and pass the scenarios through.

    final estimatedProfit = gdv - totalCost;
    final returnOnInvestment = (uplift / totalCost) * 100;

    // Extract postcode from propertyId (assuming format "Address, Postcode")
    final postcode = propertyId.split(', ').last;
    final planningApplications = await _planningService.getPlanningApplications(postcode);

    _report = PropertyReport(
      propertyAddress: propertyId,
      dateGenerated: DateTime.now(),
      investmentSignal: InvestmentSignal.green, // This would be calculated based on scenarios
      estimatedProfit: estimatedProfit,
      returnOnInvestment: returnOnInvestment,
      gdvConfidence: GdvConfidence.high,
      selectedScenarios: scenarios, // Pass the selected scenarios to the report model
      keyConstraints: ['Planning required for rear extension'], // This could also be scenario-dependent
      planningApplications: planningApplications,
    );

    notifyListeners();
  }
}
