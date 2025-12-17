class User {
  final String id;
  String email;
  String company;

  User({required this.id, required this.email, required this.company});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'company': company,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      company: map['company'] ?? '',
    );
  }
}
