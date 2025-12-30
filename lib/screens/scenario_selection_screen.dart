
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/models/scenario_model.dart';
import 'package:myapp/widgets/report_panel.dart';

class ScenarioSelectionScreen extends StatefulWidget {
  final String propertyId;

  const ScenarioSelectionScreen({Key? key, required this.propertyId}) : super(key: key);

  @override
  _ScenarioSelectionScreenState createState() => _ScenarioSelectionScreenState();
}

class _ScenarioSelectionScreenState extends State<ScenarioSelectionScreen> {
  final List<Scenario> _scenarios = [
    Scenario(id: 'REFURB_FULL', name: 'Full refurbishment'),
    Scenario(id: 'FRONT_SINGLE', name: 'Full-width front single-storey'),
    Scenario(id: 'REAR_SINGLE', name: 'Rear single-storey'),
    Scenario(id: 'FRONT_DOUBLE', name: 'Full-width front two-storey'),
    Scenario(id: 'REAR_DOUBLE', name: 'Rear two-storey'),
    Scenario(id: 'GARAGE_SINGLE', name: 'Standard single garage'),
    Scenario(id: 'SIDE_SINGLE', name: 'Side single-storey'),
    Scenario(id: 'LOFT_BASIC', name: 'Basic loft conversion'),
    Scenario(id: 'SIDE_DOUBLE', name: 'Side two-storey'),
    Scenario(id: 'LOFT_DORMER', name: 'Dormer loft conversion'),
    Scenario(id: 'LOFT_DORMER_ENSUITE', name: 'Dormer loft with ensuite'),
  ];

  void _generateReport() {
    final selectedScenarioIds = _scenarios
        .where((s) => s.isSelected)
        .map((s) => s.id)
        .toList();
    context.go("/report/${widget.propertyId}?scenarios=${selectedScenarioIds.join(',')}");
  }

  @override
  Widget build(BuildContext context) {
    // Splitting scenarios for two-column layout
    final halfLength = (_scenarios.length / 2).ceil();
    final firstHalf = _scenarios.sublist(0, halfLength);
    final secondHalf = _scenarios.sublist(halfLength);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/gemini.png"), // Placeholder
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content Overlay
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: const Icon(Icons.business), // Placeholder logo
                title: const Text("98375"), // Placeholder ID
                actions: [
                  const Text("British Land"),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {},
                  ),
                  const CircleAvatar(
                    // Placeholder profile pic
                    backgroundImage: NetworkImage("https://placehold.it/150"),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildScenarioColumn(firstHalf)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildScenarioColumn(secondHalf)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Placeholder for Address and Price
                        const Text(
                          "31 BEECH ROAD, CAMBRIDGE, CB1 3AZ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "£373k",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Report Panel at the bottom
              ReportPanel(
                onSend: _generateReport,
                address: "31 BEECH ROAD, CAMBRIDGE, CB1 3AZ", // Dummy data
                price: "£373k", // Dummy data
                images: [], // Dummy data
                gdv: 0, // Dummy data
                totalCost: 0, // Dummy data
                uplift: 0, // Dummy data
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioColumn(List<Scenario> scenarios) {
    return Column(
      children: scenarios
          .map((scenario) => CheckboxListTile(
                title: Text(scenario.name,
                    style: const TextStyle(color: Colors.white)),
                value: scenario.isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    scenario.isSelected = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.white,
                checkColor: Colors.blue,
              ))
          .toList(),
    );
  }
}
