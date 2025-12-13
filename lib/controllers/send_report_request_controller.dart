import 'package:flutter/foundation.dart';
import 'package:myapp/models/send_report_request.dart';

class SendReportRequestController with ChangeNotifier {
  final SendReportRequest _request = SendReportRequest();

  SendReportRequest get request => _request;

  void setFrom(String from) {
    _request.from = from;
    notifyListeners();
  }

  void setTo(String to) {
    _request.to = to;
    notifyListeners();
  }

  void setCc(String cc) {
    _request.cc = cc;
    notifyListeners();
  }

  void setInviteToSetupAccount(bool value) {
    _request.inviteToSetupAccount = value;
    notifyListeners();
  }
}
