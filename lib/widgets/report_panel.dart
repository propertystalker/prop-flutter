import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/controllers/send_report_request_controller.dart';
import 'package:myapp/utils/pdf_generator.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';

class ReportPanel extends StatelessWidget {
  final VoidCallback onSend;
  final String address;
  final String price;
  final List<XFile> images;

  const ReportPanel({
    super.key,
    required this.onSend,
    required this.address,
    required this.price,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<SendReportRequestController>(context);
    final request = controller.request;

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
            initialValue: request.from,
            decoration: const InputDecoration(
              labelText: 'From',
              icon: Icon(Icons.person),
            ),
            onChanged: (value) => controller.setFrom(value),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            initialValue: request.to,
            decoration: const InputDecoration(
              labelText: 'To',
              icon: Icon(Icons.person_outline),
            ),
            onChanged: (value) => controller.setTo(value),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            initialValue: request.cc,
            decoration: const InputDecoration(
              labelText: 'CC',
              icon: Icon(Icons.people_outline),
            ),
            onChanged: (value) => controller.setCc(value),
          ),
          CheckboxListTile(
            title: const Text('Also invite to setup account'),
            value: request.inviteToSetupAccount,
            onChanged: (value) => controller.setInviteToSetupAccount(value ?? false),
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
                PdfGenerator.generateAndOpenPdf(address, price, images);
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
