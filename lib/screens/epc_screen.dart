import 'package:flutter/material.dart';
import 'package:myapp/controllers/epc_controller.dart';
import 'package:myapp/models/epc_model.dart';
import 'package:provider/provider.dart';

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
            return ListView.builder(
              itemCount: controller.epcData.length,
              itemBuilder: (context, index) {
                final EpcModel epc = controller.epcData[index];
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
