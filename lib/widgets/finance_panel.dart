
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class FinancePanel extends StatelessWidget {
  final bool sendReportToLender;
  final ValueChanged<bool?> onSendReportToLenderChanged;
  final VoidCallback onSend;

  const FinancePanel({
    super.key,
    required this.sendReportToLender,
    required this.onSendReportToLenderChanged,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
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
            initialValue: 'Golden Trust Capital',
            decoration: const InputDecoration(
              labelText: 'Company Name',
              icon: Icon(Icons.business),
            ),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            initialValue: 'chris@goldentrustcapital.co.uk',
            decoration: const InputDecoration(
              labelText: 'Company email address',
              icon: Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            initialValue: 'devfinance@bigbanklender.com',
            decoration: const InputDecoration(
              labelText: 'Bank lender email address',
              icon: Icon(Icons.account_balance),
            ),
          ),
          CheckboxListTile(
            title: const Text('Also send report to lender'),
            value: sendReportToLender,
            onChanged: onSendReportToLenderChanged,
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
