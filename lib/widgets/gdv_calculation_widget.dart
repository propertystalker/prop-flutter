import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controllers/gdv_controller.dart';

class GdvCalculationWidget extends StatelessWidget {
  const GdvCalculationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final gdvController = Provider.of<GdvController>(context);
    final currencyFormatter = NumberFormat.simpleCurrency(locale: 'en_GB', decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GDV Calculation (Blended)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'How the final value estimate is derived',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text(
                  'Final GDV',
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                Text(
                  currencyFormatter.format(gdvController.finalGdv),
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Based on a weighted blend of sold data, live listings, and area benchmarks.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildGdvComponentsTable(context, gdvController, currencyFormatter),
          const SizedBox(height: 16),
          _buildWeightingDisclosure(context, gdvController),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Weighting reflects data availability and reliability in this area.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGdvComponentsTable(
      BuildContext context, GdvController controller, NumberFormat formatter) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1.5),
      },
      children: [
        const TableRow(
          children: [
            Text('GDV Source', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Estimated Value', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const TableRow(
          children: [SizedBox(height: 8), SizedBox(height: 8)], // Spacer
        ),
        _buildTableRow('Sold comparables', formatter.format(controller.gdvSold)),
        _buildTableRow('Live listings', formatter.format(controller.gdvOnMarket)),
        _buildTableRow('Area benchmark', formatter.format(controller.gdvArea)),
      ],
    );
  }

  TableRow _buildTableRow(String title, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(title, style: const TextStyle(fontSize: 14)),
        ),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildWeightingDisclosure(BuildContext context, GdvController controller) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          children: [
            const TextSpan(
              text: 'Weighting applied: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: 'Sold: ${controller.weightSold * 100}% \u00B7 '),
            TextSpan(text: 'On market: ${controller.weightOnMarket * 100}% \u00B7 '),
            TextSpan(text: 'Area benchmark: ${controller.weightArea * 100}%'),
          ],
        ),
      ),
    );
  }
}
