import 'dart:typed_data';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/services/cloudinary_service.dart';

import 'cloudinary_service_test.mocks.dart';

@GenerateMocks([CloudinaryPublic])
void main() {
  group('CloudinaryService', () {
    late CloudinaryService cloudinaryService;
    late MockCloudinaryPublic mockCloudinaryPublic;

    setUp(() {
      mockCloudinaryPublic = MockCloudinaryPublic();
      cloudinaryService = CloudinaryService.withCloudinary(mockCloudinaryPublic);
    });

    test('uploadPdf returns URL on successful upload', () async {
      // Arrange
      final pdfData = Uint8List(10);
      final fileName = 'test.pdf';
      final response = CloudinaryResponse(
        assetId: 'test_asset_id',
        publicId: 'test_public_id',
        url: 'http://cloudinary.com/test.pdf',
        secureUrl: 'https://cloudinary.com/test.pdf',
        originalFilename: 'test',
        createdAt: DateTime.now(),
        data: {},
      );

      when(mockCloudinaryPublic.uploadFile(any))
          .thenAnswer((_) async => response);

      // Act
      final result = await cloudinaryService.uploadPdf(
        pdfBytes: pdfData,
        fileName: fileName,
      );

      // Assert
      expect(result, 'https://cloudinary.com/test.pdf');
      verify(mockCloudinaryPublic.uploadFile(any)).called(1);
    });

    test('uploadPdf returns null on failed upload', () async {
      // Arrange
      final pdfData = Uint8List(10);
      final fileName = 'test.pdf';

      when(mockCloudinaryPublic.uploadFile(any))
          .thenThrow(CloudinaryException('Upload failed', 500));

      // Act
      final result = await cloudinaryService.uploadPdf(
        pdfBytes: pdfData,
        fileName: fileName,
      );

      // Assert
      expect(result, isNull);
    });
  });
}
