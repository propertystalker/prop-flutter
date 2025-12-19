import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DevelopmentScenarios extends StatefulWidget {
  final double propertyValue;
  final Function(String) onScenarioChanged;

  const DevelopmentScenarios({
    super.key,
    required this.propertyValue,
    required this.onScenarioChanged,
  });

  @override
  _DevelopmentScenariosState createState() => _DevelopmentScenariosState();
}

class _DevelopmentScenariosState extends State<DevelopmentScenarios> {
  int _currentIndex = 0;

  final List<String> _scenarios = [
    'Full Refurbishment',
    'Rear single-storey extension',
    'Rear two-storey extension',
    'Side single-storey extension',
    'Side two-storey extension',
    'Porch / small front single-storey extension',
    'Full-width front single-storey extension',
    'Full-width front two-storey front extension',
    'Standard single garage conversion',
    'Basic loft conversion (Velux)',
    'Dormer loft conversion',
    'Dormer loft with ensuite',
  ];

  // Dummy data for uplift calculation - replace with actual logic
  double _calculateUplift(String scenario) {
    // Replace with your actual uplift calculation based on the scenario
    return (scenario.hashCode % 100) * 1000.0;
  }

  void _nextScenario() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _scenarios.length;
      widget.onScenarioChanged(_scenarios[_currentIndex]);
    });
  }

  void _previousScenario() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + _scenarios.length) % _scenarios.length;
      widget.onScenarioChanged(_scenarios[_currentIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedScenario = _scenarios[_currentIndex];
    final uplift = _calculateUplift(selectedScenario);
    final gdv = widget.propertyValue + uplift;

    final List<_ChartData> chartData = [
      _ChartData('Property Value', widget.propertyValue, '£${(widget.propertyValue / 1000).toStringAsFixed(0)}K'),
      _ChartData('Uplift', uplift, '£${(uplift / 1000).toStringAsFixed(0)}K'),
    ];

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
              onPressed: _previousScenario,
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
              onPressed: _nextScenario,
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        SizedBox(
          height: 200,
          child: SfCircularChart(
            title: ChartTitle(text: 'GDV: £${(gdv / 1000).toStringAsFixed(0)}K'),
            legend: const Legend(isVisible: true, position: LegendPosition.bottom),
            series: <CircularSeries>[
              PieSeries<_ChartData, String>(
                dataSource: chartData,
                xValueMapper: (_ChartData data, _) => data.x,
                yValueMapper: (_ChartData data, _) => data.y,
                dataLabelMapper: (_ChartData data, _) => data.text,
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y, this.text);
  final String x;
  final double y;
  final String text;
}
