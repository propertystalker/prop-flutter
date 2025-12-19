import 'package:flutter/material.dart';
import 'package:myapp/controllers/epc_controller.dart';
import 'package:myapp/models/epc_model.dart';
import 'package:myapp/models/property_floor_area.dart';
import 'package:myapp/screens/property_floor_area_filter_screen.dart';
import 'package:provider/provider.dart';

// Helper function for natural sorting of addresses
int _compareAddresses(String addressA, String addressB) {
  final re = RegExp(r'(\d+)|(\D+)');
  final matchesA = re.allMatches(addressA);
  final matchesB = re.allMatches(addressB);

  final numMatches =
      matchesA.length < matchesB.length ? matchesA.length : matchesB.length;

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
  final String? flatNumber; // Added flatNumber

  const EpcScreen(
      {super.key,
      required this.postcode,
      this.houseNumber,
      this.flatNumber}); // Added flatNumber

  @override
  State<EpcScreen> createState() => _EpcScreenState();
}

class _EpcScreenState extends State<EpcScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EpcController>(context, listen: false)
          .fetchEpcData(widget.postcode);
    });
  }

  void _navigateToDetails(BuildContext context, EpcModel epc) {
    final totalFloorArea = double.tryParse(epc.totalFloorArea) ?? 0.0;
    final estimatedHabitableRooms = (totalFloorArea / 20).round();

    final knownFloorArea = KnownFloorArea(
      address: epc.address,
      postcode: epc.postcode,
      squareMeters: totalFloorArea.round(),
      habitableRooms: estimatedHabitableRooms,
      inspectionDate: epc.lodgementDate,
    );

    // Pop the current screen and then push the new screen to keep the navigation stack correct.
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PropertyFloorAreaFilterScreen(
          area: knownFloorArea,
          postcode: epc.postcode,
          propertyType: epc.propertyType,
        ),
      ),
    );
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
            return const Center(
                child: Text('No EPC data found for this postcode.'));
          }

          final sortedData = List<EpcModel>.from(controller.epcData);
          sortedData.sort((a, b) => _compareAddresses(a.address, b.address));

          List<EpcModel> filteredData;
          if (widget.houseNumber != null &&
              widget.houseNumber!.trim().isNotEmpty) {
            final houseNumberQuery = widget.houseNumber!.trim();
            final filterRegex = RegExp(r'\b' + RegExp.escape(houseNumberQuery) + r'\b',
                caseSensitive: false);

            filteredData = sortedData.where((epc) {
              return filterRegex.hasMatch(epc.address);
            }).toList();

            if (filteredData.isEmpty) {
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
            filteredData = sortedData;
          }

          final Map<String, EpcModel> latestEpcByAddress = {};
          for (final epc in filteredData) {
            final normalizedAddress = epc.address
                .replaceAll(',', '')
                .replaceAll(RegExp(r'\s+'), ' ')
                .trim();

            if (!latestEpcByAddress.containsKey(normalizedAddress) ||
                epc.lodgementDate.compareTo(
                        latestEpcByAddress[normalizedAddress]!.lodgementDate) >
                    0) {
              latestEpcByAddress[normalizedAddress] = epc;
            }
          }

          final displayData = latestEpcByAddress.values.toList();
          displayData.sort((a, b) => _compareAddresses(a.address, b.address));

          // If there is only one result, navigate directly to the details screen.
          if (displayData.length == 1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) { // Ensure the widget is still in the tree
                _navigateToDetails(context, displayData.first);
              }
            });
            // Show a loading indicator while the navigation is scheduled.
            return const Center(child: CircularProgressIndicator());
          }

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
                  onTap: () => _navigateToDetails(context, epc),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
