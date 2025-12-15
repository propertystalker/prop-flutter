import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/models/epc_model.dart';
import 'dart:developer' as developer;

class EpcService {
  static const String _baseUrl = 'https://epc.opendatacommunities.org/api/v1/domestic';
  
  final String _email = 'steve@libertyapps.co.uk';
  final String _apiKey = '3ce43250e7f8017c83fa5ce440916be1f404669f';

  Future<List<EpcModel>> getEpcData(String postcode) async {
    final url = '$_baseUrl/search?postcode=${postcode.replaceAll(' ', '+')}&size=100';
    
    final credentials = base64Encode(utf8.encode('$_email:$_apiKey'));
    
    developer.log('Fetching EPC data from: $url');

    final response = await http.get(Uri.parse(url), headers: {
      'Accept': 'application/json',
      'Authorization': 'Basic $credentials',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      developer.log('EPC API Response: ${response.body}');
      
      final List<dynamic> results = data['rows'];

      final List<EpcModel> modelItems = [];
      for (final item in results) {
        try {
          modelItems.add(EpcModel.fromJson(item));
        } catch (e, s) {
          developer.log('Failed to parse EPC item', error: e, stackTrace: s);
        }
      }
      return modelItems;
    } else {
      developer.log('EPC API Error: ${response.statusCode} ${response.body}');
      throw Exception('Failed to load EPC data: ${response.statusCode} ${response.body}');
    }
  }
}
