import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DevelopmentScenarios extends StatelessWidget {
  final String selectedScenario;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final double gdv;
  final double totalCost;
  final double uplift;

  const DevelopmentScenarios({
    super.key,
    required this.selectedScenario,
    required this.onPrevious,
    required this.onNext,
    required this.gdv,
    required this.totalCost,
    required this.uplift,
  });

  @override
  Widget build(BuildContext context) {
    final List<_ChartData> chartData = [
      _ChartData('Total Cost', totalCost, '£${(totalCost / 1000).toStringAsFixed(0)}K'),
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
