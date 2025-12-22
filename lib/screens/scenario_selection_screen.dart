import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/models/scenario_model.dart';

class ScenarioSelectionScreen extends StatefulWidget {
  final String propertyId;

  const ScenarioSelectionScreen({Key? key, required this.propertyId}) : super(key: key);

  @override
  _ScenarioSelectionScreenState createState() => _ScenarioSelectionScreenState();
}

class _ScenarioSelectionScreenState extends State<ScenarioSelectionScreen> {
  final List<Scenario> _scenarios = [
    Scenario(id: 'REFURB_FULL', name: 'Full refurbishment'),
    Scenario(id: 'REAR_SINGLE', name: 'Rear single-storey'),
    Scenario(id: 'REAR_DOUBLE', name: 'Rear two-storey'),
    Scenario(id: 'SIDE_SINGLE', name: 'Side single-storey'),
    Scenario(id: 'SIDE_DOUBLE', name: 'Side two-storey'),
    Scenario(id: 'FRONT_SINGLE', name: 'Full-width front single-storey'),
    Scenario(id: 'FRONT_DOUBLE', name: 'Full-width front two-storey'),
    Scenario(id: 'GARAGE_SINGLE', name: 'Standard single garage'),
    Scenario(id: 'LOFT_BASIC', name: 'Basic loft conversion'),
    Scenario(id: 'LOFT_DORMER', name: 'Dormer loft conversion'),
    Scenario(id: 'LOFT_DORMER_ENSUITE', name: 'Dormer loft with ensuite'),
  ];

  void _generateReport() {
    final selectedScenarioIds = _scenarios
        .where((s) => s.isSelected)
        .map((s) => s.id)
        .toList();

    // Using double quotes to avoid issues with the comma in the join method.
    context.go("/report/${widget.propertyId}?scenarios=${selectedScenarioIds.join(',')}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Scenarios'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _scenarios.length,
              itemBuilder: (context, index) {
                final scenario = _scenarios[index];
                return CheckboxListTile(
                  title: Text(scenario.name),
                  value: scenario.isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      scenario.isSelected = value ?? false;
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _generateReport,
              child: const Text('Generate Report'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // Make button wide
              ),
            ),
          ),
        ],
      ),
    );
  }
}
