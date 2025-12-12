import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/controllers/person_controller.dart';
import 'package:provider/provider.dart';

class PersonAccount extends StatelessWidget {
  final VoidCallback onSave;

  const PersonAccount({super.key, required this.onSave});

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Provider.of<PersonController>(context, listen: false).setAvatar(pickedFile);
    }
  }

  void _deleteImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Avatar'),
          content: const Text('This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Provider.of<PersonController>(context, listen: false).deleteAvatar();
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final personController = Provider.of<PersonController>(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: const Color(0xFFC9B7A6), // Brown background
      child: Column(
        children: [
          TextFormField(
            initialValue: personController.fullName,
            decoration: const InputDecoration(labelText: 'Full Name'),
            onChanged: (name) => personController.setFullName(name),
          ),
          TextFormField(
            initialValue: personController.email,
            decoration: const InputDecoration(labelText: 'Email'),
            onChanged: (email) => personController.setEmail(email),
          ),
          TextFormField(
            initialValue: personController.mobile,
            decoration: const InputDecoration(labelText: 'Mobile'),
            onChanged: (mobile) => personController.setMobile(mobile),
          ),
          TextFormField(
            initialValue: personController.linkedin,
            decoration: const InputDecoration(labelText: 'LinkedIn'),
            onChanged: (linkedin) => personController.setLinkedin(linkedin),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              const Text('Avatar', style: TextStyle(fontSize: 16)),
              const Spacer(),
              if (personController.avatar != null)
                Row(
                  children: [
                    kIsWeb
                        ? Image.network(personController.avatar!.path, width: 40, height: 40)
                        : Image.file(File(personController.avatar!.path), width: 40, height: 40),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteImage(context),
                    ),
                  ],
                )
              else
                TextButton.icon(
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Add'),
                  onPressed: () => _pickImage(context),
                ),
            ],
          ),
          const SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: onSave,
            child: const Text('Save'),
          ),
          const SizedBox(height: 16.0),
          InkWell(
            onTap: () {
              // Log out logic
            },
            child: const Text(
              'log out',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
          )
        ],
      ),
    );
  }
}
