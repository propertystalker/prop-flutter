import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/models/company.dart';
import 'package:myapp/models/person.dart';

class PersonController with ChangeNotifier {
  final Person _person = Person(
    id: '',
    fullName: '',
    email: '',
    mobile: '',
    linkedin: '',
    company: Company(id: '', name: '', email: ''),
  );
  XFile? _avatar;
  String? _avatarUrl;

  Person get person => _person;
  XFile? get avatar => _avatar;
  String? get avatarUrl => _avatarUrl;

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

  void setCompany(Company company) {
    _person.company = company;
    notifyListeners();
  }

  void setAvatar(XFile? avatar) {
    _avatar = avatar;
    notifyListeners();
  }

  void setAvatarUrl(String? url) {
    _avatarUrl = url;
    notifyListeners();
  }

  void deleteAvatar() {
    _avatar = null;
    _avatarUrl = null;
    notifyListeners();
  }
}
