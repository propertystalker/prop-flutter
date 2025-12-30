import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class PostcodeService {
  final String _baseUrl = 'https://api.postcodes.io/postcodes';

  Future<List<String>> getAutocompleteSuggestions(String postcode) async {
    if (postcode.isEmpty) {
      return [];
    }

    final url = Uri.parse('$_baseUrl/$postcode/autocomplete');
    // developer.log('Postcodes.io Request URL: $url', name: 'myapp.postcode');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // developer.log('Postcodes.io Response: ${response.body}', name: 'myapp.postcode');
        if (data['status'] == 200 && data['result'] != null) {
          final List<dynamic> results = data['result'];
          return results.cast<String>().toList();
        }
      } else {
        developer.log('Postcodes.io Error: Status Code ${response.statusCode}, Body: ${response.body}', name: 'myapp.postcode', level: 1000);
      }
      return [];
    } catch (e, s) {
      developer.log('Error fetching postcode autocomplete', name: 'myapp.postcode', error: e, stackTrace: s, level: 1000);
      return [];
    }
  }

  Future<List<String>?> getPostcodeFromCoordinates(
      double latitude, double longitude) async {
    final url = Uri.parse('$_baseUrl?lon=$longitude&lat=$latitude');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 200 &&
            data['result'] != null &&
            data['result'].isNotEmpty) {
          final List<dynamic> results = data['result'];
          return results.map((item) => item['postcode'] as String).toList();
        }
      }
      return null;
    } catch (e, s) {
      developer.log('Error fetching postcode from coordinates', name: 'myapp.postcode', error: e, stackTrace: s, level: 1000);
      return null;
    }
  }
}
