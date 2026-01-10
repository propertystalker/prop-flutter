import 'package:flutter/foundation.dart';
import 'package:myapp/models/report_model.dart';
import 'package:myapp/services/planning_service.dart';
import 'package:myapp/services/property_data_service.dart'; // Assuming this service exists
import 'package:myapp/models/planning_application.dart';

class ReportController with ChangeNotifier {
  PropertyReport? _report;
  final PlanningService _planningService = PlanningService();
  final PropertyDataService _propertyDataService = PropertyDataService(); // Assuming this service exists

  PropertyReport? get report => _report;
  List<PlanningApplication> _propertyDataApplications = [];
  List<PlanningApplication> get propertyDataApplications => _propertyDataApplications;

  Future<void> generateReport(
    String propertyId, {
    List<String> scenarios = const [],
    double gdv = 0,
    double totalCost = 0,
    double uplift = 0,
  }) async {
    final estimatedProfit = gdv - totalCost;
    final double returnOnInvestment =
        (totalCost > 0) ? (uplift / totalCost) * 100 : 0.0;

    final postcode = propertyId.split(', ').last;
    final planitApplications = await _planningService.getPlanningApplications(postcode);
    _propertyDataApplications = await _propertyDataService.getPlanningApplications(postcode); // Assuming this method exists

    final investmentSignal = _calculateInvestmentSignal(returnOnInvestment);
    final gdvConfidence = _calculateGdvConfidence(gdv);

    _report = PropertyReport(
      propertyAddress: propertyId,
      dateGenerated: DateTime.now(),
      investmentSignal: investmentSignal,
      estimatedProfit: estimatedProfit,
      returnOnInvestment: returnOnInvestment,
      gdvConfidence: gdvConfidence,
      selectedScenarios: scenarios,
      keyConstraints: ['Planning required for rear extension'],
      planningApplications: planitApplications,
    );

    notifyListeners();
  }

  InvestmentSignal _calculateInvestmentSignal(double returnOnInvestment) {
    if (returnOnInvestment > 20) {
      return InvestmentSignal.green;
    } else if (returnOnInvestment >= 10) {
      return InvestmentSignal.amber;
    } else {
      return InvestmentSignal.red;
    }
  }

  GdvConfidence _calculateGdvConfidence(double gdv) {
    if (gdv > 500000) {
      return GdvConfidence.high;
    } else if (gdv >= 200000) {
      return GdvConfidence.medium;
    } else {
      return GdvConfidence.low;
    }
  }
}
