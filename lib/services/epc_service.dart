import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/models/epc_model.dart';
import 'package:myapp/utils/constants.dart';
import 'dart:developer' as developer;

class EpcService {
  final http.Client client;

  EpcService({http.Client? client}) : client = client ?? http.Client();

  // The service only needs to fetch all data for a postcode.
  // The filtering will be handled by the UI (EpcScreen).
  Future<List<EpcModel>> getEpcData(String postcode) async {
    final url = '$epcBaseUrl/search?postcode=${postcode.replaceAll(' ', '+')}&size=100';
    
    final credentials = base64Encode(utf8.encode('$epcEmail:$epcApiKey'));
    
    // developer.log('Fetching EPC data from: $url');

    final response = await client.get(Uri.parse(url), headers: {
      'Accept': 'application/json',
      'Authorization': 'Basic $credentials',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // developer.log('EPC API Response: ${response.body}');
      
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
