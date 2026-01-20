
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:myapp/controllers/gdv_controller.dart';
import 'package:myapp/controllers/financial_controller.dart';
import 'package:myapp/controllers/report_controller.dart';
import 'package:myapp/models/report_model.dart';
import 'package:myapp/utils/pdf_generator.dart';
import 'package:myapp/models/planning_application.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportScreen extends StatefulWidget {
  final String propertyId;
  final List<String> selectedScenarios;
  final List<PlanningApplication> propertyDataApplications;
  final List<PlanningApplication> planitApplications;

  const ReportScreen({
    super.key,
    required this.propertyId,
    required this.selectedScenarios,
    required this.propertyDataApplications,
    required this.planitApplications,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _isPaymentSuccessful = false;
  bool _isProcessingPayment = false;

  Future<void> _initiatePayment() async {
    if (_isProcessingPayment) return;

    setState(() {
      _isProcessingPayment = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Initiating payment...')),
    );

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final response = await supabase.functions.invoke(
        'gocardless-payment',
        body: {
          'amount': 100, // 100p = £1.00
          'currency': 'GBP',
          'description': 'Property Report Purchase',
          'user_id': userId,
        },
      );

      if (response.status != 200) {
        final errorData = response.data as Map?;
        final errorMessage = errorData?['error'] ?? 'Failed to create payment request.';
        final reason = errorData?['reasonPhrase'] ?? '';
        throw Exception('FunctionException(status: ${response.status}, details: {error: $errorMessage}, reasonPhrase: $reason)');
      }

      final billingRequest = response.data?['billing_requests'];
      final billingRequestId = billingRequest?['id'];
      final paymentUrl = billingRequestId != null ? 'https://pay-sandbox.gocardless.com/billing/$billingRequestId' : null;


      if (paymentUrl != null) {
         if (!await canLaunchUrl(Uri.parse(paymentUrl))) {
            throw Exception('Could not launch payment URL');
        }
        await launchUrl(Uri.parse(paymentUrl), mode: LaunchMode.externalApplication);
        // A real app would use deep linking to confirm payment automatically.
        // For this example, we'll assume success when the user returns.
        setState(() {
          _isPaymentSuccessful = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful! You can now download the report.')),
        );
      } else {
        throw Exception('Payment URL not received from GoCardless response.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final gdvController = Provider.of<GdvController>(context, listen: false);
    final financialController = Provider.of<FinancialController>(context, listen: false);

    return ChangeNotifierProvider(
      create: (_) => ReportController()
        ..generateReport(
          widget.propertyId,
          scenarios: widget.selectedScenarios,
          propertyDataApplications: widget.propertyDataApplications,
          planitApplications: widget.planitApplications,
          gdv: gdvController.finalGdv,
          totalCost: financialController.totalCost,
          uplift: gdvController.finalGdv - financialController.totalCost,
          detailedCosts: financialController.detailedCosts,
        ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Property Report'),
          actions: [
            Consumer<ReportController>(
              builder: (context, controller, child) {
                return IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  tooltip: _isPaymentSuccessful ? 'Download PDF' : 'Complete payment to download',
                  onPressed: _isPaymentSuccessful && controller.report != null
                      ? () async {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Generating PDF...')),
                          );

                          final pdfData = await PdfGenerator.generatePdf(
                            controller.report!.propertyAddress,
                            '', // Price - handle this properly
                            [], // Images - handle this properly
                            null, // StreetView URL
                            gdvController,
                            financialController.totalCost,
                            gdvController.finalGdv - financialController.totalCost,
                            controller.propertyDataApplications,
                            controller.planitApplications,
                            financialController.roi,
                            financialController.areaGrowth,
                            financialController.riskIndicator,
                            controller.report!.investmentSignal,
                            controller.report!.gdvConfidence,
                            controller.report!.selectedScenarios,
                            detailedCosts: controller.report!.detailedCosts,
                          );

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();

                          if (pdfData != null) {
                            final bytes = pdfData['bytes'] as Uint8List;
                            final fileName = pdfData['filename'] as String;
                            await Printing.sharePdf(bytes: bytes, filename: fileName);
                          } else {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to generate PDF. Please try again.')),
                            );
                          }
                        }
                      : null,
                );
              },
            ),
          ],
        ),
        body: Consumer<ReportController>(
          builder: (context, controller, child) {
            if (controller.report == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.report!.selectedScenarios.isEmpty) {
              return const Center(child: Text("No scenarios were selected to generate a report."));
            }

            final report = controller.report!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(report.propertyAddress, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text('Report Generated: ${report.dateGenerated.toLocal()}', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 24),

                  Text('Selected Scenarios', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  if (report.selectedScenarios.isNotEmpty)
                    ...report.selectedScenarios.map((scenario) => ListTile(
                          leading: const Icon(Icons.check_box_outline_blank),
                          title: Text(scenario),
                        ))
                  else
                    const Text('No scenarios were selected for this report.'),

                  const SizedBox(height: 24),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildFinancialRow('Investment Signal', report.investmentSignal.name.toUpperCase(), _getInvestmentSignalColor(report.investmentSignal)),
                          _buildFinancialRow('GDV Confidence', report.gdvConfidence.name.toUpperCase()),
                          _buildFinancialRow('Estimated Profit', '£${report.estimatedProfit.toStringAsFixed(0)}'),
                          _buildFinancialRow('Return on Investment', '${report.returnOnInvestment.toStringAsFixed(1)}%'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('Key Constraints', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Coming Soon', style: Theme.of(context).textTheme.bodyMedium),

                  const SizedBox(height: 32),
                  if (!_isPaymentSuccessful)
                    Center(
                      child: _isProcessingPayment
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _initiatePayment,
                              child: const Text('Purchase Report for £1.00'),
                            ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFinancialRow(String title, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: 16, color: valueColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getInvestmentSignalColor(InvestmentSignal signal) {
    switch (signal) {
      case InvestmentSignal.green:
        return Colors.green;
      case InvestmentSignal.amber:
        return Colors.orange;
      case InvestmentSignal.red:
        return Colors.red;
    }
  }
}
