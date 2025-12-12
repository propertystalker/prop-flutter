import 'package:flutter/material.dart';

class DevelopmentScenarios extends StatelessWidget {
  final bool isFlat;
  final String selectedScenario;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const DevelopmentScenarios({
    super.key,
    required this.isFlat,
    required this.selectedScenario,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    if (isFlat) {
      return const ListTile(
        leading: Icon(Icons.apartment),
        title: Text('Flat Refurbishment Only (1–3 bed)'),
        subtitle: Text('Scenario'),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Development Scenarios',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left),
                onPressed: onPrevious,
              ),
              Expanded(
                child: Text(
                  selectedScenario,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: onNext,
              ),
            ],
          ),
        ],
      );
    }
  }
}
