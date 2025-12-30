import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import '../controllers/financial_controller.dart';

class DevelopmentScenarios extends StatefulWidget {
  final Function(String) onScenarioChanged;

  const DevelopmentScenarios({
    super.key,
    required this.onScenarioChanged,
  });

  @override
  DevelopmentScenariosState createState() => DevelopmentScenariosState();
}

class DevelopmentScenariosState extends State<DevelopmentScenarios> {
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

  @override
  void initState() {
    super.initState();
    // Trigger the initial calculation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onScenarioChanged(_scenarios[_currentIndex]);
      }
    });
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
    final financialController = Provider.of<FinancialController>(context);
    final selectedScenario = _scenarios[_currentIndex];
    
    final currencyFormatter = NumberFormat.compactSimpleCurrency(locale: 'en_GB');

    final List<ChartData> chartData = [
      ChartData('Total Cost', financialController.totalCost,
          currencyFormatter.format(financialController.totalCost)),
      ChartData('Uplift', financialController.uplift,
          currencyFormatter.format(financialController.uplift)),
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
            title: ChartTitle(
                text:
                    'GDV: ${currencyFormatter.format(financialController.gdv)}'),
            legend:
                const Legend(isVisible: true, position: LegendPosition.bottom),
            series: <CircularSeries>[
              PieSeries<ChartData, String>(
                dataSource: chartData,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                dataLabelMapper: (ChartData data, _) => data.text,
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ChartData {
  ChartData(this.x, this.y, this.text);
  final String x;
  final double y;
  final String text;
}
