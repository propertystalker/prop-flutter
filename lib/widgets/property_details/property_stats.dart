import 'package:flutter/material.dart';

class PropertyStats extends StatelessWidget {
  final int squareFeet;
  final int habitableRooms;
  final String propertyType;

  const PropertyStats({
    super.key,
    required this.squareFeet,
    required this.habitableRooms,
    required this.propertyType,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Text('Size: ', style: Theme.of(context).textTheme.titleMedium),
                  Text(squareFeet.toString(), style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Text('Bedroom: ', style: Theme.of(context).textTheme.titleMedium),
                  Text(habitableRooms.toString(), style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Text('Type: ', style: Theme.of(context).textTheme.titleMedium),
                  Text(propertyType, style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
