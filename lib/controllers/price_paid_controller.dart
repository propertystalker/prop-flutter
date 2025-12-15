import 'package:flutter/material.dart';
import 'package:myapp/models/price_paid_model.dart';
import 'package:myapp/services/price_paid_service.dart';

class PricePaidController with ChangeNotifier {
  final PricePaidService _pricePaidService = PricePaidService();
  List<PricePaidModel> _pricePaidData = [];
  bool _isLoading = false;
  String? _error;

  List<PricePaidModel> get pricePaidData => _pricePaidData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPricePaidData(String postcode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pricePaidData = await _pricePaidService.getPricePaidData(postcode);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}