
import 'package:flutter/material.dart';
import 'package:myapp/models/scenario_model.dart';

class ScenarioSelectionPanel extends StatefulWidget {
  final Function(List<String> selectedScenarioIds) onSelectionChanged;

  const ScenarioSelectionPanel({Key? key, required this.onSelectionChanged}) : super(key: key);

  @override
  _ScenarioSelectionPanelState createState() => _ScenarioSelectionPanelState();
}

class _ScenarioSelectionPanelState extends State<ScenarioSelectionPanel> {
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
  Widget build(BuildContext context) {
    final halfLength = (_scenarios.length / 2).ceil();
    final firstHalf = _scenarios.sublist(0, halfLength);
    final secondHalf = _scenarios.sublist(halfLength);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildScenarioColumn(firstHalf)),
          const SizedBox(width: 16),
          Expanded(child: _buildScenarioColumn(secondHalf)),
        ],
      ),
    );
  }

  Widget _buildScenarioColumn(List<Scenario> scenarios) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: scenarios
          .map((scenario) => Theme(
                data: ThemeData(unselectedWidgetColor: Colors.white),
                child: CheckboxListTile(
                  title: Text(scenario.name, style: const TextStyle(color: Colors.white)),
                  value: scenario.isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      scenario.isSelected = value ?? false;
                    });
                    final selectedIds = _scenarios
                        .where((s) => s.isSelected)
                        .map((s) => s.id)
                        .toList();
                    widget.onSelectionChanged(selectedIds);
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.white,
                  checkColor: Colors.blue,
                  contentPadding: EdgeInsets.zero,
                ),
              ))
          .toList(),
    );
  }
}
