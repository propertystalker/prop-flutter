
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/property.dart';

class ApiService {
  static const String _baseUrl = 'https://api.propertydata.co.uk';

  Future<List<Property>> getProperties({
    required String apiKey,
    required String postcode,
    required int bedrooms,
  }) async {
    final url = '$_baseUrl/prices?key=$apiKey&postcode=$postcode&bedrooms=$bedrooms';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        final List<dynamic> rawData = data['data']['raw_data'];
        return rawData
            .map((json) => Property.fromJson(json, postcode: postcode))
            .toList();
      } else {
        throw Exception('Failed to load properties: ${data['error']}');
      }
    } else {
      throw Exception('Failed to load properties');
    }
  }

  Future<int> getHistoricalValuation({
    required String apiKey,
    required String postcode,
    required int currentPrice,
    required int year,
    required String month,
  }) async {
    final url =
        '$_baseUrl/valuation-historical?key=$apiKey&postcode=$postcode&current_price=$currentPrice&historic_value_year=$year&historic_value_month=$month';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        return data['result']['historic_valuation'];
      } else {
        throw Exception(
            'Failed to load historical valuation: ${data['error']}');
      }
    } else {
      throw Exception('Failed to load historical valuation');
    }
  }
}
