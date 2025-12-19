
import 'package:flutter/material.dart';
import 'package:myapp/controllers/epc_controller.dart';
import 'package:myapp/models/epc_model.dart';
import 'package:myapp/models/property_floor_area.dart';
import 'package:myapp/screens/property_screen.dart';
import 'package:provider/provider.dart';
import 'package:myapp/utils/constants.dart'; // Import constants for colors

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
  final String? flatNumber;

  const EpcScreen(
      {super.key,
      required this.postcode,
      this.houseNumber,
      this.flatNumber});

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

    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PropertyScreen(
          area: knownFloorArea,
          postcode: epc.postcode,
          propertyType: epc.propertyType,
        ),
      ),
    );
  }

  // WIDGET FOR HIGHLIGHTING THE ADDRESS
  Widget _buildHighlightedTitle(String address, String? flatNumber, String? houseNumber) {
    final cleanFlatQuery = (flatNumber != null && flatNumber.trim().isNotEmpty) ? flatNumber.trim() : null;
    final cleanHouseQuery = (houseNumber != null && houseNumber.trim().isNotEmpty) ? houseNumber.trim() : null;

    if (cleanFlatQuery == null && cleanHouseQuery == null) {
      return Text(address, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16));
    }

    final Map<String, Color> searchTerms = {};
    if (cleanFlatQuery != null) searchTerms[cleanFlatQuery] = trafficGreen;
    if (cleanHouseQuery != null) searchTerms[cleanHouseQuery] = trafficRed;

    final pattern = searchTerms.keys.map((key) => RegExp.escape(key)).join('|');
    final regex = RegExp(pattern, caseSensitive: false);
    
    final List<TextSpan> spans = [];
    int lastEnd = 0;

    for (final match in regex.allMatches(address)) {
        if (match.start > lastEnd) {
            spans.add(TextSpan(text: address.substring(lastEnd, match.start)));
        }
        
        final matchedText = match.group(0)!;
        final color = searchTerms.entries.firstWhere((entry) => entry.key.toLowerCase() == matchedText.toLowerCase()).value;
        
        spans.add(
            TextSpan(
                text: matchedText,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    backgroundColor: color.withAlpha(51),
                ),
            )
        );
        lastEnd = match.end;
    }

    if (lastEnd < address.length) {
        spans.add(TextSpan(text: address.substring(lastEnd)));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
        ),
        children: spans,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    // --- BUILD THE DEBUG TITLE STRING ---
    final List<String> titleParts = ['EPC: ${widget.postcode}'];
    if (widget.flatNumber != null && widget.flatNumber!.isNotEmpty) {
      titleParts.add('Flat: ${widget.flatNumber}');
    }
    if (widget.houseNumber != null && widget.houseNumber!.isNotEmpty) {
      titleParts.add('House: ${widget.houseNumber}');
    }
    // --- END OF TITLE STRING LOGIC ---

    return Scaffold(
      appBar: AppBar(
        // UPDATED TITLE FOR DEBUGGING
        title: Text(
          titleParts.join(' | '),
          style: const TextStyle(fontSize: 14), // Smaller font to fit more text
        ),
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

          // --- NEW AND CORRECTED FILTERING LOGIC ---
          List<EpcModel> filteredData;
          final houseQuery = widget.houseNumber?.trim();
          final flatQuery = widget.flatNumber?.trim();
          final bool hasHouseQuery = houseQuery != null && houseQuery.isNotEmpty;
          final bool hasFlatQuery = flatQuery != null && flatQuery.isNotEmpty;

          if (hasHouseQuery || hasFlatQuery) {
              filteredData = sortedData.where((epc) {
                  final addressLower = epc.address.toLowerCase();
                  
                  if (hasHouseQuery) {
                      final houseRegex = RegExp(r'\b' + RegExp.escape(houseQuery) + r'\b');
                      if (!houseRegex.hasMatch(addressLower)) return false;
                  }
                  if (hasFlatQuery) {
                      final flatRegex = RegExp(r'\b' + RegExp.escape(flatQuery) + r'\b');
                      if (!flatRegex.hasMatch(addressLower)) return false;
                  }
                  return true;
              }).toList();

              if (filteredData.isEmpty) {
                  return Center(
                      child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                              'No property matching your criteria was found. Please check the numbers and try again.',
                              textAlign: TextAlign.center,
                          ),
                      ),
                  );
              }
          } else {
              filteredData = sortedData;
          }
          // --- END OF NEW LOGIC ---

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

          if (displayData.length == 1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _navigateToDetails(context, displayData.first);
              }
            });
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: displayData.length,
            itemBuilder: (context, index) {
              final EpcModel epc = displayData[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  // USE THE NEW HIGHLIGHTING WIDGET HERE
                  title: _buildHighlightedTitle(epc.address, widget.flatNumber, widget.houseNumber),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
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
