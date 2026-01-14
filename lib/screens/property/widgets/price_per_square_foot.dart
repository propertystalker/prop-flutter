
import 'package:flutter/material.dart';

import 'package:myapp/models/price_per_square_foot.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/utils/constants.dart';

class PricePerSquareFootWidget extends StatefulWidget {
  final String postcode;

  const PricePerSquareFootWidget({super.key, required this.postcode});

  @override
  State<PricePerSquareFootWidget> createState() => _PricePerSquareFootWidgetState();
}

class _PricePerSquareFootWidgetState extends State<PricePerSquareFootWidget> {
  late Future<PricePerSquareFoot> _pricePerSquareFootFuture;

  @override
  void initState() {
    super.initState();
    _pricePerSquareFootFuture = ApiService().getPricePerSquareFoot(
      apiKey: apiKey,
      postcode: widget.postcode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PricePerSquareFoot>(
      future: _pricePerSquareFootFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No data available.'));
        } else {
          final pricePerSqf = snapshot.data!;
          return Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price Per Square Foot',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16.0),
                  _buildPriceRow('Average', '£${pricePerSqf.average}'),
                  _buildPriceRow('70% Range', '£${pricePerSqf.range70pc[0]} - £${pricePerSqf.range70pc[1]}'),
                  _buildPriceRow('80% Range', '£${pricePerSqf.range80pc[0]} - £${pricePerSqf.range80pc[1]}'),
                  _buildPriceRow('90% Range', '£${pricePerSqf.range90pc[0]} - £${pricePerSqf.range90pc[1]}'),
                  _buildPriceRow('100% Range', '£${pricePerSqf.range100pc[0]} - £${pricePerSqf.range100pc[1]}'),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildPriceRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
