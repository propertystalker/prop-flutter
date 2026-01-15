import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:myapp/controllers/gdv_controller.dart';
import 'package:myapp/controllers/financial_controller.dart';

class DebugWidget extends StatelessWidget {
  const DebugWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final gdvController = Provider.of<GdvController>(context);
    final financialController = Provider.of<FinancialController>(context);
    final currencyFormatter =
        NumberFormat.simpleCurrency(locale: 'en_GB', decimalDigits: 0);

    // Check for non-zero totalInternalArea before division
    final baseValuePerSqM = financialController.totalInternalArea > 0
        ? gdvController.finalGdv / financialController.totalInternalArea
        : 0;

    // Extract floor area for special formatting
    final floorArea = financialController.detailedCosts['total floor area'];

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(178), // 70% opacity
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.yellow),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '-- DEBUG PANEL --',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow),
            ),
            const SizedBox(height: 16),
            _buildTitle('GdvController State'),
            _buildValue(
                'Final GDV', currencyFormatter.format(gdvController.finalGdv)),
            _buildValue('GDV Source (Sold)',
                currencyFormatter.format(gdvController.gdvSold)),
            _buildValue('GDV Source (On Market)',
                currencyFormatter.format(gdvController.gdvOnMarket)),
            _buildValue('GDV Source (Area)',
                currencyFormatter.format(gdvController.gdvArea)),
            _buildValue('Base Value £/m²',
                currencyFormatter.format(baseValuePerSqM)),
            const SizedBox(height: 8),
            _buildTitle('Scenario Uplifts'),
            ...gdvController.scenarioUplifts.entries.map(
              (entry) => _buildValue(
                  '  ${entry.key}',
                  'Area: ${entry.value.area.toStringAsFixed(2)}m², Rate: ${currencyFormatter.format(entry.value.rate)}, Uplift: ${currencyFormatter.format(entry.value.uplift)}'),
            ),
            const Divider(color: Colors.yellow),
            _buildTitle('FinancialController State'),
            _buildValue('Selected Scenario', financialController.selectedScenario),
             if (floorArea != null)
              _buildValue(
                'total floor area',
                '${floorArea.toStringAsFixed(2)} m²',
                isHighlight: true),
            _buildValue(
                'Total Cost', currencyFormatter.format(financialController.totalCost)),
            _buildValue('ROI', '${financialController.roi.toStringAsFixed(2)}%'),
            _buildValue('Area Growth',
                '${financialController.areaGrowth.toStringAsFixed(2)}%'),
            _buildValue('Risk Indicator', financialController.riskIndicator),
            const SizedBox(height: 8),
            _buildTitle('Detailed Costs (from Engine)'),
            ...financialController.detailedCosts.entries
                .where((entry) => entry.key != 'total floor area') // Don't show it again
                .map(
                  (entry) => _buildValue(
                      '  ${entry.key}', currencyFormatter.format(entry.value)),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Text(
        title,
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildValue(String label, dynamic value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: isHighlight ? Colors.cyan : Colors.white,
          fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
