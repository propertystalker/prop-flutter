import 'package:myapp/models/planning_application.dart';

enum InvestmentSignal { green, amber, red }

enum GdvConfidence { high, medium, low }

class PropertyReport {
  final String propertyAddress;
  final String agentLogoUrl;
  final String reportTitle;
  final DateTime dateGenerated;
  final String reportId;
  final InvestmentSignal investmentSignal;
  final double estimatedProfit;
  final double returnOnInvestment;
  final GdvConfidence gdvConfidence;
  final List<String> selectedScenarios;
  final List<String> keyConstraints;
  final List<PlanningApplication> planningApplications;

  PropertyReport({
    required this.propertyAddress,
    this.agentLogoUrl = '',
    this.reportTitle = "Full Property Analysis Report (v7.6)",
    required this.dateGenerated,
    this.reportId = '',
    required this.investmentSignal,
    required this.estimatedProfit,
    required this.returnOnInvestment,
    required this.gdvConfidence,
    this.selectedScenarios = const [],
    this.keyConstraints = const [],
    this.planningApplications = const [],
  });
}
