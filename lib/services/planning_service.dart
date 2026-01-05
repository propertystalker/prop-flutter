
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/planning_application.dart';

class PlanningService {
  final http.Client _client;
  final String _planitBaseUrl = 'https://www.planit.org.uk/api';
  final String _postcodesBaseUrl = 'https://api.postcodes.io/postcodes';

  PlanningService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<PlanningApplication>> getPlanningApplications(String postcode) async {
    final Set<String> uniqueApplicationUIDs = <String>{};
    final List<PlanningApplication> allApplications = [];

    try {
      final postcodeData = await _getPostcodeData(postcode);
      final authorities = postcodeData['authorities'] as List<String>;
      final location = postcodeData['location'] as Map<String, double>;

      if (authorities.isEmpty) {
        developer.log('No authorities found for postcode: $postcode', name: 'PlanningService');
        return [];
      }

      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      final String endDate = formatter.format(DateTime.now());
      final String startDate = formatter.format(DateTime.now().subtract(const Duration(days: 365 * 15))); // 15 years back

      for (final authority in authorities) {
        final authorityName = Uri.encodeComponent(authority);
        final url = Uri.parse(
            '$_planitBaseUrl/applics/json?auth=$authorityName&start_date=$startDate&end_date=$endDate&point=${location['lat']},${location['lng']}&dist=2.0&pg_sz=100');

        developer.log('Fetching applications for authority: $authorityName', name: 'PlanningService');
        developer.log('Request URL: $url', name: 'PlanningService');

        final response = await _client.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['records'] != null) {
            final records = data['records'] as List;
            developer.log('Found ${records.length} applications for $authorityName', name: 'PlanningService');

            for (var record in records) {
              try {
                final app = PlanningApplication.fromJson(record);
                if (uniqueApplicationUIDs.add(app.uid)) {
                  allApplications.add(app);
                }
              } catch (e) {
                developer.log('Error parsing application record: $record', error: e, name: 'PlanningService');
              }
            }
          } else {
            developer.log('No "records" key in response for $authorityName', name: 'PlanningService');
          }
        } else {
          developer.log(
              'Failed to load planning applications for $authorityName. Status: ${response.statusCode}, Body: ${response.body}',
              name: 'PlanningService', level: 900);
        }
      }

      allApplications.sort((a, b) => b.receivedDate.compareTo(a.receivedDate));
      developer.log('Total unique applications found: ${allApplications.length}', name: 'PlanningService');
      return allApplications;

    } catch (e, s) {
      developer.log('Error fetching planning applications for $postcode', error: e, stackTrace: s, name: 'PlanningService', level: 1000);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _getPostcodeData(String postcode) async {
    final formattedPostcode = postcode.replaceAll(' ', '').toUpperCase();
    final url = Uri.parse('$_postcodesBaseUrl/$formattedPostcode');
    developer.log('Fetching postcode data from: $url', name: 'PlanningService');

    final response = await _client.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 200 && data['result'] != null) {
        final result = data['result'];

        final location = {
          'lat': result['latitude'] as double,
          'lng': result['longitude'] as double,
        };

        final primaryAuthority = result['admin_district'] as String?;
        final Set<String> authorities = {};

        if (primaryAuthority != null) {
          authorities.add(primaryAuthority);

          // HACK: For postcodes in Manchester/Trafford border area, check both authorities.
          if (primaryAuthority == 'Manchester' || primaryAuthority == 'Trafford') {
            authorities.add('Manchester');
            authorities.add('Trafford');
          }
        }

        developer.log('Found location: $location', name: 'PlanningService');
        developer.log('Found authorities: $authorities', name: 'PlanningService');

        return {
          'location': location,
          'authorities': authorities.toList(),
        };
      } else {
        throw Exception('Invalid response from postcodes.io: ${data['error']}');
      }
    } else {
      throw Exception('Failed to get data for postcode. Status: ${response.statusCode}');
    }
  }
}
