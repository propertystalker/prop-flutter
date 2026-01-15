import 'package:flutter/foundation.dart';
import 'package:myapp/models/epc_model.dart';
import 'package:myapp/services/epc_service.dart';

class EpcController with ChangeNotifier {
  final EpcService _epcService = EpcService();
  List<EpcModel> _epcs = [];
  bool _isLoading = false;
  String? _errorMessage;
  EpcModel? _selectedEpc;

  List<EpcModel> get epcs => _epcs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  EpcModel? get selectedEpc => _selectedEpc;

  Future<void> fetchEpcData(String postcode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _epcs = await _epcService.getEpcData(postcode);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedEpc(EpcModel epc) {
    _selectedEpc = epc;
    notifyListeners();
  }
}
