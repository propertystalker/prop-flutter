
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/property.dart';

class PropertyDetailScreen extends StatelessWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  Widget _buildScenarios(BuildContext context) {
    // Making the check case-insensitive to be more robust
    final bool isFlat = property.type.toLowerCase() == 'flat';

    if (isFlat) {
      return const ListTile(
        leading: Icon(Icons.apartment),
        title: Text('Flat Refurbishment Only (1–3 bed)'),
        subtitle: Text('Scenario'),
      );
    } else {
      // Assuming any other type is a house with multiple scenarios
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Development Scenarios',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8.0),
          const Text('• Full Refurbishment'),
          const SizedBox(height: 4.0),
          const Text('• Extensions (Rear / Side / Front)'),
          const SizedBox(height: 4.0),
          const Text('• Loft Conversion'),
          const SizedBox(height: 4.0),
          const Text('• Garage Conversion'),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              context.push('/share', extra: property);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: £${property.price}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Type: ${property.type}'),
            Text('Bedrooms: ${property.bedrooms}'),
            Text('Distance: ${property.distance} miles'),
            Text('Location: (${property.lat}, ${property.lng})'),
            Text('Portal: ${property.portal}'),
            Text('SSTC: ${property.sstc == 1 ? 'Yes' : 'No'}'),
            if (property.gdv_sold != null) Text('GDV Sold: £${property.gdv_sold}'),
            if (property.gdv_onmarket != null)
              Text('GDV On Market: £${property.gdv_onmarket}'),
            if (property.gdv_area != null) Text('GDV Area: £${property.gdv_area}'),
            if (property.gdv_final != null)
              Text('GDV Final: £${property.gdv_final}'),
            const Divider(height: 32),
            _buildScenarios(context),
          ],
        ),
      ),
    );
  }
}
