
import 'package:flutter/foundation.dart';

class ReportInfo {
  final String fileName;
  final String reportUrl;

  ReportInfo({required this.fileName, required this.reportUrl});
}

class ReportSessionController with ChangeNotifier {
  final List<ReportInfo> _reports = [];

  List<ReportInfo> get reports => _reports;

  void addReport(String fileName, String reportUrl) {
    // Avoid adding duplicates
    if (!_reports.any((r) => r.reportUrl == reportUrl)) {
      _reports.add(ReportInfo(fileName: fileName, reportUrl: reportUrl));
      notifyListeners();
    }
  }
}
