import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/financial_controller.dart';

class UpliftRiskOverviewWidget extends StatelessWidget {
  const UpliftRiskOverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final financialController = Provider.of<FinancialController>(context);
    final numberFormatter = NumberFormat('##0.0', 'en_GB');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Uplift & Risk Overview',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Contextual indicators only',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric(
                context,
                label: 'Uplift (%)',
                value: '${numberFormatter.format(financialController.roi)}%',
                caption: 'Profit relative to total investment',
              ),
              _buildMetric(
                context,
                label: 'Area Growth',
                value: '${numberFormatter.format(financialController.areaGrowth)}%',
                caption: 'Increase in internal area',
              ),
              _buildRiskIndicator(context, financialController.riskIndicator),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'These indicators provide context only and do not represent investment advice or forecasts.',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(BuildContext context, {required String label, required String value, required String caption}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(caption, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildRiskIndicator(BuildContext context, String risk) {
    IconData icon;
    Color color;

    switch (risk) {
      case 'Medium':
        icon = Icons.warning_amber_rounded;
        color = Colors.orange;
        break;
      case 'Higher':
        icon = Icons.error_outline_rounded;
        color = Colors.red;
        break;
      case 'Low':
      default:
        icon = Icons.check_circle_outline_rounded;
        color = Colors.green;
        break;
    }

    return Column(
      children: [
        const Text('Risk Indicator', style: TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        Tooltip(
          message: 'Based on planning requirements, data confidence, and scale of works.',
          child: Chip(
            avatar: Icon(icon, color: color),
            label: Text(risk, style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: color.withAlpha(26),
          ),
        ),
      ],
    );
  }
}
