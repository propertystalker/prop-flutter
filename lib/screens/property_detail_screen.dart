
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/property.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  int _selectedScenarioIndex = 0;
  final List<String> _houseScenarios = [
    'Full Refurbishment',
    'Extensions (Rear / Side / Front)',
    'Loft Conversion',
    'Garage Conversion',
  ];

  void _nextScenario() {
    setState(() {
      _selectedScenarioIndex = (_selectedScenarioIndex + 1) % _houseScenarios.length;
    });
  }

  void _previousScenario() {
    setState(() {
      _selectedScenarioIndex =
          (_selectedScenarioIndex - 1 + _houseScenarios.length) %
              _houseScenarios.length;
    });
  }

  Widget _buildScenarios(BuildContext context) {
    final bool isFlat = widget.property.type.toLowerCase() == 'flat';

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
                onPressed: _previousScenario,
              ),
              Expanded(
                child: Text(
                  _houseScenarios[_selectedScenarioIndex],
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
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              context.push('/share', extra: widget.property);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: £${widget.property.price}',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Type: ${widget.property.type}'),
            Text('Bedrooms: ${widget.property.bedrooms}'),
            Text('Distance: ${widget.property.distance} miles'),
            Text('Location: (${widget.property.lat}, ${widget.property.lng})'),
            Text('Portal: ${widget.property.portal}'),
            Text('SSTC: ${widget.property.sstc == 1 ? 'Yes' : 'No'}'),
            if (widget.property.gdv_sold != null)
              Text('GDV Sold: £${widget.property.gdv_sold}'),
            if (widget.property.gdv_onmarket != null)
              Text('GDV On Market: £${widget.property.gdv_onmarket}'),
            if (widget.property.gdv_area != null)
              Text('GDV Area: £${widget.property.gdv_area}'),
            if (widget.property.gdv_final != null)
              Text('GDV Final: £${widget.property.gdv_final}'),
            const Divider(height: 32),
            _buildScenarios(context),
          ],
        ),
      ),
    );
  }
}
