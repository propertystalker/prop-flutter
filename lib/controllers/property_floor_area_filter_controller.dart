import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:myapp/controllers/financial_controller.dart';
import 'package:myapp/controllers/gdv_controller.dart';
import 'package:myapp/utils/constants.dart';

class PropertyFloorAreaFilterController with ChangeNotifier {
  final String postcode;
  final int habitableRooms;
  final FinancialController financialController;
  final GdvController gdvController;

  PropertyFloorAreaFilterController({
    required this.postcode,
    required this.habitableRooms,
    required this.financialController,
    required this.gdvController,
  });

  final PageController _pageController = PageController();
  PageController get pageController => _pageController;

  final List<XFile> _images = [];
  List<XFile> get images => _images;

  int _currentImageIndex = 0;
  int get currentImageIndex => _currentImageIndex;

  bool _isEditingPrice = false;
  bool get isEditingPrice => _isEditingPrice;

  final FocusNode _priceFocusNode = FocusNode();
  FocusNode get priceFocusNode => _priceFocusNode;

  bool _isFinancePanelVisible = false;
  bool get isFinancePanelVisible => _isFinancePanelVisible;

  bool _sendReportToLender = false;
  bool get sendReportToLender => _sendReportToLender;

  bool _isReportPanelVisible = false;
  bool get isReportPanelVisible => _isReportPanelVisible;

  bool _inviteToSetupAccount = false;
  bool get inviteToSetupAccount => _inviteToSetupAccount;

  bool _isCompanyAccountVisible = false;
  bool get isCompanyAccountVisible => _isCompanyAccountVisible;

  bool _isPersonAccountVisible = false;
  bool get isPersonAccountVisible => _isPersonAccountVisible;

  Future<void> fetchEstimatedPrice() async {
    final url = Uri.parse(
        'https://api.propertydata.co.uk/prices?key=$apiKey&postcode=$postcode&bedrooms=$habitableRooms');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data']['average'] != null) {
          final estimatedPrice = (data['data']['average'] as int).toDouble();
          financialController.setCurrentPrice(estimatedPrice, gdvController.finalGdv);
        } else {
          financialController.setCurrentPrice(0.0, gdvController.finalGdv);
        }
      } else {
        financialController.setCurrentPrice(0.0, gdvController.finalGdv);
      }
    } catch (e) {
      financialController.setCurrentPrice(0.0, gdvController.finalGdv);
    } finally {
      notifyListeners();
    }
  }

  void updatePrice(String value) {
    final newPrice = double.tryParse(value);
    if (newPrice != null) {
      financialController.setCurrentPrice(newPrice, gdvController.finalGdv);
    }
    _isEditingPrice = false;
    notifyListeners();
  }

  void editPrice() {
    _isEditingPrice = true;
    notifyListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _priceFocusNode.requestFocus();
    });
  }

  Future<void> pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      _images.addAll(pickedFiles);
      notifyListeners();
    }
  }

  void removeImage(int index) {
    _images.removeAt(index);
    if (_currentImageIndex >= _images.length && _images.isNotEmpty) {
      _currentImageIndex = _images.length - 1;
    }
    notifyListeners();
  }

  void onPageChanged(int index) {
    _currentImageIndex = index;
    notifyListeners();
  }

  void toggleCompanyAccountVisibility() {
    _isCompanyAccountVisible = !_isCompanyAccountVisible;
    notifyListeners();
  }

  void togglePersonAccountVisibility() {
    _isPersonAccountVisible = !_isPersonAccountVisible;
    notifyListeners();
  }

  void toggleFinancePanelVisibility() {
    _isFinancePanelVisible = !_isFinancePanelVisible;
    _isReportPanelVisible = false;
    notifyListeners();
  }

  void toggleReportPanelVisibility() {
    _isReportPanelVisible = !_isReportPanelVisible;
    _isFinancePanelVisible = false;
    notifyListeners();
  }

  void setSendReportToLender(bool? value) {
    _sendReportToLender = value ?? false;
    notifyListeners();
  }

  void setInviteToSetupAccount(bool? value) {
    _inviteToSetupAccount = value ?? false;
    notifyListeners();
  }

  void hideCompanyAccount() {
    _isCompanyAccountVisible = false;
    notifyListeners();
  }

  void hidePersonAccount() {
    _isPersonAccountVisible = false;
    notifyListeners();
  }

    void hideFinancePanel() {
    _isFinancePanelVisible = false;
    notifyListeners();
  }

  void hideReportPanel() {
    _isReportPanelVisible = false;
    notifyListeners();
  }


  @override
  void dispose() {
    _pageController.dispose();
    _priceFocusNode.dispose();
    super.dispose();
  }
}
