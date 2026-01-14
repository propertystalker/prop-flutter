
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/controllers/financial_controller.dart';
import 'package:provider/provider.dart';

class BuildCostDetails extends StatelessWidget {
  const BuildCostDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final financialController = Provider.of<FinancialController>(context);
    final currencyFormat = NumberFormat.compactSimpleCurrency(locale: 'en_GB');

    // Access the private fields via a getter or a public method if they remain private
    final costCategories = financialController.getScenarioCostMatrix()[financialController.selectedScenario] ?? [];
    final baseCosts = financialController.getBaseCosts();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Build Cost Details', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ...costCategories.map((category) {
          final cost = baseCosts[category] ?? 0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(category, style: Theme.of(context).textTheme.bodyMedium),
                Text(currencyFormat.format(cost), style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          );
        }),
      ],
    );
  }
}
