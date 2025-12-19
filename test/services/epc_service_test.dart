import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/models/epc_model.dart';
import 'package:myapp/services/epc_service.dart';
import 'package:myapp/utils/constants.dart';

import 'epc_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('EpcService', () {
    late MockClient client;
    late EpcService service;

    setUp(() {
      client = MockClient();
      service = EpcService(client: client);
    });

    test('returns a list of EpcModel if the http call completes successfully', () async {
      final response = {
        'rows': [
          {
            'address': '123 Main St, Anytown, AT1 2BC',
            'uprn': '1234567890',
            'current-energy-rating': 'B',
            'lodgement-date': '2023-01-01',
            'postcode': 'AT1 2BC',
            'county': 'Anytown',
            'country': 'UK',
            'house_number': '123',
          }
        ]
      };

       final url = '$epcBaseUrl/search?postcode=AT1+2BC&size=100';
    
      final credentials = base64Encode(utf8.encode('$epcEmail:$epcApiKey'));

      when(client.get(Uri.parse(url), headers: {
        'Accept': 'application/json',
        'Authorization': 'Basic $credentials',
      })).thenAnswer((_) async => http.Response(jsonEncode(response), 200));

      expect(await service.getEpcData('AT1 2BC'), isA<List<EpcModel>>());
    });

    test('throws an exception if the http call completes with an error', () {
      final url = '$epcBaseUrl/search?postcode=AT1+2BC&size=100';
    
      final credentials = base64Encode(utf8.encode('$epcEmail:$epcApiKey'));
      
      when(client.get(Uri.parse(url), headers: {
        'Accept': 'application/json',
        'Authorization': 'Basic $credentials',
      })).thenAnswer((_) async => http.Response('Not Found', 404));

      expect(service.getEpcData('AT1 2BC'), throwsException);
    });
  });
}
