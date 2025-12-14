import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/models/person.dart';

class PersonController with ChangeNotifier {
  final Person _person = Person(
    fullName: 'Keith Lyons',
    email: 'emilySmith@belvoragency.com',
    mobile: '+44 7123 456 789',
    linkedin: 'Keith Lyons',
  );
  XFile? _avatar;

  Person get person => _person;
  XFile? get avatar => _avatar;

  void setFullName(String name) {
    _person.fullName = name;
    notifyListeners();
  }

  void setEmail(String email) {
    _person.email = email;
    notifyListeners();
  }

  void setMobile(String mobile) {
    _person.mobile = mobile;
    notifyListeners();
  }

  void setLinkedin(String linkedin) {
    _person.linkedin = linkedin;
    notifyListeners();
  }

  void setCompany(String company) {
    _person.company = company;
    notifyListeners();
  }

  void setAvatar(XFile? avatar) {
    _avatar = avatar;
    notifyListeners();
  }

  void deleteAvatar() {
    _avatar = null;
    notifyListeners();
  }
}
