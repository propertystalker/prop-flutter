import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:myapp/models/planning_application.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/controllers/gdv_controller.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/report_model.dart';

class PdfGenerator {
  static Future<Map<String, dynamic>?> generatePdf(
    String address,
    String price,
    List<XFile> images,
    String? streetViewUrl,
    double gdv,
    double totalCost,
    double uplift,
    List<PlanningApplication> propertyDataApplications,
    List<PlanningApplication> planitApplications,
    Map<String, UpliftData> scenarioUplifts,
    double roi,
    double areaGrowth,
    String riskIndicator,
    InvestmentSignal investmentSignal,
    GdvConfidence gdvConfidence,
    List<String> selectedScenarios,
  ) async {
    try {
      final pdf = pw.Document();

      final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
      final boldFontData = await rootBundle.load("assets/fonts/NotoSans-Bold.ttf");
      
      final font = pw.Font.ttf(fontData);
      final boldFont = pw.Font.ttf(boldFontData);

      final fallbackImageBytes = await rootBundle.load('assets/images/gemini.png');
      final fallbackImage = pw.MemoryImage(fallbackImageBytes.buffer.asUint8List());

      final streetViewImage = await _getStreetViewImage(streetViewUrl, fallbackImage);

      // SECTION A
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => _buildSectionA(
            context,
            address,
            streetViewImage,
            investmentSignal,
            boldFont,
          ),
        ),
      );

