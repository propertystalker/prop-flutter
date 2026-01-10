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
    final url =
        '$epcBaseUrl/search?postcode=${postcode.replaceAll(' ', '+')}&size=500';

    final credentials = base64Encode(utf8.encode('$epcEmail:$epcApiKey'));

    // developer.log('Fetching EPC data from: $url');

    final response = await client.get(Uri.parse(url), headers: {
      'Accept': 'application/json',
      'Authorization': 'Basic $credentials',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> rows = data['rows'];
      // developer.log('Fetched ${rows.length} EPC records.');
      return rows.map((row) => EpcModel.fromJson(row)).toList();
    } else {
      developer.log('Failed to load EPC data: ${response.statusCode}');
      throw Exception('Failed to load EPC data');
    }
  }
}