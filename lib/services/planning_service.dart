import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/models/planning_application.dart';
import 'package:myapp/utils/constants.dart';

class PlanningService {
  final String _baseUrl = 'https://api.propertydata.co.uk/planning-applications';

  Future<List<PlanningApplication>> getPlanningApplications(String postcode) async {
    // Correctly use the 'apiKey' from the constants file.
    final Uri uri = Uri.parse('$_baseUrl?key=$apiKey&postcode=$postcode&max_age=730');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.containsKey('data') &&
          data['data'] is Map &&
          data['data'].containsKey('planning_applications') &&
          data['data']['planning_applications'] is List) {
        final List<dynamic> applicationsJson =
            data['data']['planning_applications'];
        return applicationsJson
            .map((json) => PlanningApplication.fromJson(json))
            .toList();
      } else {
        return []; // Return empty list if the structure is not as expected.
      }
    } else {
      throw Exception('Failed to load planning applications: ${response.body}');
    }
  }
}
