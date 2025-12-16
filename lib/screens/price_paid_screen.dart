import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:myapp/controllers/price_paid_controller.dart';

class PricePaidScreen extends StatelessWidget {
  final String postcode;
  final String houseNumber;

  const PricePaidScreen({super.key, required this.postcode, required this.houseNumber});

  @override
  Widget build(BuildContext context) {
    // The controller is now created and called with both postcode and houseNumber.
    return ChangeNotifierProvider(
      create: (_) => PricePaidController()
        ..fetchPricePaidHistoryForProperty(postcode, houseNumber),
      child: Scaffold(
        appBar: AppBar(
          // The title now reflects the specific property being viewed.
          title: Text(houseNumber.isNotEmpty
              ? 'Sales History for $houseNumber, $postcode'
              : 'Sales History for $postcode'),
        ),
        body: Consumer<PricePaidController>(
          builder: (context, controller, child) {
            // The UI now simply reacts to the state provided by the controller.
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error: ${controller.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              );
            }

            if (controller.priceHistory.isEmpty) {
              return const Center(
                  child: Text('No sales data found for this property.'));
            }

            // The complex filtering logic is gone. We just display the list.
            return ListView.builder(
              itemCount: controller.priceHistory.length,
              itemBuilder: (context, index) {
                final data = controller.priceHistory[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      'Price: £${NumberFormat('#,##0').format(data.amount)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          // Constructing the address from available fields.
                          data.fullAddress,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                            'Date: ${DateFormat.yMMMd().format(data.transactionDate)}'),
                        const SizedBox(height: 4),
                        Text('Property Type: ${data.propertyType}'),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
