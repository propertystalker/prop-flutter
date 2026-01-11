
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/property.dart';
import '../models/price_per_square_foot.dart';
import '../models/growth_per_square_foot.dart';

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

  Future<PricePerSquareFoot> getPricePerSquareFoot({
    required String apiKey,
    required String postcode,
  }) async {
    final url = '$_baseUrl/prices-per-sqf?key=$apiKey&postcode=$postcode';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        return PricePerSquareFoot.fromJson(data['data']);
      } else {
        throw Exception(
            'Failed to load price per square foot data: ${data['error']}');
      }
    } else {
      throw Exception('Failed to load price per square foot data');
    }
  }

  Future<List<GrowthPerSquareFootData>> getGrowthPerSquareFoot({
    required String apiKey,
    required String postcode,
  }) async {
    final url = '$_baseUrl/growth-psf?key=$apiKey&postcode=$postcode';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        final List<dynamic> rawData = data['data'];
        return rawData
            .map((json) => GrowthPerSquareFootData.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Failed to load growth per square foot data: ${data['error']}');
      }
    } else {
      throw Exception('Failed to load growth per square foot data');
    }
  }
}
