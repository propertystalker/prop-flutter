import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageGalleryController extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];

  List<XFile> get images => _images;

  Future<void> pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      _images.addAll(pickedFiles);
      notifyListeners();
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < _images.length) {
      _images.removeAt(index);
      notifyListeners();
    }
  }
}
