import 'package:flutter/material.dart';

class PropertyStats extends StatelessWidget {
  final int squareMeters;
  final int habitableRooms;
  final String propertyType;

  const PropertyStats({
    super.key,
    required this.squareMeters,
    required this.habitableRooms,
    required this.propertyType,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStat('Type', propertyType),
        _buildStat('Size', '$squareMeters sq m'),
        _buildStat('Rooms', habitableRooms.toString()),
      ],
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
