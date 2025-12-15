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

  const EpcScreen({super.key, required this.postcode});

  @override
  State<EpcScreen> createState() => _EpcScreenState();
}

class _EpcScreenState extends State<EpcScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch EPC data when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
          } else if (controller.error != null) {
            return Center(child: Text('Error: ${controller.error}'));
          } else if (controller.epcData.isEmpty) {
            return const Center(child: Text('No EPC data found.'));
          } else {
            // Sort the data by address using natural sorting
            final sortedData = List<EpcModel>.from(controller.epcData);
            sortedData.sort((a, b) => _compareAddresses(a.address, b.address));

            return ListView.builder(
              itemCount: sortedData.length,
              itemBuilder: (context, index) {
                final EpcModel epc = sortedData[index];
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
          }
        },
      ),
    );
  }
}
