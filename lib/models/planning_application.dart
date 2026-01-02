class PlanningApplication {
  final String uid;
  final String url;
  final String address;
  final String postcode;
  final String description;
  final String status;
  final String receivedDate;

  PlanningApplication({
    required this.uid,
    required this.url,
    required this.address,
    required this.postcode,
    required this.description,
    required this.status,
    required this.receivedDate,
  });

  factory PlanningApplication.fromJson(Map<String, dynamic> json) {
    return PlanningApplication(
      uid: json['uid'] ?? '',
      url: json['url'] ?? '',
      address: json['address'] ?? '',
      postcode: json['postcode'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      receivedDate: json['received_date'] ?? '',
    );
  }
}
