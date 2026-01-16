import 'package:flutter/foundation.dart';
import 'package:myapp/models/report_model.dart';
import 'package:myapp/models/planning_application.dart';

class ReportController with ChangeNotifier {
  PropertyReport? _report;

  PropertyReport? get report => _report;

  List<PlanningApplication> _propertyDataApplications = [];
  List<PlanningApplication> get propertyDataApplications => _propertyDataApplications;

  List<PlanningApplication> _planitApplications = [];
  List<PlanningApplication> get planitApplications => _planitApplications;

  Future<void> generateReport(
    String propertyAddress,
    {
      required List<String> scenarios,
      required List<PlanningApplication> propertyDataApplications,
      required List<PlanningApplication> planitApplications,
      required double gdv,
      required double totalCost,
      required double uplift,
      required Map<String, double> detailedCosts,
    }
  ) async {
    _propertyDataApplications = propertyDataApplications;
    _planitApplications = planitApplications;

    _report = PropertyReport(
      propertyAddress: propertyAddress,
      dateGenerated: DateTime.now(),
      selectedScenarios: scenarios,
      gdvConfidence: GdvConfidence.medium, // Placeholder
      investmentSignal: InvestmentSignal.amber, // Placeholder
      estimatedProfit: uplift,
      returnOnInvestment: (totalCost > 0) ? (uplift / totalCost) * 100 : 0, // Avoid division by zero
      keyConstraints: ['Constraint 1', 'Constraint 2'], // Placeholder
      detailedCosts: detailedCosts, 
    );
    notifyListeners();
  }
}
