import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';

class TrafficLightIndicator extends StatelessWidget {
  final bool isLoading;
  final int? price;
  final String? error;

  const TrafficLightIndicator({
    super.key,
    required this.isLoading,
    this.price,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.compactSimpleCurrency(locale: 'en_GB');

    return Column(
      children: [
        if (isLoading)
          const CircularProgressIndicator()
        else if (price != null)
          Text(currencyFormat.format(price),
              style: const TextStyle(color: accentColor))
        else if (error != null)
          Text(error!, style: const TextStyle(color: accentColor))
        else
          const Text('Prev. Price', style: TextStyle(color: accentColor)),
        const SizedBox(height: 8),
        Container(
            width: 24,
            height: 24,
            decoration:
                const BoxDecoration(color: trafficRed, shape: BoxShape.circle)),
        const SizedBox(height: 8),
        Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
                color: trafficYellow, shape: BoxShape.circle)),
        const SizedBox(height: 8),
        Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
                color: trafficGreen, shape: BoxShape.circle)),
      ],
    );
  }
}
