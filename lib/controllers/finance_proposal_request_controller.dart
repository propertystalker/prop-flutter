import 'package:flutter/foundation.dart';
import 'package:myapp/models/finance_proposal_request.dart';

class FinanceProposalRequestController with ChangeNotifier {
  final FinanceProposalRequest _request = FinanceProposalRequest(
    companyName: 'Golden Trust Capital',
    companyEmail: 'chris@goldentrustcapital.co.uk',
    lenderEmail: 'devfinance@bigbanklender.com',
    sendToLender: false,
  );

  FinanceProposalRequest get request => _request;

  void setCompanyName(String name) {
    _request.companyName = name;
    notifyListeners();
  }

  void setCompanyEmail(String email) {
    _request.companyEmail = email;
    notifyListeners();
  }

  void setLenderEmail(String email) {
    _request.lenderEmail = email;
    notifyListeners();
  }

  void setSendToLender(bool value) {
    _request.sendToLender = value;
    notifyListeners();
  }
}
