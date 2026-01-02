
import 'package:flutter/material.dart';
import '../models/planning_application.dart';
import '../services/planning_service.dart';

class PlanAppWidget extends StatefulWidget {
  final String postcode;

  const PlanAppWidget({Key? key, required this.postcode}) : super(key: key);

  @override
  _PlanAppWidgetState createState() => _PlanAppWidgetState();
}

class _PlanAppWidgetState extends State<PlanAppWidget> {
  late Future<List<PlanningApplication>> _planningApplicationsFuture;

  @override
  void initState() {
    super.initState();
    _planningApplicationsFuture = PlanningService().getPlanningApplications(widget.postcode);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PlanningApplication>>(
      future: _planningApplicationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No planning applications found.'));
        } else {
          final applications = snapshot.data!;
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
      },
    );
  }
}
