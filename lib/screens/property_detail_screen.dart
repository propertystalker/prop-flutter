
import 'package:flutter/material.dart';
import '../models/property.dart';

class PropertyDetailScreen extends StatelessWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: £${property.price}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Type: ${property.type}'),
            Text('Bedrooms: ${property.bedrooms}'),
            Text('Distance: ${property.distance} miles'),
            Text('Location: (${property.lat}, ${property.lng})'),
            Text('Portal: ${property.portal}'),
            Text('SSTC: ${property.sstc == 1 ? 'Yes' : 'No'}'),

          ],
        ),
      ),
    );
  }
}
