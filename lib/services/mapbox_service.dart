import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class MapboxService {
  final String _apiKey;
  final String _baseUrl = 'https://api.mapbox.com/geocoding/v5/mapbox.places';

  MapboxService(this._apiKey);

  Future<List<String>> getAutocompleteSuggestions(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final url = Uri.parse('$_baseUrl/$query.json?access_token=$_apiKey');
    developer.log('Mapbox Request URL: $url', name: 'myapp.mapbox');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        developer.log('Mapbox Response: ${response.body}', name: 'myapp.mapbox');
        if (data['features'] != null) {
          final List<dynamic> features = data['features'];
          final suggestions = features.map((feature) => feature['place_name'] as String).toList();
          developer.log('Parsed Suggestions: $suggestions', name: 'myapp.mapbox');
          return suggestions;
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
}
