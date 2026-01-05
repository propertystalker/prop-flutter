import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/services/mapbox_service.dart';
import 'mapbox_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('MapboxService', () {
    const apiKey = 'test_api_key';
    final client = MockClient();
    final mapboxService = MapboxService(apiKey, client: client);

    test('returns suggestions when the call is successful', () async {
      const query = 'london';
      final response = {
        'features': [
          {
            'place_name': 'London, UK',
            'address': 'London',
            'context': [
              {'id': 'postcode.123', 'text': 'SW1A 0AA'}
            ]
          }
        ]
      };

      when(client.get(any)).thenAnswer((_) async =>
          http.Response(jsonEncode(response), 200));

      final suggestions = await mapboxService.getAutocompleteSuggestions(query);

      expect(suggestions, isA<List<Map<String, dynamic>>>());
      expect(suggestions.first['place_name'], 'London, UK');
    });

    test('returns an empty list when the call fails', () async {
      const query = 'london';

      when(client.get(any))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      final suggestions = await mapboxService.getAutocompleteSuggestions(query);

      expect(suggestions, isA<List<Map<String, dynamic>>>());
      expect(suggestions, isEmpty);
    });
  });
}
