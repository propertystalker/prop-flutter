
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/models/planning_application.dart';
import 'package:myapp/services/planning_service.dart';

import 'planning_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('PlanningService', () {
    late PlanningService planningService;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      planningService = PlanningService(client: mockClient);
    });

    final String postcode = 'M1 1AA';
    final String planitBaseUrl = 'https://www.planit.org.uk/api';
    final String postcodesBaseUrl = 'https://api.postcodes.io/postcodes';

    final postcodeResponse = {
      'status': 200,
      'result': {
        'postcode': 'M1 1AA',
        'quality': 1,
        'eastings': 384433,
        'northings': 398246,
        'country': 'England',
        'nhs_ha': 'North West',
        'longitude': -2.235659,
        'latitude': 53.48095,
        'european_electoral_region': 'North West',
        'primary_care_trust': 'Manchester',
        'region': 'North West',
        'lsoa': 'Manchester 046E',
        'msoa': 'Manchester 046',
        'incode': '1AA',
        'outcode': 'M1',
        'parliamentary_constituency': 'Manchester Central',
        'admin_district': 'Manchester',
        'parish': 'Manchester, unparished area',
        'admin_county': null,
        'admin_ward': 'Piccadilly',
        'ced': null,
        'ccg': 'NHS Manchester CCG',
        'nuts': 'Manchester',
        'codes': {
          'admin_district': 'E08000003',
          'admin_county': 'E99999999',
          'admin_ward': 'E05000720',
          'parish': 'E43000163',
          'parliamentary_constituency': 'E14000800',
          'ccg': 'E38000102',
          'ced': 'E99999999',
          'nuts': 'UKD3'
        }
      }
    };

    final planningApplicationsResponse = {
      'records': [
        {
          'uid': '12345',
          'url': 'http://example.com/12345',
          'reference': 'APP/2023/12345',
          'address': '123 Fake Street, Manchester',
          'postcode': 'M1 1AA',
          'description': 'Test application',
          'received_date': '2023-01-15',
          'validated_date': '2023-01-20',
          'location': {'lat': 53.48095, 'lng': -2.235659},
          'appeal_result': null,
          'decision': 'GRANTED',
          'status': 'DECIDED',
          'comment_url': 'http://example.com/comment/12345',
          'start_date': '2023-01-15',
        }
      ]
    };

    test('getPlanningApplications returns a list of applications on success', () async {
      when(mockClient.get(Uri.parse('$postcodesBaseUrl/M11AA'))).thenAnswer(
        (_) async => http.Response(json.encode(postcodeResponse), 200),
      );

      when(mockClient.get(any)).thenAnswer((invocation) async {
        if (invocation.positionalArguments[0].toString().contains(planitBaseUrl)) {
          return http.Response(json.encode(planningApplicationsResponse), 200);
        }
        return http.Response(json.encode(postcodeResponse), 200);
      });

      final applications = await planningService.getPlanningApplications(postcode);

      expect(applications, isA<List<PlanningApplication>>());
      expect(applications.length, 1);
      expect(applications.first.uid, '12345');
    });

    test('getPlanningApplications throws an exception if postcode lookup fails', () async {
      when(mockClient.get(Uri.parse('$postcodesBaseUrl/M11AA'))).thenAnswer(
        (_) async => http.Response('Not Found', 404),
      );

      expect(planningService.getPlanningApplications(postcode), throwsException);
    });

    test('getPlanningApplications returns an empty list if no authorities are found', () async {
      final noAuthoritiesResponse = {
        'status': 200,
        'result': {
          'postcode': 'M1 1AA',
          'admin_district': null,
          'latitude': 53.48095,
          'longitude': -2.235659,
          'result': []
        }
      };

      when(mockClient.get(Uri.parse('$postcodesBaseUrl/M11AA'))).thenAnswer(
        (_) async => http.Response(json.encode(noAuthoritiesResponse), 200),
      );

      final applications = await planningService.getPlanningApplications(postcode);

      expect(applications, isA<List<PlanningApplication>>());
      expect(applications.isEmpty, isTrue);
    });

    test('getPlanningApplications returns an empty list if planning API fails', () async {
      when(mockClient.get(Uri.parse('$postcodesBaseUrl/M11AA'))).thenAnswer(
        (_) async => http.Response(json.encode(postcodeResponse), 200),
      );

      when(mockClient.get(any)).thenAnswer((invocation) async {
        if (invocation.positionalArguments[0].toString().contains(planitBaseUrl)) {
          return http.Response('Internal Server Error', 500);
        }
        return http.Response(json.encode(postcodeResponse), 200);
      });

      final applications = await planningService.getPlanningApplications(postcode);

      expect(applications, isA<List<PlanningApplication>>());
      expect(applications.isEmpty, isTrue);
    });
  });
}
