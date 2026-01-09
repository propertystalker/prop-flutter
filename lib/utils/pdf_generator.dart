import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:myapp/models/planning_application.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/controllers/gdv_controller.dart';
import 'package:intl/intl.dart';

class PdfGenerator {
  static Future<Map<String, dynamic>?> generatePdf(
    String address,
    String price,
    List<XFile> images,
    String? streetViewUrl,
    double gdv,
    double totalCost,
    double uplift,
    List<PlanningApplication> planningApplications,
    Map<String, UpliftData> scenarioUplifts,
  ) async {
    try {
      final pdf = pw.Document();

      final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
      final boldFontData = await rootBundle.load("assets/fonts/NotoSans-Bold.ttf");
      
      final font = pw.Font.ttf(fontData);
      final boldFont = pw.Font.ttf(boldFontData);

      final fallbackImageBytes = await rootBundle.load('assets/images/gemini.png');
      final fallbackImage = pw.MemoryImage(fallbackImageBytes.buffer.asUint8List());

      final imageProviders = <pw.MemoryImage>[];
      if (streetViewUrl != null && streetViewUrl.isNotEmpty) {
        try {
          final response = await http.get(Uri.parse(streetViewUrl));
          if (response.statusCode == 200) {
            imageProviders.add(pw.MemoryImage(response.bodyBytes));
          } else {
            debugPrint('Failed to load street view image: ${response.statusCode}');
            imageProviders.add(fallbackImage);
          }
        } catch (e) {
          debugPrint('Error fetching street view image: $e');
          imageProviders.add(fallbackImage);
        }
      } else {
        imageProviders.add(fallbackImage);
      }

      for (final image in images) {
        final bytes = await image.readAsBytes();
        imageProviders.add(pw.MemoryImage(bytes));
      }

      final headerStyle = pw.TextStyle(font: boldFont, fontSize: 28);
      final priceStyle = pw.TextStyle(font: font, fontSize: 24);
      final chartTitleStyle = pw.TextStyle(font: boldFont, fontSize: 16);
      final legendStyle = pw.TextStyle(font: font);

      // Sanitize financial values to prevent NaN errors
      final sanitizedGdv = gdv.isNaN ? 0.0 : gdv;
      final sanitizedTotalCost = totalCost.isNaN ? 0.0 : totalCost;
      final sanitizedUplift = uplift.isNaN ? 0.0 : uplift;

      final chart = pw.Chart(
        title: pw.Text(
          'GDV: £${(sanitizedGdv / 1000).toStringAsFixed(0)}K',
          style: chartTitleStyle,
        ),
        grid: pw.PieGrid(),
        datasets: [
          pw.PieDataSet(
            legend: 'Uplift',
            value: sanitizedUplift,
            color: PdfColors.blue,
            legendStyle: legendStyle,
          ),
          pw.PieDataSet(
            legend: 'Total Cost',
            value: sanitizedTotalCost,
            color: PdfColors.grey500,
            legendStyle: legendStyle,
          ),
        ],
      );

      final widgets = <pw.Widget>[
        pw.UrlLink(
          destination: 'http://propertystalker.com/',
          child: pw.Text(
            address,
            style: headerStyle.copyWith(
              color: PdfColors.blue,
              decoration: pw.TextDecoration.underline,
            ),
          ),
        ),
        pw.Text(price, style: priceStyle),
        pw.SizedBox(height: 20),
        pw.SizedBox(
          height: 250,
          child: chart,
        ),
        pw.SizedBox(height: 20),
        pw.Wrap(
          spacing: 10,
          runSpacing: 10,
          children: imageProviders.map((imageProvider) {
            return pw.SizedBox(
              width: 200, // Constrain image width
              height: 200, // Constrain image height
              child: pw.Image(imageProvider),
            );
          }).toList(),
        ),
        pw.Header(text: 'Planning Applications', level: 2),
      ];

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
                pw.Text(app.address.isNotEmpty ? app.address : 'No address available', style: pw.TextStyle(font: boldFont)),
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

      widgets.add(pw.Header(text: 'Uplift Analysis by Scenario', level: 2));

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
        tableRows.add(
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4.0),
                child: pw.Text(scenario.key, style: const pw.TextStyle(fontSize: 12)),
              ),
              pw.Text(numberFormatter.format(scenario.value.area), style: const pw.TextStyle(fontSize: 12), textAlign: pw.TextAlign.right),
              pw.Text(currencyFormatter.format(scenario.value.rate), style: const pw.TextStyle(fontSize: 12), textAlign: pw.TextAlign.right),
              pw.Text(currencyFormatter.format(scenario.value.uplift), style: const pw.TextStyle(fontSize: 12), textAlign: pw.TextAlign.right),
            ],
          ),
        );
      }

      widgets.add(
        pw.Table(
          columnWidths: const {
            0: pw.FlexColumnWidth(3),
            1: pw.FlexColumnWidth(1),
            2: pw.FlexColumnWidth(1.5),
            3: pw.FlexColumnWidth(1.5),
          },
          children: tableRows,
        ),
      );


      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          theme: pw.ThemeData.withFont(
            base: font,
            bold: boldFont,
          ),
          build: (context) => widgets,
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
}
