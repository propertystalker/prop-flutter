import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/controllers/gdv_controller.dart';
import 'package:myapp/models/planning_application.dart';
import 'package:myapp/utils/pdf_generator.dart';
import 'package:myapp/models/report_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter/assets'),
            (MethodCall methodCall) async {
      if (methodCall.method == 'load') {
        // Handle font loading by returning empty data
        final ByteData data = ByteData(0);
        return data.buffer.asUint8List();
      }
      return null;
    });
    SharedPreferences.setMockInitialValues({});
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter/assets'), null);
  });

  group('PdfGenerator', () {
    testWidgets('generatePdf should return a map with PDF bytes and a sanitized filename', (WidgetTester tester) async {
      const address = '123 Test Street, London, SW1A 0AA';
      const price = '£1,000,000';
      final List<XFile> images = [];
      const String? streetViewUrl = null;

      final gdvController = GdvController();
      gdvController.updateGdvSources(sold: 1500000.0, onMarket: 1575000.0, area: 1470000.0);
      gdvController.calculateAllScenarioUplifts();

      const totalCost = 1200000.0;
      const uplift = 300000.0;
      const roi = 25.0;
      const areaGrowth = 10.0;
      const riskIndicator = 'Low';
      const investmentSignal = InvestmentSignal.green;
      const gdvConfidence = GdvConfidence.high;
      final selectedScenarios = <String>['Full refurbishment'];

      final List<PlanningApplication> planningApplications = [
        PlanningApplication(
          url: 'http://example.com/planning/1234',
          address: '123 Test Street, London, SW1A 0AA',
          proposal: 'Erection of a single storey rear extension.',
          decision: Decision(text: 'Granted', rating: 'positive'),
          dates: Dates(receivedAt: DateTime(2023, 1, 15), decidedAt: null),
        ),
      ];

      final pdfData = await tester.runAsync(() => PdfGenerator.generatePdf(
            address,
            price,
            images,
            streetViewUrl,
            gdvController,
            totalCost,
            uplift,
            planningApplications,
            [],
            roi,
            areaGrowth,
            riskIndicator,
            investmentSignal,
            gdvConfidence,
            selectedScenarios,
          ));

      expect(pdfData, isNotNull, reason: "The generatePdf function should not return null.");
      final pdfMap = pdfData!;

      expect(pdfMap, isA<Map<String, dynamic>>());
      expect(pdfMap.containsKey('bytes'), isTrue, reason: "The result map should contain a 'bytes' key.");
      expect(pdfMap['bytes'], isA<Uint8List>(), reason: "The 'bytes' value should be a Uint8List.");
      expect(pdfMap['bytes'].isNotEmpty, isTrue, reason: "The generated PDF bytes should not be empty.");
      expect(pdfMap.containsKey('filename'), isTrue, reason: "The result map should contain a 'filename' key.");
      expect(pdfMap['filename'], isA<String>(), reason: "The 'filename' value should be a String.");

      final sanitizedAddress = address.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final expectedFilename = 'Property_Stalker_$sanitizedAddress.pdf';
      expect(pdfMap['filename'], equals(expectedFilename), reason: "The filename was not formatted as expected.");
    });
  });
}
