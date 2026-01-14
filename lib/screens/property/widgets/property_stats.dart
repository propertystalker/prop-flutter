
import 'package:flutter/material.dart';

class PropertyStats extends StatelessWidget {
  final int squareMeters;
  final String propertyType;

  const PropertyStats({
    super.key,
    required this.squareMeters,
    required this.propertyType,
  });

  @override
  Widget build(BuildContext context) {
    // Using a fixed-width container to ensure consistent alignment
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStat('Type', propertyType),
        _buildStat('Size', '$squareMeters sq m'),
      ],
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
