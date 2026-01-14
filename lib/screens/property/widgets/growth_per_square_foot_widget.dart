
import 'package:flutter/material.dart';
import 'package:myapp/models/growth_per_square_foot.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/utils/constants.dart';

class GrowthPerSquareFootWidget extends StatefulWidget {
  final String postcode;

  const GrowthPerSquareFootWidget({super.key, required this.postcode});

  @override
  State<GrowthPerSquareFootWidget> createState() =>
      _GrowthPerSquareFootWidgetState();
}

class _GrowthPerSquareFootWidgetState extends State<GrowthPerSquareFootWidget> {
  late Future<List<GrowthPerSquareFootData>> _growthPerSquareFootFuture;

  @override
  void initState() {
    super.initState();
    _growthPerSquareFootFuture = ApiService().getGrowthPerSquareFoot(
      apiKey: apiKey,
      postcode: widget.postcode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GrowthPerSquareFootData>>(
      future: _growthPerSquareFootFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available.'));
        } else {
          final growthData = snapshot.data!;
          return Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Growth Per Square Foot',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16.0),
                  DataTable(
                    columns: const <DataColumn>[
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Price')),
                      DataColumn(label: Text('Growth')),
                    ],
                    rows: growthData
                        .map(
                          (data) => DataRow(
                            cells: <DataCell>[
                              DataCell(Text(data.date)),
                              DataCell(Text('£${data.price}')),
                              DataCell(Text(data.growth ?? 'N/A')),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
