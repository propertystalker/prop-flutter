import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:myapp/models/price_paid_model.dart';

class PricePaidService {
  final http.Client client;

  PricePaidService({http.Client? client}) : client = client ?? http.Client();

  Future<List<PricePaidModel>> getPricePaidData(String postcode) async {
    final Map<String, String> queryParameters = {
      '_pageSize': '200',
      '_sort': '-transactionDate',
      'propertyAddress.postcode': postcode.trim().toUpperCase(),
    };

    final uri = Uri.https(
      'landregistry.data.gov.uk',
      '/data/ppi/transaction-record.json',
      queryParameters,
    );

    developer.log('Fetching data from: $uri');

    final response = await client.get(uri, headers: {'Accept': 'application/json'});

    if (response.statusCode == 200) {
      developer.log('API Response: ${response.body}');
      final data = json.decode(response.body);
      
      // Safely access the 'items' list
      final items = data['result']?['items'];
      final List<dynamic> results = (items is List) ? items : [];

      final List<PricePaidModel> modelItems = [];
      for (final item in results) {
        try {
          modelItems.add(PricePaidModel.fromJson(item));
        } catch (e, s) {
          developer.log('Failed to parse item', error: e, stackTrace: s);
        }
      }
      return modelItems;
    } else {
      developer.log('API Error: ${response.statusCode} ${response.body}');
      throw Exception(
          'Failed to load price paid data: ${response.statusCode} ${response.body}');
    }
  }
}
