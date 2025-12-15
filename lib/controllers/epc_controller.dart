import 'package:flutter/material.dart';
import 'package:myapp/models/epc_model.dart';
import 'package:myapp/services/epc_service.dart';

class EpcController with ChangeNotifier {
  final EpcService _epcService = EpcService();
  List<EpcModel> _epcData = [];
  bool _isLoading = false;
  String? _error;

  List<EpcModel> get epcData => _epcData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchEpcData(String postcode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _epcData = await _epcService.getEpcData(postcode);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
