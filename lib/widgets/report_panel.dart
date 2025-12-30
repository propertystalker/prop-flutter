import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/controllers/send_report_request_controller.dart';
import 'package:myapp/utils/pdf_generator.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';

class ReportPanel extends StatefulWidget {
  final VoidCallback onSend;
  final String address;
  final String price;
  final List<XFile> images;
  final String? streetViewUrl;
  final double gdv;
  final double totalCost;
  final double uplift;

  const ReportPanel({
    super.key,
    required this.onSend,
    required this.address,
    required this.price,
    required this.images,
    this.streetViewUrl,
    required this.gdv,
    required this.totalCost,
    required this.uplift,
  });

  @override
  State<ReportPanel> createState() => _ReportPanelState();
}

class _ReportPanelState extends State<ReportPanel> {
  bool _isSending = false;

  Future<void> _generateAndSendPdf() async {
    setState(() {
      _isSending = true;
    });

    try {
      await PdfGenerator.generateAndOpenPdf(
        widget.address,
        widget.price,
        widget.images,
        widget.streetViewUrl,
        widget.gdv,
        widget.totalCost,
        widget.uplift,
      );
      widget.onSend();
    } catch (e) {
      debugPrint("Error generating or sending PDF: $e");
      // Optionally show an error to the user
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

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
              onPressed: _isSending ? null : _generateAndSendPdf,
              child: _isSending
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Send'),
            ),
          ),
        ],
      ),
    );
  }
}
