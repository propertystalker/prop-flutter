import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:myapp/models/property_floor_area.dart';
import 'package:myapp/services/api_service.dart';

class AddressFinderController with ChangeNotifier {
  PropertyFloorAreaResponse? _floorAreaResponse;
  PropertyFloorAreaResponse? get floorAreaResponse => _floorAreaResponse;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  final String _cachedPostcode = 'W149JH';
  final String _cachedJsonResponse = '''
  {
    "status": "success",
    "postcode": "W14 9JH",
    "postcode_type": "full",
    "known_floor_areas": [
      {
        "inspection_date": "2016-08-31",
        "address": "Third Floor Flat, 32 Charleville Road",
        "square_feet": 603,
        "habitable_rooms": 3
      },
      {
        "inspection_date": "2016-04-13",
        "address": "Flat B8, 32 Charleville Road",
        "square_feet": 258,
        "habitable_rooms": 1
      },
      {
        "inspection_date": "2016-03-22",
        "address": "First Floor Flat, 46 Charleville Road",
        "square_feet": 603,
        "habitable_rooms": 2
      },
      {
        "inspection_date": "2016-02-02",
        "address": "18b Charleville Road",
        "square_feet": 258,
        "habitable_rooms": 1
      },
      {
        "inspection_date": "2015-12-15",
        "address": "Flat 1, 48 Charleville Road",
        "square_feet": 215,
        "habitable_rooms": 1
      }
    ],
    "process_time": "0.03"
  }
  ''';

  Future<void> fetchFloorAreas(String apiKey, String postcode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final normalizedPostcode = postcode.replaceAll(' ', '').toUpperCase();
      if (normalizedPostcode == _cachedPostcode) {
        _floorAreaResponse = PropertyFloorAreaResponse.fromJson(
          json.decode(_cachedJsonResponse),
        );
      } else {
        _floorAreaResponse = await ApiService().getPropertyFloorAreas(
          apiKey: apiKey,
          postcode: postcode,
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
