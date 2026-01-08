
class PlanningApplication {
  final String url;
  final String address;
  final String proposal;
  final Decision decision;
  final Dates dates;

  PlanningApplication({
    required this.url,
    required this.address,
    required this.proposal,
    required this.decision,
    required this.dates,
  });

  factory PlanningApplication.fromJson(Map<String, dynamic> json) {
    return PlanningApplication(
      url: json['url'] ?? '',
      address: json['address'] ?? '',
      proposal: json['proposal'] ?? '',
      decision: Decision.fromJson(json['decision'] ?? {}),
      dates: Dates.fromJson(json['dates'] ?? {}),
    );
  }
}

class Decision {
  final String text;
  final String rating;

  Decision({required this.text, required this.rating});

  factory Decision.fromJson(Map<String, dynamic> json) {
    return Decision(
      text: json['text'] ?? 'Unknown',
      rating: json['rating'] ?? 'neutral',
    );
  }
}

class Dates {
  final DateTime? receivedAt;
  final DateTime? decidedAt;

  Dates({required this.receivedAt, required this.decidedAt});

  factory Dates.fromJson(Map<String, dynamic> json) {
    return Dates(
      receivedAt: json['received_at'] != null ? DateTime.parse(json['received_at']) : null,
      decidedAt: json['decided_at'] != null ? DateTime.parse(json['decided_at']) : null,
    );
  }
}
