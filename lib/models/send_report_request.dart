class SendReportRequest {
  String from;
  String to;
  String cc;
  bool inviteToSetupAccount;

  SendReportRequest({
    this.from = '',
    this.to = '',
    this.cc = '',
    this.inviteToSetupAccount = false,
  });
}
