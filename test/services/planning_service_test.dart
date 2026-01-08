import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/models/planning_application.dart';
import 'package:myapp/services/planning_service.dart';
import 'package:myapp/utils/constants.dart'; // Import constants to use the apiKey

import 'planning_service_test.mocks.dart';

// Generate a MockClient using the Mockito package.
@GenerateMocks([http.Client])
void main() {
  group('PlanningService', () {
    late MockClient mockClient;
    late PlanningService planningService;

    setUp(() {
      mockClient = MockClient();
      planningService = PlanningService(client: mockClient);
    });

    final String postcode = 'M1 1AA';
    final String baseUrl = 'https://api.propertydata.co.uk/planning-applications';

    // Construct the expected URI that the service should call.
    final expectedUri = Uri.parse('$baseUrl?key=$apiKey&postcode=$postcode&max_age=730');

    // 1. Test for a successful API response with a list of applications.
    test('getPlanningApplications returns a list of PlanningApplication on success', () async {
      // Mock the API response with a realistic URL.
      final successfulResponse = json.encode({
        'data': {
          'planning_applications': [
            {
              'url': 'https://pa.manchester.gov.uk/online-applications/applicationDetails.do?activeTab=summary&keyVal=138642',
              'address': '123 Test Street, Manchester',
              'proposal': 'Erection of a single storey rear extension.',
              'decision': {'text': 'Granted', 'rating': 'positive'},
              'dates': {'received_at': '2023-01-01', 'decided_at': '2023-02-01'},
            }
          ]
        }
      });

      // Configure the mock to return a successful response ONLY for the expected URI.
      when(mockClient.get(expectedUri))
          .thenAnswer((_) async => http.Response(successfulResponse, 200));

      // Call the method under test.
      final applications = await planningService.getPlanningApplications(postcode);

      // Verify the result.
      expect(applications, isA<List<PlanningApplication>>());
      expect(applications.length, 1);
      expect(applications.first.proposal, 'Erection of a single storey rear extension.');

      // Verify that the get method was called exactly once with the correct URL.
      verify(mockClient.get(expectedUri)).called(1);
    });

    // 2. Test for a successful response but with no applications found.
    test('getPlanningApplications returns an empty list when no applications are found', () async {
      final emptyResponse = json.encode({
        'data': {
          'planning_applications': []
        }
      });

      when(mockClient.get(expectedUri))
          .thenAnswer((_) async => http.Response(emptyResponse, 200));

      final applications = await planningService.getPlanningApplications(postcode);

      expect(applications, isA<List<PlanningApplication>>());
      expect(applications.isEmpty, isTrue);
      verify(mockClient.get(expectedUri)).called(1);
    });

    // 3. Test for a malformed but successful (200) response.
    test('getPlanningApplications returns an empty list on malformed success response', () async {
       final malformedResponse = json.encode({
        'data': {
          // Missing 'planning_applications' key
        }
      });

       when(mockClient.get(expectedUri))
          .thenAnswer((_) async => http.Response(malformedResponse, 200));

      final applications = await planningService.getPlanningApplications(postcode);

      expect(applications, isA<List<PlanningApplication>>());
      expect(applications.isEmpty, isTrue);
      verify(mockClient.get(expectedUri)).called(1);
    });

    // 4. Test for an API failure (e.g., server error).
    test('getPlanningApplications throws an exception on API failure', () async {
      // Configure the mock to return an error response.
      when(mockClient.get(expectedUri))
          .thenAnswer((_) async => http.Response('Internal Server Error', 500));

      // Verify that an exception is thrown.
      expect(planningService.getPlanningApplications(postcode), throwsException);
      verify(mockClient.get(expectedUri)).called(1);
    });
  });
}
