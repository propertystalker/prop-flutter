
import 'package:flutter/material.dart';
import '../models/property_floor_area.dart';

class PropertyFloorAreaFilterScreen extends StatelessWidget {
  final KnownFloorArea area;

  const PropertyFloorAreaFilterScreen({Key? key, required this.area}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  area.address,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _buildDetailRow(
                  context,
                  label: 'Size',
                  value: area.squareFeet.toString(),
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  context,
                  label: 'Bedroom',
                  value: area.habitableRooms.toString(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, {required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
