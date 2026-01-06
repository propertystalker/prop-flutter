import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:myapp/models/planning_application.dart';

class PdfGenerator {
  static Future<Map<String, dynamic>> generatePdf(
    String address,
    String price,
    List<XFile> images,
    String? streetViewUrl,
    double gdv,
    double totalCost,
    double uplift,
    List<PlanningApplication> planningApplications,
  ) async {
    final pdf = pw.Document();

    // --- Font Loading ---
    final font = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();

    final imageProviders = <pw.MemoryImage>[];
    if (streetViewUrl != null) {
      try {
        final response = await http.get(Uri.parse(streetViewUrl));
        if (response.statusCode == 200) {
          imageProviders.add(pw.MemoryImage(response.bodyBytes));
        } else {
          debugPrint('Failed to load street view image: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('Error fetching street view image: $e');
      }
    }

    for (final image in images) {
      final bytes = await image.readAsBytes();
      imageProviders.add(pw.MemoryImage(bytes));
    }

    // --- Explicit Text Styles ---
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
        style: chartTitleStyle, // Use explicit style
      ),
      grid: pw.PieGrid(),
      datasets: [
        pw.PieDataSet(
          legend: 'Uplift',
          value: sanitizedUplift,
          color: PdfColors.blue,
          legendStyle: legendStyle, // Use explicit style
        ),
        pw.PieDataSet(
          legend: 'Total Cost',
          value: sanitizedTotalCost,
          color: PdfColors.grey500,
          legendStyle: legendStyle, // Use explicit style
        ),
      ],
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        // --- Updated Theme ---
        theme: pw.ThemeData.withFont(
          base: font,
          bold: boldFont,
        ),
        build: (context) => [
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
          pw.Text(price, style: priceStyle), // Use explicit style
          pw.SizedBox(height: 20),
          pw.SizedBox(
            height: 250,
            child: chart,
          ),
          pw.SizedBox(height: 20),
          ...imageProviders.map((imageProvider) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Image(imageProvider),
            );
          }),
          pw.NewPage(),
          pw.Header(text: 'Planning Applications', level: 2),
          ...planningApplications.map((app) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 10),
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(app.address, style: pw.TextStyle(font: boldFont)),
                  pw.SizedBox(height: 5),
                  pw.Text(app.description),
                  pw.SizedBox(height: 5),
                  pw.Text('Status: ${app.status}'),
                  pw.Text('Received: ${app.receivedDate}'),
                ],
              ),
            );
          }),
        ],
      ),
    );

    final Uint8List pdfBytes = await pdf.save();

    final sanitizedAddress = address.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final fileName = 'Property_Stalker_$sanitizedAddress.pdf';

    return {
      'bytes': pdfBytes,
      'filename': fileName,
    };
  }
}
