import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfGenerator {
  static Future<void> generateAndOpenPdf(
    String address,
    String price,
    List<XFile> images,
    String? streetViewUrl,
    double gdv,
    double totalCost,
    double uplift,
  ) async {
    final pdf = pw.Document();

    final imageProviders = <pw.MemoryImage>[];
    if (streetViewUrl != null) {
      try {
        final response = await http.get(Uri.parse(streetViewUrl));
        if (response.statusCode == 200) {
          imageProviders.add(pw.MemoryImage(response.bodyBytes));
        } else {
          print('Failed to load street view image: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching street view image: $e');
      }
    }

    for (final image in images) {
      final bytes = await image.readAsBytes();
      imageProviders.add(pw.MemoryImage(bytes));
    }

    final font = await PdfGoogleFonts.notoSansRegular();

    final chart = pw.Chart(
      title: pw.Text(
        'GDV: £${(gdv / 1000).toStringAsFixed(0)}K',
        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
      ),
      grid: pw.PieGrid(),
      datasets: [
        pw.PieDataSet(
          legend: 'Uplift',
          value: uplift,
          color: PdfColors.blue,
          legendStyle: pw.TextStyle(font: font),
        ),
        pw.PieDataSet(
          legend: 'Total Cost',
          value: totalCost,
          color: PdfColors.grey500,
          legendStyle: pw.TextStyle(font: font),
        ),
      ],
    );

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: font),
        build: (context) => [
          pw.Header(text: address, level: 1),
          pw.Text(price, style: const pw.TextStyle(fontSize: 24)),
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

    // Sanitize the address to create a valid filename
    final sanitizedAddress = address.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Property_Stalker_${sanitizedAddress}.pdf',
    );
  }
}
