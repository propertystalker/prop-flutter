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
    final estimatedProfit = gdv - totalCost;
    final double returnOnInvestment =
        (totalCost > 0) ? (uplift / totalCost) * 100 : 0.0;

    final postcode = propertyId.split(', ').last;
    final planningApplications =
        await _planningService.getPlanningApplications(postcode);

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
      planningApplications: planningApplications,
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
