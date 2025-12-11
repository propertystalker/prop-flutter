import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../models/property_floor_area.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:docx_template/docx_template.dart' as docx;
import 'package:open_file/open_file.dart' as open_file;
import 'package:image_picker/image_picker.dart';

class ReportGenerator {
  static Future<void> generateReport({
    required KnownFloorArea area,
    required List<XFile> images,
  }) async {
    try {
      final ByteData data = await rootBundle
          .load('assets/PS_v7_3_Dummy_Report_Standard Author Chris May.docx');
      final List<int> bytes = data.buffer.asUint8List();
      final template = await docx.DocxTemplate.fromBytes(bytes);

      final content = docx.Content();

      // 1. Property Details (Text)
      content.add(docx.TextContent("property_address", area.address));
      content.add(docx.TextContent("report_date", DateTime.now().toIso8601String()));
      content.add(docx.TextContent("size", area.squareFeet.toString()));
      content.add(docx.TextContent("bedrooms", area.habitableRooms.toString()));

      // 2. Logo Image
      final ByteData logoData = await rootBundle.load('assets/images/app_icon.png');
      final Uint8List logoBytes = logoData.buffer.asUint8List();
      content.add(docx.ImageContent('LOGO PLACEHOLDER', logoBytes));

      // 3. Property Photos (up to 4)
      for (int i = 0; i < 4; i++) {
        if (i < images.length) {
          final imageBytes = await images[i].readAsBytes();
          content.add(docx.ImageContent('photo${i + 1}', imageBytes));
        }
      }

      final d = await template.generate(content);

      final Directory? directory =
          await path_provider.getApplicationDocumentsDirectory();

      if (directory != null) {
        final String filePath = '${directory.path}/generated_report.docx';
        final File file = File(filePath);
        if (d != null) {
          await file.writeAsBytes(d);
          await open_file.OpenFile.open(filePath);
        }
      }
    } catch (e) {
      print('Error generating report: $e');
    }
  }
}
