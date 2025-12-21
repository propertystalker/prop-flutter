import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/controllers/price_paid_controller.dart';
import 'package:myapp/data/inflation_data.dart';
import 'package:provider/provider.dart';

class PriceHistory extends StatelessWidget {
  const PriceHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PricePaidController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error != null) {
          return Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Price History',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.priceHistory.isEmpty) {
          return const SizedBox.shrink();
        }

        final lastTransaction = controller.priceHistory.first;
        final now = DateTime.now();
        bool showInflation = now.year > lastTransaction.transactionDate.year;

        double inflatedPrice = 0;
        double overallInflation = 0;

        if (showInflation) {
          inflatedPrice = lastTransaction.amount.toDouble();
          int startYear = lastTransaction.transactionDate.year;

          for (int year = startYear; year < now.year; year++) {
            if (ukHousePriceInflation.containsKey(year)) {
              inflatedPrice *= (1 + (ukHousePriceInflation[year]! / 100));
            }
          }
          overallInflation = ((inflatedPrice - lastTransaction.amount) / lastTransaction.amount) * 100;
        }

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Price History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                if (showInflation)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      title: Text(
                          NumberFormat.simpleCurrency(locale: 'en_GB').format(inflatedPrice),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      subtitle: const Text('Estimated current value'),
                      trailing: Text('${overallInflation.toStringAsFixed(1)}% since last sale',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.priceHistory.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = controller.priceHistory[index];
                    final formattedDate =
                        DateFormat.yMMMMd().format(item.transactionDate);
                    final formattedPrice =
                        NumberFormat.simpleCurrency(locale: 'en_GB')
                            .format(item.amount);
                    return ListTile(
                      title: Text(formattedPrice,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Sold on $formattedDate'),
                      trailing: Text(item.propertyType,
                          style: Theme.of(context).textTheme.bodySmall),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
