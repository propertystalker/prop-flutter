class Company {
  final String id; // This now represents the user_id
  final String name;
  final String email;

  Company({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id: map['user_id'] as String, // Maps from the 'user_id' column in the database
      name: map['name'] as String,
      email: map['email'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': id, // Maps to the 'user_id' column in the database
      'name': name,
      'email': email,
    };
  }

  // Helper method to create an empty company for new users
  factory Company.empty() {
    return Company(id: '', name: '', email: '');
  }
}
