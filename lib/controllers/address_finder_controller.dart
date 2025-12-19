import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/models/property_floor_area.dart';

class AddressFinderController with ChangeNotifier {
  PropertyFloorAreaResponse? _floorAreaResponse;
  PropertyFloorAreaResponse? get floorAreaResponse => _floorAreaResponse;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchFloorAreas(String apiKey, String postcode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final url = Uri.parse(
        'https://api.propertydata.co.uk/floor-areas?key=$apiKey&postcode=$postcode');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        _floorAreaResponse = PropertyFloorAreaResponse.fromJson(jsonDecode(response.body));
      } else {
        _error = 'Failed to load floor areas: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Failed to load floor areas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
