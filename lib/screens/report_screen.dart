
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myapp/controllers/report_controller.dart';
import 'package:myapp/controllers/report_session_controller.dart';
import 'package:myapp/models/report_model.dart';

class ReportScreen extends StatelessWidget {
  final String propertyId;
  final List<String> selectedScenarios;
  final double gdv;
  final double totalCost;
  final double uplift;

  const ReportScreen({
    super.key,
    required this.propertyId,
    this.selectedScenarios = const [],
    required this.gdv,
    required this.totalCost,
    required this.uplift,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportController()
        ..generateReport(
          propertyId,
          scenarios: selectedScenarios,
          gdv: gdv,
          totalCost: totalCost,
          uplift: uplift,
        ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Property Report'),
        ),
        body: Consumer<ReportController>(
          builder: (context, controller, child) {
            if (controller.report == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final report = controller.report!;

            if (report.selectedScenarios.isEmpty) {
              return const Center(
                child: Text(
                  'No scenarios were selected to generate a report.',
                  textAlign: TextAlign.center,
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(report.propertyAddress, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  Text(report.reportTitle, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Generated: ${DateFormat.yMMMMd().format(report.dateGenerated.toLocal())}'),
                  const SizedBox(height: 24),
                  _buildDealAtAGlance(context, report),
                  const SizedBox(height: 24),
                  _buildSessionReports(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDealAtAGlance(BuildContext context, PropertyReport report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deal at a Glance', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                // Investment Signal Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getSignalColor(report.investmentSignal),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    report.investmentSignal.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                // GDV Confidence Chip
                Chip(
                  label: Text('GDV Confidence: ${report.gdvConfidence.toString().split('.').last}'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Profit and ROI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildKpiTile('Estimated Profit', '£${report.estimatedProfit.toStringAsFixed(0)}'),
                _buildKpiTile('ROI', '${report.returnOnInvestment.toStringAsFixed(1)}%'),
              ],
            ),
            const SizedBox(height: 16),
            // Selected Scenarios
            Text('Selected Scenarios:', style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 8.0,
              children: report.selectedScenarios.map<Widget>((scenario) => Chip(label: Text(scenario))).toList(),
            ),
            const SizedBox(height: 16),
            // Key Constraints
            Text('Key Constraints:', style: Theme.of(context).textTheme.titleMedium),
            ...report.keyConstraints.map((constraint) => Text('- $constraint')),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionReports(BuildContext context) {
    final sessionReports = Provider.of<ReportSessionController>(context).reports;

    if (sessionReports.isEmpty) {
      return const SizedBox.shrink(); // Don't show anything if there are no session reports
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Session Reports', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sessionReports.length,
          itemBuilder: (context, index) {
            final reportInfo = sessionReports[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: Text(reportInfo.fileName),
                onTap: () async {
                  final url = Uri.parse(reportInfo.reportUrl);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not open report: ${reportInfo.reportUrl}')),
                    );
                  }
                },
              ),
            );
          },
        ),
      ],
    );
  }

    Color _getSignalColor(InvestmentSignal signal) {
    switch (signal) {
      case InvestmentSignal.green:
        return Colors.green;
      case InvestmentSignal.amber:
        return Colors.amber;
      case InvestmentSignal.red:
        return Colors.red;
    }
  }

  Widget _buildKpiTile(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
