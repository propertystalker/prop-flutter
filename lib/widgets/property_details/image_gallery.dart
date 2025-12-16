
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/controllers/property_floor_area_filter_controller.dart';
import 'package:provider/provider.dart';

class ImageGallery extends StatelessWidget {
  const ImageGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PropertyFloorAreaFilterController>(
      builder: (context, controller, child) {
        if (controller.images.isEmpty) {
          return const Center(child: Text('Your photos will appear here'));
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: controller.pageController,
              itemCount: controller.images.length,
              onPageChanged: controller.onPageChanged,
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
                onPressed: () => controller.removeImage(controller.currentImageIndex),
              ),
            ),
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
                  '${controller.currentImageIndex + 1} / ${controller.images.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () {
                      if (controller.currentImageIndex > 0) {
                        controller.pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    onPressed: () {
                      if (controller.currentImageIndex < controller.images.length - 1) {
                        controller.pageController.nextPage(
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
        );
      },
    );
  }
}
