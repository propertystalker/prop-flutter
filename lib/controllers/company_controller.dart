import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CompanyController with ChangeNotifier {
  String _companyName = 'Urban Splash';
  XFile? _companyLogo;

  String get companyName => _companyName;
  XFile? get companyLogo => _companyLogo;

  void setCompanyName(String name) {
    _companyName = name;
    notifyListeners();
  }

  void setCompanyLogo(XFile? logo) {
    _companyLogo = logo;
    notifyListeners();
  }

  void deleteCompanyLogo() {
    _companyLogo = null;
    notifyListeners();
  }
}
