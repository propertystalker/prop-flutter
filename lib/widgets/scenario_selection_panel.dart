import 'package:flutter/material.dart';
import 'package:myapp/models/scenario_model.dart';

class ScenarioSelectionPanel extends StatelessWidget {
  final List<Scenario> scenarios;
  final Function(String, bool) onScenarioSelected;

  const ScenarioSelectionPanel({
    super.key,
    required this.scenarios,
    required this.onScenarioSelected,
  });

  @override
  Widget build(BuildContext context) {
    final halfLength = (scenarios.length / 2).ceil();
    final firstHalf = scenarios.sublist(0, halfLength);
    final secondHalf = scenarios.sublist(halfLength);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildScenarioColumn(context, firstHalf)),
          const SizedBox(width: 16),
          Expanded(child: _buildScenarioColumn(context, secondHalf)),
        ],
      ),
    );
  }

  Widget _buildScenarioColumn(BuildContext context, List<Scenario> scenarios) {
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
                    onScenarioSelected(scenario.id, value ?? false);
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
