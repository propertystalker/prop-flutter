import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controllers/gdv_controller.dart';

class UpliftAnalysisWidget extends StatelessWidget {
  const UpliftAnalysisWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final gdvController = Provider.of<GdvController>(context);
    final currencyFormatter = NumberFormat.simpleCurrency(locale: 'en_GB', decimalDigits: 0);
    final numberFormatter = NumberFormat.decimalPattern('en_GB');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Uplift Analysis by Scenario',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildUpliftTable(context, gdvController, currencyFormatter, numberFormatter),
          const SizedBox(height: 16),
          _buildTotalUplift(context, gdvController, currencyFormatter),
          const SizedBox(height: 16),
          _buildDisclosure(),
        ],
      ),
    );
  }

  Widget _buildUpliftTable(BuildContext context, GdvController controller, 
                         NumberFormat currencyFormatter, NumberFormat numberFormatter) {
    final scenarios = controller.scenarioUplifts;

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.5),
      },
      children: [
        const TableRow(
          children: [
            Text('Scenario', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Area (m²)', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
            Text('Uplift £/m²', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
            Text('Uplift (£)', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
          ],
        ),
        const TableRow(
          children: [SizedBox(height: 8), SizedBox(height: 8), SizedBox(height: 8), SizedBox(height: 8)], // Spacer
        ),
        for (var scenario in scenarios.entries)
          _buildTableRow(
            scenario.key,
            numberFormatter.format(scenario.value.area),
            currencyFormatter.format(scenario.value.rate),
            currencyFormatter.format(scenario.value.uplift),
          ),
      ],
    );
  }

  TableRow _buildTableRow(String title, String area, String rate, String uplift) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(title, style: const TextStyle(fontSize: 12)),
        ),
        Text(area, style: const TextStyle(fontSize: 12), textAlign: TextAlign.right),
        Text(rate, style: const TextStyle(fontSize: 12), textAlign: TextAlign.right),
        Text(uplift, style: const TextStyle(fontSize: 12), textAlign: TextAlign.right),
      ],
    );
  }

  Widget _buildTotalUplift(BuildContext context, GdvController controller, NumberFormat currencyFormatter) {
    final totalUplift = controller.scenarioUplifts.values.fold(0.0, (sum, item) => sum + item.uplift);
    return Center(
      child: Column(
        children: [
          const Text(
            'Total Potential Uplift',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            currencyFormatter.format(totalUplift),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclosure() {
    return const Text(
      'Uplift modelling is indicative and used to explain value creation by scenario. Final value is reflected in GDV.',
      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
      textAlign: TextAlign.center,
    );
  }
}
