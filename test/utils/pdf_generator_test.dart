import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/controllers/gdv_controller.dart';
import 'package:myapp/models/planning_application.dart';
import 'package:myapp/utils/pdf_generator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PdfGenerator', () {
    testWidgets('generatePdf should return a map with PDF bytes and a sanitized filename', (WidgetTester tester) async {
      // 1. SETUP: Create mock data.
      const address = '123 Test Street, London, SW1A 0AA';
      const price = '£1,000,000';
      final List<XFile> images = [];
      const String? streetViewUrl = null;
      const gdv = 1500000.0;
      const totalCost = 1200000.0;
      const uplift = 300000.0;
      final Map<String, UpliftData> scenarioUplifts = {};

      final List<PlanningApplication> planningApplications = [
        PlanningApplication(
          url: 'http://example.com/planning/1234',
          address: '123 Test Street, London, SW1A 0AA',
          proposal: 'Erection of a single storey rear extension.',
          decision: Decision(text: 'Granted', rating: 'positive'),
          dates: Dates(receivedAt: DateTime(2023, 1, 15), decidedAt: null),
        ),
      ];

      // 2. EXECUTE: Call the function under test.
      final pdfData = await tester.runAsync(() => PdfGenerator.generatePdf(
            address,
            price,
            images,
            streetViewUrl,
            gdv,
            totalCost,
            uplift,
            planningApplications,
            scenarioUplifts,
          ));

      // 3. VERIFY: Check the output.

      expect(pdfData, isNotNull, reason: "The generatePdf function should not return null.");
      final pdfMap = pdfData!;

      expect(pdfMap, isA<Map<String, dynamic>>());
      expect(pdfMap.containsKey('bytes'), isTrue, reason: "The result map should contain a 'bytes' key.");
      expect(pdfMap['bytes'], isA<Uint8List>(), reason: "The 'bytes' value should be a Uint8List.");
      expect(pdfMap['bytes'].isNotEmpty, isTrue, reason: "The generated PDF bytes should not be empty.");
      expect(pdfMap.containsKey('filename'), isTrue, reason: "The result map should contain a 'filename' key.");
      expect(pdfMap['filename'], isA<String>(), reason: "The 'filename' value should be a String.");

      const expectedFilename = 'Property_Stalker_123 Test Street, London, SW1A 0AA.pdf';
      expect(pdfMap['filename'], equals(expectedFilename), reason: "The filename was not formatted as expected.");
    });
  });
}
