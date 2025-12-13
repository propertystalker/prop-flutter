class FinanceProposalRequest {
  String companyName;
  String companyEmail;
  String lenderEmail;
  bool sendToLender;

  FinanceProposalRequest({
    this.companyName = '',
    this.companyEmail = '',
    this.lenderEmail = '',
    this.sendToLender = false,
  });
}
