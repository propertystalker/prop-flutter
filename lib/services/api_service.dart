
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/property.dart';

class ApiService {
  static const String _baseUrl = 'https://api.propertydata.co.uk/prices';

  Future<List<Property>> getProperties({
    required String apiKey,
    required String postcode,
    required int bedrooms,
  }) async {
    final url =
        '$_baseUrl?key=$apiKey&postcode=$postcode&bedrooms=$bedrooms';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        final List<dynamic> rawData = data['data']['raw_data'];
        return rawData.map((json) => Property.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load properties: ${data['error']}');
      }
    } else {
      throw Exception('Failed to load properties');
    }
  }
}
