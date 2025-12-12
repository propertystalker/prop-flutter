import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PersonController with ChangeNotifier {
  String _fullName = 'Keith Lyons';
  String _email = 'emilySmith@belvoragency.com';
  String _mobile = '+44 7123 456 789';
  String _linkedin = 'Keith Lyons';
  XFile? _avatar;

  String get fullName => _fullName;
  String get email => _email;
  String get mobile => _mobile;
  String get linkedin => _linkedin;
  XFile? get avatar => _avatar;

  void setFullName(String name) {
    _fullName = name;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setMobile(String mobile) {
    _mobile = mobile;
    notifyListeners();
  }

  void setLinkedin(String linkedin) {
    _linkedin = linkedin;
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
