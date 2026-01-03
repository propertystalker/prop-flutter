
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfGenerator {
  static Future<Map<String, dynamic>> generatePdf(
    String address,
    String price,
    List<XFile> images,
    String? streetViewUrl,
    double gdv,
    double totalCost,
    double uplift,
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

    final chart = pw.Chart(
      title: pw.Text(
        'GDV: £${(gdv / 1000).toStringAsFixed(0)}K',
        style: chartTitleStyle, // Use explicit style
      ),
      grid: pw.PieGrid(),
      datasets: [
        pw.PieDataSet(
          legend: 'Uplift',
          value: uplift,
          color: PdfColors.blue,
          legendStyle: legendStyle, // Use explicit style
        ),
        pw.PieDataSet(
          legend: 'Total Cost',
          value: totalCost,
          color: PdfColors.grey500,
          legendStyle: legendStyle, // Use explicit style
        ),
      ],
    );

    pdf.addPage(
      pw.MultiPage(
        // --- Updated Theme ---
        theme: pw.ThemeData.withFont(
          base: font,
          bold: boldFont,
        ),
        build: (context) => [
          pw.Header(text: address, level: 1, textStyle: headerStyle), // Use explicit style
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
