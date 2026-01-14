
import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class CloudinaryService {
  static const String _cloudName = 'dc5cnouvd';
  static const String _uploadPreset = 'reports';

  late final CloudinaryPublic _cloudinary;

  CloudinaryService() {
    _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);
  }

  @visibleForTesting
  CloudinaryService.withCloudinary(this._cloudinary);

  Future<String?> uploadPdf({
    required Uint8List pdfBytes,
    required String fileName,
    String? folder,
  }) async {
    try {
      developer.log('Starting PDF upload to Cloudinary...', name: 'CloudinaryService');

      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          pdfBytes,
          identifier: fileName, // The required identifier for the file
          resourceType: CloudinaryResourceType.Raw,
          folder: folder,
          publicId: fileName,
        ),
      );

      developer.log('PDF uploaded successfully. URL: ${response.secureUrl}', name: 'CloudinaryService');
      return response.secureUrl;

    } on CloudinaryException catch (e) {
      developer.log(
        'Cloudinary upload failed.',
        name: 'CloudinaryService',
        error: e.message,
        level: 1000,
      );
      return null;
    } catch (e, s) {
      developer.log('Exception during Cloudinary upload', error: e, stackTrace: s, name: 'CloudinaryService', level: 1000);
      return null;
    }
  }
}
