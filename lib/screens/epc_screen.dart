import 'package:flutter/material.dart';
import 'package:myapp/controllers/epc_controller.dart';
import 'package:myapp/models/epc_model.dart';
import 'package:provider/provider.dart';

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

class EpcScreen extends StatefulWidget {
  final String postcode;
  final String? houseNumber;

  const EpcScreen({super.key, required this.postcode, this.houseNumber});

  @override
  State<EpcScreen> createState() => _EpcScreenState();
}

class _EpcScreenState extends State<EpcScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // We fetch all data for the postcode. The filtering happens in the build method.
      Provider.of<EpcController>(context, listen: false)
          .fetchEpcData(widget.postcode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EPC Data for ${widget.postcode}'),
      ),
      body: Consumer<EpcController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.error != null) {
            return Center(child: Text('Error: ${controller.error}'));
          }
          if (controller.epcData.isEmpty) {
            return const Center(child: Text('No EPC data found for this postcode.'));
          }

          // 1. Start with the full, sorted list of properties
          final sortedData = List<EpcModel>.from(controller.epcData);
          sortedData.sort((a, b) => _compareAddresses(a.address, b.address));

          // 2. Determine the final list to display
          List<EpcModel> displayData;

          // If a house number is provided and is not empty, filter the list.
          if (widget.houseNumber != null && widget.houseNumber!.trim().isNotEmpty) {
            final houseNumberQuery = widget.houseNumber!.trim();
            
            // Use a robust RegExp to match the house number at the start of the address.
            // '\b' creates a word boundary to prevent partial matches (e.g., '2' matching '12').
            displayData = sortedData.where((epc) {
              return RegExp(r'^' + RegExp.escape(houseNumberQuery) + r'\b', caseSensitive: false)
                  .hasMatch(epc.address);
            }).toList();

            // If after filtering, no properties match, show a specific message.
            if (displayData.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No property matching house number "$houseNumberQuery" was found at this postcode.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
          } else {
            // If no house number is provided, display all properties.
            displayData = sortedData;
          }

          // 3. Build the list view with the final 'displayData'.
          return ListView.builder(
            itemCount: displayData.length,
            itemBuilder: (context, index) {
              final EpcModel epc = displayData[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(epc.address),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Postcode: ${epc.postcode}'),
                      Text('Current Rating: ${epc.currentEnergyRating}'),
                      Text('Potential Rating: ${epc.potentialEnergyRating}'),
                      Text('Property Type: ${epc.propertyType}'),
                      Text('Built Form: ${epc.builtForm}'),
                      Text('Main Fuel: ${epc.mainFuel}'),
                      Text('Total Floor Area: ${epc.totalFloorArea} sq m'),
                      Text('Lodgement Date: ${epc.lodgementDate}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
