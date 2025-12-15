import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/price_paid_model.dart';
import 'package:provider/provider.dart';
import 'package:myapp/controllers/price_paid_controller.dart';

// Helper function for natural sorting of addresses
int _compareAddresses(String addressA, String addressB) {
  final re = RegExp(r'(\d+)|(\D+)');
  final matchesA = re.allMatches(addressA);
  final matchesB = re.allMatches(addressB);

  final numMatches = matchesA.length < matchesB.length ? matchesA.length : matchesB.length;

  for (int i = 0; i < numMatches; i++) {
    final matchA = matchesA.elementAt(i).group(0)!;
    final matchB = matchesB.elementAt(i).group(0)!;

    final isNumA = int.tryParse(matchA) != null;
    final isNumB = int.tryParse(matchB) != null;

    if (isNumA && isNumB) {
      final comp = int.parse(matchA).compareTo(int.parse(matchB));
      if (comp != 0) return comp;
    } else {
      final comp = matchA.compareTo(matchB);
      if (comp != 0) return comp;
    }
  }

  return matchesA.length.compareTo(matchesB.length);
}

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
              // Sort the data by address using natural sorting
              final sortedData = List<PricePaidModel>.from(controller.pricePaidData);
              sortedData.sort((a, b) => _compareAddresses(a.fullAddress, b.fullAddress));

              return ListView.builder(
                itemCount: sortedData.length,
                itemBuilder: (context, index) {
                  final data = sortedData[index];
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
