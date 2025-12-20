import 'package:flutter/material.dart';

class PropertyHeaderController with ChangeNotifier {
  bool _isEditingPrice = false;
  final FocusNode priceFocusNode = FocusNode();

  bool get isEditingPrice => _isEditingPrice;

  void editPrice() {
    _isEditingPrice = true;
    notifyListeners();
    // Request focus after the widget rebuilds to show the text field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      priceFocusNode.requestFocus();
    });
  }

  void finishEditing() {
    _isEditingPrice = false;
    notifyListeners();
  }
}
