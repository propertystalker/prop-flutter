import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/controllers/address_finder_controller.dart';
import 'property_floor_area_filter_screen.dart';

class AddressFinderScreen extends StatelessWidget {
  final String postcode;
  final String apiKey;

  const AddressFinderScreen(
      {super.key, required this.postcode, required this.apiKey});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddressFinderController()..fetchFloorAreas(apiKey, postcode),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Floor Areas for $postcode'),
        ),
        body: Consumer<AddressFinderController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (controller.error != null) {
              return Center(child: Text('Error: ${controller.error}'));
            } else if (controller.floorAreaResponse == null ||
                controller.floorAreaResponse!.knownFloorArea.isEmpty) {
              return const Center(child: Text('No floor area data found.'));
            } else {
              final floorAreas = controller.floorAreaResponse!.knownFloorArea;
              floorAreas.sort((a, b) {
                final houseNumberA = int.tryParse(a.address.split(' ').first.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                final houseNumberB = int.tryParse(b.address.split(' ').first.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                return houseNumberA.compareTo(houseNumberB);
              });
              return ListView.builder(
                itemCount: floorAreas.length,
                itemBuilder: (context, index) {
                  final area = floorAreas[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(area.address),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Square Meters: ${area.squareMeters}'),
                          Text('Habitable Rooms: ${area.habitableRooms}'),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PropertyFloorAreaFilterScreen(
                              area: area,
                              postcode: postcode,
                            ),
                          ),
                        );
                      },
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
