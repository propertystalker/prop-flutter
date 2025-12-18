import 'package:myapp/models/company.dart';

class Person {
  String id;
  String fullName;
  String email;
  String? mobile;
  String? linkedin;
  String? password;
  Company company;
  String? avatarUrl;

  Person({
    required this.id,
    this.fullName = '',
    this.email = '',
    this.mobile,
    this.linkedin,
    this.password,
    required this.company,
    this.avatarUrl,
  });

  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      id: map['id'] as String,
      fullName: map['full_name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      mobile: map['mobile'] as String?,
      linkedin: map['linkedin'] as String?,
      // The company object is populated by the relation in the select query
      company: map['companies'] != null
          ? Company.fromMap(map['companies'] as Map<String, dynamic>)
          : Company.empty(), // Return an empty company if null
      avatarUrl: map['avatar_url'] as String?,
    );
  }

  // This map is used for updating the 'profiles' table.
  // It should only contain columns that exist in the 'profiles' table.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'mobile': mobile,
      'linkedin': linkedin,
      'avatar_url': avatarUrl,
      // We don't include the 'company' object here because the relationship
      // is handled by the user_id. The 'profiles.company' text field might be legacy.
    };
  }
}
