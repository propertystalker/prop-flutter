import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/controllers/company_controller.dart';
import 'package:myapp/controllers/person_controller.dart';
import 'package:provider/provider.dart';

class PropertyFilterAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onLogoTap;
  final VoidCallback onAvatarTap;
  final VoidCallback? onSettingsTap;

  const PropertyFilterAppBar(
      {super.key, required this.onLogoTap, required this.onAvatarTap, this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: onLogoTap,
          child: Consumer<CompanyController>(
            builder: (context, controller, child) {
              return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: controller.companyLogo != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: kIsWeb
                              ? Image.network(controller.companyLogo!.path,
                                  fit: BoxFit.cover)
                              : Image.file(File(controller.companyLogo!.path),
                                  fit: BoxFit.cover),
                        )
                      : const Icon(Icons.business));
            },
          ),
        ),
      ),
      title: Consumer<CompanyController>(
        builder: (context, controller, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text('98375',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Text(controller.companyName, style: const TextStyle(fontSize: 18)),
            ],
          );
        },
      ),
      actions: [
        IconButton(icon: const Icon(Icons.settings), onPressed: onSettingsTap ?? () {}),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GestureDetector(
            onTap: onAvatarTap,
            child: Consumer<PersonController>(
              builder: (context, controller, child) {
                return CircleAvatar(
                  backgroundImage: controller.avatar != null
                      ? (kIsWeb
                          ? NetworkImage(controller.avatar!.path)
                          : FileImage(File(controller.avatar!.path)))
                          as ImageProvider
                      : const NetworkImage(
                          'https://picsum.photos/seed/picsum/200/300'),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
