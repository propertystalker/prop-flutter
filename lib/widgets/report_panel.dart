import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/utils/pdf_generator.dart';
import '../utils/constants.dart';

class ReportPanel extends StatelessWidget {
  final bool inviteToSetupAccount;
  final ValueChanged<bool?> onInviteToSetupAccountChanged;
  final VoidCallback onSend;
  final String address;
  final List<XFile> images;

  const ReportPanel({
    super.key,
    required this.inviteToSetupAccount,
    required this.onInviteToSetupAccountChanged,
    required this.onSend,
    required this.address,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: trafficYellow, width: 2),
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
            'Create & Send Report',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'From',
              icon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'To',
              icon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'CC',
              icon: Icon(Icons.people_outline),
            ),
          ),
          CheckboxListTile(
            title: const Text('Also invite to setup account'),
            value: inviteToSetupAccount,
            onChanged: onInviteToSetupAccountChanged,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 16.0),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                PdfGenerator.generateAndOpenPdf(address, images);
                onSend();
              },
              child: const Text('Send'),
            ),
          ),
        ],
      ),
    );
  }
}
