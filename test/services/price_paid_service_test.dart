import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/models/price_paid_model.dart';
import 'package:myapp/services/price_paid_service.dart';

import 'price_paid_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('PricePaidService', () {
    late MockClient client;
    late PricePaidService service;

    setUp(() {
      client = MockClient();
      service = PricePaidService(client: client);
    });

    test('returns a list of PricePaidModel if the http call completes successfully', () async {
      final response = {
        'result': {
          'items': [
            {
              'transactionId': 'A8C21B2_A8C21B_1001-01',
              'transactionDate': '2023-01-01T12:00:00',
              'pricePaid': 250000,
              'propertyAddress': {
                'paon': '123',
                'street': 'Main Street',
                'town': 'Anytown',
                'postcode': 'AT1 2BC',
                'county': 'AnyCounty'
              },
              'propertyType': 'S',
              'transactionCategory': 'STANDARD_PRICE_PAID_TRANSACTION'
            }
          ]
        }
      };

      final Map<String, String> queryParameters = {
        '_pageSize': '200',
        '_sort': '-transactionDate',
        'propertyAddress.postcode': 'AT1 2BC',
      };

      final uri = Uri.https(
        'landregistry.data.gov.uk',
        '/data/ppi/transaction-record.json',
        queryParameters,
      );

      when(client.get(
        uri,
        headers: {'Accept': 'application/json'},
      )).thenAnswer((_) async => http.Response(jsonEncode(response), 200));

      expect(await service.getPricePaidData('AT1 2BC'), isA<List<PricePaidModel>>());
    });

    test('throws an exception if the http call completes with an error', () {
       final Map<String, String> queryParameters = {
        '_pageSize': '200',
        '_sort': '-transactionDate',
        'propertyAddress.postcode': 'AT1 2BC',
      };

      final uri = Uri.https(
        'landregistry.data.gov.uk',
        '/data/ppi/transaction-record.json',
        queryParameters,
      );

      when(client.get(
        uri,
        headers: {'Accept': 'application/json'},
      )).thenAnswer((_) async => http.Response('Not Found', 404));

      expect(service.getPricePaidData('AT1 2BC'), throwsException);
    });
  });
}
