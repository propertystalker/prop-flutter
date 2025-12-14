import 'package:flutter/foundation.dart';
import 'package:myapp/models/person.dart';

class UserController with ChangeNotifier {
  final List<Person> _users = [];

  List<Person> get users => _users;

  void addUser(Person user) {
    _users.add(user);
    notifyListeners();
  }

  void removeUser(Person user) {
    _users.remove(user);
    notifyListeners();
  }

  void updateUser(Person oldUser, Person newUser) {
    final index = _users.indexOf(oldUser);
    if (index != -1) {
      _users[index] = newUser;
      notifyListeners();
    }
  }

  Person? getUserByEmail(String email) {
    try {
      return _users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }
}
