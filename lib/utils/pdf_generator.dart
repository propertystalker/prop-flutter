import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfGenerator {
  static Future<void> generateAndOpenPdf(
      String address, String price, List<XFile> images) async {
    final pdf = pw.Document();

    final imageProviders = <pw.MemoryImage>[];
    for (final image in images) {
      final bytes = await image.readAsBytes();
      imageProviders.add(pw.MemoryImage(bytes));
    }

    // Fetch a Unicode-compatible font using the printing package's helper
    final font = await PdfGoogleFonts.notoSansRegular();

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: font),
        build: (context) => [
          pw.Header(text: address, level: 1),
          pw.Text(price, style: pw.TextStyle(fontSize: 24)),
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
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'report.pdf',
    );
  }
}
