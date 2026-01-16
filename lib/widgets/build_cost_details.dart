import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/controllers/financial_controller.dart';
import 'package:provider/provider.dart';

class BuildCostDetails extends StatelessWidget {
  final String propertyType;
  const BuildCostDetails({super.key, required this.propertyType});

  @override
  Widget build(BuildContext context) {
    final financialController = Provider.of<FinancialController>(context);
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'en_GB', decimalDigits: 0);
    final detailedCosts = financialController.detailedCosts;

    // Define the specific key for floor area
    const String floorAreaKey = 'total floor area';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Build Cost Details - $propertyType', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        if (detailedCosts.isEmpty)
          const Center(child: Text('Select a scenario to see the cost breakdown.'))
        else
          ...detailedCosts.entries.map((entry) {
            final isTotal = entry.key.toLowerCase().contains('total');
            final isSubTotal = entry.key.toLowerCase().contains('sub-total');
            final isFloorArea = entry.key.toLowerCase() == floorAreaKey;

            String formattedValue;
            if (isFloorArea) {
              // Special formatting for floor area
              formattedValue = '${entry.value.toStringAsFixed(0)} m²';
            } else {
              // Default currency formatting for all other costs
              formattedValue = currencyFormat.format(entry.value);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key.replaceAll('_', ' '), // Make keys more readable
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: isTotal || isSubTotal || isFloorArea
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                  ),
                  Text(
                    formattedValue,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: isTotal || isSubTotal || isFloorArea
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
