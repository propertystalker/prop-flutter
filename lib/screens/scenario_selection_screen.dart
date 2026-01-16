import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/controllers/epc_controller.dart';
import 'package:myapp/controllers/financial_controller.dart';
import 'package:myapp/models/planning_application.dart';
import 'package:myapp/models/scenario_model.dart';
import 'package:myapp/services/planning_service.dart';
import 'package:myapp/services/property_data_service.dart';
import 'package:myapp/widgets/report_panel.dart';

class ScenarioSelectionScreen extends StatefulWidget {
  final String propertyId;

  const ScenarioSelectionScreen({super.key, required this.propertyId});

  @override
  State<ScenarioSelectionScreen> createState() =>
      _ScenarioSelectionScreenState();
}

class _ScenarioSelectionScreenState extends State<ScenarioSelectionScreen> {
  List<PlanningApplication> _planitApplications = [];
  List<PlanningApplication> _propertyDataApplications = [];

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

  @override
  void initState() {
    super.initState();
    _fetchPlanningApplications();
    _updateFinancialControllerWithPropertyData();
  }

  Future<void> _fetchPlanningApplications() async {
    try {
      final postcode = widget.propertyId.split(', ').last;
      final planitApps = await PlanningService().getPlanningApplications(postcode);
      final propertyDataApps = await PropertyDataService().getPlanningApplications(postcode);
      if (mounted) {
        setState(() {
          _planitApplications = planitApps;
          _propertyDataApplications = propertyDataApps;
        });
      }
    } catch (e) {
      debugPrint("Error fetching planning applications: $e");
    }
  }

  void _updateFinancialControllerWithPropertyData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final epcController = Provider.of<EpcController>(context, listen: false);
      final financialController = Provider.of<FinancialController>(context, listen: false);
      final selectedEpc = epcController.selectedEpc;

      if (selectedEpc != null) {
        final floorArea = double.tryParse(selectedEpc.totalFloorArea) ?? 0.0;
        financialController.updatePropertyData(
          totalFloorArea: floorArea,
          propertyType: selectedEpc.propertyType,
          builtForm: selectedEpc.builtForm,
          epcRating: selectedEpc.currentEnergyRating,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final halfLength = (_scenarios.length / 2).ceil();
    final firstHalf = _scenarios.sublist(0, halfLength);
    final secondHalf = _scenarios.sublist(halfLength);

    final selectedScenarioNames = _scenarios.where((s) => s.isSelected).map((s) => s.name).toList();
    developer.log('Building ScenarioSelectionScreen. Selected Scenarios: $selectedScenarioNames', name: 'ScenarioSelectionScreen');

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/gemini.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
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
                            color: const Color.fromRGBO(0, 0, 0, 0.5),
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
              ReportPanel(
                propertyId: widget.propertyId,
                address: "31 BEECH ROAD, CAMBRIDGE, CB1 3AZ",
                price: "£373k",
                images: const [],
                planitApplications: _planitApplications,
                propertyDataApplications: _propertyDataApplications,
                selectedScenarios: selectedScenarioNames,
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
