import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:myapp/controllers/price_paid_controller.dart';

class PricePaidScreen extends StatelessWidget {
  final String postcode;

  const PricePaidScreen({super.key, required this.postcode});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PricePaidController()..fetchPricePaidData(postcode),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Price Paid Data for $postcode'),
        ),
        body: Consumer<PricePaidController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (controller.error != null) {
              return Center(child: Text('Error: ${controller.error}'));
            } else if (controller.pricePaidData.isEmpty) {
              return const Center(child: Text('No price paid data found.'));
            } else {
              // 1. Find the most recent transaction in the entire dataset for the postcode.
              final mostRecentTransaction = controller.pricePaidData.reduce((a, b) => a.transactionDate.isAfter(b.transactionDate) ? a : b);
              final targetAddress = mostRecentTransaction.fullAddress;

              // 2. Filter the list to get all transactions for that single property.
              final propertyHistory = controller.pricePaidData
                  .where((p) => p.fullAddress == targetAddress)
                  .toList();

              // 3. Sort the history for that property by date (most recent first).
              propertyHistory.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

              // 4. Display the results.
              return ListView.builder(
                itemCount: propertyHistory.length,
                itemBuilder: (context, index) {
                  final data = propertyHistory[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(data.fullAddress),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Price: £${NumberFormat('#,##0').format(data.amount)}'),
                          Text(
                              'Date: ${DateFormat.yMMMd().format(data.transactionDate)}'),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
