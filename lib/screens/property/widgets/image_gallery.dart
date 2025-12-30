import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/controllers/image_gallery_controller.dart';
import 'package:provider/provider.dart';

class ImageGallery extends StatefulWidget {
  const ImageGallery({super.key});

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  int _currentImageIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentImageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ImageGalleryController>(context);

    return GestureDetector(
      onTap: () => controller.pickImages(),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: controller.images.isEmpty
            ? const Center(child: Text('Your photos will appear here'))
            : Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: controller.images.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, index) {
                      final image = controller.images[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: kIsWeb
                            ? Image.network(image.path, fit: BoxFit.cover)
                            : Image.file(File(image.path), fit: BoxFit.cover),
                      );
                    },
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.white),
                      onPressed: () {
                        controller.removeImage(_currentImageIndex);
                        if (_currentImageIndex >= controller.images.length && controller.images.isNotEmpty) {
                          _currentImageIndex = controller.images.length - 1;
                        }
                      },
                    ),
                  ),
                  if (controller.images.isNotEmpty)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(153),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1} / ${controller.images.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  if (controller.images.length > 1)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                            onPressed: () {
                              if (_currentImageIndex > 0) {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                            onPressed: () {
                              if (_currentImageIndex < controller.images.length - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
