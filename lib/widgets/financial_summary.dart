import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FinancialSummary extends StatelessWidget {
  final double gdv;
  final double totalCost;
  final double uplift;
  final double roi;

  const FinancialSummary({
    super.key,
    required this.gdv,
    required this.totalCost,
    required this.uplift,
    required this.roi,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.compactSimpleCurrency(locale: 'en_GB');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('GDV: ${currencyFormat.format(gdv)}',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('Total Cost: ${currencyFormat.format(totalCost)}',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('Uplift: ${currencyFormat.format(uplift)}',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('ROI: ${roi.toStringAsFixed(2)}%',
            style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
