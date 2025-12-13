import 'package:flutter/material.dart';
import 'package:myapp/controllers/finance_proposal_request_controller.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';

class FinancePanel extends StatelessWidget {
  final VoidCallback onSend;

  const FinancePanel({super.key, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<FinanceProposalRequestController>(context);
    final request = controller.request;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: trafficGreen, width: 2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Request Finance Proposal',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            initialValue: request.companyName,
            decoration: const InputDecoration(
              labelText: 'Company Name',
              icon: Icon(Icons.business),
            ),
            onChanged: (value) => controller.setCompanyName(value),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            initialValue: request.companyEmail,
            decoration: const InputDecoration(
              labelText: 'Company email address',
              icon: Icon(Icons.email),
            ),
            onChanged: (value) => controller.setCompanyEmail(value),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            initialValue: request.lenderEmail,
            decoration: const InputDecoration(
              labelText: 'Bank lender email address',
              icon: Icon(Icons.account_balance),
            ),
            onChanged: (value) => controller.setLenderEmail(value),
          ),
          CheckboxListTile(
            title: const Text('Also send report to lender'),
            value: request.sendToLender,
            onChanged: (value) => controller.setSendToLender(value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 16.0),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: onSend,
              child: const Text('Send'),
            ),
          ),
        ],
      ),
    );
  }
}
