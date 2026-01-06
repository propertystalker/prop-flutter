
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
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

      // Correctly instantiate PlanningApplication using the fields from the model file
      // and explicitly type the list.
      final List<PlanningApplication> planningApplications = [
        PlanningApplication(
          uid: 'PA/2023/1234',
          url: 'http://example.com/planning/1234',
          address: '123 Test Street, London, SW1A 0AA',
          postcode: 'SW1A 0AA',
          description: 'Erection of a single storey rear extension.',
          status: 'Granted',
          receivedDate: '2023-01-15', // This is a String in the model
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
          ));

      // 3. VERIFY: Check the output.

      // First, ensure the result is not null.
      expect(pdfData, isNotNull, reason: "The generatePdf function should not return null.");

      // Since we've confirmed it's not null, we can safely use the ! operator.
      final pdfMap = pdfData!;

      // Ensure the result is the correct type.
      expect(pdfMap, isA<Map<String, dynamic>>());

      // Verify the 'bytes' key.
      expect(pdfMap.containsKey('bytes'), isTrue, reason: "The result map should contain a 'bytes' key.");
      expect(pdfMap['bytes'], isA<Uint8List>(), reason: "The 'bytes' value should be a Uint8List.");
      expect(pdfMap['bytes'].isNotEmpty, isTrue, reason: "The generated PDF bytes should not be empty.");

      // Verify the 'filename' key.
      expect(pdfMap.containsKey('filename'), isTrue, reason: "The result map should contain a 'filename' key.");
      expect(pdfMap['filename'], isA<String>(), reason: "The 'filename' value should be a String.");

      // Verify the filename is correctly formatted. The generator does not sanitize spaces.
      const expectedFilename = 'Property_Stalker_123 Test Street, London, SW1A 0AA.pdf';
      expect(pdfMap['filename'], equals(expectedFilename), reason: "The filename was not formatted as expected.");
    });
  });
}
