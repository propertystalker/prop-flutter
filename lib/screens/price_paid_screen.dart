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
              return ListView.builder(
                itemCount: controller.pricePaidData.length,
                itemBuilder: (context, index) {
                  final data = controller.pricePaidData[index];
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
