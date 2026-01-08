import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/models/planning_application.dart';
import 'package:myapp/services/planning_service.dart';
import 'package:myapp/utils/constants.dart';

import 'planning_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('PlanningService', () {
    late PlanningService planningService;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      planningService = PlanningService(); // No client needed in constructor anymore
    });

    final String postcode = 'M1 1AA';

    final successfulResponse = {
      'data': {
        'planning_applications': [
          {
            'url': 'http://example.com/123',
            'address': '123 Test Street, Testville',
            'proposal': 'Build a thing',
            'decision': {'text': 'Approved', 'rating': 'positive'},
            'dates': {'received_at': '2023-01-01', 'decided_at': '2023-02-01'},
          }
        ]
      }
    };

    final emptyResponse = {
      'data': {
        'planning_applications': []
      }
    };

    test('getPlanningApplications returns a list of applications on success', () async {
      when(mockClient.get(any)).thenAnswer((_) async =>
          http.Response(json.encode(successfulResponse), 200));

      final applications = await planningService.getPlanningApplications(postcode);

      expect(applications, isA<List<PlanningApplication>>());
      expect(applications.length, 1);
      expect(applications.first.proposal, 'Build a thing');
    });

    test('getPlanningApplications returns an empty list if no applications are found', () async {
      when(mockClient.get(any)).thenAnswer((_) async =>
          http.Response(json.encode(emptyResponse), 200));

      final applications = await planningService.getPlanningApplications(postcode);

      expect(applications, isA<List<PlanningApplication>>());
      expect(applications.isEmpty, isTrue);
    });

    test('getPlanningApplications throws an exception on API failure', () async {
       when(mockClient.get(any)).thenAnswer((_) async =>
          http.Response('Server Error', 500));

      expect(planningService.getPlanningApplications(postcode), throwsException);
    });


  });
}
