import 'package:flutter/foundation.dart';
import 'package:myapp/models/person.dart';

class UserController with ChangeNotifier {
  final List<Person> _users = [];

  List<Person> get users => _users;

  void addUser(Person user) {
    _users.add(user);
    notifyListeners();
  }

  Person? getUserByEmail(String email) {
    try {
      return _users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }
}
