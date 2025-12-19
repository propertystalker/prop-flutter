import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controllers/gdv_controller.dart';

class GdvRangeWidget extends StatelessWidget {
  const GdvRangeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final gdvController = Provider.of<GdvController>(context);
    final currencyFormatter = NumberFormat.compactSimpleCurrency(locale: 'en_GB');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GDV Range (Indicative)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Illustrative range reflecting market uncertainty',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          _buildRangeBar(context, gdvController, currencyFormatter),
          const SizedBox(height: 8),
          _buildRangeLabels(context, gdvController, currencyFormatter),
        ],
      ),
    );
  }

  Widget _buildRangeBar(
      BuildContext context, GdvController controller, NumberFormat formatter) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // The main bar
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Base GDV marker
              Positioned(
                // The marker is positioned based on its percentage of the total range
                child: Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Cautious and Optimistic labels
              Positioned(
                left: 0,
                child: Text(
                  formatter.format(controller.cautiousGdv),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                right: 0,
                child: Text(
                  formatter.format(controller.optimisticGdv),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRangeLabels(
      BuildContext context, GdvController controller, NumberFormat formatter) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLabel('Cautious', formatter.format(controller.cautiousGdv)),
        _buildLabel('Base', formatter.format(controller.baseGdv), isBase: true),
        _buildLabel('Optimistic', formatter.format(controller.optimisticGdv)),
      ],
    );
  }

  Widget _buildLabel(String title, String value, {bool isBase = false}) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBase ? FontWeight.bold : FontWeight.normal,
            color: isBase ? Colors.black : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBase ? FontWeight.bold : FontWeight.normal,
            color: isBase ? Colors.black : Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
