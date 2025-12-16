import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:myapp/models/price_paid_model.dart';
import 'package:myapp/services/price_paid_service.dart';

class PricePaidController with ChangeNotifier {
  final PricePaidService _pricePaidService = PricePaidService();

  List<PricePaidModel> _pricePaidData = [];
  List<PricePaidModel> get pricePaidData => _pricePaidData;

  List<PricePaidModel> _priceHistory = [];
  List<PricePaidModel> get priceHistory => _priceHistory;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get error => _errorMessage;

  Future<void> fetchPricePaidData(String postcode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pricePaidData = await _pricePaidService.getPricePaidData(postcode);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPricePaidHistoryForProperty(
      String postcode, String houseNumber) async {
    if (postcode.isEmpty) {
      _errorMessage = "Postcode cannot be empty.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _priceHistory = []; // Clear previous results
    notifyListeners();

    try {
      // 1. Fetch all transactions for the postcode.
      final allTransactions = await _pricePaidService.getPricePaidData(postcode);

      // 2. Filter the results in-memory by Primary Addressable Object Name (paon).
      if (houseNumber.isNotEmpty) {
        _priceHistory = allTransactions
            .where((item) =>
                item.paon?.toUpperCase().trim() == houseNumber.toUpperCase().trim())
            .toList();
      } else {
        // If no house number is given, we return the whole list for the postcode.
        _priceHistory = allTransactions;
      }
      
      // Corrected the logging statement here
      developer.log('Found ${_priceHistory.length} transactions for house $houseNumber at postcode $postcode.');

      if (_priceHistory.isEmpty && houseNumber.isNotEmpty) {
        _errorMessage = 'No sales history found for house number "$houseNumber" at this postcode. It may have a different official name (e.g., "The Barn") or no recent sales.';
      }

    } catch (e) {
      developer.log('Error in PricePaidController: $e');
      _errorMessage = e.toString();
      _priceHistory = []; // Ensure list is empty on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
