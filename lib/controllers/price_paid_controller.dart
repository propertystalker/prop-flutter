import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:myapp/models/price_paid_model.dart';
import 'package:myapp/models/property.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/services/price_paid_service.dart';
import 'package:myapp/utils/constants.dart';

class PricePaidController with ChangeNotifier {
  final PricePaidService _pricePaidService = PricePaidService();
  final ApiService _apiService = ApiService();

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

      // 2. Filter for the specific property.
      if (houseNumber.isNotEmpty) {
        final searchNumber = houseNumber.toUpperCase().trim();
        _priceHistory = allTransactions.where((item) {
          final paon = item.paon?.toUpperCase().trim() ?? '';
          return paon == searchNumber;
        }).toList();
      } else {
        _priceHistory = allTransactions;
      }
      
      // 3. If no sales history is found, fall back to the estimation API.
      if (_priceHistory.isEmpty && houseNumber.isNotEmpty) {
        try {
          // TODO: The bedroom count is hardcoded. This should be dynamic.
          final List<Property> propertyData = await _apiService.getProperties(postcode: postcode, apiKey: apiKey, bedrooms: 3);

          if (propertyData.isNotEmpty) {
            // The PropertyData API doesn't return house numbers, so we take the first result.
            final property = propertyData.first;
            
            _priceHistory = [
              PricePaidModel(
                transactionId: 'estimated_price',
                amount: property.price,
                transactionDate: DateTime.now(),
                propertyType: property.type,
                fullAddress: postcode, // Best guess
                paon: houseNumber,      // Use the number we searched for
              )
            ];
          }
        } catch (e) {
          developer.log('Failed to fetch from PropertyData API: $e');
        }
      }

      if (_priceHistory.isEmpty && houseNumber.isNotEmpty) {
        _errorMessage = 'No sales history or price estimate found for house number "$houseNumber" at this postcode.';
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
