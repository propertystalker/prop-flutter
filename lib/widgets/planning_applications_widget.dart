
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

  String _generateTrendsSentence() {
    if (planningApplications.isEmpty) {
      return '';
    }

    final approvedApplications = planningApplications
        .where((app) => app.decision.rating == 'positive')
        .toList();

    if (approvedApplications.isEmpty) {
      return '';
    }

    // Group keywords to count trends more accurately (e.g., 'extension' and 'extensions' are the same trend).
    final keywordGroups = {
      'extensions': ['extension', 'extensions'],
      'loft conversions': ['loft', 'dormer'],
      'alterations': ['alteration', 'alterations', 'amendment'],
      'garages': ['garage', 'carport'],
      'porches': ['porch'],
      'new builds': ['new dwelling', 'new build', 'new house'],
      'windows & doors': ['window', 'windows', 'door', 'doors'],
      'fences & walls': ['fence', 'fencing', 'wall', 'walls', 'guardrail', 'guardrails'],
      'trees & landscaping': ['tree', 'trees', 'landscaping'],
      'roof alterations': ['roof'],
      'demolition': ['demolition'],
      'basements': ['basement'],
      'balconies': ['balcony', 'balconies'],
      'conditions & consents': ['condition', 'consent'],
    };

    final groupCounts = <String, int>{};

    for (final app in approvedApplications) {
      final proposal = app.proposal.toLowerCase();
      final matchedGroups = <String>{}; // Use a Set to count each group only once per application

      keywordGroups.forEach((groupName, keywords) {
        for (final keyword in keywords) {
          if (proposal.contains(keyword)) {
            matchedGroups.add(groupName);
            break; // Move to the next group once a keyword in the current group is found
          }
        }
      });

      for (final group in matchedGroups) {
          groupCounts.update(group, (value) => value + 1, ifAbsent: () => 1);
      }
    }

    if (groupCounts.isEmpty) {
      return '';
    }

    // Sort by count descending
    final sortedGroups = groupCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Filter out groups with low counts to avoid showing trends for single occurrences
    final significantTrends = sortedGroups.where((entry) => entry.value > 0).toList();

    if (significantTrends.isEmpty) {
      return '';
    }

    final topTrends = significantTrends.take(2).map((e) => e.key).toList();

    if (topTrends.isEmpty) {
      return '';
    }

    if (topTrends.length == 1) {
      return 'This area shows approval trends for ${topTrends[0]}.';
    } else {
      return 'This area shows strong approval trends for ${topTrends[0]} and ${topTrends[1]}.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final trendsSentence = _generateTrendsSentence();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Planning Applications',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        if (trendsSentence.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              trendsSentence,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
            ),
          ),
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
                                  Flexible(
                                    child: Text(
                                      'Decision: ${app.decision.text}',
                                      style: TextStyle(
                                        color: app.decision.rating == 'positive'
                                            ? Colors.green
                                            : app.decision.rating == 'negative'
                                                ? Colors.red
                                                : Colors.grey,
                                      ),
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
