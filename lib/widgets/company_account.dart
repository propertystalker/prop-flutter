import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/controllers/company_controller.dart';
import 'package:provider/provider.dart';

class CompanyAccount extends StatelessWidget {
  final Function(String) onCompanyChanged;
  final VoidCallback onSave;

  const CompanyAccount(
      {super.key, required this.onCompanyChanged, required this.onSave});

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (!context.mounted) return;
      Provider.of<CompanyController>(context, listen: false)
          .setCompanyLogo(pickedFile);
    }
  }

  void _deleteImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Logo'),
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
                Provider.of<CompanyController>(context, listen: false)
                    .deleteCompanyLogo();
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
    final companyController = Provider.of<CompanyController>(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: const Color(0xFFF0F4F8), // A light grey background
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              initialValue: companyController.companyName,
              decoration: const InputDecoration(labelText: 'Company Name'),
              onChanged: onCompanyChanged,
            ),
            TextFormField(
              initialValue: 'info@belvoragency.com',
              decoration: const InputDecoration(labelText: 'Enquiry Email'),
            ),
            TextFormField(
              initialValue: '+44(0)161 339 06646',
              decoration: const InputDecoration(labelText: 'Company Phone Number'),
            ),
            TextFormField(
              initialValue: 'XBelvor',
              decoration: const InputDecoration(labelText: 'Company X Page'),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                const Text('Company Logo', style: TextStyle(fontSize: 16)),
                const Spacer(),
                if (companyController.companyLogo != null)
                  Row(
                    children: [
                      kIsWeb
                          ? Image.network(companyController.companyLogo!.path,
                              width: 40, height: 40)
                          : Image.file(File(companyController.companyLogo!.path),
                              width: 40, height: 40),
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
            Center(
              child: ElevatedButton(
                onPressed: onSave,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
