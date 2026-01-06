import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class MapboxService {
  final String _apiKey;
  final String _baseUrl = 'https://api.mapbox.com/geocoding/v5/mapbox.places';
  final http.Client _client;

  MapboxService(this._apiKey, {http.Client? client}) : _client = client ?? http.Client();

  Future<List<Map<String, dynamic>>> getAutocompleteSuggestions(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final url = Uri.parse('$_baseUrl/$query.json?access_token=$_apiKey');
    developer.log('Mapbox Request URL: $url', name: 'myapp.mapbox');

    try {
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        developer.log('Mapbox Response: ${response.body}', name: 'myapp.mapbox');
        if (data['features'] != null) {
          final List<dynamic> features = data['features'];
          return features.cast<Map<String, dynamic>>().toList();
        }
      } else {
        developer.log('Mapbox Error: Status Code ${response.statusCode}, Body: ${response.body}', name: 'myapp.mapbox', level: 1000);
      }
      return [];
    } catch (e, s) {
      developer.log('Error fetching autocomplete suggestions', name: 'myapp.mapbox', error: e, stackTrace: s, level: 1000);
      return [];
    }
  }

  Future<Map<String, dynamic>?> reverseGeocode(double latitude, double longitude) async {
    final url = Uri.parse('$_baseUrl/$longitude,$latitude.json?access_token=$_apiKey');
    developer.log('Mapbox Reverse Geocode URL: $url', name: 'myapp.mapbox');

    try {
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        developer.log('Mapbox Reverse Geocode Response: ${response.body}', name: 'myapp.mapbox');
        if (data['features'] != null && data['features'].isNotEmpty) {
          return data['features'][0];
        }
      } else {
        developer.log('Mapbox Reverse Geocode Error: Status Code ${response.statusCode}, Body: ${response.body}', name: 'myapp.mapbox', level: 1000);
      }
      return null;
    } catch (e, s) {
      developer.log('Error with reverse geocoding', name: 'myapp.mapbox', error: e, stackTrace: s, level: 1000);
      return null;
    }
  }
}
