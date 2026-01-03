
import 'package:flutter/material.dart';
import '../models/planning_application.dart';

class PlanAppWidget extends StatelessWidget {
  final List<PlanningApplication> applications;

  const PlanAppWidget({super.key, required this.applications});

  @override
  Widget build(BuildContext context) {
    if (applications.isEmpty) {
      return const Center(child: Text('No planning applications found.'));
    }

    return ListView.builder(
      itemCount: applications.length,
      itemBuilder: (context, index) {
        final app = applications[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            title: Text(app.address),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(app.description),
                const SizedBox(height: 4),
                Text('Status: ${app.status}'),
                Text('Received: ${app.receivedDate}'),
              ],
            ),
            trailing: Text(app.postcode),
          ),
        );
      },
    );
  }
}
