
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/planning_application.dart';

class PlanningApplicationsWidget extends StatelessWidget {
  final List<PlanningApplication> planningApplications;
  final bool isLoading;

  const PlanningApplicationsWidget({
    super.key,
    required this.planningApplications,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Planning Applications',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : planningApplications.isEmpty
                ? const Text('No recent planning applications found.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: planningApplications.length,
                    itemBuilder: (context, index) {
                      final app = planningApplications[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                app.address,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(app.proposal),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Decision: ${app.decision.text}',
                                    style: TextStyle(
                                      color: app.decision.rating == 'positive'
                                          ? Colors.green
                                          : app.decision.rating == 'negative'
                                              ? Colors.red
                                              : Colors.grey,
                                    ),
                                  ),
                                  if (app.dates.receivedAt != null)
                                    Text(
                                      'Received: ${DateFormat.yMMMd().format(app.dates.receivedAt!)}',
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ],
    );
  }
}
