import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/controllers/financial_controller.dart';
import 'package:myapp/controllers/gdv_controller.dart';
import 'package:myapp/controllers/report_session_controller.dart';
import 'package:myapp/controllers/send_report_request_controller.dart';
import 'package:myapp/models/planning_application.dart';
import 'package:myapp/services/cloudinary_service.dart';
import 'package:myapp/utils/pdf_generator.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import 'package:myapp/models/report_model.dart';

class ReportPanel extends StatefulWidget {
  final VoidCallback onSend;
  final String address;
  final String price;
  final List<XFile> images;
  final String? streetViewUrl;
  final List<PlanningApplication> propertyDataApplications;
  final List<PlanningApplication> planitApplications;
  final List<String> selectedScenarios;

  const ReportPanel({
    super.key,
    required this.onSend,
    required this.address,
    required this.price,
    required this.images,
    this.streetViewUrl,
    required this.propertyDataApplications,
    required this.planitApplications,
    required this.selectedScenarios,
  });

  @override
  State<ReportPanel> createState() => _ReportPanelState();
}

class _ReportPanelState extends State<ReportPanel> {
  bool _isSending = false;

  InvestmentSignal _calculateInvestmentSignal(double returnOnInvestment) {
    if (returnOnInvestment > 20) {
      return InvestmentSignal.green;
    } else if (returnOnInvestment >= 10) {
      return InvestmentSignal.amber;
    } else {
      return InvestmentSignal.red;
    }
  }

  GdvConfidence _calculateGdvConfidence(double gdv) {
    if (gdv > 500000) {
      return GdvConfidence.high;
    } else if (gdv >= 200000) {
      return GdvConfidence.medium;
    } else {
      return GdvConfidence.low;
    }
  }

  Future<void> _generateAndUploadReport() async {
    if (_isSending) return;

    setState(() {
      _isSending = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating your report...')),
      );
    }

    try {
      final gdvController = Provider.of<GdvController>(context, listen: false);
      final financialController = Provider.of<FinancialController>(context, listen: false);
      final investmentSignal = _calculateInvestmentSignal(financialController.roi);
      final gdvConfidence = _calculateGdvConfidence(gdvController.finalGdv);

      final pdfData = await PdfGenerator.generatePdf(
        widget.address,
        widget.price,
        widget.images,
        widget.streetViewUrl,
        gdvController, // Pass the controller
        financialController.totalCost, // Get from controller
        gdvController.finalGdv - financialController.totalCost, // Calculate uplift
        widget.propertyDataApplications,
        widget.planitApplications,
        financialController.roi,
        financialController.areaGrowth,
        financialController.riskIndicator,
        investmentSignal,
        gdvConfidence,
        widget.selectedScenarios,
      );

      if (pdfData == null) {
        throw Exception('PDF generation failed.');
      }

      final pdfBytes = pdfData['bytes'];
      final originalFileName = pdfData['filename'];

      if (pdfBytes == null || originalFileName == null) {
        throw Exception('PDF generation failed to return data.');
      }
      
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-');
      final fileName = '${originalFileName.split('.').first}_$timestamp.pdf';

      await Printing.sharePdf(bytes: pdfBytes, filename: fileName);

      if(mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading your report...')),
        );
      }

      final cloudinaryService = CloudinaryService();
      final reportUrl = await cloudinaryService.uploadPdf(
        pdfBytes: pdfBytes,
        fileName: fileName,
        folder: 'reports',
      );

      if (reportUrl != null) {
        developer.log('Report uploaded successfully: $reportUrl', name: 'ReportPanel');
        
        if(mounted){
          final reportSessionController = Provider.of<ReportSessionController>(context, listen: false);
          reportSessionController.addReport(fileName, reportUrl);
        }

        widget.onSend();
      } else {
        throw Exception('Failed to upload report to Cloudinary.');
      }

    } catch (e, s) {
      developer.log('Error during report generation/upload', error: e, stackTrace: s, name: 'ReportPanel');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
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
              onPressed: _isSending ? null : _generateAndUploadReport,
              child: _isSending
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Send Report'),
            ),
          ),
        ],
      ),
    );
  }
}