      // SECTION B
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => _buildSectionB(
            context,
            gdv,
            totalCost,
            uplift,
            gdvConfidence,
            roi,
            boldFont,
            font,
          ),
        ),
      );

      // SECTION C
       pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(
            base: font,
            bold: boldFont,
          ),
          header: (context) => pw.Header(text: 'Section C: Planning Applications', level: 1),
          build: (context) => _buildSectionC(
            propertyDataApplications.isNotEmpty ? propertyDataApplications : planitApplications,
            boldFont,
          ),
        ),
      );

      // SECTION D
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => _buildSectionD(
            context,
            selectedScenarios,
            scenarioUplifts,
            boldFont,
            font,
          ),
        ),
      );

      final Uint8List pdfBytes = await pdf.save();

      final sanitizedAddress = address.replaceAll(RegExp(r'[\/:*?"<>|]'), '_');
      final fileName = 'Property_Stalker_$sanitizedAddress.pdf';

      return {
        'bytes': pdfBytes,
        'filename': fileName,
      };
    } catch (e, s) {
      debugPrint('Error generating PDF: $e\n$s');
      return null;
    }
  }

  static Future<pw.MemoryImage> _getStreetViewImage(String? streetViewUrl, pw.MemoryImage fallbackImage) async {
    if (streetViewUrl != null && streetViewUrl.isNotEmpty) {
        try {
          final response = await http.get(Uri.parse(streetViewUrl));
          if (response.statusCode == 200) {
            return pw.MemoryImage(response.bodyBytes);
          } else {
            debugPrint('Failed to load street view image: ${response.statusCode}');
            return fallbackImage;
          }
        } catch (e) {
          debugPrint('Error fetching street view image: $e');
          return fallbackImage;
        }
      } else {
        return fallbackImage;
      }
  }

  static pw.Widget _buildSectionA(
    pw.Context context,
    String address,
    pw.MemoryImage streetViewImage,
    InvestmentSignal investmentSignal,
    pw.Font boldFont,
  ) {
    final town = address.split(', ').last;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(text: 'Section A: Property Overview', level: 1),
        pw.Text(address, style: pw.TextStyle(font: boldFont, fontSize: 24)),
        pw.Text(town, style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700)),
        pw.SizedBox(height: 20),
        pw.Image(streetViewImage, width: 400, height: 200, fit: pw.BoxFit.cover),
        pw.SizedBox(height: 20),
        pw.Row(
          children: [
            pw.Text('Investment Signal:', style: pw.TextStyle(font: boldFont, fontSize: 18)),
            pw.SizedBox(width: 10),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: pw.BoxDecoration(
                color: _getInvestmentSignalColor(investmentSignal),
                borderRadius: pw.BorderRadius.circular(16),
              ),
              child: pw.Text(
                investmentSignal.toString().split('.').last.toUpperCase(),
                style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSectionB(
    pw.Context context,
    double gdv,
    double totalCost,
    double uplift,
    GdvConfidence gdvConfidence,
    double roi,
    pw.Font boldFont,
    pw.Font font,
  ) {
    final sanitizedGdv = gdv.isNaN ? 0.0 : gdv;
    final sanitizedTotalCost = totalCost.isNaN ? 0.0 : totalCost;
    final sanitizedUplift = uplift.isNaN ? 0.0 : uplift;

    final chart = pw.Chart(
        title: pw.Text(
          'GDV: £${(sanitizedGdv / 1000).toStringAsFixed(0)}K',
          style: pw.TextStyle(font: boldFont, fontSize: 16),
        ),
        grid: pw.PieGrid(),
        datasets: [
          pw.PieDataSet(
            legend: 'Uplift',
            value: sanitizedUplift,
            color: PdfColors.blue,
            legendStyle: pw.TextStyle(font: font),
          ),
          pw.PieDataSet(
            legend: 'Total Cost',
            value: sanitizedTotalCost,
            color: PdfColors.grey500,
            legendStyle: pw.TextStyle(font: font),
          ),
        ],
      );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(text: 'Section B: GDV Information', level: 1),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: [
            pw.SizedBox(
              width: 250, 
              height: 250,
              child: chart,
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('GDV Confidence: ${gdvConfidence.toString().split('.').last}', style: pw.TextStyle(font: boldFont, fontSize: 18)),
                pw.SizedBox(height: 10),
                pw.Text('Return on Investment: ${roi.toStringAsFixed(1)}%', style: pw.TextStyle(font: boldFont, fontSize: 18)),
              ]
            )
          ]
        ),
      ],
    );
  }

  static List<pw.Widget> _buildSectionC(
    List<PlanningApplication> planningApplications,
    pw.Font boldFont,
  ) {
    final List<pw.Widget> widgets = [];
    for (var app in planningApplications) {
        widgets.add(
          pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 10),
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.UrlLink(
                  destination: app.url,
                  child: pw.Text(
                    app.address.isNotEmpty ? app.address : 'No address available',
                    style: pw.TextStyle(font: boldFont, color: PdfColors.blue, decoration: pw.TextDecoration.underline),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(app.proposal.isNotEmpty ? app.proposal : 'No description available'),
                pw.SizedBox(height: 5),
                pw.Text('Decision: ${app.decision.text.isNotEmpty ? app.decision.text : 'N/A'}'),
                pw.Text('Received: ${app.dates.receivedAt != null ? app.dates.receivedAt.toString() : 'N/A'}'),
              ],
            ),
          ),
        );
      }
      return widgets;
  }

  static pw.Widget _buildSectionD(
    pw.Context context,
    List<String> selectedScenarios,
    Map<String, UpliftData> scenarioUplifts,
    pw.Font boldFont,
    pw.Font font,
  ) {
     final currencyFormatter = NumberFormat.simpleCurrency(locale: 'en_GB', decimalDigits: 0);
      final numberFormatter = NumberFormat.decimalPattern('en_GB');

    final List<pw.TableRow> tableRows = [];
      tableRows.add(
        pw.TableRow(
          children: [
            pw.Text('Scenario', style: pw.TextStyle(font: boldFont)),
            pw.Text('Area (m²)', style: pw.TextStyle(font: boldFont), textAlign: pw.TextAlign.right),
            pw.Text('Uplift £/m²', style: pw.TextStyle(font: boldFont), textAlign: pw.TextAlign.right),
            pw.Text('Uplift (£)', style: pw.TextStyle(font: boldFont), textAlign: pw.TextAlign.right),
          ],
        ),
      );

      for (var scenario in scenarioUplifts.entries) {
        if(selectedScenarios.contains(scenario.key)){
          tableRows.add(
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4.0),
                  child: pw.Text(scenario.key, style: pw.TextStyle(fontSize: 12)),
                ),
                pw.Text(numberFormatter.format(scenario.value.area), style: pw.TextStyle(fontSize: 12), textAlign: pw.TextAlign.right),
                pw.Text(currencyFormatter.format(scenario.value.rate), style: pw.TextStyle(fontSize: 12), textAlign: pw.TextAlign.right),
                pw.Text(currencyFormatter.format(scenario.value.uplift), style: pw.TextStyle(fontSize: 12), textAlign: pw.TextAlign.right),
              ],
            ),
          );
        }
      }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(text: 'Section D: Selected Scenarios', level: 1),
         pw.Table(
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(1.5),
          },
          children: tableRows,
        ),
      ],
    );
  }
}

PdfColor _getRiskColor(String risk) {
  switch (risk) {
    case 'Medium':
      return PdfColors.orange;
    case 'Higher':
      return PdfColors.red;
    case 'Low':
    default:
      return PdfColors.green;
  }
}

PdfColor _getInvestmentSignalColor(InvestmentSignal signal) {
  switch (signal) {
    case InvestmentSignal.green:
      return PdfColors.green;
    case InvestmentSignal.amber:
      return PdfColors.orange;
    case InvestmentSignal.red:
      return PdfColors.red;
  }
}
