import 'dart:convert';
import 'package:http/http.dart' as http;

class PostcodeService {
  final String _baseUrl = 'https://api.postcodes.io/postcodes';

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
    } catch (e) {
      // Handle exceptions like network errors
      print('Error fetching postcode: $e');
      return null;
    }
  }
}
