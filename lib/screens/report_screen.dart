import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:myapp/controllers/gdv_controller.dart';
import 'package:myapp/controllers/financial_controller.dart';
import 'package:myapp/controllers/report_controller.dart';
import 'package:myapp/models/report_model.dart';
import 'package:myapp/utils/pdf_generator.dart';
import 'package:myapp/models/planning_application.dart';

class ReportScreen extends StatelessWidget {
  final String propertyId;
  final List<String> selectedScenarios;
  final List<PlanningApplication> propertyDataApplications;
  final List<PlanningApplication> planitApplications;

  const ReportScreen({
    super.key,
    required this.propertyId,
    required this.selectedScenarios,
    required this.propertyDataApplications,
    required this.planitApplications,
  });

  @override
  Widget build(BuildContext context) {
    final gdvController = Provider.of<GdvController>(context, listen: false);
    final financialController = Provider.of<FinancialController>(context, listen: false);

    return ChangeNotifierProvider(
      create: (_) => ReportController()
        ..generateReport(
          propertyId,
          scenarios: selectedScenarios,
          propertyDataApplications: propertyDataApplications,
          planitApplications: planitApplications, 
          gdv: gdvController.finalGdv,
          totalCost: financialController.totalCost,
          uplift: gdvController.finalGdv - financialController.totalCost,
          detailedCosts: financialController.detailedCosts,
        ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Property Report'),
          actions: [
            Consumer<ReportController>(
              builder: (context, controller, child) {
                return IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  onPressed: controller.report == null
                      ? null
                      : () async {
                          if (!context.mounted) return; // Mounted check
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Generating PDF...')),
                          );

                          final pdfData = await PdfGenerator.generatePdf(
                            controller.report!.propertyAddress,
                            '', // Price - handle this properly
                            [], // Images - handle this properly
                            null, // StreetView URL
                            gdvController,
                            financialController.totalCost,
                            gdvController.finalGdv - financialController.totalCost,
                            controller.propertyDataApplications, 
                            controller.planitApplications, 
                            financialController.roi,
                            financialController.areaGrowth,
                            financialController.riskIndicator,
                            controller.report!.investmentSignal,
                            controller.report!.gdvConfidence,
                            controller.report!.selectedScenarios,
                            detailedCosts: controller.report!.detailedCosts,
                          );

                          if (!context.mounted) return; // Mounted check
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();

                          if (pdfData != null) {
                            final bytes = pdfData['bytes'] as Uint8List;
                            final fileName = pdfData['filename'] as String;
                            await Printing.sharePdf(bytes: bytes, filename: fileName);
                          } else {
                            if (!context.mounted) return; // Mounted check
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to generate PDF. Please try again.')),
                            );
                          }
                        },
                );
              },
            ),
          ],
        ),
        body: Consumer<ReportController>(
          builder: (context, controller, child) {
            if (controller.report == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.report!.selectedScenarios.isEmpty) {
              return const Center(child: Text("No scenarios were selected to generate a report."));
            }

            final report = controller.report!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(report.propertyAddress, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text('Report Generated: ${report.dateGenerated.toLocal()}', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 24),
                  
                  // --- Selected Scenarios Section ---
                  Text('Selected Scenarios', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  if (report.selectedScenarios.isNotEmpty)
                    ...report.selectedScenarios.map((scenario) => ListTile(
                          leading: const Icon(Icons.check_box_outline_blank),
                          title: Text(scenario),
                        ))
                  else
                    const Text('No scenarios were selected for this report.'),
                  
                  const SizedBox(height: 24),

                  // --- Financial Summary ---
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildFinancialRow('Investment Signal', report.investmentSignal.name.toUpperCase(), _getInvestmentSignalColor(report.investmentSignal)),
                          _buildFinancialRow('GDV Confidence', report.gdvConfidence.name.toUpperCase()),
                          _buildFinancialRow('Estimated Profit', '£${report.estimatedProfit.toStringAsFixed(0)}'),
                          _buildFinancialRow('Return on Investment', '${report.returnOnInvestment.toStringAsFixed(1)}%'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Key Constraints ---
                  Text('Key Constraints', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Coming Soon', style: Theme.of(context).textTheme.bodyMedium),

                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFinancialRow(String title, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: 16, color: valueColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getInvestmentSignalColor(InvestmentSignal signal) {
    switch (signal) {
      case InvestmentSignal.green:
        return Colors.green;
      case InvestmentSignal.amber:
        return Colors.orange;
      case InvestmentSignal.red:
        return Colors.red;
    }
  }
}
